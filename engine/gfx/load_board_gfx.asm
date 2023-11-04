LoadBoardMenuGFX::
	ld de, .BoardMenuGFX
	ld hl, vTiles0 + BOARD_MENU_BG_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuGFX), TEXTBOX_INNERW * BOARD_MENU_ITEM_HEIGHT
	call Get2bppViaHDMA
	ld de, .BoardMenuOAMGFX
	ld hl, vTiles0 + BOARD_MENU_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BoardMenuOAMGFX), BOARD_MENU_ITEM_SIZE * NUM_BOARD_MENU_ITEMS
	call Get2bppViaHDMA
	ld de, .DieRollOAMGFX
	ld hl, vTiles0 + DIE_ROLL_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.DieRollOAMGFX), DIE_SIZE * 10
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

.DieRollOAMGFX:
INCBIN "gfx/board/die_roll.2bpp"

LoadBoardMenuDieNumbersGFX::
	ld de, .DieNumbersOAMGFX
; overwrite in vTiles0 the no-longer-needed BoardMenuOAMGFX, but keep DieRollOAMGFX
	ld hl, vTiles0 + DIE_NUMBERS_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.DieNumbersOAMGFX), DIE_NUMBER_SIZE * 10
	call Get2bppViaHDMA
	ret

.DieNumbersOAMGFX:
INCBIN "gfx/board/die_numbers.2bpp"

LoadBranchArrowsGFX::
	ld de, .BranchArrowsOAMGFX
	ld hl, vTiles0 + BRANCH_ARROWS_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.BranchArrowsOAMGFX), NUM_DIRECTIONS
	call Get2bppViaHDMA
	ret

.BranchArrowsOAMGFX:
INCBIN "gfx/board/branch_arrows.2bpp"

LoadViewMapModeGFX::
	ld de, .ViewMapModeArrowsOAMGFX
	ld hl, vTiles0 + VIEW_MAP_MODE_OAM_FIRST_TILE * LEN_2BPP_TILE
	lb bc, BANK(.ViewMapModeArrowsOAMGFX), NUM_DIRECTIONS
	call Get2bppViaHDMA
	ret

.ViewMapModeArrowsOAMGFX:
INCBIN "gfx/board/view_map_arrows.2bpp"
