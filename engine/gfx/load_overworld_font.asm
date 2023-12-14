_LoadOverworldFontAndFrame::
	ld de, OverworldFontGFX
	ld hl, vTiles1
	lb bc, BANK(OverworldFontGFX), 64
	call Get2bppViaHDMA
	ld de, OverworldFontGFX + 64 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $40
	lb bc, BANK(OverworldFontGFX), 48
	call Get2bppViaHDMA
	ld de, OverworldFontSpaceGFX
	ld hl, vTiles2 tile " "
	lb bc, BANK(OverworldFontSpaceGFX), 1
	call Get2bppViaHDMA
	ld a, [wEnvironment]
	maskbits NUM_ENVIRONMENTS
	ld bc, OW_TEXTBOX_FRAME_TILES * LEN_2BPP_TILE
	ld hl, OverworldFrames
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, vTiles0 tile OVERWORLD_FRAME_FIRST_TILE ; $f0
	lb bc, BANK(OverworldFrames), OW_TEXTBOX_FRAME_TILES
	jp Get2bppViaHDMA

RestoreOverworldFontOverBoardMenuGFX::
	ld de, OverworldFontGFX
	ld hl, vTiles1
	lb bc, BANK(OverworldFontGFX), TEXTBOX_INNERW * BOARD_MENU_ITEM_HEIGHT
	jp Get2bppViaHDMA

OverworldFontGFX:
INCBIN "gfx/font/overworld.2bpp"

OverworldFontSpaceGFX:
INCBIN "gfx/font/overworld_space.2bpp"

OverworldFrames:
	table_width OW_TEXTBOX_FRAME_TILES * LEN_2BPP_TILE, OverworldFrames
INCBIN "gfx/frames/ow1.2bpp" ; OUTDOOR_GRASSY
INCBIN "gfx/frames/ow2.2bpp" ; OUTDOOR_MOUNTAIN
INCBIN "gfx/frames/ow3.2bpp" ; OUTDOOR_COAST
INCBIN "gfx/frames/ow4.2bpp" ; OUTDOOR_SEA
INCBIN "gfx/frames/ow5.2bpp" ; INDOOR_FOREST
INCBIN "gfx/frames/ow6.2bpp" ; INDOOR_CAVE
INCBIN "gfx/frames/ow7.2bpp" ; INDOOR_ICE_CAVE
INCBIN "gfx/frames/ow8.2bpp" ; INDOOR_BUILDING
	assert_table_length NUM_ENVIRONMENTS