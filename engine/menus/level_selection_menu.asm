LevelSelectionMenu::
	ldh a, [hInMenu]
	push af
	xor a
	ldh [hInMenu], a
	xor a
	ld [wVramState], a

	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	call DisableLCD
	call LevelSelectionMenu_LoadGFX
	farcall ClearSpriteAnims
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a

	xor a
	ld [wLevelSelectionMenuCurrentLandmark], a
	call LevelSelectionMenu_GetLandmarkPage
	ld [wLevelSelectionMenuCurrentPage], a

	call LevelSelectionMenu_InitTilemap
	ld b, CGB_LEVEL_SELECTION_MENU
	call GetCGBLayout
	call SetPalettes

	ld de, MUSIC_GAME_CORNER
	call PlayMusic
.loop
	call DelayFrame
	jr .loop

	pop af
	ldh [hInMenu], a
	ret

LevelSelectionMenu_LoadGFX:
	ld hl, LevelSelectionMenuGFX
	ld de, vTiles2
	call Decompress
	farcall GetPlayerIcon
	ld h, d
	ld l, e
	ld a, b
	ld de, vTiles0
	ld bc, 24 tiles
	call FarCopyBytes
	ret

LevelSelectionMenu_InitTilemap:
; init tilemap of page at wLevelSelectionMenuCurrentPage
	ld hl, .Tilemaps
	ld bc, 2
	ld a, [wLevelSelectionMenuCurrentPage]
	call AddNTimes
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 0, 0
.loop
	ld a, [de]
	cp $ff ; tilemaps are $ff-terminated
	jp z, WaitBGMap2 ; takes 8 frames to commit tilemap and attrmap
	ld a, [de]
	ld [hli], a
	inc de
	jr .loop

.Tilemaps:
	dw LevelSelectionMenuPage1Tilemap
	dw LevelSelectionMenuPage2Tilemap
	dw LevelSelectionMenuPage3Tilemap
	dw LevelSelectionMenuPage4Tilemap

LevelSelectionMenu_GetLandmarkPage:
; Return page number (a) of landmark a.
	push hl
	ld hl, LevelSelectionMenu_Landmarks
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hl]
	pop hl
	ret

LevelSelectionMenu_GetLandmarkCoords:
; Return coordinates (d, e) of landmark e.
	push hl
	push bc
	ld hl, LevelSelectionMenu_Landmarks + $1
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	ld a, e
	call AddNTimes
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop bc
	pop hl
	ret

INCLUDE "data/level_selection_menu.asm"

LevelSelectionMenuGFX:
INCBIN "gfx/level_selection_menu/background.2bpp.lz"

LevelSelectionMenuPage1Tilemap:
INCBIN "gfx/level_selection_menu/page_1.tilemap"

LevelSelectionMenuPage2Tilemap:
INCBIN "gfx/level_selection_menu/page_2.tilemap"

LevelSelectionMenuPage3Tilemap:
INCBIN "gfx/level_selection_menu/page_3.tilemap"

LevelSelectionMenuPage4Tilemap:
INCBIN "gfx/level_selection_menu/page_4.tilemap"
