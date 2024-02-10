LevelSelectionMenu::
	xor a
	ldh [hInMenu], a
	ldh [hMapAnims], a
	ldh [hSCY], a
	ldh [hSCX], a
	ld a, 1 << DONT_CLEAR_SHADOW_OAM_IN_SPRITE_ANIMS_F
	ld [wStateFlags], a

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

	ld a, [wLevelSelectionMenuEntryEventQueue]
	bit LSMEVENT_SHOW_UNLOCKED_LEVELS, a
	jp z, .load_default_landmark

	ld a, [wLastUnlockedLevelsCount]
	and a
	jp z, .load_default_landmark

	ld hl, wLastUnlockedLevels
.show_unlocked_levels_loop
	ld a, [hli]
	cp $ff
	jp z, .load_default_landmark

	push hl
; perform level-to-landmark lookup of wLastUnlockedLevels[i] in $ff-terminated LandmarkToLevelTable.
; stop at the first match and load it to wLevelSelectionMenuCurrentLandmark.
	ld hl, LandmarkToLevelTable
	ld c, 0
.level_to_landmark_loop
	ld b, [hl]
	inc b
	jr z, .invalid_level ; if reached $ff byte of LandmarkToLevelTable
	cp [hl]
	jr z, .match
	inc hl
	inc c
	jr .level_to_landmark_loop
.match
	ld a, c
	ld [wLevelSelectionMenuCurrentLandmark], a
	call LevelSelectionMenu_GetLandmarkPage
	ld [wLevelSelectionMenuCurrentPage], a

; load and draw gfx involved in the show unlocked levels event
	call LevelSelectionMenu_DrawTilemapAndAttrmap
	call LevelSelectionMenu_DrawTimeOfDaySymbol
	ld b, CGB_LEVEL_SELECTION_MENU
	call GetCGBLayout ; apply and commit pals
	call SetDefaultBGPAndOBP
	ld c, 20         ;
	call DelayFrames ; page shown --> page and textbox shown

	call LevelSelectionMenu_PrintLevelAndLandmarkNameAndStageIndicators
	call LevelSelectionMenu_DrawStageTrophies
	call LevelSelectionMenu_RefreshTextboxAttrs

; play animation that highlights landmark of unlocked level
	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkCoords
	ld a, SPRITE_ANIM_OBJ_LEVEL_SELECTION_MENU_HIGHLIGHT_LEVEL
	call InitSpriteAnimStruct
	ld a, (15 + 1) * 6 ; %01100000
.highlight_level_anim_loop
	ld [wFrameCounter], a
	ld a, [wFrameCounter]
	and %11111
	ld de, SFX_POKEBALLS_PLACED_ON_TABLE
	call z, PlaySFX
	farcall PlaySpriteAnimationsAndDelayFrame
	ld a, [wFrameCounter]
	dec a
	jr nz, .highlight_level_anim_loop
	farcall ClearSpriteAnims

; fade to the next unlocked level, or to the regular level selection menu
	ld b, RGBFADE_TO_BLACK_6BGP_1OBP1
	call DoRGBFadeEffect
	ld c, 30         ;
	call DelayFrames ; black screen --> next landmark shown
.invalid_level
	pop hl
	jp .show_unlocked_levels_loop

.load_default_landmark
	ld a, [wDefaultLevelSelectionMenuLandmark]
	ld [wLevelSelectionMenuCurrentLandmark], a
	call LevelSelectionMenu_GetLandmarkPage
	ld [wLevelSelectionMenuCurrentPage], a
	ld a, TRUE
	ld [wLevelSelectionMenuStandingStill], a

	call LevelSelectionMenu_DrawTilemapAndAttrmap
	call LevelSelectionMenu_DrawTimeOfDaySymbol
	ld b, CGB_LEVEL_SELECTION_MENU
	call GetCGBLayout ; apply and commit pals
	call SetDefaultBGPAndOBP

	ld de, MUSIC_GAME_CORNER
	call PlayMusic
	call DelayFrame ; wait for pal update

	call LevelSelectionMenu_InitPlayerSprite
	call LevelSelectionMenu_InitLandmark
	call LevelSelectionMenu_PrintLevelAndLandmarkNameAndStageIndicators
	call LevelSelectionMenu_DrawDirectionalArrows
	call LevelSelectionMenu_DrawStageTrophies
	call LevelSelectionMenu_RefreshTextboxAttrs

	ld a, [wLevelSelectionMenuEntryEventQueue]
	bit LSMEVENT_ANIMATE_TIME_OF_DAY, a
	jp z, .main_loop

	call LevelSelectionMenu_Delay10Frames

	ld bc, SPRITEOAMSTRUCT_LENGTH
	ld e, 3 * TILE_WIDTH
