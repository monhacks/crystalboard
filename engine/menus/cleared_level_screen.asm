ClearedLevelScreen:
	xor a
	ldh [hMapAnims], a
	ldh [hLCDStatIntRequired], a
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
	call SetDefaultBGPAndOBP
	call EnableLCD
	ld hl, .LevelCleared1Text
	bccoord 3, 1
	call PrintTextboxTextAt
	ld hl, .LevelCleared2Text
	bccoord 3, 3
	call PrintTextboxTextAt
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
	jp UnlockLevels

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
	ld a, [wCurSpaceEffect] ; End Space effect byte contains STAGE_*_F
	ld [wLastClearedLevelStage], a
	call GetClearedLevelsStageAddress
	ld b, CHECK_FLAG
	ld d, 0
	ld a, [wCurLevel]
	ld e, a
	push de
	call FlagAction
	pop de
	jr nz, .already_cleared ; return if this level stage already cleared
	ld b, SET_FLAG
	call FlagAction
	ret
.already_cleared
	ld a, $ff
	ld [wLastClearedLevelStage], a
	ret

UnlockLevels:
	call ComputeLevelsToUnlock
	jp SaveUnlockedLevels

ComputeLevelsToUnlock:
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
	jr z, .done ; done if went through all existing levels
	ld a, [wLastUnlockedLevelsCount]
	cp MAX_UNLOCK_LEVELS_AT_ONCE
	jr nc, .done ; done if reached the capacity of wLastUnlockedLevels
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
	jr z, .check_number_of_levels_cleared
	cp UNLOCK_WHEN_TECHNIQUES_CLEARED
	jr .check_techniques_cleared

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

.check_number_of_levels_cleared
	push hl
	ld hl, wClearedLevelsStage1
	ld b, ((NUM_LEVELS + 7) / 8) * 4
	call CountSetBits
	pop hl
	ld a, [hli]
	cp c
	jr c, .reqs_met
	jr z, .reqs_met
	jr .reqs_not_met

.check_techniques_cleared
	ld bc, 0
.check_techniques_cleared_loop
	ld a, [hli]
	ld e, a
	push hl
	ld hl, wUnlockedTechniques
	add hl, bc
	and [hl]
	cp e
	pop hl
	jr nz, .reqs_not_met
	inc c
	ld a, c
	cp (NUM_TECHNIQUES + 7) / 8
	jr nc, .reqs_met
	jr .check_techniques_cleared_loop

.reqs_met
; add level to wLastUnlockedLevels
	pop bc ; b = which level
	push hl
	ld a, [wLastUnlockedLevelsCount]
	ld e, a
	ld d, 0
	ld hl, wLastUnlockedLevels
	add hl, de
	ld [hl], b
	inc hl
	ld [hl], $ff
	inc a
	ld [wLastUnlockedLevelsCount], a
	pop hl
	pop de
	ret

.reqs_not_met
	pop bc
	pop de
	ret

SaveUnlockedLevels:
	ld hl, wLastUnlockedLevels
.loop
	ld a, [hli]
	ld e, a
	inc a ; cp $ff
	ret z
	push hl
	ld b, SET_FLAG
	call UnlockedLevelsFlagAction
	pop hl
	jr .loop

INCLUDE "data/levels/levels.asm"
