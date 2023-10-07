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
	call ClearMenuAndWindowData
	ld b, CGB_DIPLOMA
	call GetCGBLayout
	call SetPalettes
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
	ld a, [wSaveFileInOverworld]
	and a
	jr z, .not_in_overworld

	ld a, MAPSETUP_CONTINUE
	jr .SpawnToMap

.not_in_overworld
	farcall LevelSelectionMenu
	ret nc ; if pressed B, go back to Game Menu

	farcall ClearSpriteAnims
	call ClearSprites
	ld a, MAPSETUP_ENTERLEVEL
;	jr .SpawnToMap

.SpawnToMap:
	ldh [hMapEntryMethod], a
	ld a, $8
	ld [wMusicFade], a
	ld a, LOW(MUSIC_NONE)
	ld [wMusicFadeID], a
	ld a, HIGH(MUSIC_NONE)
	ld [wMusicFadeID + 1], a
	call ClearBGPalettes
	call ClearTilemap
	ld c, 20
	call DelayFrames
	farcall JumpRoamMons
	xor a
	ld [wDontPlayMapMusicOnReload], a ; play map music
	ld [wLinkMode], a
	ld [wBoardMenuLastCursorPosition], a
	ld hl, wGameTimer
	set GAME_TIMER_COUNTING_F, [hl] ; start game timer counter
	farcall OverworldLoop

; return from overworld loop
	call ClearBGPalettes
	call ClearSprites
	farcall AutoSaveGameOutsideOverworld
	ret

GameMenu_Shop:
	ret