.tod_symbol_upwards_loop
	farcall PlaySpriteAnimationsAndDelayFrame
	ld hl, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH + SPRITEOAMSTRUCT_YCOORD
	dec [hl]
	add hl, bc
	dec [hl]
	add hl, bc
	dec [hl]
	add hl, bc
	dec [hl]
	dec e
	jr nz, .tod_symbol_upwards_loop

	ld a, [wTimeOfDay]
	ld [wLevelSelectionMenuStartingToD], a

	cp NITE_F
	ld e, -4
	jr z, .change_tod_symbol
	cp EVE_F
	ld e, -2
	jr z, .change_tod_symbol
	cp DAY_F
	ld e, 4
	jr z, .change_tod_symbol
	ld e, 2
.change_tod_symbol
	ld hl, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH + SPRITEOAMSTRUCT_TILE_ID
	ld bc, SPRITEOAMSTRUCT_LENGTH
	ld d, 2 * 2
.change_tod_symbol_loop
	ld a, [hl]
	add e
	ld [hl], a
	add hl, bc
	dec d
	jr nz, .change_tod_symbol_loop

	call AdvanceTimeOfDay

	xor a
	ld [wLevelSelectionMenuToDFadeStep], a
	ld b, CGB_LEVEL_SELECTION_MENU_TOD_CHANGE
	call GetCGBLayout
	call LevelSelectionMenu_Delay4Frames
	ld a, 1
	ld [wLevelSelectionMenuToDFadeStep], a
	ld b, CGB_LEVEL_SELECTION_MENU_TOD_CHANGE
	call GetCGBLayout
	call LevelSelectionMenu_Delay4Frames
	ld a, 2
	ld [wLevelSelectionMenuToDFadeStep], a
	ld b, CGB_LEVEL_SELECTION_MENU_TOD_CHANGE
	call GetCGBLayout
	call LevelSelectionMenu_Delay4Frames
	ld a, 3
	ld [wLevelSelectionMenuToDFadeStep], a
	ld b, CGB_LEVEL_SELECTION_MENU_TOD_CHANGE
	call GetCGBLayout

	ld bc, SPRITEOAMSTRUCT_LENGTH
	ld e, 3 * TILE_WIDTH
.tod_symbol_downwards_loop
	farcall PlaySpriteAnimationsAndDelayFrame
	ld hl, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH + SPRITEOAMSTRUCT_YCOORD
	inc [hl]
	add hl, bc
	inc [hl]
	add hl, bc
	inc [hl]
	add hl, bc
	inc [hl]
	dec e
	jr nz, .tod_symbol_downwards_loop

.main_loop
	farcall PlaySpriteAnimations
	call DelayFrame
	call GetJoypad
	call LevelSelectionMenu_GetValidKeys
	ld hl, hJoyPressed
	ld a, [hl]
	and c
	bit A_BUTTON_F, a
	jp nz, .enter_level
	bit B_BUTTON_F, a
	jp nz, .exit
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
	ld c, DOWN
	jr .start_movement
.pressed_up
	ld c, UP
	jr .start_movement
.pressed_left
	ld c, LEFT
	jr .start_movement
.pressed_right
	ld c, RIGHT
	jr .start_movement

.start_movement
	ld e, c ; copy direction to e for later (for LevelSelectionMenu_SetAnimSeqAndFrameset)
; make hl point to the beginning of the transition data for the chosen direction at c
	ld hl, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, -1
	call AdvanceNEntries
	ld bc, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a

; clear textbox and non-player sprites, as we are about to move out of current landmark
	call LevelSelectionMenu_Delay10Frames
	call LevelSelectionMenu_ClearTextboxOAM ; preserves e
	call LevelSelectionMenu_ClearTextbox ; preserves e
	call LevelSelectionMenu_RefreshTextboxAttrs ; preserves e
; begin transition
	xor a ; FALSE
	ld [wLevelSelectionMenuStandingStill], a
	ld a, 1 << 7 ; "first step of movement" flag
	ld [wLevelSelectionMenuMovementStepsLeft], a
	call LevelSelectionMenu_SetAnimSeqAndFrameset

; perform all movements to transition to the new landmark
.wait_transition_loop
; wait until the sprite anim has signaled end of all movements
; by setting wLevelSelectionMenuStandingStill to TRUE
	farcall PlaySpriteAnimations
	call DelayFrame
	call LevelSelectionMenu_DoPageChangeEvent
	ld a, [wLevelSelectionMenuStandingStill]
	and a
	jr z, .wait_transition_loop

	call LevelSelectionMenu_InitLandmark
	call LevelSelectionMenu_PrintLevelAndLandmarkNameAndStageIndicators
	call LevelSelectionMenu_DrawDirectionalArrows
	call LevelSelectionMenu_DrawStageTrophies
	call LevelSelectionMenu_RefreshTextboxAttrs
	jp .main_loop

