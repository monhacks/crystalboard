INCLUDE "data/sprites/facings.asm"

INCLUDE "data/sprites/map_objects.asm"

DeleteMapObject::
	push bc
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	push af
	ld h, b
	ld l, c
	ld bc, OBJECT_LENGTH
	xor a
	call ByteFill
	pop af
	cp -1
	jr z, .ok
	bit 7, a
	jr nz, .ok
	call GetMapObject
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld [hl], -1
.ok
	pop bc
	ret

HandleObjectStep:
	call CheckObjectStillVisible
	ret c
	call HandleStepType
	call HandleObjectAction
	ret

CheckObjectStillVisible:
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OBJ_FLAGS2_6, [hl]
	ld a, [wXCoord]
	ld e, a
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .ok
	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .ok
	ld a, [wYCoord]
	ld e, a
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .ok
	cp MAPOBJECT_SCREEN_HEIGHT
	jr nc, .ok
	jr .yes

.ok
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OBJ_FLAGS2_6, [hl]
	ld a, [wXCoord]
	ld e, a
	ld hl, OBJECT_INIT_X
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .ok2
	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .ok2
	ld a, [wYCoord]
	ld e, a
	ld hl, OBJECT_INIT_Y
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .ok2
	cp MAPOBJECT_SCREEN_HEIGHT
	jr nc, .ok2
.yes
	and a
	ret

.ok2
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit WONT_DELETE_F, [hl]
	jr nz, .yes2
	call DeleteMapObject
	scf
	ret

.yes2
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OBJ_FLAGS2_6, [hl]
	and a
	ret

HandleStepType:
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld a, [hl]
	and a
	jr z, .zero
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit FROZEN_F, [hl]
	jr nz, .frozen
	cp STEP_TYPE_FROM_MOVEMENT
	jr z, .one
	jr .ok3

.zero
	call StepFunction_Reset
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit FROZEN_F, [hl]
	jr nz, .frozen
.one
	call StepFunction_FromMovement
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld a, [hl]
	and a
	ret z
	cp STEP_TYPE_FROM_MOVEMENT
	ret z
.ok3
	ld hl, StepTypesJumptable
	rst JumpTable
	ret

.frozen
	ret

HandleObjectAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit INVISIBLE_F, [hl]
	jr nz, SetFacingStanding
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit OBJ_FLAGS2_6, [hl]
	jr nz, SetFacingStanding
	bit FROZEN_F, [hl]
	jr nz, _CallFrozenObjectAction
; use first column (normal)
	ld de, ObjectActionPairPointers
	jr CallObjectAction

HandleFrozenObjectAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit INVISIBLE_F, [hl]
	jr nz, SetFacingStanding
_CallFrozenObjectAction:
; use second column (frozen)
	ld de, ObjectActionPairPointers + 2
	jr CallObjectAction ; pointless

CallObjectAction:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld a, [hl]
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	ret

INCLUDE "engine/overworld/map_object_action.asm"

CopyCoordsTileToLastCoordsTile:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_TILE
	add hl, bc
	ld [hl], a
	call SetTallGrassFlags
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call UselessAndA
	ret

CopyLastCoordsToCoords:
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld [hl], a
	ret

UpdateTallGrassFlags:
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit OVERHEAD_F, [hl]
	jr z, .ok
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call SetTallGrassFlags
.ok
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call UselessAndA
	ret c ; never happens
	ld hl, OBJECT_LAST_TILE
	add hl, bc
	ld a, [hl]
	call UselessAndA
	ret

SetTallGrassFlags:
	call CheckSuperTallGrassTile
	jr z, .set
	call CheckGrassTile
	jr c, .reset
.set
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OVERHEAD_F, [hl]
	ret

.reset
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	ret

UselessAndA:
	and a
	ret

EndSpriteMovement:
	xor a
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld [hli], a
	ld [hli], a ; OBJECT_STEP_INDEX
	ld [hli], a ; OBJECT_1D
	ld [hl], a  ; OBJECT_1E
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

InitStep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit FIXED_FACING_F, [hl]
	jr nz, GetNextTile
	add a
	add a
	and %00001100
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	; fallthrough

