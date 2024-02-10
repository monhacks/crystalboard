UpdateTimeSensitivePals::
; update time-sensitive palettes if overworld sprite updates are enabled

; sprite updates enabled?
	ld a, [wSpriteUpdatesEnabled]
	cp 0
	ret z

; obj update on?
	ld a, [wStateFlags]
	bit 0, a ; obj update
	ret z

TimeOfDayPals::
	callfar _TimeOfDayPals
	ret

UpdateTimePals::
	callfar _UpdateTimePals
	ret