.enter_level
	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkSpawnPoint
	ld [wDefaultSpawnpoint], a
	call LevelSelectionMenu_Delay10Frames
	ld de, SFX_WARP_TO
	call PlaySFX
	call LevelSelectionMenu_Delay10Frames
	call .EnterLevelFadeOut
	call WaitSFX
	scf
	ret

.EnterLevelFadeOut:
	ld b, RGBFADE_TO_WHITE_6BGP_6OBP
	jp DoRGBFadeEffect

.exit
	call LevelSelectionMenu_Delay10Frames
	call ClearBGPalettes
	call ClearTilemap
	farcall ClearSpriteAnims
	call ClearSprites
	xor a
	ld [wStateFlags], a
	ret ; nc

LevelSelectionMenu_LoadGFX:
; load inverted font
	farcall LoadInversedFont
; load gfx for the background tiles, and for the player and directional arrow sprites
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
	ld hl, LevelSelectionMenuDirectionalArrowsGFX
;	ld de, vTiles0 + 24 tiles
	ld bc, NUM_DIRECTIONS tiles
	call FarCopyBytes
	ld hl, LevelSelectionMenuStageTrophiesGFX
;	ld de, vTiles0 + (24 + NUM_DIRECTIONS) tiles
	ld bc, NUM_LEVEL_STAGES * 2 tiles
	call FarCopyBytes
	ld hl, LevelSelectionMenuTimeOfDaySymbolsGFX
;	ld de, vTiles0 + (24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2) tiles
	ld bc, NUM_DAYTIMES * 4 tiles
	call FarCopyBytes
	ld hl, LevelSelectionMenuLevelHighlighterGFX
;	ld de, vTiles0 + (24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2 + NUM_DAYTIMES * 4) tiles
	ld bc, 8 tiles
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
	ret z
	ld a, [de]
	ld [hli], a
	inc de
	jr .loop

.Tilemaps:
	dw LevelSelectionMenuPage1Tilemap
	dw LevelSelectionMenuPage2Tilemap
	dw LevelSelectionMenuPage3Tilemap
	dw LevelSelectionMenuPage4Tilemap

LevelSelectionMenu_InitAttrmap:
; assign attrs based on tile ids according to LevelSelectionMenuAttrmap
	hlcoord 0, 0
	decoord 0, 0, wAttrmap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
.loop
	push hl
	ld a, [hl] ; tile id
	ld hl, LevelSelectionMenuAttrmap
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a
	ld a, [hl] ; attr value
	ld [de], a
	pop hl
	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

LevelSelectionMenu_DrawTilemapAndAttrmap:
	call LevelSelectionMenu_InitTilemap
	call LevelSelectionMenu_InitAttrmap
	call WaitBGMap2
	xor a
	ldh [hBGMapMode], a
	ret

LevelSelectionMenu_InitPlayerSprite:
; initialize the anim struct of the player's sprite.
; because ClearSpriteAnims was called before, it's always loaded to wSpriteAnim1
	depixel 0, 0
; all the SPRITE_ANIM_* related to the level selection menu are sorted by direction, then by gender
	ld a, SPRITE_ANIM_OBJ_LEVEL_SELECTION_MENU_WALK_DOWN
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $00
	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkCoords
; wSpriteAnim1*Coord contain the coord of the bottom right object of the player sprite
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

LevelSelectionMenu_InitLandmark:
; make wLevelSelectionMenuLandmarkTransitionsPointer point
; to the start of the transition data of the current landmark.
	ld a, [wLevelSelectionMenuCurrentLandmark]
	ld e, a
	ld hl, LevelSelectionMenu_LandmarkTransitions
	ld b, -1
rept NUM_DIRECTIONS
	ld c, e
	call AdvanceNEntries
endr
	ld de, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	ret

LevelSelectionMenu_PrintLevelAndLandmarkNameAndStageIndicators:
; level indicator and level numbers are 8x16.
; botton half of their graphics are $10 tiles after the top half.
	hlcoord LSMTEXTBOX_X_COORD, LSMTEXTBOX_Y_COORD
	ld a, LSMTEXTBOX_LEVEL_INDICATOR_TILE
	ld [hl], a
	add $10
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld [hl], a
; get level from landmark and copy it to wCurLevel
	ld a, [wLevelSelectionMenuCurrentLandmark]
	ld e, a
	ld d, 0
	ld hl, LandmarkToLevelTable
	add hl, de
	ld a, [hl]
	ld [wCurLevel], a
	ld c, 0
.loop1
	ld e, a
	sub 10
	jr c, .next1
	inc c
	jr .loop1