GetNextTile:
	call GetStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld a, d
	call GetStepVectorSign
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	add [hl]
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld [hl], a
	ld d, a
	ld a, e
	call GetStepVectorSign
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	add [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld [hl], a
	ld e, a
	push bc
	call GetCoordTileCollision
	pop bc
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	ret

AddStepVector:
	call GetStepVector
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	add d
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	add e
	ld [hl], a
	ret

GetStepVector:
; Return (x, y, duration, speed) in (d, e, a, h).
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00001111
	add a
	add a
	ld l, a
	ld h, 0
	ld de, StepVectors
	add hl, de
	ld d, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld a, [hli]
	ld h, [hl]
	ret

StepVectors:
; x,  y, duration, speed
	; slow
	db  0,  1, 16, 1
	db  0, -1, 16, 1
	db -1,  0, 16, 1
	db  1,  0, 16, 1
	; normal
	db  0,  2,  8, 2
	db  0, -2,  8, 2
	db -2,  0,  8, 2
	db  2,  0,  8, 2
	; fast
	db  0,  4,  4, 4
	db  0, -4,  4, 4
	db -4,  0,  4, 4
	db  4,  0,  4, 4

GetStepVectorSign:
	add a
	ret z  ; 0 or 128 (-128)
	ld a, 1
	ret nc ; +1 to +127
	ld a, -1
	ret    ; -127 to -1

UpdatePlayerStep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00000011
	ld [wPlayerStepDirection], a
	call AddStepVector
	ld a, [wPlayerStepVectorX]
	add d
	ld [wPlayerStepVectorX], a
	ld a, [wPlayerStepVectorY]
	add e
	ld [wPlayerStepVectorY], a
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_CONTINUE_F, [hl]
	ret

GetMapObjectField: ; unreferenced
	push bc
	ld e, a
	ld d, 0
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	call GetMapObject
	add hl, de
	ld a, [hl]
	pop bc
	ret

RestoreDefaultMovement:
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	cp -1
	jr z, .ok
	push bc
	call GetMapObject
	ld hl, MAPOBJECT_MOVEMENT
	add hl, bc
	ld a, [hl]
	pop bc
	ret

.ok
	ld a, SPRITEMOVEDATA_STANDING_DOWN
	ret

ObjectMovement_ZeroAnonJumptableIndex: ; unreferenced
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld [hl], 0
	ret

ObjectMovement_IncAnonJumptableIndex:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	inc [hl]
	ret

ObjectMovement_DecAnonJumptableIndex:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	dec [hl]
	ret

ObjectMovement_AnonJumptable:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld a, [hl]
	pop hl
	rst JumpTable
	ret

ObjectStep_ZeroAnonJumptableIndex:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld [hl], 0
	ret

ObjectStep_IncAnonJumptableIndex:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	inc [hl]
	ret

ObjectStep_AnonJumptable:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld a, [hl]
	pop hl
	rst JumpTable
	ret

ObjectStep_GetAnonJumptableIndex: ; unreferenced
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld a, [hl]
	ret

ObjectStep_SetAnonJumptableIndex: ; unreferenced
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld [hl], a
	ret

StepFunction_Reset:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	push bc
	call GetCoordTileCollision
	pop bc
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	call CopyCoordsTileToLastCoordsTile
	call EndSpriteMovement
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_FromMovement:
	call ObjectStep_ZeroAnonJumptableIndex
	call GetSpriteMovementFunction
	ld a, [hl]
	ld hl, .Pointers
	rst JumpTable
	ret

.Pointers:
; entries correspond to SPRITEMOVEFN_* constants (see constants/map_object_constants.asm)
	table_width 2, StepFunction_FromMovement.Pointers
	dw MovementFunction_Null                 ; 00
	dw MovementFunction_RandomWalkY          ; 01
	dw MovementFunction_RandomWalkX          ; 02
	dw MovementFunction_RandomWalkXY         ; 03
	dw MovementFunction_RandomSpinSlow       ; 04
	dw MovementFunction_RandomSpinFast       ; 05
	dw MovementFunction_Standing             ; 06
	dw MovementFunction_ObeyDPad             ; 07
	dw MovementFunction_Indexed1             ; 08
	dw MovementFunction_Indexed2             ; 09
	dw MovementFunction_0a                   ; 0a
	dw MovementFunction_0b                   ; 0b
	dw MovementFunction_0c                   ; 0c
	dw MovementFunction_0d                   ; 0d
	dw MovementFunction_0e                   ; 0e
	dw MovementFunction_Follow               ; 0f
	dw MovementFunction_Script               ; 10
	dw MovementFunction_Strength             ; 11
	dw MovementFunction_FollowNotExact       ; 12
	dw MovementFunction_Shadow               ; 13
	dw MovementFunction_Emote                ; 14
	dw MovementFunction_BigStanding          ; 15
	dw MovementFunction_Bouncing             ; 16
	dw MovementFunction_ScreenShake          ; 17
	dw MovementFunction_SpinClockwise        ; 18
	dw MovementFunction_SpinCounterclockwise ; 19
	dw MovementFunction_BoulderDust          ; 1a
	dw MovementFunction_ShakingGrass         ; 1b
	assert_table_length NUM_SPRITEMOVEFN

MovementFunction_Null:
	ret

MovementFunction_RandomWalkY:
	call Random
	ldh a, [hRandomAdd]
	and %00000001
	jp _RandomWalkContinue

MovementFunction_RandomWalkX:
	call Random
	ldh a, [hRandomAdd]
	and %00000001
	or  %00000010
	jp _RandomWalkContinue

MovementFunction_RandomWalkXY:
	call Random
	ldh a, [hRandomAdd]
	and %00000011
	jp _RandomWalkContinue

MovementFunction_RandomSpinSlow:
	call Random
	ldh a, [hRandomAdd]
	and %00001100
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	jp RandomStepDuration_Slow

MovementFunction_RandomSpinFast:
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	and %00001100
	ld d, a
	call Random
	ldh a, [hRandomAdd]
	and %00001100
	cp d
	jr nz, .keep
	xor %00001100
.keep
	ld [hl], a
	jp RandomStepDuration_Fast

MovementFunction_Standing:
	call CopyLastCoordsToCoords
	call EndSpriteMovement
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESTORE
	ret

MovementFunction_ObeyDPad:
	ld hl, GetPlayerNextMovementIndex
	jp HandleMovementData

MovementFunction_Indexed1:
	ld hl, GetIndexedMovementIndex1
	jp HandleMovementData

MovementFunction_Indexed2:
	ld hl, GetIndexedMovementIndex2
	jp HandleMovementData

MovementFunction_0a:
	jp _GetMovementObject

MovementFunction_0b:
	jp _GetMovementObject

MovementFunction_0c:
	jp _GetMovementObject

MovementFunction_0d:
	ld hl, GetPlayerNextMovementIndex
	jp HandleMovementData

MovementFunction_0e:
	jp _GetMovementObject

MovementFunction_Follow:
	ld hl, GetFollowerNextMovementIndex
	jp HandleMovementData

MovementFunction_Script:
	ld hl, GetMovementIndex
	jp HandleMovementData

MovementFunction_Strength:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw .start
	dw .stop

.start:
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call CheckPitTile
	jr z, .on_pit
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit OBJ_FLAGS2_2, [hl]
	res OBJ_FLAGS2_2, [hl]
	jr z, .ok
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	and %00000011
	or 0
	call InitStep
	call CanObjectMoveInDirection
	jr c, .ok2
	ld de, SFX_STRENGTH
	call PlaySFX
	call SpawnStrengthBoulderDust
	call UpdateTallGrassFlags
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STRENGTH_BOULDER
	ret

.ok2
	call CopyLastCoordsToCoords
.ok
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

.on_pit
	call ObjectMovement_IncAnonJumptableIndex
.stop:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

MovementFunction_FollowNotExact:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	push bc
	call GetObjectStruct
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr z, .standing
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld a, [hl]
	cp d
	jr z, .equal
	jr c, .less
	ld a, 3
	jr .done

.less
	ld a, 2
	jr .done

.equal
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld a, [hl]
	cp e
	jr z, .standing
	jr c, .less2
	ld a, 0
	jr .done

.less2
	ld a, 1
.done
	ld d, a
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00001100
	or d
	pop bc
	jp NormalStep

.standing
	pop bc
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ret

MovementFunction_BigStanding:
	call EndSpriteMovement
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BIG_DOLL_SYM
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STANDING
	ret

MovementFunction_Bouncing:
	call EndSpriteMovement
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BOUNCE
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STANDING
	ret

MovementFunction_SpinCounterclockwise:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw _MovementSpinInit
	dw _MovementSpinRepeat
	dw _MovementSpinTurnLeft

MovementFunction_SpinClockwise:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw _MovementSpinInit
	dw _MovementSpinRepeat
	dw _MovementSpinTurnRight

_MovementSpinInit:
	call EndSpriteMovement
	call ObjectMovement_IncAnonJumptableIndex
	; fallthrough

_MovementSpinRepeat:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	ld a, $10
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SLEEP
	call ObjectMovement_IncAnonJumptableIndex
	ret

_MovementSpinTurnLeft:
	ld de, .facings_counterclockwise
	call _MovementSpinNextFacing
	jr MovementFunction_SpinCounterclockwise

.facings_counterclockwise:
	db OW_RIGHT
	db OW_LEFT
	db OW_DOWN
	db OW_UP

_MovementSpinTurnRight:
	ld de, .facings_clockwise
	call _MovementSpinNextFacing
	jr MovementFunction_SpinClockwise

.facings_clockwise:
	db OW_LEFT
	db OW_RIGHT
	db OW_UP
	db OW_DOWN

_MovementSpinNextFacing:
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	and %00001100
	rrca
	rrca
	push hl
	ld l, a
	ld h, 0
	add hl, de
	ld a, [hl]
	pop hl
	ld [hl], a
	call ObjectMovement_DecAnonJumptableIndex
	ret

MovementFunction_Shadow:
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SHADOW
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	inc a
	add a
	add 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, de
	ld a, [hl]
	maskbits NUM_DIRECTIONS
	ld d, 1 * TILE_WIDTH + 6
	cp DOWN
	jr z, .ok
	cp UP
	jr z, .ok
	ld d, 1 * TILE_WIDTH + 4
.ok
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], d
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

MovementFunction_Emote:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_EMOTE
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], -2 * TILE_WIDTH
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

MovementFunction_BoulderDust:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BOULDER_DUST
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	inc a
	add a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, de
	ld a, [hl]
	and %00000011
	ld e, a
	ld d, 0
	ld hl, .dust_coords
	add hl, de
	add hl, de
	ld d, [hl]
	inc hl
	ld e, [hl]
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], d
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], e
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

