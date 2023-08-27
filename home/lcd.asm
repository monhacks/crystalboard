; LCD handling

LCD::
	push af

; hLCDCPointer is used in battle transition, battle anims, and movies (crystal intro, credits, etc.)
; uses rSTAT_INT_HBLANK and doesn't overlap with hWindowHUD.
	ldh a, [hLCDCPointer]
	and a
	jr z, .next

; At this point it's assumed we're in BANK(wLYOverrides)!
	push bc
	ldh a, [rLY]
	ld c, a
	ld b, HIGH(wLYOverrides)
	ld a, [bc]
	ld b, a
	ldh a, [hLCDCPointer]
	ld c, a
	ld a, b
	ldh [c], a
	pop bc

.next
; hWindowHUD uses rSTAT_INT_LYC
	ldh a, [hWindowHUD]
	and a
	jr z, .done

; disable window for the remainder of the frame
.wait_hblank
	ldh a, [rSTAT]
	and rSTAT_STATUS_FLAGS
	jr nz, .wait_hblank
	ldh a, [rLCDC]
	res rLCDC_WINDOW_ENABLE, a
	ldh [rLCDC], a

.done
	pop af
	reti

DisableLCD::
; Turn the LCD off

; Don't need to do anything if the LCD is already off
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a
	ret z

	xor a
	ldh [rIF], a
	ldh a, [rIE]
	ld b, a

; Disable VBlank
	res VBLANK, a
	ldh [rIE], a

.wait
; Wait until VBlank would normally happen
	ldh a, [rLY]
	cp LY_VBLANK + 1
	jr nz, .wait

	ldh a, [rLCDC]
	and ~(1 << rLCDC_ENABLE)
	ldh [rLCDC], a

	xor a
	ldh [rIF], a
	ld a, b
	ldh [rIE], a
	ret

EnableLCD::
	ldh a, [rLCDC]
	set rLCDC_ENABLE, a
	ldh [rLCDC], a
	ret