.next1
	; c = first digit ; e = second digit
	hlcoord LSMTEXTBOX_X_COORD + 1, LSMTEXTBOX_Y_COORD
	ld a, LSMTEXTBOX_LEVEL_NUMBERS_FIRST_TILE
	add c
	ld [hli], a
	ld a, LSMTEXTBOX_LEVEL_NUMBERS_FIRST_TILE
	add e
	ld [hl], a
	hlcoord LSMTEXTBOX_X_COORD + 1, LSMTEXTBOX_Y_COORD + 1
	ld a, LSMTEXTBOX_LEVEL_NUMBERS_FIRST_TILE + $10
	add c
	ld [hli], a
	ld a, LSMTEXTBOX_LEVEL_NUMBERS_FIRST_TILE + $10
	add e
	ld [hl], a

	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkName
	ld hl, wStringBuffer1
	decoord LSMTEXTBOX_X_COORD + 4, LSMTEXTBOX_Y_COORD
	ld bc, LSMTEXTBOX_MAX_TEXT_ROW_LENGTH
	call CopyBytes
	ld hl, wStringBuffer2
	decoord LSMTEXTBOX_X_COORD + 4, LSMTEXTBOX_Y_COORD + 1
	ld bc, LSMTEXTBOX_MAX_TEXT_ROW_LENGTH
	call CopyBytes

	ld de, 0 ; e tracks number of already printed stages, to know where to print current one (in descending order)
	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkLevelStages
	bit STAGE_4_F, a
	push af
	ld a, LSMTEXTBOX_STAGE_4_INDICATOR_TILE
	call nz, .PrintStageTile
	pop af
	bit STAGE_3_F, a
	push af
	ld a, LSMTEXTBOX_STAGE_3_INDICATOR_TILE
	call nz, .PrintStageTile
	pop af
	bit STAGE_2_F, a
	push af
	ld a, LSMTEXTBOX_STAGE_2_INDICATOR_TILE
	call nz, .PrintStageTile
	pop af
	bit STAGE_1_F, a
	ld a, LSMTEXTBOX_STAGE_1_INDICATOR_TILE
	call nz, .PrintStageTile

	ld a, 2
	ld [hBGMapThird], a
	dec a ; ld a ,1
	ld [hBGMapMode], a
	call DelayFrame
	xor a
	ld [hBGMapMode], a
	ret

.PrintStageTile:
	hlcoord LSMTEXTBOX_X_COORD + (LSMTEXTBOX_WIDTH - 1), LSMTEXTBOX_Y_COORD
	add hl, de
	ld [hl], a
	ld bc, SCREEN_WIDTH
	add hl, bc
	add $10
	ld [hl], a
	dec de
	ret

LevelSelectionMenu_ClearTextbox:
	hlcoord LSMTEXTBOX_X_COORD, LSMTEXTBOX_Y_COORD
	ld a, LSMTEXTBOX_BLACK_TILE
	lb bc, LSMTEXTBOX_HEIGHT, LSMTEXTBOX_WIDTH
	call FillBoxWithByte
	ld a, 2
	ld [hBGMapThird], a
	dec a ; ld a, 1
	ld [hBGMapMode], a
	call DelayFrame
	xor a
	ld [hBGMapMode], a
	ret

LevelSelectionMenu_RefreshTextboxAttrs:
; OAM priority changes in the textbox depending on whether a landmark is shown
; (stage trophies OAM has priority) or player is moving (all BG has priority).
; Assumes affected tiles are only in the textbox, which is in the bottom third of screen.
	push de
	hlcoord LSMTEXTBOX_X_COORD, LSMTEXTBOX_Y_COORD
	decoord LSMTEXTBOX_X_COORD, LSMTEXTBOX_Y_COORD, wAttrmap
	ld bc, SCREEN_WIDTH * (SCREEN_HEIGHT - LSMTEXTBOX_Y_COORD)
	call LevelSelectionMenu_InitAttrmap.loop
	ld a, 2
	ld [hBGMapThird], a
	ld [hBGMapMode], a
	call DelayFrame
	xor a
	ld [hBGMapMode], a
	pop de
	ret

LevelSelectionMenu_DrawTimeOfDaySymbol:
	ld hl, .OAM
	ld de, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH ; always goes after player sprite
	ld a, [wTimeOfDay]
	add a
	ld c, a
	call .CopyObject
	call .CopyObject
	call .CopyObject
	call .CopyObject
	ret

.CopyObject:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	add c
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ret

.OAM:
	db 3 * TILE_WIDTH, 2 * TILE_WIDTH, 24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2 + 0, PAL_LSM_TOD
	db 3 * TILE_WIDTH, 3 * TILE_WIDTH, 24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2 + 1, PAL_LSM_TOD
	db 4 * TILE_WIDTH, 2 * TILE_WIDTH, 24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2 + 8, PAL_LSM_TOD
	db 4 * TILE_WIDTH, 3 * TILE_WIDTH, 24 + NUM_DIRECTIONS + NUM_LEVEL_STAGES * 2 + 9, PAL_LSM_TOD