.dust_coords:
	;   x,  y
	db  0, -4
	db  0,  8
	db  6,  2
	db -6,  2

MovementFunction_ShakingGrass:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_GRASS_SHAKE
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	add -1
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

InitMovementField1dField1e:
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	push bc
	call GetObjectStruct
	ld d, b
	ld e, c
	pop bc
	ld hl, OBJECT_1D
	add hl, bc
	ld [hl], e
	inc hl ; OBJECT_1E
	ld [hl], d
	ret

MovementFunction_ScreenShake:
	call EndSpriteMovement
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	call .GetDurationAndField1e
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], e
	ld hl, OBJECT_1E
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SCREENSHAKE
	ret

.GetDurationAndField1e:
	ld d, a
	and %00111111
	ld e, a
	ld a, d
	rlca
	rlca
	and %00000011
	ld d, a
	inc d
	ld a, 1
.loop
	dec d
	ret z
	add a
	jr .loop

_RandomWalkContinue:
	call InitStep
	call CanObjectMoveInDirection
	jr c, .new_duration
	call UpdateTallGrassFlags
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STEP
	ld hl, wCenteredObject
	ldh a, [hMapObjectIndex]
	cp [hl]
	jr z, .centered
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_CONTINUE_WALK
	ret

.centered
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_PLAYER_WALK
	ret

.new_duration:
	call EndSpriteMovement
	call CopyLastCoordsToCoords
	; fallthrough

RandomStepDuration_Slow:
	call Random
	ldh a, [hRandomAdd]
	and %01111111
	jr _SetRandomStepDuration

RandomStepDuration_Fast:
	call Random
	ldh a, [hRandomAdd]
	and %00011111
_SetRandomStepDuration:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SLEEP
	ret

StepTypesJumptable:
; entries correspond to STEP_TYPE_* constants (see constants/map_object_constants.asm)
	table_width 2, StepTypesJumptable
	dw StepFunction_Reset           ; 00
	dw StepFunction_FromMovement    ; 01
	dw StepFunction_NPCWalk         ; 02
	dw StepFunction_Sleep           ; 03
	dw StepFunction_Standing        ; 04
	dw StepFunction_Restore         ; 05
	dw StepFunction_PlayerWalk      ; 06
	dw StepFunction_ContinueWalk    ; 07
	dw StepFunction_NPCJump         ; 08
	dw StepFunction_PlayerJump      ; 09
	dw StepFunction_Turn            ; 0a
	dw StepFunction_Bump            ; 0b
	dw StepFunction_TeleportFrom    ; 0c
	dw StepFunction_TeleportTo      ; 0d
	dw StepFunction_Skyfall         ; 0e
	dw StepFunction_StrengthBoulder ; 0f
	dw StepFunction_GotBite         ; 10
	dw StepFunction_RockSmash       ; 11
	dw StepFunction_DigTo           ; 12
	dw StepFunction_TrackingObject  ; 13
	dw StepFunction_14              ; 14
	dw StepFunction_ScreenShake     ; 15
	dw StepFunction_16              ; 16
	dw StepFunction_17              ; 17
	dw StepFunction_Delete          ; 18
	dw StepFunction_SkyfallTop      ; 19
	assert_table_length NUM_STEP_TYPES

WaitStep_InPlace:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_NPCJump:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Jump
	dw .Land

.Jump:
	call AddStepVector
	call UpdateJumpPosition
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	call GetNextTile
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
	ret

.Land:
	call AddStepVector
	call UpdateJumpPosition
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_PlayerJump:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .initjump
	dw .stepjump
	dw .initland
	dw .stepland

.initjump
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.stepjump
	call UpdateJumpPosition
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	set PLAYERSTEP_MIDAIR_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
	ret

.initland
	call GetNextTile
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.stepland
	call UpdateJumpPosition
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TeleportFrom:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .InitSpin
	dw .DoSpin
	dw .InitSpinRise
	dw .DoSpinRise

.InitSpin:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
.DoSpin:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
	ret

.InitSpinRise:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], $10
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.DoSpinRise:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	call Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TeleportTo:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .InitWait
	dw .DoWait
	dw .InitDescent
	dw .DoDescent
	dw .InitFinalSpin
	dw .DoFinalSpin
	dw .FinishStep

.InitWait:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
	ret

.DoWait:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.InitDescent:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
	ret

.DoDescent:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	call Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.InitFinalSpin:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
	ret

.DoFinalSpin:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
.FinishStep:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Skyfall:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Step
	dw .Fall
	dw .Finish

.Init:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
.Step:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STEP
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
.Fall:
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	call Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.Finish:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_GotBite:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 8
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	call ObjectStep_IncAnonJumptableIndex
.Run:
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld a, [hl]
	xor 1
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_RockSmash:
	call .Step
	jp WaitStep_InPlace

.Step:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and %00000001
	ld a, OBJECT_ACTION_STAND
	jr z, .yes
	ld a, OBJECT_ACTION_00
.yes
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], a
	ret

StepFunction_DigTo:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and %00000001
	ld a, OBJECT_ACTION_SPIN
	jr z, .yes
	ld a, OBJECT_ACTION_SPIN_FLICKER
.yes
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], a
	jp WaitStep_InPlace

StepFunction_Sleep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Delete:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	jp DeleteMapObject

StepFunction_Bump:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Restore:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Reset
	dw StepFunction_Standing

.Reset:
	call RestoreDefaultMovement
	call GetInitialFacing
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	call ObjectStep_IncAnonJumptableIndex
	; fallthrough

StepFunction_Standing:
	call Stubbed_UpdateYOffset
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

StepFunction_NPCWalk:
	call Stubbed_UpdateYOffset
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_ContinueWalk:
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	jp RandomStepDuration_Slow

StepFunction_PlayerWalk:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .init
	dw .step

.init
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.step
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Turn:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .init1
	dw .step1
	dw .init2
	dw .step2

.init1
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld a, [hl]
	ld [hl], 4
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 1
	call ObjectStep_IncAnonJumptableIndex
.step1
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.init2
	ld hl, OBJECT_1D ; new facing
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 3
	call ObjectStep_IncAnonJumptableIndex
.step2
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_StrengthBoulder:
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	push bc
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	ld b, a
	farcall CopyDECoordsToMapObject
	pop bc
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OBJ_FLAGS2_2, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TrackingObject:
	ld hl, OBJECT_1D
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, OBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .nope
	ld hl, OBJECT_SPRITE_X
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret nz
.nope
	jp DeleteMapObject

StepFunction_14:
StepFunction_ScreenShake:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	xor a
	ld hl, OBJECT_1D
	add hl, bc
	ld [hl], a
	call ObjectStep_IncAnonJumptableIndex
.Run:
	ld hl, OBJECT_1D
	add hl, bc
	ld d, [hl]
	ld a, [wPlayerStepVectorY]
	sub d
	ld [wPlayerStepVectorY], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	jr z, .ok
	ld a, [hl]
	call .GetSign
	ld hl, OBJECT_1D
	add hl, bc
	ld [hl], a
	ld d, a
	ld a, [wPlayerStepVectorY]
	add d
	ld [wPlayerStepVectorY], a
	ret

.ok
	call DeleteMapObject
	ret

