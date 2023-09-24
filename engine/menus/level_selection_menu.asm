LevelSelectionMenu::
	xor a
	ldh [hInMenu], a
	ld a, 1 << 2 ; do not clear wShadowOAM during DoNextFrameForAllSprites
	ld [wVramState], a
	ld a, -1
	ld [wUnlockedLevels], a ; debug

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
	call LevelSelectionMenu_InitAttrmap
	call WaitBGMap2
	xor a
	ldh [hBGMapMode], a
	ld b, CGB_LEVEL_SELECTION_MENU
	call GetCGBLayout ; apply and commit pals
	call SetPalettes

	ld de, MUSIC_GAME_CORNER
	call PlayMusic
	call DelayFrame ; wait for pal update

	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_InitPlayerSprite
	call LevelSelectionMenu_InitLandmark
	call LevelSelectionMenu_DrawDirectionalArrows

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
; make hl point to the beginning of the transition data for the chosen direction at c
	ld e, c ; also copy direction to e for later
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

; begin transition
	call LevelSelectionMenu_Delay10Frames
	xor a ; FALSE
	ld [wLevelSelectionMenuStandingStill], a
	ld a, 1 << 7 ; "first step of movement" flag
	ld [wLevelSelectionMenuMovementStepsLeft], a
	call LevelSelectionMenu_SetAnimSeqAndFrameset
	call LevelSelectionMenu_ClearNonPlayerSpriteOAM

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
	call LevelSelectionMenu_DrawDirectionalArrows
	jr .main_loop

.enter_level
	call LevelSelectionMenu_Delay10Frames
	ld de, SFX_WARP_TO
	call PlaySFX
	call LevelSelectionMenu_Delay10Frames
	call .EnterLevelFadeOut
	ld a, $8
	ld [wMusicFade], a
	ld a, LOW(MUSIC_NONE)
	ld [wMusicFadeID], a
	ld a, HIGH(MUSIC_NONE)
	ld [wMusicFadeID + 1], a
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	xor a
	ld [wVramState], a
	ld c, 20
	call DelayFrames

	ld a, [wLevelSelectionMenuCurrentLandmark]
	call LevelSelectionMenu_GetLandmarkSpawnPoint
	ld [wDefaultSpawnpoint], a
	ld a, MAPSETUP_ENTERLEVEL
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
	ld b, RGBFADE_TO_WHITE_6BGP_2OBP
	jp DoRGBFadeEffect

.exit
	call LevelSelectionMenu_Delay10Frames
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	xor a
	ld [wVramState], a
	ret

LevelSelectionMenu_LoadGFX:
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
	ld bc, 4 tiles
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

LevelSelectionMenu_InitPlayerSprite:
; initialize the anim struct of the player's sprite.
; because ClearSpriteAnims was called before, it's always loaded to wSpriteAnim1
	push af
	depixel 0, 0
; all the SPRITE_ANIM_* related to the level selection menu are sorted by direction, then by gender
	ld b, SPRITE_ANIM_OBJ_LEVEL_SELECTION_MENU_MALE_WALK_DOWN
	ld a, [wPlayerGender]
	add b
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $00
	pop af
	ld e, a
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

LevelSelectionMenu_DrawDirectionalArrows:
; Draw directional arrows OAM around player sprite for the valid directions.
; Objects are drawn in OAM after player sprite objects in wWalkingDirection order.
; Depends on wLevelSelectionMenuLandmarkTransitionsPointer being initialized.
	call LevelSelectionMenu_GetValidDirections
	ld hl, .OAM
	ld de, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH ; always goes after player sprite
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
	gender_to_pal
	ld [de], a ; attr (use the same pal as player sprite)
	inc de
	ret

.OAM:
; y offset against wSpriteAnim1YCoord, x offset against wSpriteAnim1XCoord, tile id
; tiles have been loaded to vTiles0 after the player sprites
	db   8,  -4, 24 + DOWN
	db -16,  -4, 24 + UP
	db  -4, -16, 24 + LEFT
	db  -4,   8, 24 + RIGHT

LevelSelectionMenu_ClearNonPlayerSpriteOAM:
	ld hl, wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH
	ld bc, wShadowOAMEnd - (wShadowOAM + $4 * SPRITEOAMSTRUCT_LENGTH)
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
	ld a, [wPlayerGender]
	ld d, a
	ld a, SPRITE_ANIM_FRAMESET_LEVEL_SELECTION_MENU_MALE_WALK_DOWN
	add e
	add e ; add direction
	add d ; add gender
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
; =------------------=
; =========DD=========
; =========DD=========
; ====================
; for movements spanning two pages, when one edge is reached, the page change occurs
; and the player appears in the other page at the coordinate of the new edge.
; hence, for calculating movement length, it's as if both pages were adjacent without the border frame.
DEF PAGE_EDGE_DOWN  EQU $90
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
	call LevelSelectionMenu_InitTilemap
	call LevelSelectionMenu_InitAttrmap
	call WaitBGMap2
	xor a
	ldh [hBGMapMode], a
	call .PageChangeFadeIn
; adjust steps left for the "duplicate" movement of the player leaving and entering a page
	ld hl, wLevelSelectionMenuMovementStepsLeft
	ld a, [hl]
	add 2 * TILE_WIDTH
	ld [hl], a
	ret

.PageChangeFadeOut:
	ld b, RGBFADE_TO_BLACK_6BGP
	jp DoRGBFadeEffect

.PageChangeFadeIn:
	ld b, RGBFADE_TO_LIGHTER_6BGP
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
; make the player sprite face down as the default state
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld a, SPRITE_ANIM_FUNC_LEVEL_SELECTION_MENU_WALK_DOWN
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld a, [wPlayerGender]
	ld d, a
	ld a, SPRITE_ANIM_FRAMESET_LEVEL_SELECTION_MENU_MALE_WALK_DOWN
	add d
	ld [hl], a
; return nc to signal back not to apply a displacement during this frame
	xor a
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

LevelSelectionMenuAttrmap:
INCLUDE "gfx/level_selection_menu/attrmap.asm"

LevelSelectionMenuDirectionalArrowsGFX:
INCBIN "gfx/level_selection_menu/directional_arrows.2bpp"