LevelSelectionMenu_DrawDirectionalArrows:
; Draw directional arrows OAM around player sprite for the valid directions.
; Objects are drawn in OAM after player sprite objects in wWalkingDirection order.
; Depends on wLevelSelectionMenuLandmarkTransitionsPointer being initialized.
	call LevelSelectionMenu_GetValidDirections
	ld hl, .OAM
	ld de, wShadowOAM + ($4 + $4) * SPRITEOAMSTRUCT_LENGTH ; always goes after player sprite and ToD symbol
	bit D_DOWN_F, c
	jr z, .next1
	call .DrawArrow
.next1
	ld hl, .OAM + $3
	bit D_UP_F, c
	jr z, .next2
	call .DrawArrow
.next2
	ld hl, .OAM + $6
	bit D_LEFT_F, c
	jr z, .next3
	call .DrawArrow
.next3
	ld hl, .OAM + $9
	bit D_RIGHT_F, c
	call nz, .DrawArrow
	ret

.DrawArrow:
	ld a, [wSpriteAnim1YCoord]
	add [hl]
	ld [de], a ; y coord
	inc hl
	inc de
	ld a, [wSpriteAnim1XCoord]
	add [hl]
	ld [de], a ; x coord
	inc hl
	inc de
	ld a, [hli]
	ld [de], a ; tile id
	inc de
	xor a ; PAL_LSM_PLAYER
	ld [de], a ; attr (uses the same pal as player sprite)
	inc de
	ret

.OAM:
; y offset against wSpriteAnim1YCoord, x offset against wSpriteAnim1XCoord, tile id
; tiles have been loaded to vTiles0 after the player sprites
	db   8,  -4, 24 + DOWN
	db -16,  -4, 24 + UP
	db  -4, -16, 24 + LEFT
	db  -4,   8, 24 + RIGHT

LevelSelectionMenu_DrawStageTrophies:
; Draw stage trophies OAM of cleared level stages.
; These objects go after player sprite, ToD symbol, and arrows in OAM.
	ld de, wShadowOAM + ($4 + $4 + NUM_DIRECTIONS + $0) * SPRITEOAMSTRUCT_LENGTH
	bccoord LSMTEXTBOX_X_COORD + (LSMTEXTBOX_WIDTH - 1), LSMTEXTBOX_Y_COORD
	ld a, 6
	call .draw_stage_trophy
	ret c
	ld de, wShadowOAM + ($4 + $4 + NUM_DIRECTIONS + $2) * SPRITEOAMSTRUCT_LENGTH
	bccoord LSMTEXTBOX_X_COORD + (LSMTEXTBOX_WIDTH - 2), LSMTEXTBOX_Y_COORD
	ld a, 4
	call .draw_stage_trophy
	ret c
	ld de, wShadowOAM + ($4 + $4 + NUM_DIRECTIONS + $4) * SPRITEOAMSTRUCT_LENGTH
	bccoord LSMTEXTBOX_X_COORD + (LSMTEXTBOX_WIDTH - 3), LSMTEXTBOX_Y_COORD
	ld a, 2
	call .draw_stage_trophy
	ret c
	ld de, wShadowOAM + ($4 + $4 + NUM_DIRECTIONS + $6) * SPRITEOAMSTRUCT_LENGTH
	bccoord LSMTEXTBOX_X_COORD + (LSMTEXTBOX_WIDTH - 4), LSMTEXTBOX_Y_COORD
	xor a
	call .draw_stage_trophy
	ret

.draw_stage_trophy:
; input:
; - de: wShadowOAM address
; - bc: current tile address in wTilemap
; -  a: .BaseOAMCoords entry to use
; if current tile is not a stage indicator tile, return carry to signal to not keep going
	push af
	ld a, [bc]
	sub LSMTEXTBOX_STAGE_1_INDICATOR_TILE
	jr c, .ret_c
	cp STAGE_4_F + 1
	jr nc, .ret_c
	call .IsLevelStageCleared
	jr z, .ret_nc ; this level has not been cleared, but there are more levels yet to check, so return nc
	add a
	add a
	ld c, a
	ld b, 0
	ld hl, .BaseOAMTilesAttrs
	add hl, bc
	pop af
	push hl
	add a
	ld c, a
	ld b, 0
	ld hl, .BaseOAMCoords
	add hl, bc
	pop bc
	call .CopyObject
	call .CopyObject
	xor a
	ret ; nc

.ret_c:
	pop af
	scf
	ret

.ret_nc
	pop af
	xor a
	ret

.IsLevelStageCleared:
; return nz if [wCurLevel]'s stage in a has been cleared, z otherwise.
; preserve a and de.
	ld c, a
	push bc
	push de
	call GetClearedLevelsStageAddress
	ld b, CHECK_FLAG
	ld d, 0
	ld a, [wCurLevel]
	ld e, a
	call FlagAction
	pop de
	pop bc
	ld a, c
	ret

