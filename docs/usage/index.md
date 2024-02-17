# pokecrystal-board

pokecrystal-board is a board game engine for the GBC based on [pokecrystal](https://github.com/pret/pokecrystal).

In pokecrystal-board **you will find**:
- Content with new features
  - Overworld board game engine: menus, movement, events, etc.
  - Level selection menu ("world map")
  - Other supporting features
- Empty canvas with pokecrystal-board placeholder content, or with no content
  - Actual levels and maps, and their design
  - Board space effects
  - Many GFX and SFX elements
  - ...
- Empty canvas with pokecrystal placeholder content
  - The complete battle engine
  - Pokemon data and storage
  - Item data and storage
  - ...

In pokecrystal-board **you will *not* find**:
- A ready-to-play game
- An engine that requires less ASM knowledge to hack than the pokecrystal disassembly
- Guaranteed compatibility with extensions to pokecrystal developed by the community
- Definitive GFX and SFX assets

**How can you use and what can you do with pokecrystal-board**:
- Use it as the base engine to develop your own game
- Develop new features for the purpose of your own game
- Develop new features to be incorporated into pokecrystal-board
- Design assets to be incorporated in place of the placeholder GFX/SFX in pokecrystal-board (see issue XXX)
- Request or show your interest in specific features to be added to pokecrystal-board (open an issue for this)

pokecrystal-board requires RGBDS 0.7.0 to build. It has two build targets: *crystal*, and *crystal_debug*. The former builds a ROM with the *_DEBUG* symbol undefined, and the latter builds a ROM with the *_DEBUG* symbol defined. *crystal_debug* is meant to include additional content and configurations to facilitate testing during development, while *crystal* builds the ROM meant to be hypothetically released to the public.

For generic changes made in pokecrystal-board (adaptations, cleaning up, etc.) refer to issues #1, #2, #7, #8.

If you have specific questions about the usage of pokecrystal-board or how to contribute to it, feel free to open an issue or to contact me on Discord. But please, do not do this for questions that are rather in the domain of pokecrystal.

If you are interested on developing on top of pokecrystal-board, the rest of this document details the different features.

## Level selection menu

The level selection menu is essentially a world map that the player navigates to select a level to play. The player can move through landmarks that correspond to unlocked levels in the level selection menu. The level seleciton menu can have multiple map pages each with their own landmarks. When the player moves from a landmark in one page to a landmark in another page, the new page is loaded during the transition.

TODO: add image

The usual level:landmark relation is expected to be 1:1, but 1:n is also supported, for levels that may have alternative starting points.

The implementation is located in [engine/menus/level_selection_menu.asm](engine/menus/level_selection_menu.asm). GFX assets are included at the bottom of this file and point to [gfx/level_selection_menu](gfx/level_selection_menu):
- *LevelSelectionMenuGFX*: tile GFX shared by all the pages
- *LevelSelectionMenuPage\*Tilemap*: tilemap of each page
- *LevelSelectionMenuAttrmap*: attribute map shared by all the pages
- Various object graphics (direction arrows, etc.). These use *PAL_LSM_\** palettes.

A bunch of constants are defined for the level selection menu. These are mostly found in [constants/landmark_constants.asm](constants/landmark_constants.asm). Look out for those that start with or contain *LSM*.

The data is located in [data/levels/level_selection_menu.asm](data/levels/level_selection_menu.asm). This is how you design your level selection menu:
- *LevelSelectionMenu_Landmarks*: landmark data. Each entry uses a *level_selection_menu_landmark* macro and specifies, in this order: page number, x coordinate, y coordinate, landmark name, spawn point, level stages.
- *LevelSelectionMenu_LandmarkTransitions*: for each landmark, its transition data for each of the four directions, in down/up/left/right order (i.e. applicable to when the player presses the corresponding dpad key while in the landmark). Each entry contains direction/displacement pairs. Maximum displacement is 7; if you want a larger movement use e.g. DOWN, 7, DOWN, 3. Note that if the level that a given transition points to has not been unlocked, said transition won't be available.
- *LevelSelectionMenu_PageGrid*: layout of all pages in the big picture. Each byte entry is the page number, or -1 for no page.
- *LandmarkToLevelTable*: denotes the mapping between landmarks and levels.

## Overworld

The overworld uses a turn-based system. Each level is composed of one or more maps, and the maps are designed with spaces in them, which are meant for the player to move through them. Each turn the player rolls a die and advances spaces accordingly. Events may occur as appropriate while the player is advancing and/or when it lands in a space.

In addition to what is covered in this section, you can find more low level stuff about the pokecrystal-board overworld engine in the rough workflows described here: [docs/develop/index.md](docs/develop/index.md)

### Board menu

The board menu is shown to the player at the beginning of each turn. In allows for several choices. The only ones that are specific to the pokecrystal-board engine are "roll die", "view map", and "exit level". The other three choices point to the party menu, bag menu, and pokegear, and are placeholders from pokecrystal. The board menu can be navigated horizontally. All menu options are accessed by selecting the corresponding icon of the menu, except for "view map" which is accessible via the Select button. All menu options except for "roll die" and "exit level" eventually return back to the board menu.

TODO: add image

The implementation is located in [engine/board/menu.asm](engine/board/menu.asm). Icon tiles are drawn over the background of the textbox as if they were font characters. The current menu item is highlighted with a colored overlay using objects. This file includes also the animation logic for rolling a die when the "roll die" option is selected. These animations leverage the overworld sprite animation engine from pokecrystal. Finally, [gfx/board](gfx/board) contains GFX assets.

### Board spaces

#### Regular spaces

#### Branch space

#### End space

### Object events

#### Trainer events

#### Talker events

### Board movement

#### Warp events

#### Technique events

### View map mode

### Map state preservation

## Game navigation and progression

## Other

### Window HUD

### Overworld textbox

### Tilesets

### RGB palette fading

### Time counting

### OAM management
