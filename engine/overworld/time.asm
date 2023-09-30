ClearDailyTimers::
	xor a
	ld [wLuckyNumberDayTimer], a
	ld [wDailyResetTimer], a
	ret

InitCallReceiveDelay::
	xor a
	ld [wTimeCyclesSinceLastCall], a

NextCallReceiveDelay:
	ld a, [wTimeCyclesSinceLastCall]
	cp 3
	jr c, .okay
	ld a, 3

.okay
	ld e, a
	ld d, 0
	ld hl, .ReceiveCallDelays
	add hl, de
	ld a, [hl]
if DEF(_DEBUG)
	ld h, a
	ld a, BANK(sDebugTimeCyclesSinceLastCall)
	call OpenSRAM
	ld a, [sDebugTimeCyclesSinceLastCall]
	call CloseSRAM
	dec a
	cp 2
	jr nc, .debug_ok
	xor 1
	ld h, a
.debug_ok
	ld a, h
endc
	jp RestartReceiveCallDelay

.ReceiveCallDelays:
	db 20, 10, 5, 3

CheckReceiveCallTimer:
	call CheckReceiveCallDelay ; check timer
	ret nc
	ld hl, wTimeCyclesSinceLastCall
	ld a, [hl]
	cp 3
	jr nc, .ok
	inc [hl]

.ok
	call NextCallReceiveDelay ; restart timer
	scf
	ret

InitOneDayCountdown:
	ld a, 1

InitNDaysCountdown:
	ld [hl], a
	inc hl ; wLuckyNumberDayTimer + 1 or wDailyResetTimer + 1 (both are dw)
	ld a, [wCurDay]
	ld [hl], a
	ret

CheckDayDependentEventHL:
	inc hl
	push hl
	call CalcDaysSince
	call GetDaysSince
	pop hl
	dec hl
	call UpdateTimeRemaining
	ret

RestartReceiveCallDelay:
	ld hl, wReceiveCallDelay_MinsRemaining
	ld [hl], a
	ld hl, wReceiveCallDelay_StartTime
	call CopyHourMinToHL
	ret

CheckReceiveCallDelay:
	ld hl, wReceiveCallDelay_StartTime
	call CalcMinsHoursSince
	call GetMinutesSinceIfLessThan60
	ld hl, wReceiveCallDelay_MinsRemaining
	call UpdateTimeRemaining
	ret

RestartDailyResetTimer:
	ld hl, wDailyResetTimer
	jp InitOneDayCountdown

CheckDailyResetTimer::
	ld hl, wDailyResetTimer
	call CheckDayDependentEventHL
	ret nc
	xor a
	ld hl, wDailyFlags1
	ld [hli], a ; wDailyFlags1
	ld [hli], a ; wDailyFlags2
	ld [hli], a ; wSwarmFlags
	ld [hl], a  ; wSwarmFlags + 1
	jr RestartDailyResetTimer

StartBugContestTimer:
	ld a, BUG_CONTEST_MINUTES
	ld [wBugContestMinsRemaining], a
	ld a, BUG_CONTEST_SECONDS
	ld [wBugContestSecsRemaining], a
	ld hl, wBugContestStartTime
	call CopyHourMinSecToHL
	ret

CheckBugContestTimer::
	ld hl, wBugContestStartTime
	call CalcSecsMinsHoursSince
	ld a, [wHoursSince]
	and a
	jr nz, .timed_out
	ld a, [wSecondsSince]
	ld b, a
	ld a, [wBugContestSecsRemaining]
	sub b
	jr nc, .okay
	add 60

.okay
	ld [wBugContestSecsRemaining], a
	ld a, [wMinutesSince]
	ld b, a
	ld a, [wBugContestMinsRemaining]
	sbc b
	ld [wBugContestMinsRemaining], a
	jr c, .timed_out
	and a
	ret

.timed_out
	xor a
	ld [wBugContestMinsRemaining], a
	ld [wBugContestSecsRemaining], a
	scf
	ret

