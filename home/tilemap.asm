ClearBGPalettes::
	call ClearPalettes
WaitBGMap::
; Tell VBlank to update BG Map
	ld a, 1 ; BG Map 0 tiles
	ldh [hBGMapMode], a
; Wait for it to do its magic
	ld c, 4
	call DelayFrames
	ret

WaitBGMap2::
	ld a, 2
	ldh [hBGMapMode], a
	ld c, 4
	call DelayFrames

	ld a, 1
	ldh [hBGMapMode], a
	ld c, 4
	call DelayFrames
	ret

ApplyTilemap::
	ld a, [wSpriteUpdatesEnabled]
	cp 0
	jr z, .wait_bg_map

	ld a, 1
	ldh [hBGMapMode], a
	jr CopyTilemapAtOnce

.wait_bg_map
; WaitBGMap
	ld a, 1
	ldh [hBGMapMode], a
	ld c, 4
	call DelayFrames
	ret

CopyTilemapAtOnce::
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a

	ldh a, [hMapAnims]
	push af
	xor a
	ldh [hMapAnims], a

	call DelayFrame

	ldh a, [hWindowHUDLY]
	and a
	jr z, .go

	; wait until LCD interrupt has ocurred this frame ([rLY] - [hWindowHUDLY] >= 0)
.wait_lcd
;	ldh a, [hWindowHUDLY]
	ld b, a
	ldh a, [rLY]
	sub b
	jr c, .wait_lcd

.go
	di
	ld a, BANK(vBGMap2)
	ldh [rVBK], a
	hlcoord 0, 0, wAttrmap
	call .CopyBGMapViaStack
	ld a, BANK(vBGMap0)
	ldh [rVBK], a
	hlcoord 0, 0
	call .CopyBGMapViaStack
	ei

	pop af
	ldh [hMapAnims], a
	pop af
	ldh [hBGMapMode], a
	ret

.CopyBGMapViaStack:
; Copy all tiles to vBGMap
	ld [hSPBuffer], sp
	ld sp, hl
	ldh a, [hBGMapAddress + 1]
	ld h, a
	ld l, 0
	ld a, SCREEN_HEIGHT
	ldh [hTilesPerCycle], a
	ld b, 1 << rSTAT_BUSY ; not in v/hblank
	ld c, LOW(rSTAT)

.loop
rept SCREEN_WIDTH / 2
	pop de
; if not in v/hblank, wait until in v/hblank
.loop\@
	ldh a, [c]
	and b
	jr nz, .loop\@
; load vBGMap
	ld [hl], e
	inc l
	ld [hl], d
	inc l
endr

	ld de, BG_MAP_WIDTH - SCREEN_WIDTH
	add hl, de
	ldh a, [hTilesPerCycle]
	dec a
	ldh [hTilesPerCycle], a
	jr nz, .loop

	ldh a, [hSPBuffer]
	ld l, a
	ldh a, [hSPBuffer + 1]
	ld h, a
	ld sp, hl
	ret

SetPalettes::
; Inits the Palettes
; depending on the system the monochromes palettes or color palettes
	ldh a, [hCGB]
	and a
	jr nz, .SetPalettesForGameBoyColor
	ld a, %11100100
	ldh [rBGP], a
	ld a, %11010000
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

.SetPalettesForGameBoyColor:
	push de
	ld a, %11100100
	call DmgToCgbBGPals
	lb de, %11100100, %11100100
	call DmgToCgbObjPals
	pop de
	ret

ClearPalettes::
; Make all palettes white

; CGB: make all the palette colors white
	ldh a, [hCGB]
	and a
	jr nz, .cgb

; DMG: just change palettes to 0 (white)
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

.cgb
	ldh a, [rSVBK]
	push af

	ld a, BANK(wBGPals2)
	ldh [rSVBK], a

; Fill wBGPals2 and wOBPals2 with $ffff (white)
	ld hl, wBGPals2
	ld bc, 16 palettes
	ld a, $ff
	call ByteFill

	pop af
	ldh [rSVBK], a

; Request palette update
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ret

GetMemCGBLayout::
	ld b, CGB_DEFAULT
GetCGBLayout::
	predef_jump LoadCGBLayout

SetHPPal::
; Set palette for hp bar pixel length e at hl.
	call GetHPPal
	ld [hl], d
	ret

GetHPPal::
; Get palette for hp bar pixel length e in d.
	ld d, HP_GREEN
	ld a, e
	cp (HP_BAR_LENGTH_PX * 50 / 100) ; 24
	ret nc
	inc d ; HP_YELLOW
	cp (HP_BAR_LENGTH_PX * 21 / 100) ; 10
	ret nc
	inc d ; HP_RED
	ret
