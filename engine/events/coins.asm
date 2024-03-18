GiveCoins::
	ld a, 3
	call AddCoins
	call LoadMaxCoins_bc
	ld a, 3
	call CompareCoins
	jr z, .not_maxed_out
	jr c, .not_maxed_out
	call LoadMaxCoins_hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	scf
	ret

.not_maxed_out
	and a
	ret

LoadMaxCoins_bc:
	ld a, d
	cp HIGH(wCurLevelCoins)
	ld bc, MaxCurLevelCoins ; CUR_LEVEL_COINS
	ret z
	ld bc, MaxCoins ; YOUR_COINS
	ret

LoadMaxCoins_hl:
	call LoadMaxCoins_bc
	ld h, b
	ld l, c
	ret

MaxCoins:
	dt MAX_COINS

MaxCurLevelCoins:
	dt MAX_LEVEL_COINS

TakeCoins::
	ld a, 3
	call SubtractCoins
	jr nc, .okay
	; leave with 0 coins
	xor a
	ld [de], a
	inc de
	ld [de], a
	inc de
	ld [de], a
	scf
	ret

.okay
	and a
	ret

CompareCoins::
	ld a, 3
CompareFunds:
; a: number of bytes
; bc: start addr of amount (big-endian)
; de: start addr of account (big-endian)
	push hl
	push de
	push bc
	ld h, b
	ld l, c
	ld c, 0
	ld b, a
.loop1
	dec a
	jr z, .done
	inc de
	inc hl
	jr .loop1

.done
	and a
.loop2
	ld a, [de]
	sbc [hl]
	jr z, .okay
	inc c

.okay
	dec de
	dec hl
	dec b
	jr nz, .loop2
	jr c, .set_carry
	ld a, c
	and a
	jr .skip_carry

.set_carry
	ld a, 1
	and a
	scf
.skip_carry
	pop bc
	pop de
	pop hl
	ret

SubtractCoins:
	ld a, 3
SubtractFunds:
; a: number of bytes
; bc: start addr of amount (big-endian)
; de: start addr of account (big-endian)
	push hl
	push de
	push bc
	ld h, b
	ld l, c
	ld b, a
	ld c, 0
.loop
	dec a
	jr z, .done
	inc de
	inc hl
	jr .loop

.done
	and a
.loop2
	ld a, [de]
	sbc [hl]
	ld [de], a
	dec de
	dec hl
	dec b
	jr nz, .loop2
	pop bc
	pop de
	pop hl
	ret

AddCoins:
	ld a, 3
AddFunds:
; a: number of bytes
; bc: start addr of amount (big-endian)
; de: start addr of account (big-endian)
	push hl
	push de
	push bc

	ld h, b
	ld l, c
	ld b, a
.loop1
	dec a
	jr z, .done
	inc de
	inc hl
	jr .loop1

.done
	and a
.loop2
	ld a, [de]
	adc [hl]
	ld [de], a
	dec de
	dec hl
	dec b
	jr nz, .loop2

	pop bc
	pop de
	pop hl
	ret

GiveChips::
	ld a, 2
	ld de, wChips
	call AddFunds
	ld a, 2
	ld bc, .maxchips
	call CompareFunds
	jr c, .not_maxed
	ld hl, .maxchips
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	scf
	ret

.not_maxed
	and a
	ret

.maxchips
	bigdw MAX_CHIPS

TakeChips::
	ld a, 2
	ld de, wChips
	call SubtractFunds
	jr nc, .okay
	; leave with 0 chips
	xor a
	ld [de], a
	inc de
	ld [de], a
	scf
	ret

.okay
	and a
	ret

CheckChips::
	ld a, 2
	ld de, wChips
	jp CompareFunds
