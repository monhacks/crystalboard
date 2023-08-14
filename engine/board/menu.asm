DEF BOARD_MENU_BG_FIRST_TILE EQU "A"
DEF BOARD_MENU_OAM_FIRST_TILE EQU BOARD_MENU_BG_FIRST_TILE + 18 * 3

BoardMenu::
; returns the selected menu item (BOARDMENUITEM_*) in wScriptVar upon exit
	ld a, [wBoardMenuLastCursorPosition]
	ld [wBoardMenuCursorPosition], a
	farcall LoadBoardMenuGFX
	call DrawBoardMenuTiles
	call ApplyTilemap
	call UpdateSprites
; draw board menu OAM after overworld sprites
	call DrawBoardMenuOAM

.loop
	call GetBoardMenuSelection
	jr c, .done
	ld hl, wBoardMenuCursorPosition
	ld a, [wBoardMenuLastCursorPosition]
	cp [hl]
	jr z, .loop

; menu item change: refresh board menu OAM and save cursor position
	call DrawBoardMenuOAM
	ld a, [wBoardMenuCursorPosition]
	ld [wBoardMenuLastCursorPosition], a
	jr .loop

.done
	ld a, [wBoardMenuCursorPosition]
	ld [wScriptVar], a
	ret

DrawBoardMenuTiles:
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY
	ld a, BOARD_MENU_BG_FIRST_TILE
	lb bc, 3, 18
	jp FillBoxWithConsecutiveBytes

DrawBoardMenuOAM:
	ld hl, BoardMenuItemPals
	ld a, [wBoardMenuLastCursorPosition]
	ld bc, PALETTE_SIZE
	call AddNTimes
 ; set wOBPals2 directly rather than wOBPals1 to avoid calling ApplyPals and overwriting other overworld pals
	ld de, wOBPals2 palette PAL_OW_MISC
	ld bc, PALETTE_SIZE
	ld a, BANK(wOBPals2)
	call FarCopyWRAM

	ld hl, .OAM
	ld a, [wBoardMenuCursorPosition]
	ld bc, 3 * 3 * SPRITEOAMSTRUCT_LENGTH
	call AddNTimes
; find the beginning of free space in OAM, and assure there's space for 3 * 3 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (3 * 3 * SPRITEOAMSTRUCT_LENGTH)
	jr nc, .oam_full
; copy the sprite data (3 * 3 objects) of that item to the available space in OAM
	ld e, a
	ld d, HIGH(wShadowOAM)
	ld bc, 3 * 3 * SPRITEOAMSTRUCT_LENGTH
	call CopyBytes
.oam_full
	ret

.OAM:

GetBoardMenuSelection:
	scf
	ret

BoardMenuItemPals:
INCLUDE "gfx/board/menu.pal"
