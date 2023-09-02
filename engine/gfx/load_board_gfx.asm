LoadBoardMenuGFX::
	ld de, .BoardMenuGFX
	ld hl, vTiles0 + BOARD_MENU_BG_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuGFX), 18 * 3
	call Get2bppViaHDMA
	ld de, .BoardMenuOAMGFX
	ld hl, vTiles0 + BOARD_MENU_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuOAMGFX), 3 * 3 * NUM_BOARD_MENU_ITEMS
	call Get2bppViaHDMA
	ret

.BoardMenuGFX:
INCBIN "gfx/board/menu.2bpp"

.BoardMenuOAMGFX:
	table_width 3 * 3 * LEN_2BPP_TILE, .BoardMenuOAMGFX
INCBIN "gfx/board/menu_die.2bpp"
INCBIN "gfx/board/menu_pokemon.2bpp"
INCBIN "gfx/board/menu_bag.2bpp"
INCBIN "gfx/board/menu_pokegear.2bpp"
INCBIN "gfx/board/menu_exit.2bpp"
	assert_table_length NUM_BOARD_MENU_ITEMS
