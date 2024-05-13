#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Usage: python tools/board/tileset.py

Generates palette map, 2bpp image, metatiles, and collision for a new tileset. A source tileset is used as a base to generate the new one.

The layout of the generated tileset is as follows:
- Tiles from 0x00 to 0xbf come from the source tileset.
- Tiles from 0xc0 to 0xdf come from gfx/tilesets/spaces/fixed_spaces.png
- Tiles from 0xe0 to 0xff come from gfx/tilesets/spaces/variable_spaces_<N>.png

The layout of the generated tileset's metatiles is as follows:
- Metatiles from 0x00 to 0x7f come from the source tileset.
- Metatiles from 0x80 to 0xdf are each made to use the specified space in the top left tile.
- Metatiles from 0xe0 to 0xff are fixed to use the grey space in the top left tile.
- All non-space tiles in the metatiles are fixed to 0x01.

The user inputs the following before generating the new tileset:
- In the fixed_spaces list of the program: your layout of gfx/tilesets/spaces/fixed_spaces.png
- In the program window: name of the source tileset.
- In the program window: name of the tileset to create
- In the program window: index of variable spaces to use in the new tileset.
- In the program window: layout of spaces in metatiles 0x80 - 0xdf.

User must later add the tileset information in the following assembly files:
- constants/tileset_constants.asm
- gfx/tilesets.asm
- gfx/tileset_palette_maps.asm
- data/tilesets.asm
- engine/tilesets/tileset_anims.asm

