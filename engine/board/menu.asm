BoardMenuScript::
	opentext
.display_menu
	callasm BoardMenu
	ifequal BOARDMENUITEM_DIE,      .Die
	ifequal BOARDMENUITEM_PARTY,    .Party
	ifequal BOARDMENUITEM_PACK,     .Pack
	ifequal BOARDMENUITEM_POKEGEAR, .Pokegear
	ifequal BOARDMENUITEM_EXIT,     .Exit
	closetext
	end

.Die:
	callasm BoardMenu_Die
	iffalse BoardMenuScript
	callasm BoardMenu_BreakDieAnimation
	end

.Party:
	callasm BoardMenu_Party
	scall .SubmenuCallback
	sjump .display_menu

.Pack:
	callasm BoardMenu_Pack
	scall .SubmenuCallback
	sjump .display_menu

.Pokegear:
	callasm BoardMenu_Pokegear
	scall .SubmenuCallback
	sjump .display_menu

.Exit:
	writetext .EmptyText
	callasm RestoreOverworldFontOverBoardMenuGFX
	writetext .ConfirmExitText
	yesorno
	iftrue .exit
	writetext .EmptyText
	sjump .display_menu

.exit:
	exitoverworld $00

.ConfirmExitText:
	text "Abandon level and"
	line "return to menu?"
	done

.EmptyText:
	text ""
	done

.SubmenuCallback:
; if submenu has requested a callback through hMenuReturn,
; it has also taken care of queuing it into wQueuedScriptBank/wQueuedScriptAddr.
	readmem hMenuReturn
	ifequal HMENURETURN_SCRIPT, .CallbackScript
	ifequal HMENURETURN_ASM, .CallbackAsm
	end

.CallbackScript:
	memjump wQueuedScriptBank

.CallbackAsm:
	memcallasm wQueuedScriptBank
	end

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
	call DrawBoardMenuTilesAndClearPriorityAttr
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

DrawBoardMenuTilesAndClearPriorityAttr:
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY
	ld a, BOARD_MENU_BG_FIRST_TILE
	lb bc, 3, 18
	call FillBoxWithConsecutiveBytes
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY, wAttrmap
	ld a, PAL_BG_TEXT
	lb bc, 3, 18
	jp FillBoxWithByte

ApplyBoardMenuSpritePalette:
	ld hl, BoardMenuItemPals
	ld a, [wBoardMenuCursorPosition]
	ld bc, PALETTE_SIZE
	call AddNTimes
; write to wOBPals2 directly as well to avoid calling ApplyPals and overwriting other overworld pals
; writing to wOBPals1 is still necessary to make fading animations consistent
	ld de, wOBPals1 palette PAL_OW_MISC
	ld bc, PALETTE_SIZE
	ld a, BANK(wOBPals1)
	call FarCopyWRAM
	ld hl, wOBPals1 palette PAL_OW_MISC
	ld de, wOBPals2 palette PAL_OW_MISC
	ld bc, PALETTE_SIZE
	ld a, BANK(wOBPals1)
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

BoardMenu_Die:
DIE_MAX_NUMBER EQU 6
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_DIE_ROLL_F, [hl]
	ld a, 1
	ld [wDieRoll], a
	call HDMATransferTilemapAndAttrmap_OpenAndCloseMenu ;
	call CloseText	                                    ; closetext

.rotate_die_loop
	call IsSFXPlaying
	ld de, SFX_KINESIS
	call c, PlaySFX
	call Random
.sample_die_loop
	sub DIE_MAX_NUMBER
	jr nc, .sample_die_loop
	add DIE_MAX_NUMBER
	add $1
	ld [wDieRoll], a
	farcall _UpdateSecondarySprites
	call GetJoypad
	ldh a, [hJoyPressed]
	bit B_BUTTON_F, a
	jr nz, .back_to_menu
	bit A_BUTTON_F, a
	jr nz, .confirm_roll
	call DelayFrame
	jr .rotate_die_loop

.back_to_menu
	call PlayClickSFX
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_DIE_ROLL_F, [hl]
	xor a ; FALSE
	ld [wScriptVar], a
	ret

.confirm_roll
	call UpdateSprites
	ld a, TRUE
	ld [wScriptVar], a
	ret

BoardMenu_BreakDieAnimation:
	farcall LoadBoardMenuDieNumbersGFX
	ld a, [wDieRoll]
	dec a
	add a
	ld c, a
	ld a, SPRITE_ANIM_DICT_BOARD_MENU
	ld hl, wSpriteAnimDict ; wSpriteAnimDict[0]
	ld [hli], a
	ld a, DIE_ROLL_OAM_FIRST_TILE
	add c
	ld [hli], a
	xor a ; SPRITE_ANIM_DICT_DEFAULT
	ld [hli], a ; wSpriteAnimDict[1]
	ld a, DIE_NUMBERS_OAM_FIRST_TILE
	add c
	ld [hl], a

