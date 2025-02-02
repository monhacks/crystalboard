BillsGrandfather:
	farcall SelectMonFromParty
	jr c, .cancel
	ld a, [wCurPartySpecies]
	ldh [hScriptVar], a
	ld [wNamedObjectIndex], a
	call GetPokemonName
	jp CopyPokemonName_Buffer1_Buffer3

.cancel
	xor a
	ldh [hScriptVar], a
	ret

OlderHaircutBrother:
	ld hl, HappinessData_OlderHaircutBrother
	jr HaircutOrGrooming

YoungerHaircutBrother:
	ld hl, HappinessData_YoungerHaircutBrother
	jr HaircutOrGrooming

DaisysGrooming:
	ld hl, HappinessData_DaisysGrooming
	; fallthrough

HaircutOrGrooming:
	push hl
	farcall SelectMonFromParty
	pop hl
	jr c, .nope
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	push hl
	call GetCurNickname
	call CopyPokemonName_Buffer1_Buffer3
	pop hl
	call Random
.loop
	sub [hl]
	jr c, .ok
	inc hl
	inc hl
	inc hl
	jr .loop

.ok
	inc hl
	ld a, [hli]
	ldh [hScriptVar], a
	ld c, [hl]
	call ChangeHappiness
	ret

.nope
	xor a
	ldh [hScriptVar], a
	ret

.egg
	ld a, 1
	ldh [hScriptVar], a
	ret

INCLUDE "data/events/happiness_probabilities.asm"

CopyPokemonName_Buffer1_Buffer3:
	ld hl, wStringBuffer1
	ld de, wStringBuffer3
	ld bc, MON_NAME_LENGTH
	jp CopyBytes

DummyPredef1:
	ret
