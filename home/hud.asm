OVERWORLD_HUD_HEIGHT EQU 8

EnableOverworldHUD::
	ld a, HUD_OVERWORLD
	ld [wWhichHUD], a
	ld a, OVERWORLD_HUD_HEIGHT - 1
	; fallthrough

EnableWindowHUD:
	ldh [hWindowHUDLY], a
	; configure LCD interrupt
	ldh [rLYC], a
	; make window hidden this frame to prevent graphical glitches
	ld a, $90
	ldh [hWY], a
	; configure LCD interrupt
	ld a, 1 << rSTAT_INT_LYC ; LYC=LC
	ldh [rSTAT], a
	ret

DisableOverworldHUD::
	xor a
	ld [wWhichHUD], a
	; fallthrough

DisableWindowHUD::
	xor a
	ldh [hWindowHUDLY], a
	; configure LCD interrupt
	xor a
	ldh [rLYC], a
	ld a, 1 << rSTAT_INT_HBLANK ; hblank (default)
	ldh [rSTAT], a
	; leave window in default state (hidden with WY=$90)
	; rLCDC[rLCDC_WINDOW_ENABLE] will be set during next vblank
	ld a, $90
	ldh [hWY], a
	ret

LoadWindowHUD::
; like LoadHUD, but for HUDs that require a Window overlay
	ldh a, [hWindowHUDLY]
	and a
	ret z
	; fallthrough

LoadHUD::
; load the HUD at wWhichHUD to the top of wTilemap and wAttrmap
	ld a, [wWhichHUD]
	and a
	ret z
	farcall _LoadHUD
	ret

ConstructOverworldHUDTilemap::
; draw the overworld HUD's tilemap into wOverworldHUDTiles
	ld hl, .Tilemap
	ld de, wOverworldHUDTiles
	ld bc, .TilemapEnd - .Tilemap ; SCREEN_WIDTH
	call CopyBytes
	ret

.Tilemap:
	db "▶- ▶-   ▶     ▶     "
.TilemapEnd:
	assert .TilemapEnd - .Tilemap == wOverworldHUDTilesEnd - wOverworldHUDTiles

TransferOverworldHUDToBGMap::
; transfer overworld HUD to vBGMap1/vBGMap3 during v/hblank(s)
; tilemap is read from wOverworldHUDTiles, attrmap is all PAL_BG_TEXT | PRIORITY
	ldh a, [rVBK]
	push af

; Tilemap
	ld a, BANK(vBGMap1)
	ldh [rVBK], a
	ld de, vBGMap1
	ld hl, wOverworldHUDTiles

	ld b, 1 << rSTAT_BUSY ; not in v/hblank
	ld c, LOW(rSTAT)

rept SCREEN_WIDTH / 2
; if not in v/hblank, wait until in v/hblank
.loop\@
	ldh a, [c]
	and b
	jr nz, .loop\@
; copy
; we have at least a margin of 16 cycles of Mode2 left
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
endr

; Attrmap
	ld a, BANK(vBGMap3)
	ldh [rVBK], a
	ld hl, vBGMap3

rept SCREEN_WIDTH / 5
; if not in v/hblank, wait until in v/hblank
.loop\@
	ldh a, [c]
	and b
	jr nz, .loop\@
; fill
; we have at least a margin of 16 cycles of Mode2 left
	ld a, PAL_BG_TEXT | PRIORITY
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
endr

	pop af
	ld [rVBK], a
	ret
