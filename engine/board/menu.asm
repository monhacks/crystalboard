BoardMenu::
; returns the selected menu item (BOARDMENUITEM_*) in wScriptVar upon exit
	ld a, [wBoardMenuLastCursorPosition]
	cp NUM_BOARD_MENU_ITEMS
	jr c, .ok
	ld a, BOARDMENUITEM_DIE
.ok
	ld [wBoardMenuCursorPosition], a
; refresh overworld sprites to hide those behind textbox before drawing new graphics
	call UpdateSprites
	farcall LoadBoardMenuGFX
	call DrawBoardMenuTiles
	call ApplyBoardMenuSpritePalette
; allow Pal update to complete, then apply the tilemap
	call DelayFrame
	call ApplyTilemap
; update sprites again to display the sprites of the selected menu item
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_BOARD_MENU_F, [hl]
	call UpdateSprites

.loop
	call GetBoardMenuSelection
	jr c, .done
	ld hl, wBoardMenuCursorPosition
	ld a, [wBoardMenuLastCursorPosition]
	cp [hl]
	jr z, .loop

; menu item change: refresh board menu OAM and save cursor position
	call ApplyBoardMenuSpritePalette
	call UpdateSprites
	ld a, [wBoardMenuCursorPosition]
	ld [wBoardMenuLastCursorPosition], a
	jr .loop

.done
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_BOARD_MENU_F, [hl]
	ld a, [wBoardMenuCursorPosition]
	ld [wScriptVar], a
	ret

DrawBoardMenuTiles:
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY
	ld a, BOARD_MENU_BG_FIRST_TILE
	lb bc, 3, 18
	jp FillBoxWithConsecutiveBytes

ApplyBoardMenuSpritePalette:
	ld hl, BoardMenuItemPals
	ld a, [wBoardMenuCursorPosition]
	ld bc, PALETTE_SIZE
	call AddNTimes
 ; set wOBPals2 directly rather than wOBPals1 to avoid calling ApplyPals and overwriting other overworld pals
	ld de, wOBPals2 palette PAL_OW_MISC
	ld bc, PALETTE_SIZE
	ld a, BANK(wOBPals2)
	call FarCopyWRAM
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ret

GetBoardMenuSelection:
	call JoyTextDelay
	call GetMenuJoypad
	bit A_BUTTON_F, a
	jr nz, .a_button
	bit D_RIGHT_F, a
	jr nz, .d_right
	bit D_LEFT_F, a
	jr nz, .d_left
	xor a
	ret ; nc

.a_button
	call PlayClickSFX
	call WaitSFX
	scf
	ret

.d_right
	call PlayClickSFX
	ld a, [wBoardMenuCursorPosition]
	inc a
	cp NUM_BOARD_MENU_ITEMS
	jr c, .right_dont_wrap_around
	ld a, BOARDMENUITEM_DIE
.right_dont_wrap_around
	ld [wBoardMenuCursorPosition], a
	xor a
	ret ; nc

.d_left
	call PlayClickSFX
	ld a, [wBoardMenuCursorPosition]
	dec a
	cp -1
	jr nz, .left_dont_wrap_around
	ld a, NUM_BOARD_MENU_ITEMS - 1 ; BOARDMENUITEM_EXIT
.left_dont_wrap_around
	ld [wBoardMenuCursorPosition], a
	xor a
	ret ; nc

BoardMenuItemPals:
INCLUDE "gfx/board/menu.pal"
