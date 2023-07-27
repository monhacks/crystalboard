OpenSRAM::
; if invalid bank, sram is disabled
	cp NUM_SRAM_BANKS
	jr c, .valid
if DEF(_DEBUG)
	push af
	push bc
	ld b, 1
.loop
	sla b
	dec a
	jr nz, .loop
	ld a, BANK(sOpenedInvalidSRAM)
	call OpenSRAM
	ld a, [sOpenedInvalidSRAM]
	or b
	ld [sOpenedInvalidSRAM], a
	pop bc
	pop af
endc
	jr CloseSRAM

.valid:
; switch to sram bank a
	push af
; enable sram write
	ld a, SRAM_ENABLE
	ld [MBC3SRamEnable], a
; select sram bank
	pop af
	ld [MBC3SRamBank], a
	ret

CloseSRAM::
	push af
	ld a, SRAM_DISABLE
; disable sram write
	ld [MBC3SRamEnable], a
	pop af
	ret