.CopyObject:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [bc]
	ld [de], a
	inc bc
	inc de
	ld a, [bc]
	ld [de], a
	inc bc
	inc de
	ret

.BaseOAMCoords:
	db 17 * TILE_WIDTH, 16 * TILE_WIDTH
	db 18 * TILE_WIDTH, 16 * TILE_WIDTH
	db 17 * TILE_WIDTH, 17 * TILE_WIDTH
	db 18 * TILE_WIDTH, 17 * TILE_WIDTH
	db 17 * TILE_WIDTH, 18 * TILE_WIDTH
	db 18 * TILE_WIDTH, 18 * TILE_WIDTH
	db 17 * TILE_WIDTH, 19 * TILE_WIDTH
	db 18 * TILE_WIDTH, 19 * TILE_WIDTH

.BaseOAMTilesAttrs:
	db 24 + NUM_DIRECTIONS + 0, PAL_LSM_TROPHY_1
	db 24 + NUM_DIRECTIONS + 4, PAL_LSM_TROPHY_1
	db 24 + NUM_DIRECTIONS + 1, PAL_LSM_TROPHY_2
	db 24 + NUM_DIRECTIONS + 5, PAL_LSM_TROPHY_2
	db 24 + NUM_DIRECTIONS + 2, PAL_LSM_TROPHY_3
	db 24 + NUM_DIRECTIONS + 6, PAL_LSM_TROPHY_3
	db 24 + NUM_DIRECTIONS + 3, PAL_LSM_TROPHY_4
	db 24 + NUM_DIRECTIONS + 7, PAL_LSM_TROPHY_4

LevelSelectionMenu_ClearTextboxOAM:
	ld hl, wShadowOAM + $8 * SPRITEOAMSTRUCT_LENGTH
	ld bc, wShadowOAMEnd - (wShadowOAM + $8 * SPRITEOAMSTRUCT_LENGTH)
	xor a
	jp ByteFill

LevelSelectionMenu_SetAnimSeqAndFrameset:
; Set the animation sequence and frameset for this movement.
; direction (in wWalkingDirection order) is provided in e.
	ld bc, wSpriteAnim1
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld a, SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_DOWN
	add e ; add direction
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld a, SPRITE_ANIM_FRAMESET_LEVEL_SELECTION_MENU_WALK_DOWN
	add e ; add direction
	ld [hl], a
	ret

LevelSelectionMenu_DoPageChangeEvent:
	ld de, .Events
	ld bc, wSpriteAnim1
.loop
	ld a, [de] ; SPRITE_ANIM_FUNC_* or $00 table terminator
	and a
	ret z
	inc de
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	cp [hl]
	jr nz, .next1
	ld a, [de] ; SPRITEANIMSTRUCT_YCOORD or SPRITEANIMSTRUCT_XCOORD
	ld l, a
	ld h, 0
	add hl, bc
	inc de
	ld a, [de] ; X/Y coordinate
	cp [hl]
	jr nz, .next2

; this entry matches
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	jp hl

.next1
	inc de
.next2
	inc de
	inc de
	inc de
	jr .loop

; LEVELSELECTIONMENU_PAGE_EDGE_* represent values when the player sprite is at:
;          UU
; =========UU=========
; =------------------=
; =------------------=
; =------------------=
; =------------------=
; =------------------=
; =------------------=
; =------------------=
;LL------------------RR
;LL------------------RR
; =------------------=
; =------------------=
; =------------------=
; =------------------=
; =========DD=========
; =========DD=========
; ====================
; ====================
; for movements spanning two pages, when one edge is reached, the page change occurs
; and the player appears in the other page at the coordinate of the new edge.
; hence, for calculating movement length, it's as if both pages were adjacent without the border frame.
DEF PAGE_EDGE_DOWN  EQU $88
DEF PAGE_EDGE_UP    EQU $10
DEF PAGE_EDGE_LEFT  EQU $08
DEF PAGE_EDGE_RIGHT EQU $a8

MACRO page_change_event
; SPRITE_ANIM_FUNC_* to match, Match object's X or Y, X/Y coordinate, Action if both SPRITE_ANIM_FUNC_* and X/Y match
	db \1, \2, \3
	dw \4
ENDM

.Events:
	page_change_event SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_DOWN,  SPRITEANIMSTRUCT_YCOORD, PAGE_EDGE_DOWN,  .PageChangeDown
	page_change_event SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_UP,    SPRITEANIMSTRUCT_YCOORD, PAGE_EDGE_UP,    .PageChangeUp
	page_change_event SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_LEFT,  SPRITEANIMSTRUCT_XCOORD, PAGE_EDGE_LEFT,  .PageChangeLeft
	page_change_event SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_RIGHT, SPRITEANIMSTRUCT_XCOORD, PAGE_EDGE_RIGHT, .PageChangeRight
	db $0