.GetSign:
	ld hl, OBJECT_1E
	add hl, bc
	and 1
	ld a, [hl]
	ret z
	cpl
	inc a
	ret

StepFunction_16:
	call ObjectStep_AnonJumptable
	; jumptable was dummied out here

StepFunction_17:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .null
	dw .null
	dw .null
.null

StepFunction_SkyfallTop:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SKYFALL
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex

.Run:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], $60
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

Stubbed_UpdateYOffset:
; dummied out
	ret
	ld hl, OBJECT_1D
	add hl, bc
	inc [hl]
	ld a, [hl]
	srl a
	srl a
	and %00000111
	ld l, a
	ld h, 0
	ld de, .y_offsets
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

.y_offsets:
	db 0, -1, -2, -3, -4, -3, -2, -1

UpdateJumpPosition:
	call GetStepVector
	ld a, h
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld e, [hl]
	add e
	ld [hl], a
	nop
	srl e
	ld d, 0
	ld hl, .y_offsets
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

.y_offsets:
	db  -4,  -6,  -8, -10, -11, -12, -12, -12
	db -11, -10,  -9,  -8,  -6,  -4,   0,   0

GetPlayerNextMovementIndex:
; copy [wPlayerNextMovement] to [wPlayerMovement]
	ld a, [wPlayerNextMovement]
	ld hl, wPlayerMovement
	ld [hl], a
; load [wPlayerNextMovement] with movement_step_sleep
	ld a, movement_step_sleep
	ld [wPlayerNextMovement], a
; recover the previous value of [wPlayerNextMovement]
	ld a, [hl]
	ret

GetMovementIndex:
	ld hl, wMovementDataBank
	call _GetMovementIndex
	ret

GetIndexedMovementIndex1:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld e, [hl]
	inc [hl]
	ld d, 0
	ld hl, wMovementObject
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hl]
	ret

GetIndexedMovementIndex2:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld e, [hl]
	inc [hl]
	ld d, 0
	ld hl, wIndexedMovement2Pointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hl]
	ret

_GetMovementObject:
	ld hl, GetMovementObject
	jp HandleMovementData

GetMovementObject:
	ld a, [wMovementObject]
	ret

HandleMovementData:
	call .StorePointer
.loop
	xor a
	ld [wContinueReadingMovement], a
	call JumpMovementPointer
	call DoMovementFunction
	ld a, [wContinueReadingMovement]
	and a
	jr nz, .loop
	ret

.StorePointer:
	ld a, l
	ld [wMovementPointer], a
	ld a, h
	ld [wMovementPointer + 1], a
	ret

JumpMovementPointer:
	ld hl, wMovementPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

ContinueReadingMovement:
	ld a, TRUE
	ld [wContinueReadingMovement], a
	ret

DoMovementFunction:
	push af
	call ApplyMovementToFollower
	pop af
	ld hl, MovementPointers
	rst JumpTable
	ret

INCLUDE "engine/overworld/movement.asm"

ApplyMovementToFollower:
	ld e, a
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	ld a, [wObjectFollow_Leader]
	ld d, a
	ldh a, [hMapObjectIndex]
	cp d
	ret nz
	ld a, e
	cp movement_step_sleep
	ret z
	cp movement_step_end
	ret z
	cp movement_step_4b
	ret z
	cp movement_step_bump
	ret z
	cp movement_slow_step
	ret c
	push af
	ld hl, wFollowerMovementQueueLength
	inc [hl]
	ld e, [hl]
	ld d, 0
	ld hl, wFollowMovementQueue
	add hl, de
	pop af
	ld [hl], a
	ret

GetFollowerNextMovementIndex:
	ld hl, wFollowerMovementQueueLength
	ld a, [hl]
	and a
	jr z, .done
	cp -1
	jr z, .done
	dec [hl]
	ld e, a
	ld d, 0
	ld hl, wFollowMovementQueue
	add hl, de
	inc e
	ld a, -1
.loop
	ld d, [hl]
	ld [hld], a
	ld a, d
	dec e
	jr nz, .loop
	ret

.done
	call .CancelFollowIfLeaderMissing
	ret c
	ld a, movement_step_sleep
	ret

.CancelFollowIfLeaderMissing:
	ld a, [wObjectFollow_Leader]
	cp -1
	jr z, .nope
	push bc
	call GetObjectStruct
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	pop bc
	and a
	jr z, .nope
	and a
	ret

.nope
	ld a, -1
	ld [wObjectFollow_Follower], a
	ld a, movement_step_end
	scf
	ret

SpawnShadow:
	push bc
	ld de, .ShadowObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.ShadowObject:
	; vtile, palette, movement
	db $00, PAL_OW_GREY, SPRITEMOVEDATA_SHADOW

SpawnStrengthBoulderDust:
	push bc
	ld de, .BoulderDustObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.BoulderDustObject:
	; vtile, palette, movement
	db $00, PAL_OW_GREY, SPRITEMOVEDATA_BOULDERDUST

SpawnEmote:
	push bc
	ld de, .EmoteObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.EmoteObject:
	; vtile, palette, movement
	db $00, PAL_OW_GREY, SPRITEMOVEDATA_EMOTE

ShakeGrass:
	push bc
	ld de, .GrassObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.GrassObject:
	; vtile, palette, movement
	db $00, PAL_OW_TREE, SPRITEMOVEDATA_GRASS

ShakeScreen:
	push bc
	push af
	ld de, .ScreenShakeObject
	call CopyTempObjectData
	pop af
	ld [wTempObjectCopyRange], a
	call InitTempObject
	pop bc
	ret

.ScreenShakeObject:
	; vtile, palette, movement
	db $00, PAL_OW_GREY, SPRITEMOVEDATA_SCREENSHAKE

DespawnEmote:
	push bc
	ldh a, [hMapObjectIndex]
	ld c, a
	call .DeleteEmote
	pop bc
	ret

.DeleteEmote:
	ld de, wObjectStructs
	ld a, NUM_OBJECT_STRUCTS
.loop
	push af
	ld hl, OBJECT_FLAGS1
	add hl, de
	bit EMOTE_OBJECT_F, [hl]
	jr z, .next
	ld hl, OBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .next
	push bc
	xor a
	ld bc, OBJECT_LENGTH
	call ByteFill
	pop bc
.next
	ld hl, OBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop af
	dec a
	jr nz, .loop
	ret

InitTempObject:
	call FindFirstEmptyObjectStruct
	ret nc
	ld d, h
	ld e, l
	farcall CopyTempObjectToObjectStruct
	ret

CopyTempObjectData:
; load into wTempObjectCopy:
; -1, -1, [de], [de + 1], [de + 2], [hMapObjectIndex], [NextMapX], [NextMapY], -1
; This spawns the object at the same place as whichever object is loaded into bc.
	ld hl, wTempObjectCopyMapObjectIndex
	ld [hl], -1
	inc hl
	ld [hl], -1
	inc hl
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hli], a
	ldh a, [hMapObjectIndex]
	ld [hli], a
	push hl
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	pop hl
	ld [hl], d
	inc hl
	ld [hl], e
	inc hl
	ld [hl], -1
	ret

UpdateAllObjectsFrozen::
	ld a, [wStateFlags]
	bit 0, a
	ret z
	ld bc, wObjectStructs
	xor a
.loop
	ldh [hMapObjectIndex], a
	call DoesObjectHaveASprite
	jr z, .ok
	call UpdateObjectFrozen
.ok
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