Run this script from the base directory of the repository.
"""

import os
import re
import tkinter as tk
from tkinter import messagebox

# Matrix of default metatile space values
default_values = [
    ['BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE'],
    ['BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE'],
    ['BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE', 'BLUE'],
    ['POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON'],
    ['POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON'],
    ['POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON', 'POKEMON'],
    ['RED', 'RED', 'RED', 'RED', 'RED', 'RED', 'RED', 'RED'],
    ['RED', 'RED', 'RED', 'RED', 'RED', 'RED', 'RED', 'RED'],
    ['END', 'GREEN', 'ITEM', 'MINIGAME', 'GREEN', 'GREEN', 'ITEM', 'MINIGAME'],
    ['END', 'GREEN', 'ITEM', 'MINIGAME', 'GREEN', 'GREEN', 'ITEM', 'MINIGAME'],
    ['END', 'GREEN', 'ITEM', 'MINIGAME', 'GREEN', 'GREEN', 'ITEM', 'MINIGAME'],
    ['END', 'GREEN', 'ITEM', 'MINIGAME', 'GREEN', 'GREEN', 'ITEM', 'MINIGAME']
]

fixed_spaces = ['BLUE', 'RED', 'GREEN', 'ITEM', 'POKEMON', 'MINIGAME', 'END', 'GREY']

def create_palette_map(new_tileset_name, source_tileset_name, variable_spaces_id):
    # Generate the filename for the source tileset
    source_filename = source_tileset_name + "_palette_map.asm"

    # Check if the source tileset file exists
    source_filepath = os.path.join("gfx", "tilesets", source_filename)
    if not os.path.exists(source_filepath):
        messagebox.showerror("Error", f"Source tileset file '{source_filename}' not found.")
        return None

    # Read the first 24 lines of the source tileset file
    with open(source_filepath, "r") as source_file:
        first_24_lines = "".join(source_file.readlines()[:24])

    # Read the first 4 lines from the fixed spaces palette map file
    fixed_spaces_filepath = os.path.join("gfx", "tilesets", "spaces", "fixed_spaces_palette_map.asm")
    with open(fixed_spaces_filepath, "r") as fixed_spaces_file:
        fixed_spaces_lines = "".join(fixed_spaces_file.readlines()[:4])

    # Read the first 4 lines from the variable spaces palette map file
    variable_spaces_filename = f"variable_spaces_{variable_spaces_id}_palette_map.asm"
    variable_spaces_filepath = os.path.join("gfx", "tilesets", "spaces", variable_spaces_filename)
    if not os.path.exists(variable_spaces_filepath):
        messagebox.showerror("Error", f"Variable spaces palette map file '{variable_spaces_filename}' not found.")
        return None

    with open(variable_spaces_filepath, "r") as variable_spaces_file:
        variable_spaces_lines = "".join(variable_spaces_file.readlines()[:4])

    # Generate the filename for the new tileset
    new_tileset_filename = new_tileset_name + "_palette_map.asm"
    new_tileset_filepath = os.path.join("gfx", "tilesets", new_tileset_filename)

    # Write the lines to the new tileset file
    with open(new_tileset_filepath, "w") as new_tileset_file:
        new_tileset_file.write(first_24_lines)
        new_tileset_file.write(fixed_spaces_lines)
        new_tileset_file.write(variable_spaces_lines)

    return new_tileset_filename

def create_2bpp(new_tileset_name, source_tileset_name, variable_spaces_id):
    # Generate the filename for the source binary file
    source_binary_filename = source_tileset_name + ".2bpp"

    # Check if the source binary file exists
    source_binary_filepath = os.path.join("gfx", "tilesets", source_binary_filename)
    if not os.path.exists(source_binary_filepath):
        messagebox.showerror("Error", f"Source binary file '{source_binary_filename}' not found.")
        return None

    # Calculate the number of bytes to copy (128*96*2/8)
    num_bytes = 128 * 96 * 2 // 8

    # Read the specified number of bytes from the source binary file
    with open(source_binary_filepath, "rb") as source_binary_file:
        binary_data = source_binary_file.read(num_bytes)

    # Read the first (16*96*2/8) bytes from the fixed spaces binary file
    fixed_spaces_filename = "fixed_spaces.2bpp"
    fixed_spaces_filepath = os.path.join("gfx", "tilesets", "spaces", fixed_spaces_filename)
    with open(fixed_spaces_filepath, "rb") as fixed_spaces_file:
        fixed_spaces_data = fixed_spaces_file.read(num_bytes // 8 * 2)

    # Read the first (16*96*2/8) bytes from the variable spaces binary file
    variable_spaces_filename = f"variable_spaces_{variable_spaces_id}.2bpp"
    variable_spaces_filepath = os.path.join("gfx", "tilesets", "spaces", variable_spaces_filename)
    if not os.path.exists(variable_spaces_filepath):
        messagebox.showerror("Error", f"Variable spaces binary file '{variable_spaces_filename}' not found.")
        return None

    with open(variable_spaces_filepath, "rb") as variable_spaces_file:
        variable_spaces_data = variable_spaces_file.read(num_bytes // 8 * 2)

    # Generate the filename for the new binary file
    new_binary_filename = new_tileset_name + ".2bpp"
    new_binary_filepath = os.path.join("gfx", "tilesets", new_binary_filename)

    # Write the binary data to the new binary file
    with open(new_binary_filepath, "wb") as new_binary_file:
        new_binary_file.write(binary_data)
        new_binary_file.write(fixed_spaces_data)
        new_binary_file.write(variable_spaces_data)

    return new_binary_filename

def create_metatiles(new_tileset_name, source_tileset_name, collision_values):
    # Generate the filename for the source metatiles binary file
    source_metatiles_filename = source_tileset_name + "_metatiles.bin"

    # Check if the source metatiles binary file exists
    source_metatiles_filepath = os.path.join("data", "tilesets", source_metatiles_filename)
    if not os.path.exists(source_metatiles_filepath):
        messagebox.showerror("Error", f"Source metatiles binary file '{source_metatiles_filename}' not found.")
        return None

    # Read (128*16) bytes from the source metatiles binary file
    num_bytes = 128 * 16
    with open(source_metatiles_filepath, "rb") as source_metatiles_file:
        metatiles_data = source_metatiles_file.read(num_bytes)

    # Generate the filename for the new metatiles binary file
    new_metatiles_filename = new_tileset_name + "_metatiles.bin"
    new_metatiles_filepath = os.path.join("data", "tilesets", new_metatiles_filename)

    # Write the metatiles data to the new binary file
    with open(new_metatiles_filepath, "wb") as new_metatiles_file:
        new_metatiles_file.write(metatiles_data)

        # Write 96 chunks of 16 bytes
        for value in collision_values:
            # Find the index of the value in fixed_spaces
            index = fixed_spaces.index(value)
            # Write the corresponding 16 bytes
            for i in range(16):
                if i == 0 or i == 1:
                    byte_value = index * 2 + 0xc0 + i
                elif i == 4 or i == 5:
                    byte_value = index * 2 + 0xd0 + (i - 4)
                else:
                    byte_value = 0x01
                new_metatiles_file.write(bytearray([byte_value]))

        # Write 32*16 bytes corresponding to 'GREY' space
        index = fixed_spaces.index('GREY')
        for i in range(32):
            new_metatiles_file.write(bytearray([index * 2 + 0xc0, index * 2 + 0xc1, 0x01, 0x01, index * 2 + 0xd0, index * 2 + 0xd1, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01]))

    return new_metatiles_filename

def create_collision(new_tileset_name, source_tileset_name, collision_values):
    # Generate the filename for the source collision text file
    source_collision_filename = source_tileset_name + "_collision.asm"

    # Check if the source collision text file exists
    source_collision_filepath = os.path.join("data", "tilesets", source_collision_filename)
    if not os.path.exists(source_collision_filepath):
        messagebox.showerror("Error", f"Source collision text file '{source_collision_filename}' not found.")
        return None

    # Read 128 lines from the source collision text file
    with open(source_collision_filepath, "r") as source_collision_file:
        collision_lines = source_collision_file.readlines()[:128]

    # Generate the filename for the new collision text file
    new_collision_filename = new_tileset_name + "_collision.asm"
    new_collision_filepath = os.path.join("data", "tilesets", new_collision_filename)

    # Write the collision lines to the new text file
    with open(new_collision_filepath, "w") as new_collision_file:
        new_collision_file.writelines(collision_lines)

        # Append additional lines based on collision_values
        for index, value in enumerate(collision_values, start=0x80):
            new_collision_file.write(f'\ttilecoll {value}_SPACE, FLOOR, FLOOR, FLOOR ; {format(index, "02x")}\n')

        # Add fixed 32 lines at the end
        for index in range(0xe0, 0x100):
            new_collision_file.write(f'\ttilecoll GREY_SPACE, FLOOR, FLOOR, FLOOR ; {format(index, "02x")}\n')

    return new_collision_filename

def create_tileset():
    # Get the values from the entry fields
    new_tileset_name = new_tileset_entry.get()
    source_tileset_name = source_tileset_entry.get()
    variable_spaces_id = variable_spaces_entry.get()

    # Read the values from the dropdown menus into a 12x8 array
    collision_values = []
    for i in range(12):
        row_values = []
        for j in range(8):
            row_values.append(collision_dropdowns[i][j].get())
        collision_values.append(row_values)
    # Flatten the resulting array
    collision_values = [value for sublist in collision_values for value in sublist]

    # Create the palette map file
    palette_map_filename = create_palette_map(new_tileset_name, source_tileset_name, variable_spaces_id)
    if palette_map_filename is None:
        return

    # Copy the binary data
    binary_filename = create_2bpp(new_tileset_name, source_tileset_name, variable_spaces_id)
    if binary_filename is None:
        return

    # Copy the metatiles data
    metatiles_filename = create_metatiles(new_tileset_name, source_tileset_name, collision_values)
    if metatiles_filename is None:
        return

    # Copy the collision data
    collision_filename = create_collision(new_tileset_name, source_tileset_name, collision_values)
    if collision_filename is None:
        return

    message = (
        f"Tileset '{palette_map_filename}' created successfully.\n"
        f"2bpp file '{binary_filename}' created successfully.\n"
        f"Metatiles file '{metatiles_filename}' created successfully.\n"
        f"Collision file '{collision_filename}' created successfully."
    )
    messagebox.showinfo("Success", message)


# Create the main window
root = tk.Tk()
root.title("Create Tileset")

# Create labels and entry fields
tk.Label(root, text="New Tileset Name:").grid(row=0, column=0, padx=10, pady=5)
new_tileset_entry = tk.Entry(root)
new_tileset_entry.grid(row=0, column=1, padx=10, pady=5)

tk.Label(root, text="Source Tileset Name:").grid(row=1, column=0, padx=10, pady=5)
source_tileset_entry = tk.Entry(root)
source_tileset_entry.grid(row=1, column=1, padx=10, pady=5)

tk.Label(root, text="Variable Spaces ID:").grid(row=2, column=0, padx=10, pady=5)
variable_spaces_entry = tk.Entry(root)
variable_spaces_entry.grid(row=2, column=1, padx=10, pady=5)

# Create dropdown menus for collision constants
collision_constants = []
with open("constants/collision_constants.asm", "r") as collision_constants_file:
    for line in collision_constants_file:
        match = re.search(r'const COLL_([A-Z]*)_SPACE', line)
        if match:
            collision_constants.append(match.group(1))

# Define a matrix to store the dropdown menus
collision_dropdowns = []

# Create dropdown menus for each row
for i in range(12):
    label_text = f"0x{format(i * 8 + 0x80, '02x')}"
    tk.Label(root, text=label_text).grid(row=i, column=2, padx=10, pady=5)
    row_dropdowns = []
    for j in range(8):
        default_value = default_values[i][j]
        if default_value not in collision_constants:
            default_value = collision_constants[0]  # Use the first collision constant if the default value is not found
        variable = tk.StringVar(root)
        variable.set(default_value)  # set default value
        dropdown = tk.OptionMenu(root, variable, *collision_constants)
        dropdown.grid(row=i, column=j + 3, padx=10, pady=5)
        row_dropdowns.append(variable)
    collision_dropdowns.append(row_dropdowns)

# Create "Create" button
create_button = tk.Button(root, text="Create", command=create_tileset)
create_button.grid(row=15, column=0, columnspan=10, padx=10, pady=10)

# Run the GUI
root.mainloop()
