ClearedLevelScreen:
	xor a
	ldh [hMapAnims], a
	ldh [hSCY], a
	ld a, -$4
	ldh [hSCX], a
	call ClearTilemap
	call LoadFrame
	call LoadStandardFont
	call ClearMenuAndWindowData
	ld b, CGB_DIPLOMA
	call GetCGBLayout
	call SetPalettes
	ld hl, .LevelCleared1Text
	bccoord 3, 1
	call PrintHLTextAtBC
	ld hl, .LevelCleared2Text
	bccoord 3, 3
	call PrintHLTextAtBC
.loop
	call DelayFrame
	call GetJoypad
	ldh a, [hJoyPressed]
	bit A_BUTTON_F, a
	jr nz, .exit
	bit B_BUTTON_F, a
	jr z, .loop
.exit
	call AddLevelCoinsToBalance
	ld c, 30
	jp DelayFrames

.LevelCleared1Text:
	text "  L E V E L"
	done

.LevelCleared2Text:
	text "C L E A R E D"
	done

AddLevelCoinsToBalance:
; givecoins YOUR_COINS, COINS_FROM_RAM | wCurLevelCoins
	ld de, wCoins ; YOUR_COINS
	ld hl, wCurLevelCoins
	ld bc, hCoinsTemp
	push bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a
	pop bc
	farcall GiveCoins
	ret