RespawnPlayerAndOpponent:
; called at battle start
	call HideAllObjects
	ld a, PLAYER
	call RespawnObject
	ld a, [wBattleScriptFlags]
	bit 7, a
	jr z, .skip_opponent
	ldh a, [hLastTalked]
	and a
	jr z, .skip_opponent
	call RespawnObject
.skip_opponent
	call _UpdateActiveSprites
	ret

RespawnPlayer:
	call HideAllObjects
	ld a, PLAYER
	call RespawnObject
	call _UpdateActiveSprites
	ret

RespawnObject:
	cp NUM_OBJECTS
	ret nc
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp -1
	ret z
	cp NUM_OBJECT_STRUCTS
	ret nc
	call GetObjectStruct
	call DoesObjectHaveASprite
	ret z
	call UpdateRespawnedObjectFrozen
	ret

HideAllObjects:
	xor a
	ld bc, wObjectStructs
.loop
	ldh [hMapObjectIndex], a
	call SetFacing_Standing
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

UpdateObjectFrozen:
	push bc
	call CheckObjectCoveredByTextbox
	pop bc
	jr c, SetFacing_Standing
	call CheckObjectOnScreen
	jr c, SetFacing_Standing
	call UpdateObjectTile
	call HandleFrozenObjectAction
	xor a
	ret

UpdateRespawnedObjectFrozen:
	call CheckObjectOnScreen
	jr c, SetFacing_Standing
	call HandleFrozenObjectAction
	xor a
	ret

SetFacing_Standing:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], STANDING
	scf
	ret

UpdateObjectTile:
	push bc
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	call GetCoordTileCollision
	pop bc
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	call UpdateTallGrassFlags
	ret

CheckObjectOnScreen:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	inc d
	inc e
	ld a, [wXCoord]
	cp d
	jr z, .equal_x
	jr nc, .nope
	add MAPOBJECT_SCREEN_WIDTH - 1
	cp d
	jr c, .nope
.equal_x
	ld a, [wYCoord]
	cp e
	jr z, .equal_y
	jr nc, .nope
	add MAPOBJECT_SCREEN_HEIGHT - 1
	cp e
	jr c, .nope
.equal_y
	xor a
	ret

.nope
	scf
	ret

CheckObjectCoveredByTextbox:
; Check whether the object fits in the screen width.
	ld a, [wPlayerBGMapOffsetX]
	ld d, a
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	add [hl]
	add d
	cp $f0
	jr nc, .ok1
	cp SCREEN_WIDTH_PX
	jp nc, .disappear
.ok1
; Account for objects currently moving left/right.
	and %00000111
	ld d, 2
	cp TILE_WIDTH / 2
	jr c, .ok2
	ld d, 3
.ok2
; Convert pixels to tiles.
	ld a, [hl]
	srl a
	srl a
	srl a
	cp SCREEN_WIDTH
	jr c, .ok3
	sub BG_MAP_WIDTH
.ok3
	ldh [hCurSpriteXCoord], a

; Check whether the object fits in the screen height.
	ld a, [wPlayerBGMapOffsetY]
	ld e, a
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	add [hl]
	add e
	cp $f0
	jr nc, .ok4
	cp SCREEN_HEIGHT_PX
	jr nc, .disappear
.ok4
; Account for objects currently moving up/down.
	and %00000111
	ld e, 2
	cp TILE_WIDTH / 2
	jr c, .ok5
	ld e, 3
.ok5
; Convert pixels to tiles.
	ld a, [hl]
	srl a
	srl a
	srl a
	cp SCREEN_HEIGHT
	jr c, .ok6
	sub BG_MAP_HEIGHT
.ok6
	ldh [hCurSpriteYCoord], a

; Account for big objects that are twice as wide and high.
	ld hl, OBJECT_PALETTE
	add hl, bc
	bit BIG_OBJECT_F, [hl]
	jr z, .ok7
	ld a, d
	add 2
	ld d, a
	ld a, e
	add 2
	ld e, a
.ok7
	ld a, d
	ldh [hCurSpriteXPixel], a

.loop
	ldh a, [hCurSpriteXPixel]
	ld d, a
	ldh a, [hCurSpriteYCoord]
	add e
	dec a
	ld b, a
.next
	ldh a, [hCurSpriteXCoord]
	add d
	dec a
	ld c, a
	push bc
	call ScrollAwareCoord2Tile
	pop bc
; NPCs disappear if standing on tiles FIRST_REGULAR_TEXT_CHAR or above,
; since those IDs are for text characters and textbox frames.
; - if 1bpp text, a single textbox tile overlapping with the sprite makes it disappear.
; - if 2bpp text, sprite only disappears if ALL overlapping tiles are textbox tiles.
	ld a, [hl]
	cp FIRST_REGULAR_TEXT_CHAR
	jr c, .object_not_in_textbox

;.object_in_textbox
	ld a, [wText2bpp]
	and a
	jr z, .disappear
	jr .ok8

.object_not_in_textbox
	ld a, [wText2bpp]
	and a
	jr nz, .not_disappear

.ok8
	dec d
	jr nz, .next
.ok9
; while sprites are centered to tiles in the X axis exactly on top of two adjacent horizonal tiles,
; in the Y axis they occupy 4-8-4 pixels of adjacent vertical tiles instead.
; this is why we loop here one more time (thrice for regular-sized sprites) than horizontally.
	dec e
	ld a, e
	cp $ff
	jr nz, .loop

; if we managed make it here without returning early, there are only two options:
; - if 1bpp text, the sprite is wholly outside of a textbox
; - if 2bpp text, the sprite is wholly inside a textbox
	ld a, [wText2bpp]
	and a
	jr z, .not_disappear

.disappear
	scf
	ret

.not_disappear
	and a
	ret

HandleNPCStep::
	call ResetStepVector
	call DoStepsForAllObjects
	ret

ResetStepVector:
	xor a
	ld [wPlayerStepVectorX], a
	ld [wPlayerStepVectorY], a
	ld [wPlayerStepFlags], a
	ld a, STANDING
	ld [wPlayerStepDirection], a
	ret

DoStepsForAllObjects:
	ld bc, wObjectStructs
	xor a
.loop
	ldh [hMapObjectIndex], a
	call DoesObjectHaveASprite
	jr z, .next
	call HandleObjectStep
.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

RefreshPlayerSprite:
	ld a, movement_step_sleep
	ld [wPlayerNextMovement], a
	ld [wPlayerMovement], a
	xor a
	ld [wPlayerTurningDirection], a
	ld [wPlayerStepFrame], a
	call TryResetPlayerAction
	farcall CheckWarpFacingDown
	call c, SpawnInFacingDown
	call SpawnInCustomFacing
	ret

TryResetPlayerAction:
	ld hl, wPlayerSpriteSetupFlags
	bit PLAYERSPRITESETUP_RESET_ACTION_F, [hl]
	jr nz, .ok
	ret

.ok
	ld a, OBJECT_ACTION_00
	ld [wPlayerAction], a
	ret

SpawnInCustomFacing:
	ld hl, wPlayerSpriteSetupFlags
	bit PLAYERSPRITESETUP_CUSTOM_FACING_F, [hl]
	ret z
	ld a, [wPlayerSpriteSetupFlags]
	and PLAYERSPRITESETUP_FACING_MASK
	add a
	add a
	jr _ContinueSpawnFacing

SpawnInFacingDown:
	ld a, DOWN
