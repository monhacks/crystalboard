StepTowardsNextSpace::
	ld a, [wCurSpaceNextSpace]
	call LoadTempSpaceData
	ld a, [wTempSpaceXCoord]
	ld c, a
	ld a, [wXCoord]
	cp c
	jr z, .check_y
	ld a, D_RIGHT
	jr c, .done
	ld a, D_LEFT
	jr .done

.check_y
	ld a, [wTempSpaceYCoord]
	ld c, a
	ld a, [wYCoord]
	cp c
	jr z, .arrived
	ld a, D_DOWN
	jr c, .done
	ld a, D_UP
	jr .done

.arrived
	xor a
.done
	ld [wCurInput], a
	ret