.PageChangeDown:
	call .PageChangeFadeOut
	ld a, PAGE_EDGE_UP
	ld [wSpriteAnim1YCoord], a ; respawn in opposite edge
	ld e, DOWN
	jr .PageChange_Common

.PageChangeUp:
	call .PageChangeFadeOut
	ld a, PAGE_EDGE_DOWN
	ld [wSpriteAnim1YCoord], a ; respawn in opposite edge
	ld e, UP
	jr .PageChange_Common

.PageChangeLeft:
	call .PageChangeFadeOut
	ld a, PAGE_EDGE_RIGHT
	ld [wSpriteAnim1XCoord], a ; respawn in opposite edge
	ld e, LEFT
	jr .PageChange_Common

.PageChangeRight:
	call .PageChangeFadeOut
	ld a, PAGE_EDGE_LEFT
	ld [wSpriteAnim1XCoord], a ; respawn in opposite edge
	ld e, RIGHT
	jr .PageChange_Common

.PageChange_Common:
; set new page and redraw screen
	call LevelSelectionMenu_GetNewPage
	ld [wLevelSelectionMenuCurrentPage], a
	call LevelSelectionMenu_DrawTilemapAndAttrmap
	call .PageChangeFadeIn
; adjust steps left for the "duplicate" movement of the player leaving and entering a page
	ld hl, wLevelSelectionMenuMovementStepsLeft
	ld a, [hl]
	add 2 * TILE_WIDTH
	ld [hl], a
	ret

.PageChangeFadeOut:
	ld b, RGBFADE_TO_BLACK_6BGP_1OBP1
	jp DoRGBFadeEffect

.PageChangeFadeIn:
	ld b, RGBFADE_TO_LIGHTER_6BGP_1OBP1
	jp DoRGBFadeEffect

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
; Return coordinates (d, e) of landmark a.
	push hl
	push bc
	ld hl, LevelSelectionMenu_Landmarks + $1
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop bc
	pop hl
	ret

LevelSelectionMenu_GetLandmarkName::
; Copy the name of landmark a to wStringBuffer1 (tow row) and wStringBuffer2 (bottom row).
	push hl
	push de
	push bc

	ld hl, LevelSelectionMenu_Landmarks + $3
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld de, wStringBuffer1
	call .copy
	ld de, wStringBuffer2
	call .copy

	pop bc
	pop de
	pop hl
	ret

.copy
	ld c, LSMTEXTBOX_MAX_TEXT_ROW_LENGTH
.copy_loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy_loop
	ret

LevelSelectionMenu_GetLandmarkSpawnPoint:
; Return SPAWN_* (a) of landmark a.
	ld hl, LevelSelectionMenu_Landmarks + $5
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hl]
	ret

LevelSelectionMenu_GetLandmarkLevelStages:
; Return STAGE_* flags (a) of landmark a.
	ld hl, LevelSelectionMenu_Landmarks + $6
	ld bc, LevelSelectionMenu_Landmarks.landmark2 - LevelSelectionMenu_Landmarks.landmark1
	call AddNTimes
	ld a, [hl]
	ret

LevelSelectionMenu_GetValidKeys:
	call LevelSelectionMenu_GetValidDirections
	ld a, c
	or A_BUTTON | B_BUTTON | SELECT | START
	ld c, a
	ret

LevelSelectionMenu_GetValidDirections:
; Return the valid directions according to landmark transitions and unlocked levels.
; Depends on wLevelSelectionMenuLandmarkTransitionsPointer being initialized.
; Return the result in c as a mask of D_<DIR>_F.
	ld hl, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, 0
	ld a, [hli]
	inc a
	jr z, .next1
.loop1
	ld a, [hli]
	inc a
	jr nz, .loop1
	call .IsLevelUnlocked
	jr z, .next1
	set D_DOWN_F, c
.next1
	ld a, [hli]
	inc a
	jr z, .next2
.loop2
	ld a, [hli]
	inc a
	jr nz, .loop2
	call .IsLevelUnlocked
	jr z, .next2
	set D_UP_F, c
.next2
	ld a, [hli]
	inc a
	jr z, .next3
.loop3
	ld a, [hli]
	inc a
	jr nz, .loop3
	call .IsLevelUnlocked
	jr z, .next3
	set D_LEFT_F, c
.next3
	ld a, [hli]
	inc a
	ret z
.loop4
	ld a, [hli]
	inc a
	jr nz, .loop4
	call .IsLevelUnlocked
	ret z
	set D_RIGHT_F, c
	ret

.IsLevelUnlocked:
	push hl
	push bc
; the landmark byte of this transition is two bytes back
	dec hl
	dec hl
; use LandmarkToLevelTable to find the level that this landmark belongs to
	ld e, [hl]
	ld d, 0
	ld hl, LandmarkToLevelTable
	add hl, de
