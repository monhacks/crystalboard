StepTowardsNextSpace::
	ld a, [wCurSpaceNextSpace]
	cp NEXT_SPACE_IS_ANCHOR_POINT
	jr nc, .move_towards_anchor_point
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

.move_towards_anchor_point
	ld c, D_DOWN
	cp GO_DOWN
	jr z, .done2
	ld c, D_UP
	cp GO_UP
	jr z, .done2
	ld c, D_LEFT
	cp GO_LEFT
	jr z, .done2
	ld c, D_RIGHT
.done2
	ld a, c
	ld [wCurInput], a
	ret