_ContinueSpawnFacing:
	ld bc, wPlayerStruct
	call SetSpriteDirection
	ret

_SetPlayerPalette:
	ld a, d
	and 1 << 7
	ret z
	ld bc, 0 ; debug?
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	or d
	ld [hl], a
	ld a, d
	swap a
	and PALETTE_MASK
	ld d, a
	ld bc, wPlayerStruct
	ld hl, OBJECT_PALETTE
	add hl, bc
	ld a, [hl]
	and ~PALETTE_MASK
	or d
	ld [hl], a
	ret

StartFollow::
	push bc
	ld a, b
	call SetLeaderIfVisible
	pop bc
	ret c
	ld a, c
	call SetFollowerIfVisible
	farcall QueueFollowerFirstStep
	ret

SetLeaderIfVisible:
	call CheckObjectVisibility
	ret c
	ldh a, [hObjectStructIndex]
	ld [wObjectFollow_Leader], a
	ret

StopFollow::
	call ResetLeader
	call ResetFollower
	ret

ResetLeader:
	ld a, -1
	ld [wObjectFollow_Leader], a
	ret

SetFollowerIfVisible:
	push af
	call ResetFollower
	pop af
	call CheckObjectVisibility
	ret c
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], SPRITEMOVEDATA_FOLLOWING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ldh a, [hObjectStructIndex]
	ld [wObjectFollow_Follower], a
	ret

ResetFollower:
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	call GetObjectStruct
	call ResetObject
	ld a, -1
	ld [wObjectFollow_Follower], a
	ret

FreezeAllOtherObjects::
	ld a, c
	call CheckObjectVisibility
	ret c
	push bc
	call FreezeAllObjects
	pop bc
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
	xor a
	ret

FreezeObject: ; unreferenced
	call CheckObjectVisibility
	ret c
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set FROZEN_F, [hl]
	xor a
	ret

FreezeAllObjects:
	ld bc, wObjectStructs
	xor a
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .next
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set FROZEN_F, [hl]
.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

_UnfreezeFollowerObject::
	ld a, [wObjectFollow_Leader]
	cp -1
	ret z
	push bc
	call GetObjectStruct
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	pop bc
	cp c
	ret nz
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	call GetObjectStruct
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
	ret

UnfreezeAllObjects::
	push bc
	ld bc, wObjectStructs
	xor a
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .next
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	pop bc
	ret

UnfreezeObject: ; unreferenced
	call CheckObjectVisibility
	ret c
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
	ret

ResetObject:
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	cp -1
	jp z, .set_standing
	push bc
	call GetMapObject
	ld hl, MAPOBJECT_MOVEMENT
	add hl, bc
	ld a, [hl]
	pop bc
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ret

.set_standing:
	call GetSpriteDirection
	rrca
	rrca
	ld e, a
	ld d, 0
	ld hl, .standing_movefns
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ret

.standing_movefns:
	db SPRITEMOVEDATA_STANDING_DOWN
	db SPRITEMOVEDATA_STANDING_UP
	db SPRITEMOVEDATA_STANDING_LEFT
	db SPRITEMOVEDATA_STANDING_RIGHT

; Used to make the last talked object remain hidden.
; This is done by setting its event flag to special value ALWAYS_HIDDEN.
; Otherwise when data is read from wMapObjectsBackups after entering the map,
; it would appear by default even if it had been made disappear.
SetObjectToRemainHidden:
	ldh a, [hLastTalked]
	call GetMapObject
	ld hl, MAPOBJECT_EVENT_FLAG
	add hl, bc
	ld de, ALWAYS_HIDDEN
	ld [hl], e
	inc hl
	ld [hl], d
	ret

_UpdateActiveSpritesAfterOffset::
	ld a, [wStateFlags]
	bit 0, a
	ret z
	jr _UpdateActiveSprites.go

_UpdateActiveSprites::
	ld a, [wStateFlags]
	bit 0, a
	ret z
	xor a
	ldh [hUsedSpriteIndex], a
.go
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
	call InitSprites
	call .fill
	pop af
	ldh [hOAMUpdate], a
	ret

.fill
	ld a, [wStateFlags]
	bit 1, a
	ld b, NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH
	jr z, .ok
	ld b, (NUM_SPRITE_OAM_STRUCTS - 12) * SPRITEOAMSTRUCT_LENGTH
.ok
	ldh a, [hUsedSpriteIndex]
	cp b
	ret nc
	ld l, a
	ld h, HIGH(wShadowOAM)
	ld de, SPRITEOAMSTRUCT_LENGTH
	ld a, b
	ld c, SCREEN_HEIGHT_PX + 2 * TILE_WIDTH
.loop
	ld [hl], c ; y
	add hl, de
	cp l
	jr nz, .loop
	ret

ApplyBGMapAnchorToObjects:
	push hl
	push de
	push bc
	ld a, [wPlayerBGMapOffsetX]
	ld d, a
	ld a, [wPlayerBGMapOffsetY]
	ld e, a
	ld bc, wObjectStructs
	ld a, NUM_OBJECT_STRUCTS
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .skip
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	add d
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	add e
	ld [hl], a
.skip
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	dec a
	jr nz, .loop
	xor a
	ld [wPlayerBGMapOffsetX], a
	ld [wPlayerBGMapOffsetY], a
	pop bc
	pop de
	pop hl
	ret

DEF PRIORITY_LOW  EQU $10
DEF PRIORITY_NORM EQU $20
DEF PRIORITY_HIGH EQU $30

InitSprites:
	call InitSecondarySprites
	call .DeterminePriorities
	ld c, PRIORITY_HIGH
	call .InitSpritesByPriority
	ld c, PRIORITY_NORM
	call .InitSpritesByPriority
	ld c, PRIORITY_LOW
	call .InitSpritesByPriority
	ret

.DeterminePriorities:
	xor a
	ld hl, wObjectPriorities
	ld bc, NUM_OBJECT_STRUCTS
	call ByteFill
	ld d, 0
	ld bc, wObjectStructs
	ld hl, wObjectPriorities
.loop
	push hl
	call DoesObjectHaveASprite
	jr z, .skip
	ld hl, OBJECT_FACING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr z, .skip
; Define the sprite priority.
	ld e, PRIORITY_LOW
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit LOW_PRIORITY_F, [hl]
	jr nz, .add
	ld e, PRIORITY_NORM
	bit HIGH_PRIORITY_F, [hl]
	jr z, .add
	ld e, PRIORITY_HIGH
	jr .add

.skip
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	jr .next

.add
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, d
	or e
	ld [hli], a
.next
	inc d
	ld a, d
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

.InitSpritesByPriority:
	ld hl, wObjectPriorities
.next_sprite
	ld a, [hli]
	ld d, a
	and $f0
	ret z
	cp c
	jr nz, .next_sprite
	push bc
	push hl
	ld a, d
	and $f
	call .GetObjectStructPointer
	call .InitSprite
	pop hl
	pop bc
	jr .next_sprite

.InitSprite:
	ld hl, OBJECT_SPRITE_TILE
	add hl, bc
	ld a, [hl]
	and ~(1 << 7)
	ldh [hCurSpriteTile], a
	xor a
	bit 7, [hl]
	jr nz, .not_vram1
	or VRAM_BANK_1
.not_vram1
	ld hl, OBJECT_FLAGS2
	add hl, bc
	ld e, [hl]
	bit OBJ_FLAGS2_7, e
	jr z, .not_priority
	or PRIORITY
