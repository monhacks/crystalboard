; return field e in player a
; for one-byte field: in a
; for two-byte field: in hl
GetPlayerField::
	ld hl, Players
	ld bc, PLAYERDATA_LENGTH
	call AddNTimes
	ld d, 0
	add hl, de
	ld a, BANK(Players)
	call GetFarWord
	ld a, l
	ret
