ClearedLevelScreen:
	xor a
	ldh [hMapAnims], a
	ldh [hSCY], a
	ld a, -$4
	ldh [hSCX], a
	call DisableLCD
	call ClearTilemap
	call ClearBGMap0or2
	call LoadFrame
	call LoadStandardFont
	call ClearMenuAndWindowData
	ld b, CGB_DIPLOMA
	call GetCGBLayout
	call SetPalettes
	call EnableLCD
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
	call ClearLevel
	call UnlockLevels
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

ClearLevel:
	ld a, [wCurSpaceEffect] ; End Space effect byte contains STAGE_*
	call GetClearedLevelsStageAddress
	ld b, SET_FLAG
	ld d, 0
	ld a, [wCurLevel]
	ld e, a
	call FlagAction
	ret

UnlockLevels:
	ld hl, LevelUnlockRequirements
	ld de, wUnlockedLevels - 1
	ld b, 0
.next_byte
	ld c, 8
	inc de
	ld a, [de]
.next_bit
	srl a
	push af
	call nc, .CheckUnlockLevel ; skip if level is already unlocked
	inc b
	ld a, b
	cp NUM_LEVELS
	jr z, .done
; advance hl to next level in LevelUnlockRequirements
.loop
	ld a, [hli]
	inc a ; cp $ff
	jr nz, .loop
	pop af
	dec c
	jr z, .next_byte
	jr .next_bit

.done
	pop af
	ret

; check if the LevelUnlockRequirements[b] at hl for unlocking level b are met.
; return hl pointing to up to the $ff byte of this LevelUnlockRequirements entry.
.CheckUnlockLevel:
	push de
	push bc
	ld a, [hl]
	cp $ff
	jr z, .reqs_met ; jump if no specific reqs to unlock this level
	inc hl
	cp UNLOCK_WHEN_LEVELS_CLEARED
	jr z, .check_levels_cleared_loop
	cp UNLOCK_WHEN_NUMBER_OF_LEVELS_CLEARED
	cp UNLOCK_WHEN_TECHNIQUES_CLEARED

.check_levels_cleared_loop
	ld a, [hli] ; which level
	ld e, a
	inc a ; cp $ff
	jr z, .reqs_met ; jump when no more required levels and all passed so far
	ld a, [hli] ; which stage
	push hl
	call GetClearedLevelsStageAddress
	ld b, CHECK_FLAG
	ld d, 0
	call FlagAction
	pop hl
	jr z, .reqs_not_met ; if this level is not cleared, requirements aren't met
	jr .check_levels_cleared_loop ; otherwise check next level in list

.reqs_met
	pop bc
	pop de
	ret

.reqs_not_met
	pop bc
	pop de
	ret

; return hl = wClearedLevelsStage* given STAGE_ constant in a
GetClearedLevelsStageAddress:
	ld hl, wClearedLevelsStage1
	cp ES1
	ret z
	ld hl, wClearedLevelsStage2
	cp ES2
	ret z
	ld hl, wClearedLevelsStage3
	cp ES3
	ret z
	ld hl, wClearedLevelsStage4
	ret

INCLUDE "data/levels/levels.asm"
