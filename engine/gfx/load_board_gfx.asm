LoadBoardMenuGFX::
	ld de, .BoardMenuGFX
	ld hl, vTiles0 + BOARD_MENU_BG_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuGFX), TEXTBOX_INNERW * BOARD_MENU_ITEM_HEIGHT
	call Get2bppViaHDMA
	ld de, .BoardMenuOAMGFX
	ld hl, vTiles0 + BOARD_MENU_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuOAMGFX), BOARD_MENU_ITEM_SIZE * NUM_BOARD_MENU_ITEMS
	call Get2bppViaHDMA
	ret

.BoardMenuGFX:
INCBIN "gfx/board/menu.2bpp"

.BoardMenuOAMGFX:
	table_width BOARD_MENU_ITEM_SIZE * LEN_2BPP_TILE, .BoardMenuOAMGFX
INCBIN "gfx/board/menu_die.2bpp"
INCBIN "gfx/board/menu_party.2bpp"
INCBIN "gfx/board/menu_pack.2bpp"
INCBIN "gfx/board/menu_pokegear.2bpp"
INCBIN "gfx/board/menu_exit.2bpp"
	assert_table_length NUM_BOARD_MENU_ITEMS