; initialize break die animation
	depixel 8, 10, 0, 0
	ld a, SPRITE_ANIM_OBJ_BOARD_MENU_BREAK_DIE
	call InitSpriteAnimStruct

; initialize appear die number animation, but only if there is enough
; OAM space without pushing aside some NPC (aesthetic failsafe).
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (4 * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .anims_initialized
	depixel 8, 10, 0, 0
	ld a, SPRITE_ANIM_OBJ_BOARD_MENU_APPEAR_DIE_NUMBER
	call InitSpriteAnimStruct

.anims_initialized
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_DIE_ROLL_F, [hl]

	ld hl, wVramState
	set 2, [hl] ; do not clear wShadowOAM during DoNextFrameForAllSprites
; animation plays above NPCs so draw the graphics at the beginning of OAM.
; begin placing NPC sprites in OAM after all objects allocated to animations.
	ld a, [wSpriteAnim2Index]
	and a
	ld a, $8 * SPRITEOAMSTRUCT_LENGTH ; with SPRITE_ANIM_OBJ_BOARD_MENU_APPEAR_DIE_NUMBER
	jr nz, .go
	ld a, $4 * SPRITEOAMSTRUCT_LENGTH ; w/o SPRITE_ANIM_OBJ_BOARD_MENU_APPEAR_DIE_NUMBER
.go
	ldh [hUsedSpriteIndex], a
	farcall _UpdateSpritesAfterOffset

	ld de, SFX_STRENGTH
	call PlaySFX

; play break die and appear die number animations
	ld a, 61 ; total duration of SPRITE_ANIM_FRAMESET_BOARD_MENU_BREAK_DIE.
	         ; the total duration is the sum of all durations in the frameset
	         ; plus one for each oam* entry in the frameset.
	ld [wFrameCounter], a
.loop1
	farcall PlaySpriteAnimationsAndDelayFrame
	ld hl, wFrameCounter
	ld a, [hl]
	and a
	jr z, .next
	dec [hl]
	jr .loop1

.next
; initialize move die number animation
	depixel 8, 10, 0, 0
	ld a, SPRITE_ANIM_OBJ_BOARD_MENU_MOVE_DIE_NUMBER
	call InitSpriteAnimStruct

	ld a, $4 * SPRITEOAMSTRUCT_LENGTH
	ldh [hUsedSpriteIndex], a
	farcall _UpdateSpritesAfterOffset

; play move die number animation
	ld a, 41 ; total duration of SPRITE_ANIM_FRAMESET_BOARD_MENU_MOVE_DIE_NUMBER
	ld [wFrameCounter], a
.loop2
	farcall PlaySpriteAnimationsAndDelayFrame
	ld hl, wFrameCounter
	ld a, [hl]
	and a
	jr z, .done
	dec [hl]
	jr .loop2

.done
	ld hl, wVramState
	res 2, [hl]
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_SPACES_LEFT_F, [hl]
	ld a, [wDieRoll]
	ld [wSpacesLeft], a
	call UpdateSprites
	ret

BoardMenu_Party:
	ld a, [wPartyCount]
	and a
	ret z

	call BoardMenu_OpenSubmenu
	farcall Party
	jr nc, .quit

.return
; if cancelled or pressed B
	call BoardMenu_CloseSubmenu
	ret

.quit
; if quitted party menu after using field move
	call BoardMenu_CloseSubmenu
	ld a, HMENURETURN_SCRIPT
	ldh [hMenuReturn], a
	ret

BoardMenu_Pack:
	call BoardMenu_OpenSubmenu
	farcall Pack
	call BoardMenu_CloseSubmenu
	ld a, [wPackUsedItem]
	and a
	ret z
	ld a, HMENURETURN_SCRIPT
	ldh [hMenuReturn], a
	ret

BoardMenu_Pokegear:
	call BoardMenu_OpenSubmenu
	farcall PokeGear
	jp BoardMenu_CloseSubmenu

BoardMenu_OpenSubmenu:
	xor a
	ldh [hMenuReturn], a
	ldh [hBGMapMode], a
	call LoadStandardMenuHeader
	farcall FadeOutPalettesToWhite
	call DisableOverworldHUD
	ld hl, wTextboxFlags
	res TEXT_2BPP_F, [hl]
	call LoadStandardFont
	call LoadFrame
	call ClearSprites
	call DisableSpriteUpdates
	ret

BoardMenu_CloseSubmenu:
	call ClearBGPalettes
	ld hl, wTextboxFlags
	set TEXT_2BPP_F, [hl]
	call EnableOverworldHUD
	call ReloadTilesetAndPalettes
	call UpdateSprites
	call ExitMenu
	call ClearTextbox
	ld b, CGB_MAPPALS
	call GetCGBLayout
	call WaitBGMap2
	farcall FadeInPalettesFromWhite
	call EnableSpriteUpdates
	ret

BoardMenuItemPals:
INCLUDE "gfx/board/menu.pal"