CheckPokerusTick::
	ld hl, .Day0
	call CalcDaysSince
	call GetDaysSince
	and a
	jr z, .done ; not even a day has passed since game start
	ld b, a
	farcall ApplyPokerusTick
.done
	xor a
	ret

.Day0:
	db 0

RestartLuckyNumberCountdown:
	call .GetDaysUntilNextFriday
	ld hl, wLuckyNumberDayTimer
	jp InitNDaysCountdown

.GetDaysUntilNextFriday:
	call GetWeekday
	ld c, a
	ld a, FRIDAY
	sub c
	jr z, .friday_saturday
	jr nc, .earlier ; could have done "ret nc"

.friday_saturday
	add 7

.earlier
	ret

_CheckLuckyNumberShowFlag:
	ld hl, wLuckyNumberDayTimer
	jp CheckDayDependentEventHL

UpdateTimeRemaining:
; If the amount of time elapsed exceeds the capacity of its
; unit, skip this part.
	cp -1
	jr z, .set_carry
	ld c, a
	ld a, [hl] ; time remaining
	sub c
	jr nc, .ok
	xor a

.ok
	ld [hl], a
	jr z, .set_carry
	xor a
	ret

.set_carry
	xor a
	ld [hl], a
	scf
	ret

GetSecondsSinceIfLessThan60: ; unreferenced
	ld a, [wHoursSince]
	and a
	jr nz, GetTimeElapsed_ExceedsUnitLimit
	ld a, [wMinutesSince]
	jr nz, GetTimeElapsed_ExceedsUnitLimit
	ld a, [wSecondsSince]
	ret

GetMinutesSinceIfLessThan60:
	ld a, [wHoursSince]
	and a
	jr nz, GetTimeElapsed_ExceedsUnitLimit
	ld a, [wMinutesSince]
	ret

GetHoursSinceIfLessThan24: ; unreferenced
	ld a, [wHoursSince]
	ret

GetDaysSince:
	ld a, [wDaysSince]
	ret

GetTimeElapsed_ExceedsUnitLimit:
	ld a, -1
	ret

CalcDaysSince:
	xor a
	jr _CalcDaysSince

CalcHoursSince: ; unreferenced
	xor a
	jr _CalcHoursSince

CalcMinsHoursSince:
	inc hl
	xor a
	jr _CalcMinsHoursSince

CalcSecsMinsHoursSince:
	inc hl
	inc hl
	ld a, [wGameTimeSeconds]
	ld c, a
	sub [hl]
	jr nc, .skip
	add 60
.skip
	ld [hl], c ; current seconds
	dec hl
	ld [wSecondsSince], a ; seconds since

_CalcMinsHoursSince:
	ld a, [wGameTimeMinutes]
	ld c, a
	sbc [hl]
	jr nc, .skip
	add 60
.skip
	ld [hl], c ; current minutes
	dec hl
	ld [wMinutesSince], a ; minutes since

_CalcHoursSince:
; assumes differentials below 256 hours
	ld a, [wGameTimeHours + 1]
	ld c, a
	sub [hl]
	ld [hl], c ; current hours
	ld [wHoursSince], a ; hours since
	ret

_CalcDaysSince:
	ld a, [wCurDay]
	ld c, a
	sbc [hl]
	jr nc, .skip
	add MAX_DAYS
.skip
	ld [hl], c ; current days
	ld [wDaysSince], a ; days since
	ret

CopyHourMinSecToHL:
	ld a, [wGameTimeHours + 1]
	ld [hli], a
	ld a, [wGameTimeMinutes]
	ld [hli], a
	ld a, [wGameTimeSeconds]
	ld [hli], a
	ret

CopyHourMinToHL:
	ld a, [wGameTimeHours + 1]
	ld [hli], a
	ld a, [wGameTimeMinutes]
	ld [hli], a
	ret