; find if said level has been unlocked
	ld e, [hl]
	ld b, CHECK_FLAG
	call UnlockedLevelsFlagAction
	pop bc
	pop hl
	ret

LevelSelectionMenu_GetNewPage:
; return in a the new page that the player is ending up at during this movement involving page change.
; direction (in wWalkingDirection order) is provided in e.
	ld hl, LevelSelectionMenu_PageGrid - 1
	ld c, LEVELSELECTIONMENU_PAGE_GRID_WIDTH * LEVELSELECTIONMENU_PAGE_GRID_HEIGHT + 1
.loop
	inc hl
	dec c
	jr z, .out_of_bounds
	ld a, [wLevelSelectionMenuCurrentPage]
	cp [hl]
	jr nz, .loop

; find the next page in the grid according to movement direction
	ld a, e
	ld bc, LEVELSELECTIONMENU_PAGE_GRID_WIDTH
	cp DOWN
	jr z, .ok
	ld bc, -LEVELSELECTIONMENU_PAGE_GRID_WIDTH
	cp UP
	jr z, .ok
	ld bc, -1
	cp LEFT
	jr z, .ok
	ld bc, 1
.ok
	add hl, bc
	ld a, [hl]
	cp -1
	jr z, .out_of_bounds
	ret

.out_of_bounds
	ld a, 1
	ret

LevelSelectionMenu_Delay4Frames:
	ld a, 4
	jr LevelSelectionMenu_Delay10Frames.loop

LevelSelectionMenu_Delay10Frames:
; Delay 10 frames while playing sprite anims
	ld a, 10
.loop
	push af
	farcall PlaySpriteAnimationsAndDelayFrame
	pop af
	dec a
	jr nz, .loop
	ret

_LevelSelectionMenuHandleTransition:
; Called from the corresponding SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_* animation sequence.
; This function is here because LevelSelectionMenu_LandmarkTransitions is in this bank.
; Applies the animation to the player sprite for the current frame.
	ld hl, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
; hl is now somewhere in LevelSelectionMenu_LandmarkTransitions	for this transition
	ld de, wLevelSelectionMenuMovementStepsLeft
	ld a, [de]
	bit 7, a
	jr z, .not_first_step
; if first step of movement, extract the number of steps left of the current movement
; of the transition, and copy it to wLevelSelectionMenuMovementStepsLeft (clearing bit 7)
	ld a, [hl]
	and %00111111
	ld [de], a
.not_first_step
	and a
	jr z, .movement_over

; one less step left to finish this movement
	dec a
	ld [de], a
.done
; return carry to signal back to apply a displacement during this frame
	scf
	ret

.movement_over
; advance pointer to the next movement
	ld hl, wLevelSelectionMenuLandmarkTransitionsPointer
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
; check if we just ran the last movement of the transition
; that would be the case if the next byte is the landmark, and the one after it is -1
	inc de
	ld a, [de]
	dec de
	inc a
	jr z, .all_movements_over
; more movements left. which direction is the next movement?
	ld a, [de]
	and %11000000
	swap a
	srl a
	srl a
	ld e, a ; DOWN / UP / LEFT / RIGHT
	call LevelSelectionMenu_SetAnimSeqAndFrameset
	ld a, 1 << 7 ; "first step of movement" flag
	ld [wLevelSelectionMenuMovementStepsLeft], a
; return nc to signal back not to apply a displacement during this frame
	xor a
	ret

.all_movements_over
; all movements of this transition are over
; hl is now pointing to the destination landmark byte of this tranisiton
; end the movement state
	ld a, TRUE
	ld [wLevelSelectionMenuStandingStill], a
; set new landmark
	ld a, [de]
	ld [wLevelSelectionMenuCurrentLandmark], a
	ld [wDefaultLevelSelectionMenuLandmark], a
; make the player sprite face down as the default state
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld a, SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_DOWN
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld a, SPRITE_ANIM_FRAMESET_LEVEL_SELECTION_MENU_WALK_DOWN
	ld [hl], a
; return nc to signal back not to apply a displacement during this frame
	xor a
	ret

INCLUDE "data/levels/level_selection_menu.asm"

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

LevelSelectionMenuAttrmap:
INCLUDE "gfx/level_selection_menu/attrmap.asm"

LevelSelectionMenuDirectionalArrowsGFX:
INCBIN "gfx/level_selection_menu/directional_arrows.2bpp"

LevelSelectionMenuStageTrophiesGFX:
INCBIN "gfx/level_selection_menu/stage_trophies.2bpp"

LevelSelectionMenuTimeOfDaySymbolsGFX:
INCBIN "gfx/level_selection_menu/time_of_day_symbols.2bpp"

LevelSelectionMenuLevelHighlighterGFX:
INCBIN "gfx/level_selection_menu/level_highlighter.2bpp"
