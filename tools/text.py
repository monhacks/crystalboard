#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Usage: python text.py

Converts plain text in asm files into pokecrystal-compatible text according to the line length and to the text commands of pokecrystal.
text.py looks for blocks of plain text that are enclosed between lines that contain ;!>text and ;<text, and formats the text in-between.
After a block is formatted, its opening ;!>text line is replaced by ;>text, signaling that this block requires no processing in a subsequent pass.
If the user wishes to request the formatting of the same block again after a modification,
they shall do it by replacing the opening ;>text with ;!>text and deleting the old converted text in the middle.
In the plain text, paragraphs shall use tab identation and be separated by line breaks.
;!>text shall be followed by prompt to finish the resulting text with the "prompt" text command. Otherwise it will be finished with "done" by default.

For example the following block:

;!>text
;	You're a #MON trainer, right?
;	Becoming a good trainer is really tough.
;	I'm going to battle other people to get better.
;<text

Produces:

;>text
;	You're a #MON trainer, right?
;	Becoming a good trainer is really tough.
;	I'm going to battle other people to get better.
	text "You're a #MON"
	line "trainer, right?"
	para "Becoming a good"
	line "trainer is really"
	cont "tough."
	para "I'm going to battle"
	line "other people to"
	cont "get better."
	done
;<text

This script is meant to be called during the build process from within the Makefile (once per build process).
"""

import os

# Directories to apply text.py to
TEXT_DIRS = ["./maps"]

TEXT_BLOCK_START = ";!>text"
PROCESSED_TEXT_BLOCK_START = ";>text"
TEXT_BLOCK_END = ";<text"

# pokecrystal line length
MAX_LINE_LENGTH = 18

# charmaps with lengths that do not match their written length
CHARMAP_LENGTH = {
      "'d": 1,
      "'l": 1,
      "'m": 1,
      "'r": 1,
      "'s": 1,
      "'t": 1,
      "'v": 1,
      "#": 4,
      "<PLAYER>": 7,
}

def process_word(word):
    """
    Return the length of a given word accounting for pokecrystal charmap and count an additional space character after the word.
    """
    length = len(word)
    for char, charlen in CHARMAP_LENGTH.items():
        length += (charlen - len(char)) * word.count(char)
    if length > MAX_LINE_LENGTH:
        exc = f"Found a word too long to split (above {MAX_LINE_LENGTH} characters)."
        raise Exception(exc)
    return length + 1

def process_paragraph(line):
    """
    Split a paragraph provided in a single plain text line into multiple pokecrystal-sized lines.
    """
    words = line.split()
    word_pos = 0
    char_pos = 0
    word_breaks = []
    line_partitioned = []
    while word_pos < len(words):
        char_pos += process_word(words[word_pos])
        if char_pos > (MAX_LINE_LENGTH + 1):
            word_breaks.append(word_pos)
            char_pos = 0
            continue
        word_pos += 1
    start_word = 0
    for word_break in word_breaks:
        line_partitioned.append(' '.join(words[start_word:word_break]))
        start_word = word_break
    line_partitioned.append(' '.join(words[start_word:]))
    return line_partitioned

def format_paragraph_lines(paragraph, is_first_paragraph):
    """
    For each pokecrystal text line, prepend to it the corresponding pokecrystal text command and append to it \n
    """
    line_length = len(paragraph)
    cur_line_no = 1
    formatted_paragraph = ""
    for line in paragraph:
        formatted_line = ""
        if cur_line_no == 1 and is_first_paragraph:
            formatted_line += "\ttext "
        elif cur_line_no % 2 and cur_line_no == line_length and line_length > 1:
            formatted_line += "\tcont "
        elif cur_line_no % 2:
            formatted_line += "\tpara "
        else:
            formatted_line += "\tline "
        formatted_line = formatted_line + '"' + line + '"' + "\n"
        cur_line_no += 1
        formatted_paragraph += formatted_line
    return formatted_paragraph

def process_block(text_block, end_command):
    is_first_paragraph = True
    resulting_paragraph = ""
    for paragraph in text_block:
        if paragraph.startswith(TEXT_BLOCK_START):
            continue
        if paragraph.startswith(TEXT_BLOCK_END):
            continue
        paragraph = paragraph[2:-1]
        # split one plain text line (a paragraph) into multiple pokecrystal text lines
        paragraph = process_paragraph(paragraph)
        # format the lines with pokecrystal text commands
        resulting_paragraph += format_paragraph_lines(paragraph, is_first_paragraph)
        is_first_paragraph = False
    text_block = resulting_paragraph + "\t" + end_command + "\n"
    return text_block

def write_text_to_file(f, lines, text_block, line_no, text_start_index):
    lines[text_start_index] = PROCESSED_TEXT_BLOCK_START + "\n" # Signal that this text was processed
    lines.insert(line_no, text_block)
    f.seek(0)
    f.writelines(lines)
    f.truncate()

def main():
    filepaths = []
    for directory in TEXT_DIRS:
        filepaths.extend([os.path.join(directory, filename) for filename in os.listdir(directory) if filename.endswith(".asm")])
    for filepath in filepaths:
        with open(filepath, "r+") as f:
            lines = f.readlines()
            cur_file_index = -1
            text_start_index = -1
            for line in lines:
                cur_file_index += 1
                if TEXT_BLOCK_START in line:
                    index = cur_file_index
                    text_start_index = index
                    text_block = [line]
                    while True:
                        index += 1
                        next_line = lines[index]
                        text_block.append(next_line)
                        if next_line.startswith(TEXT_BLOCK_END):
                            end_command = "prompt" if " prompt" in next_line else "done"
                            break
                        if next_line.startswith(";	") and next_line.endswith("\n"):
                            continue
                        else:
                            exc = f"Invalid text block in file {filepath}, line {cur_file_index}. Make sure there is not already valid generated text in the middle. Aborting."
                            raise Exception(exc)
                    text_block = process_block(text_block, end_command)
                    write_text_to_file(f, lines, text_block, index, text_start_index)

if __name__ == '__main__':
    main()
