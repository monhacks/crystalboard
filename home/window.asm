RefreshScreen::
	call ClearMenuAndWindowData
	ldh a, [hROMBank]
	push af
	ld a, BANK(ReanchorBGMap_NoOAMUpdate) ; aka BANK(LoadFont_NoOAMUpdate)
	rst Bankswitch

	call ReanchorBGMap_NoOAMUpdate
	call _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap
	call HideWindow_EnableLCDInt

	pop af
	rst Bankswitch
	ret

CloseText::
	ldh a, [hOAMUpdate]
	push af
	ld a, $1
	ldh [hOAMUpdate], a

	call ClearMenuAndWindowData
	xor a
	ldh [hBGMapMode], a
	call OverworldTextModeSwitch
	call _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap
	xor a
	ldh [hBGMapMode], a
	call SafeUpdateSprites
	ld a, $90
	ldh [hWY], a
	call UpdatePlayerSprite
	xor a
	ldh [hBGMapMode], a

	pop af
	ldh [hOAMUpdate], a
	ld hl, wVramState
	res 6, [hl]
	ret

OpenText2bpp::
	call ClearMenuAndWindowData
	ldh a, [hROMBank]
	push af
	ld a, BANK(ReanchorBGMap_NoOAMUpdate)
	rst Bankswitch

; assumes that the overworld 2bpp font and frame are loaded when calling this
	call ReanchorBGMap_NoOAMUpdate ; clear bgmap
	call SpeechTextbox2bpp
	call _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap ; anchor bgmap
	call HideWindow_EnableLCDInt

	pop af
	rst Bankswitch

	ret

OpenText1bpp::
	call ClearMenuAndWindowData
	ldh a, [hROMBank]
	push af
	ld a, BANK(ReanchorBGMap_NoOAMUpdate) ; aka BANK(LoadFont_NoOAMUpdate)
	rst Bankswitch

	call ReanchorBGMap_NoOAMUpdate ; clear bgmap
	call SpeechTextbox1bpp
	call _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap ; anchor bgmap
	call LoadFont_NoOAMUpdate ; load 1bpp font and frame, hide window

	pop af
	rst Bankswitch

	ret

_OpenAndCloseMenu_HDMATransferTilemapAndAttrmap::
	ldh a, [hOAMUpdate]
	push af
	ld a, $1
	ldh [hOAMUpdate], a

	farcall OpenAndCloseMenu_HDMATransferTilemapAndAttrmap

	pop af
	ldh [hOAMUpdate], a
	ret

SafeUpdateSprites::
	ldh a, [hOAMUpdate]
	push af
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a
	ld a, $1
	ldh [hOAMUpdate], a

	call UpdateSprites

	xor a
	ldh [hOAMUpdate], a
	call DelayFrame
	pop af
	ldh [hBGMapMode], a
	pop af
	ldh [hOAMUpdate], a
	ret

HideWindow_EnableLCDInt::
	ld a, $90
	ldh [hWY], a
	ldh a, [hWindowHUD]
	and a
	ld a, 1 << rSTAT_INT_HBLANK
	jr z, .ok
	ld a, 1 << rSTAT_INT_LYC
.ok
	ldh [rSTAT], a
	ret

OVERWORLD_HUD_HEIGHT EQU 8

EnableOverworldWindowHUD::
	ld a, OVERWORLD_HUD_HEIGHT - 1
	; fallthrough

EnableWindowHUD:
	ldh [hWindowHUD], a
	; configure LCD interrupt
	ldh [rLYC], a
	; make window hidden this frame to prevent graphical glitches
	ld a, $90
	ldh [hWY], a
	; configure LCD interrupt
	ld a, 1 << rSTAT_INT_LYC ; LYC=LC
	ldh [rSTAT], a
	ret

DisableWindowHUD::
	xor a
	ldh [hWindowHUD], a
	; configure LCD interrupt
	xor a
	ldh [rLYC], a
	ld a, 1 << rSTAT_INT_HBLANK ; hblank (default)
	ldh [rSTAT], a
	; leave window in default state (enabled and hidden)
	ld a, $90
	ldh [hWY], a
	ldh a, [rLCDC]
	set rLCDC_WINDOW_ENABLE, a
	ldh [rLCDC], a
	ret