.not_priority
	bit USE_OBP1_F, e
	jr z, .not_obp_num
	or OBP_NUM
.not_obp_num
	ld hl, OBJECT_PALETTE
	add hl, bc
	ld d, a
	ld a, [hl]
	and PALETTE_MASK
	or d
	ld d, a
	xor a
	bit OVERHEAD_F, e
	jr z, .not_overhead
	or PRIORITY
.not_overhead
	ldh [hCurSpriteOAMFlags], a
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	add [hl]
	add 8
	ld e, a
	ld a, [wPlayerBGMapOffsetX]
	add e
	ldh [hCurSpriteXPixel], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	add [hl]
	add 12
	ld e, a
	ld a, [wPlayerBGMapOffsetY]
	add e
	ldh [hCurSpriteYPixel], a
	ld hl, OBJECT_FACING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jp z, .done
	cp NUM_FACINGS
	jp nc, .done
	ld l, a
	ld h, 0
	add hl, hl
	ld bc, Facings
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hUsedSpriteIndex]
	ld c, a
	ld b, HIGH(wShadowOAM)
	ld a, [hli]
	ldh [hUsedSpriteTile], a
	add c
	cp LOW(wShadowOAMEnd)
	jr nc, .full
.addsprite
	ldh a, [hCurSpriteYPixel]
	add [hl]
	inc hl
	ld [bc], a ; y
	inc c
	ldh a, [hCurSpriteXPixel]
	add [hl]
	inc hl
	ld [bc], a ; x
	inc c
	ld e, [hl]
	inc hl
	ldh a, [hCurSpriteTile]
	bit ABSOLUTE_TILE_ID_F, e
	jr z, .nope1
	xor a
.nope1
	add [hl]
	inc hl
	ld [bc], a ; tile id
	inc c
	ld a, e
	bit RELATIVE_ATTRIBUTES_F, a
	jr z, .nope2
	ldh a, [hCurSpriteOAMFlags]
	or e
.nope2
	and OBP_NUM | X_FLIP | Y_FLIP | PRIORITY
	or d
	ld [bc], a ; attributes
	inc c
	ldh a, [hUsedSpriteTile]
	dec a
	ldh [hUsedSpriteTile], a
	jr nz, .addsprite
	ld a, c
	ldh [hUsedSpriteIndex], a
.done
	xor a
	ret

.full
	scf
	ret

.GetObjectStructPointer:
	ld c, a
	ld b, 0
	ld hl, .Addresses
	add hl, bc
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ret

.Addresses:
	dw wPlayerStruct
	dw wObject1Struct
	dw wObject2Struct
	dw wObject3Struct
	dw wObject4Struct
	dw wObject5Struct
	dw wObject6Struct
	dw wObject7Struct
	dw wObject8Struct
	dw wObject9Struct
	dw wObject10Struct
	dw wObject11Struct
	dw wObject12Struct

_UpdateSecondarySprites::
; this is a shorter _UpdateActiveSprites for when only secondary sprites
; have changed since the last sprites update, but NOT expanded or shrinked,
; which would require to displace primary (NPC) sprites in OAM.
; if it is detected that the size of secondary sprites has increased in the end,
; fall back to calling _UpdateActiveSprites to avoid corruption.
	ld a, [wStateFlags]
	bit 0, a
	ret z
	ld a, [hUsedSpriteIndex]
	push af

	xor a
	ldh [hUsedSpriteIndex], a
.go
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
	call InitSecondarySprites
	pop af
	ldh [hOAMUpdate], a

	ldh a, [hUsedSpriteIndex]
	ld c, a
	pop af
	cp c
	ret nc
	jp _UpdateActiveSprites

InitSecondarySprites:
	ld a, [wDisplaySecondarySprites]
	bit SECONDARYSPRITES_BOARD_MENU_F, a
	call nz, InitBoardMenuSprites
	bit SECONDARYSPRITES_DIE_ROLL_F, a
	call nz, InitDieRollSprites
	bit SECONDARYSPRITES_SPACES_LEFT_F, a
	call nz, InitSpacesLeftNumberSprites
	bit SECONDARYSPRITES_BRANCH_SPACE_F, a
	call nz, InitBranchArrowsSprites
	bit SECONDARYSPRITES_VIEW_MAP_MODE_F, a
	call nz, InitViewMapModeSprites
	bit SECONDARYSPRITES_TALKER_EVENT_F, a
	call nz, InitTalkerEventSprites
	bit SECONDARYSPRITES_GAIN_OR_LOSE_COINS_F, a
	call nz, InitGainOrLoseCoinsSprites
	ret

InitBoardMenuSprites:
	push af

	ld hl, BoardMenuOAM
	ld a, [wBoardMenuCursorPosition]
	ld bc, BOARD_MENU_ITEM_SIZE * SPRITEOAMSTRUCT_LENGTH
	call AddNTimes
