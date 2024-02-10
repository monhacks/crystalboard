	; GameMenu.String and GameMenu.Jumptable indexes
	const_def
	const GAMEMENU_WORLD_MAP
	const GAMEMENU_SHOP

GameMenu:
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld de, MUSIC_MAIN_MENU
	call PlayMusic
	; fallthrough

GameMenu_KeepMusic:
	xor a
	ldh [hMapAnims], a
	call ClearTilemap
	call LoadFrame
	call LoadStandardFont
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	call ClearMenuAndWindowData
	ld b, CGB_DIPLOMA
	call GetCGBLayout
	call SetDefaultBGPAndOBP
	xor a
	ld [wWhichIndexSet], a
	ld hl, .MenuHeader
	call LoadMenuHeader
	call GameMenuJoypadLoop
	call CloseWindow
	jr c, .quit
	call ClearTilemap
	ld a, [wMenuSelection]
	ld hl, .Jumptable
	rst JumpTable
	jr GameMenu

.quit
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 16, 7
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 0 ; items
	dw GameMenuItems
	dw PlaceMenuStrings
	dw .Strings

.Strings:
; entries correspond to GAMEMENUITEM_* constants
	db "WORLD MAP@"
	db "SHOP@"

.Jumptable:
; entries correspond to GAMEMENUITEM_* constants
	dw GameMenu_WorldMap
	dw GameMenu_Shop

GameMenuItems:
	db 2
	db GAMEMENU_WORLD_MAP
	db GAMEMENU_SHOP
	db -1

GameMenuJoypadLoop:
	call SetUpMenu
.loop
	ld a, [w2DMenuFlags1]
	set 5, a
	ld [w2DMenuFlags1], a
	call GetScrollingMenuJoypad
	ld a, [wMenuJoypad]
	cp B_BUTTON
	jr z, .b_button
	cp A_BUTTON
	jr z, .a_button
	jr .loop

.a_button
	call PlayClickSFX
	and a
	ret

.b_button
	scf
	ret

GameMenu_WorldMap:
; the following 500ms fading delay applies:
; - from post-level screen to level selection menu
; - from overworld to level selection menu
; - from selecting "WORLD MAP" in game menu to level selection menu (save outside ow)
; - from selecting "WORLD MAP" in game menu to overworld (save in ow)
	ld a, 8
	ld [wMusicFade], a
	ld a, LOW(MUSIC_NONE)
	ld [wMusicFadeID], a
	ld a, HIGH(MUSIC_NONE)
	ld [wMusicFadeID + 1], a
	call ClearBGPalettes
	call ClearTilemap
	ld c, 30 - 8
	call DelayFrames

	ld a, [wSaveFileInOverworld]
	and a
	jr z, .not_in_overworld

	ld a, MAPSETUP_CONTINUE
	jr .SpawnToMap

.not_in_overworld
	farcall LevelSelectionMenu
; dequeue all level selection menu events (which triggered during call above if set).
; game is not saved until player enters a level, so if game is turned off in the middle of
; an event or in the menu, the player will be able to replay the events when they come back.
	ld a, 0
	ld [wLevelSelectionMenuEntryEventQueue], a
	ret nc ; if pressed B, go back to Game Menu

	farcall ClearSpriteAnims
	call ClearSprites
	ld a, MAPSETUP_ENTERLEVEL
;	jr .SpawnToMap

.SpawnToMap:
	ldh [hMapEntryMethod], a
	farcall JumpRoamMons
	xor a
	ld [wDontPlayMapMusicOnReload], a ; play map music
	ld [wLinkMode], a
	ld [wBoardMenuLastCursorPosition], a
	ld hl, wGameTimer
	set GAME_TIMER_COUNTING_F, [hl] ; start game timer counter
	farcall OverworldLoop

; return from overworld loop
	call ClearObjectStructs
	call ClearBGPalettes
	call ClearSprites
; clear unlocked levels
	xor a
	ld [wLastUnlockedLevelsCount], a
	ld a, $ff
	ld [wLastUnlockedLevels], a
; handle overworld exit
	ld a, [wExitOverworldReason]
	cp CLEARED_LEVEL
	jr nz, .save_and_return
; if CLEARED_LEVEL:
; show post-level screen, clear level, unlock levels, request appropriate LSM events
	farcall ClearedLevelScreen
	ld hl, wLevelSelectionMenuEntryEventQueue
	set LSMEVENT_ANIMATE_TIME_OF_DAY, [hl]
	ld a, [wLastUnlockedLevelsCount]
	and a
	jr z, .save_and_return
	set LSMEVENT_SHOW_UNLOCKED_LEVELS, [hl]
.save_and_return
	farcall AutoSaveGameOutsideOverworld
	jp GameMenu_WorldMap

GameMenu_Shop:
	ret
