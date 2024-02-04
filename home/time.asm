Timer::
	reti

InitTime::
	ld hl, wStartDay
	ld [hli], a ; wStartDay
	ld [hli], a ; wStartHour
	ld [hli], a ; wStartMinute
	ld [hl], a ; wStartSecond
	ret

AdvanceTimeOfDay::
	ld hl, .TimeOfDayOrder
	ld a, [wTimeOfDay]
	maskbits NUM_DAYTIMES
.loop
	cp [hl]
	inc hl
	jr z, .gotTimeOfDay
	jr .loop
.gotTimeOfDay
	ld a, [hl]
	ld [wTimeOfDay], a
	cp MORN_F
	ret nz

; advance wCurDay and clear daily timers on a transition from NITE to MORN
	ld a, [wCurDay]
	cp MAX_DAYS
	jr z, .restart_days
	inc a
	jr .set_days
.restart_days
	xor a
.set_days
	ld [wCurDay], a

	farcall ClearDailyTimers

	ret

.TimeOfDayOrder:
	db MORN_F, DAY_F, EVE_F, NITE_F, MORN_F
