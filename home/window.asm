RefreshScreen::
	call ClearMenuAndWindowData
	ldh a, [hROMBank]
	push af
	ld a, BANK(ReanchorBGMap_NoOAMUpdate) ; aka BANK(LoadFont_NoOAMUpdate)
	rst Bankswitch

	call ReanchorBGMap_NoOAMUpdate
	call HDMATransferTilemapAndAttrmap_Menu
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
	call LoadOverworldTilemapAndAttrmapPals
	call HDMATransferTilemapAndAttrmap_Menu
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

	ld a, TRUE
	ld [wText2bpp], a

	; assumes that the overworld 2bpp font and frame are loaded when calling this
	call ReanchorBGMap_NoOAMUpdate ; anchor bgmap
	call SpeechTextbox2bpp
	call HDMATransferTilemapAndAttrmap_Menu ; transfer bgmap
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

	; note: 1bpp text is NOT compatible with the overworld HUD enabled because it uses 2bpp font tiles.
	ld a, FALSE
	ld [wText2bpp], a

	call ReanchorBGMap_NoOAMUpdate ; anchor bgmap
	call SpeechTextbox1bpp
	call HDMATransferTilemapAndAttrmap_Menu ; transfer bgmap
	call LoadFont_NoOAMUpdate ; load 1bpp font and frame, hide window

	pop af
	rst Bankswitch

	ret

HDMATransferTilemapAndAttrmap_Menu::
	ldh a, [hOAMUpdate]
	push af
	ld a, $1
	ldh [hOAMUpdate], a

	farcall _HDMATransferTilemapAndAttrmap_Menu

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
	ldh a, [hWindowHUDLY]
	and a
	ld a, 1 << rSTAT_INT_HBLANK
	jr z, .ok
	ld a, 1 << rSTAT_INT_LYC
.ok
	ldh [rSTAT], a
	ret
