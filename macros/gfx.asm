; Graphics macros

DEF palred   EQUS "(1 << 0) *"
DEF palgreen EQUS "(1 << 5) *"
DEF palblue  EQUS "(1 << 10) *"

MACRO assert_valid_rgb
	rept _NARG
		assert 0 <= (\1) && (\1) <= 31, "RGB channel must be 0-31"
		shift
	endr
ENDM

MACRO RGB
	rept _NARG / 3
		assert_valid_rgb \1, \2, \3
		dw palred (\1) + palgreen (\2) + palblue (\3)
		if DEF(fade_src)
			DEF {fade_src}_{d:color_index} EQU \1
			DEF color_index += 1
			DEF {fade_src}_{d:color_index} EQU \2
			DEF color_index += 1
			DEF {fade_src}_{d:color_index} EQU \3
			DEF color_index += 1
		endc
		shift 3
	endr
ENDM

MACRO rgbpals_fade_src
	DEF fade_src EQUS \1
	DEF color_index = 0
ENDM

MACRO rgbpals_fade_src_end
	DEF {fade_src}_len = color_index
	PURGE fade_src
ENDM

MACRO rgbpals_fade_apply
	DEF fade_from EQUS \1
	DEF fade_to EQUS \2
	assert {fade_from}_len == {fade_to}_len, "fade_from pals and fade_to pals must be same length"
	for i, \3
		for j, 0, {fade_from}_len, 3
			DEF rgbch_red = {j} + 0
			DEF rgbch_green = {j} + 1
			DEF rgbch_blue = {j} + 2
			DEF palred_value = {fade_from}_{d:rgbch_red} + ({fade_to}_{d:rgbch_red} - {fade_from}_{d:rgbch_red}) * i / \3
			DEF palgreen_value = {fade_from}_{d:rgbch_green} + ({fade_to}_{d:rgbch_green} - {fade_from}_{d:rgbch_green}) * i / \3
			DEF palblue_value = {fade_from}_{d:rgbch_blue} + ({fade_to}_{d:rgbch_blue} - {fade_from}_{d:rgbch_blue}) * i / \3
			dw palred (palred_value) + palgreen (palgreen_value) + palblue (palblue_value)
		endr
	endr
	PURGE fade_from, fade_to, rgbch_red, rgbch_green, rgbch_blue, palred_value, palgreen_value, palblue_value
ENDM

/* MACRO rgbpals_fade_end
	rept _NARG
		for i,
		endr
		shift
	endr
ENDM */

DEF palettes EQUS "* PALETTE_SIZE"
DEF palette  EQUS "+ PALETTE_SIZE *"
DEF color    EQUS "+ PAL_COLOR_SIZE *"

DEF tiles EQUS "* LEN_2BPP_TILE"
DEF tile  EQUS "+ LEN_2BPP_TILE *"

; extracts the middle two colors from a 2bpp binary palette
; example usage:
; INCBIN "foo.gbcpal", middle_colors
DEF middle_colors EQUS "PAL_COLOR_SIZE, PAL_COLOR_SIZE * 2"

MACRO dbpixel
	if _NARG >= 4
	; x tile, y tile, x pixel, y pixel
		db \1 * TILE_WIDTH + \3, \2 * TILE_WIDTH + \4
	else
	; x tile, y tile
		db \1 * TILE_WIDTH, \2 * TILE_WIDTH
	endc
ENDM

MACRO ldpixel
	if _NARG >= 5
	; register, x tile, y tile, x pixel, y pixel
		lb \1, \2 * TILE_WIDTH + \4, \3 * TILE_WIDTH + \5
	else
	; register, x tile, y tile
		lb \1, \2 * TILE_WIDTH, \3 * TILE_WIDTH
	endc
ENDM

DEF depixel EQUS "ldpixel de,"
DEF bcpixel EQUS "ldpixel bc,"

MACRO dbsprite
; x tile, y tile, x pixel, y pixel, vtile offset, attributes
	db (\2 * TILE_WIDTH) % $100 + \4, (\1 * TILE_WIDTH) % $100 + \3, \5, \6
ENDM
