LevelSelectionMenu::
	xor a
	ldh [hInMenu], a
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
	ld a, TRUE
	ld [wLevelSelectionMenuStandingStill], a

	call LevelSelectionMenu_InitTilemap
	ld b, CGB_LEVEL_SELECTION_MENU
	call GetCGBLayout ; apply and commit attrmap (takes 4 frames) and pals
	call SetPalettes

	ld de, MUSIC_GAME_CORNER
	call PlayMusic
	call DelayFrame ; wait for pal update

	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_InitPlayerSprite

.main_loop
	farcall PlaySpriteAnimations
	call DelayFrame
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	bit A_BUTTON_F, a
	jp nz, .enter_level
	bit B_BUTTON_F, a
	jp nz, .exit
	ld hl, hJoyLast
	ld a, [hl]
	bit D_DOWN_F, a
	jr nz, .pressed_down
	bit D_UP_F, a
	jr nz, .pressed_up
	bit D_LEFT_F, a
	jr nz, .pressed_left
	bit D_RIGHT_F, a
	jr nz, .pressed_right
	jr .main_loop

.pressed_down
.pressed_up
.pressed_left
.pressed_right
	jr .main_loop

.enter_level
	call LevelSelectionMenu_Delay10Frames
	ld de, SFX_WARP_TO
	call PlaySFX
	call LevelSelectionMenu_Delay10Frames
	call .EnterLevelFadeOut
	ld c, 10
	call DelayFrames
	ld a, $8
	ld [wMusicFade], a
	ld a, LOW(MUSIC_NONE)
	ld [wMusicFadeID], a
	ld a, HIGH(MUSIC_NONE)
	ld [wMusicFadeID + 1], a
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	ld c, 20
	call DelayFrames

	ld a, [wLevelSelectionMenuCurrentLandmark]
	ld [wDefaultSpawnpoint], a
	call LevelSelectionMenu_GetLandmarkSpawnPoint
	ld a, MAPSETUP_WARP
	ld [hMapEntryMethod], a
	xor a
	ld [wDontPlayMapMusicOnReload], a ; play map music
	ld [wLinkMode], a
	ld a, PLAYER_NORMAL
	ld [wPlayerState], a ; this may need to be set on a per-level basis (e.g. if specific level starts with player in surf state)
	ld hl, wGameTimerPaused
	set GAME_TIMER_PAUSED_F, [hl] ; start game timer counter
	farcall OverworldLoop
	ret

.EnterLevelFadeOut:
	ret

.exit
	call LevelSelectionMenu_Delay10Frames
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
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
	jp z, WaitBGMap ; commit tilemap (4 frames)
	ld a, [de]
	ld [hli], a
	inc de
	jr .loop

.Tilemaps:
	dw LevelSelectionMenuPage1Tilemap
	dw LevelSelectionMenuPage2Tilemap
	dw LevelSelectionMenuPage3Tilemap
	dw LevelSelectionMenuPage4Tilemap

LevelSelectionMenu_InitPlayerSprite:
	push af
	depixel 0, 0
	ld b, SPRITE_ANIM_INDEX_LEVEL_SELECTION_MENU_MALE_WALK_DOWN
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .got_gender
	ld b, SPRITE_ANIM_INDEX_LEVEL_SELECTION_MENU_FEMALE_WALK_DOWN
.got_gender
	ld a, b
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $00
	pop af
	ld e, a
	call LevelSelectionMenu_GetLandmarkCoords
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

LevelSelectionMenu_GetLandmarkPage:
; Return page number (a) of landmark a.
	push hl
	ld hl, LevelSelectionMenu_Landmarks
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hl]
	pop hl
	ret

LevelSelectionMenu_GetLandmarkCoords::
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

LevelSelectionMenu_GetLandmarkName::
; Copy the name of landmark e to wStringBuffer1.
	push hl
	push de
	push bc

	ld hl, LevelSelectionMenu_Landmarks + $3
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	ld a, e
	call AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld de, wStringBuffer1
	ld c, 18
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy

	pop bc
	pop de
	pop hl
	ret

LevelSelectionMenu_GetLandmarkSpawnPoint:
; Return SPAWN_* (a) of landmark a.
	push hl
	ld hl, LevelSelectionMenu_Landmarks + $5
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hl]
	pop hl
	ret

LevelSelectionMenu_Delay10Frames:
; Delay 10 frames while playing sprite anims
	ld a, 10
.loop
	push af
	farcall PlaySpriteAnimations
	call DelayFrame
	pop af
	dec a
	jr nz, .loop
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
