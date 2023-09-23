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
INCBIN "gfx/frames/ow1.2bpp"
INCBIN "gfx/frames/ow2.2bpp"
INCBIN "gfx/frames/ow3.2bpp"
INCBIN "gfx/frames/ow4.2bpp"
INCBIN "gfx/frames/ow5.2bpp"
INCBIN "gfx/frames/ow6.2bpp"
INCBIN "gfx/frames/ow7.2bpp"
INCBIN "gfx/frames/ow8.2bpp"
	assert_table_length NUM_ENVIRONMENTS