; find the beginning of free space in OAM, and assure there's space for a BOARD_MENU_ITEM_SIZE object
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (BOARD_MENU_ITEM_SIZE * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full
; copy the sprite data (BOARD_MENU_ITEM_SIZE objects) of that item to the available space in OAM
	ld e, a
	ld d, HIGH(wShadowOAM)
	ld bc, BOARD_MENU_ITEM_SIZE * SPRITEOAMSTRUCT_LENGTH
	call CopyBytes

	ldh a, [hUsedSpriteIndex]
	add (BOARD_MENU_ITEM_SIZE * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

InitDieRollSprites:
	push af

	ld a, [wDieRoll]
	and a
	jr z, .zero_or_oam_full
	dec a
	ld hl, DieRollOAM
	ld bc, DIE_SIZE * SPRITEOAMSTRUCT_LENGTH
	call AddNTimes
; find the beginning of free space in OAM, and assure there's space for a DIE_SIZE object
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (DIE_SIZE * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .zero_or_oam_full
; copy the sprite data (DIE_SIZE objects) of that item to the available space in OAM
	ld e, a
	ld d, HIGH(wShadowOAM)
	ld bc, DIE_SIZE * SPRITEOAMSTRUCT_LENGTH
	call CopyBytes

	ldh a, [hUsedSpriteIndex]
	add (DIE_SIZE * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.zero_or_oam_full
	pop af
	ret

InitSpacesLeftNumberSprites:
	push af

	ld hl, SpacesLeftNumberOAM
	ld a, [wSpacesLeft]
	dec a
	ld bc, DIE_NUMBER_SIZE * SPRITEOAMSTRUCT_LENGTH
	call AddNTimes
; find the beginning of free space in OAM, and assure there's space for a DIE_NUMBER_SIZE object
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (DIE_NUMBER_SIZE * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full
; copy the sprite data (DIE_NUMBER_SIZE objects) of that item to the available space in OAM
	ld e, a
	ld d, HIGH(wShadowOAM)
	ld bc, DIE_NUMBER_SIZE * SPRITEOAMSTRUCT_LENGTH
	call CopyBytes

	ldh a, [hUsedSpriteIndex]
	add (DIE_NUMBER_SIZE * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

InitBranchArrowsSprites:
	push af

;; arrows
; find the beginning of free space in OAM, and assure there's space for 4 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (NUM_DIRECTIONS * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full

	ld hl, BranchArrowsOAM
	ld de, wTempSpaceBranchStruct
	ld c, NUM_DIRECTIONS
.loop
	ld a, [de]
	cp BRANCH_DIRECTION_INVALID
	jr z, .next1 ; skip this arrow if this direction is not valid
	cp BRANCH_DIRECTION_UNAVAILABLE
	ld b, PAL_OW_GREY ; draw grey arrow if this direction is unavailable
	jr z, .got_pal
	call GetSecondarySpritesPal
	ld b, a

.got_pal
; draw this arrow and advance hUsedSpriteIndex
; preserve loop variables d, e, c
	push de
	push bc
	ldh a, [hUsedSpriteIndex]
	ld e, a
	ld d, HIGH(wShadowOAM)
; copy all bytes minus the attributes one. the palette matches the
; player's color palette, or is PAL_OW_GREY if direction is unavailable
	push bc
	ld bc, SPRITEOAMSTRUCT_LENGTH - 1
	call CopyBytes
	pop bc
	ld a, b ; palette
	ld [de], a
	inc de
	ld a, e
	ldh [hUsedSpriteIndex], a
	pop bc
	pop de
	jr .next2

.next1
	inc hl ;
	inc hl ;
	inc hl ;

.next2
	inc hl ; next object in BranchArrowsOAM
	inc de
	dec c
	jr nz, .loop

;; legend
; find the beginning of free space in OAM, and assure there's space for 8 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (8 * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full
; copy the sprite data of the legend to the available space in OAM.
; the palette byte overrides that data as it matches the player's color palette.
	ld e, a
	ld d, HIGH(wShadowOAM)
	call GetSecondarySpritesPal
	ld b, a
	ld c, 8 ; number of objects
	ld hl, BranchLegendOAM
.loop2
	push bc
	ld bc, SPRITEOAMSTRUCT_LENGTH - 1
	call CopyBytes
	pop bc
	ld a, b ; palette
	ld [de], a
	inc hl
	inc de
	dec c
	jr nz, .loop2

	ldh a, [hUsedSpriteIndex]
	add (8 * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

InitViewMapModeSprites:
	push af

;; arrows
; find the beginning of free space in OAM, and assure there's space for 4 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (NUM_DIRECTIONS * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full

	ld hl, ViewMapModeArrowsOAM
	ld de, wTileDown
	ld c, NUM_DIRECTIONS

.loop
	ld a, [de]
	cp $ff
	jr z, .next1 ; skip this arrow if this direction is not valid
	call GetSecondarySpritesPal
	ld b, a
; draw this arrow and advance hUsedSpriteIndex
; preserve loop variables d, e, c
	push de
	push bc
	ldh a, [hUsedSpriteIndex]
	ld e, a
	ld d, HIGH(wShadowOAM)
; copy all bytes minus the attributes one.
; the palette matches the player's color palette.
	push bc
	ld bc, SPRITEOAMSTRUCT_LENGTH - 1
	call CopyBytes
	pop bc
	ld a, b ; palette
	ld [de], a
	inc de
	ld a, e
	ldh [hUsedSpriteIndex], a
	pop bc
	pop de
	jr .next2

.next1
	inc hl ;
	inc hl ;
	inc hl ;

.next2
	inc hl ; next object in ViewMapModeArrowsOAM
	inc de
	dec c
	jr nz, .loop

;; legend
; find the beginning of free space in OAM, and assure there's space for 8 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (8 * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full
; copy the sprite data of the legend to the available space in OAM.
; the palette byte overrides that data as it matches the player's color palette.
	ld e, a
	ld d, HIGH(wShadowOAM)
	call GetSecondarySpritesPal
	ld b, a
	ld c, 8 ; number of objects
	ld hl, ViewMapModeLegendOAM
.loop2
	push bc
	ld bc, SPRITEOAMSTRUCT_LENGTH - 1
	call CopyBytes
	pop bc
	ld a, b ; palette
	ld [de], a
	inc hl
	inc de
	dec c
	jr nz, .loop2

	ldh a, [hUsedSpriteIndex]
	add (8 * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

InitTalkerEventSprites:
	push af

; find the beginning of free space in OAM, and assure there's space for 8 objects
	ldh a, [hUsedSpriteIndex]
	cp (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (8 * SPRITEOAMSTRUCT_LENGTH) + 1
	jr nc, .oam_full
; copy the sprite data of the legend to the available space in OAM.
; the palette byte overrides that data as it matches the player's color palette.
	ld e, a
	ld d, HIGH(wShadowOAM)
	call GetSecondarySpritesPal
	ld b, a
	ld c, 8 ; number of objects
	ld hl, TalkerEventLegendOAM
.loop2
	push bc
	ld bc, SPRITEOAMSTRUCT_LENGTH - 1
	call CopyBytes
	pop bc
	ld a, b ; palette
	ld [de], a
	inc hl
	inc de
	dec c
	jr nz, .loop2

	ldh a, [hUsedSpriteIndex]
	add (8 * SPRITEOAMSTRUCT_LENGTH)
	ldh [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

InitGainOrLoseCoinsSprites:
	push af

; print string at wStringBuffer1 as OAM
; get string length
	ld hl, wStringBuffer1
	ld c, 0
.get_length_loop
	ld a, [hli]
	cp "@"
	jr z, .got_length
	inc c
	ld a, c
	cp $2 + MAX_DELTA_COINS_DIGITS + 1
	jr nz, .get_length_loop

.got_length
	ld e, c
; find the beginning of free space in OAM, and assure there's space for c objects
	ld a, (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) + 1
	sla c ;
	sla c ; c *= SPRITEOAMSTRUCT_LENGTH
	sub c
	ld b, a ; b = (NUM_SPRITE_OAM_STRUCTS * SPRITEOAMSTRUCT_LENGTH) - (c * SPRITEOAMSTRUCT_LENGTH) + 1
	ldh a, [hUsedSpriteIndex]
	cp b
	jr nc, .oam_full

; align OAM in the X axis according to the string length (e)
	ld a, 10 * TILE_WIDTH
	ld c, TILE_WIDTH / 2
.x_coord_loop
	sub c
	dec e
	jr nz, .x_coord_loop
; b = SPRITEOAMSTRUCT_XCOORD
	ld b, a
; c = SPRITEOAMSTRUCT_YCOORD
	ld c, 8 * TILE_WIDTH
; de = address within wShadowOAM
	ld a, [hUsedSpriteIndex]
	ld e, a
	ld d, HIGH(wShadowOAM)
	ld hl, wStringBuffer1
.print_oam_loop
	ld a, c
	ld [de], a ; SPRITEOAMSTRUCT_YCOORD
	inc de
	ld a, b
	ld [de], a ; SPRITEOAMSTRUCT_XCOORD
	inc de
	add 1 * TILE_WIDTH
	ld b, a
	ld a, [hli]
	ld [de], a ; SPRITEOAMSTRUCT_TILE_ID
	inc de
	ld a, PAL_OW_MISC
	ld [de], a ; SPRITEOAMSTRUCT_ATTRIBUTES
	inc de
	ld a, [hl]
	cp "@"
	jr nz, .print_oam_loop

	ld a, e
	ld [hUsedSpriteIndex], a

.oam_full
	pop af
	ret

GetSecondarySpritesPal:
	push hl
	push de
	push bc
	ld a, [wPlayerCharacter]
	ld e, PLAYERDATA_OW_PAL
	call GetPlayerField
	pop bc
	pop de
	pop hl
	ret

INCLUDE "data/sprites/secondary_sprites.asm"
