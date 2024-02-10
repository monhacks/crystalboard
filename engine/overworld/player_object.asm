BlankScreen:
	call DisableSpriteUpdates
	xor a
	ldh [hBGMapMode], a
	call ClearBGPalettes
	call ClearSprites
	hlcoord 0, 0
	ld bc, wTilemapEnd - wTilemap
	ld a, " "
	call ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, wAttrmapEnd - wAttrmap
	ld a, $7
	call ByteFill
	call WaitBGMap2
	call SetDefaultBGPAndOBP
	ret

SpawnPlayer:
	ld a, -1
	ld [wObjectFollow_Leader], a
	ld [wObjectFollow_Follower], a
	ld a, PLAYER
	ld hl, PlayerObjectTemplate
	call CopyPlayerObjectTemplate
	ld b, PLAYER
	call PlayerSpawn_ConvertCoords
	ld a, PLAYER_OBJECT
	call GetMapObject
	ld hl, MAPOBJECT_PALETTE
	add hl, bc
	ln e, PAL_NPC_RED, OBJECTTYPE_SCRIPT
	ld a, [wPlayerSpriteSetupFlags]
	bit PLAYERSPRITESETUP_FEMALE_TO_MALE_F, a
	jr nz, .ok
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .ok
	ln e, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT

.ok
	ld [hl], e
	ld a, PLAYER_OBJECT
	ldh [hMapObjectIndex], a
	ld bc, wMapObjects
	ld a, PLAYER_OBJECT
	ldh [hObjectStructIndex], a
	ld de, wObjectStructs
	call CopyMapObjectToObjectStruct
	ld a, PLAYER
	ld [wCenteredObject], a
	ret

PlayerObjectTemplate:
; A dummy map object used to initialize the player object.
; Shorter than the actual amount copied by two bytes.
; Said bytes seem to be unused.
	object_event -4, -4, SPRITE_CHRIS, SPRITEMOVEDATA_PLAYER, 15, 15, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, 0, -1

CopyDECoordsToMapObject::
	push de
	ld a, b
	call GetMapObject
	pop de
	ld hl, MAPOBJECT_X_COORD
	add hl, bc
	ld [hl], d
	ld hl, MAPOBJECT_Y_COORD
	add hl, bc
	ld [hl], e
	ret

PlayerSpawn_ConvertCoords:
	push bc
	ld a, [wXCoord]
	add 4
	ld d, a
	ld a, [wYCoord]
	add 4
	ld e, a
	pop bc
	call CopyDECoordsToMapObject
	ret

WriteObjectXY::
	ld a, b
	call CheckObjectVisibility
	ret c

	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ldh a, [hMapObjectIndex]
	ld b, a
	call CopyDECoordsToMapObject
	and a
	ret

RefreshPlayerCoords::
	ld a, [wXCoord]
	add 4
	ld d, a
	ld hl, wPlayerMapX
	sub [hl]
	ld [hl], d
	ld hl, wMapObjects + MAPOBJECT_X_COORD
	ld [hl], d
	ld hl, wPlayerLastMapX
	ld [hl], d
	ld d, a
	ld a, [wYCoord]
	add 4
	ld e, a
	ld hl, wPlayerMapY
	sub [hl]
	ld [hl], e
	ld hl, wMapObjects + MAPOBJECT_Y_COORD
	ld [hl], e
	ld hl, wPlayerLastMapY
	ld [hl], e
	ld e, a
; the next three lines are useless
	ld a, [wObjectFollow_Leader]
	cp PLAYER
	ret nz
	ret

CopyObjectStruct::
	call CheckObjectMask
	and a
	ret nz ; masked

	ld hl, wObjectStructs + OBJECT_LENGTH * 1
	ld a, 1
	ld de, OBJECT_LENGTH
.loop
	ldh [hObjectStructIndex], a
	ld a, [hl]
	and a
	jr z, .done
	add hl, de
	ldh a, [hObjectStructIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	scf
	ret ; overflow

.done
	ld d, h
	ld e, l
	call CopyMapObjectToObjectStruct
	ld hl, wVramState
	bit 7, [hl]
	ret z

	ld hl, OBJECT_FLAGS2
	add hl, de
	set 5, [hl]
	ret

CopyMapObjectToObjectStruct:
	call .CopyMapObjectToTempObject
	call CopyTempObjectToObjectStruct
	ret

.CopyMapObjectToTempObject:
	ldh a, [hObjectStructIndex]
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld [hl], a

	ldh a, [hMapObjectIndex]
	ld [wTempObjectCopyMapObjectIndex], a

	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopySprite], a

	call GetSpriteVTile
	ld [wTempObjectCopySpriteVTile], a

	ld a, [hl]
	call GetSpritePalette
	ld [wTempObjectCopyPalette], a

	ld hl, MAPOBJECT_PALETTE
	add hl, bc
	ld a, [hl]
	and MAPOBJECT_PALETTE_MASK
	jr z, .skip_color_override
	swap a
	and PALETTE_MASK
	ld [wTempObjectCopyPalette], a

.skip_color_override
	ld hl, MAPOBJECT_MOVEMENT
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopyMovement], a

	ld hl, MAPOBJECT_SIGHT_RANGE
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopyRange], a

	ld hl, MAPOBJECT_X_COORD
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopyX], a

	ld hl, MAPOBJECT_Y_COORD
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopyY], a

	ld hl, MAPOBJECT_RADIUS
	add hl, bc
	ld a, [hl]
	ld [wTempObjectCopyRadius], a
	ret

InitializeVisibleSprites:
	ld bc, wMapObject1
	ld a, 1
.loop
	ldh [hMapObjectIndex], a
	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	and a
	jr z, .next

	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp -1
	jr nz, .next

	ld a, [wXCoord]
	ld d, a
	ld a, [wYCoord]
	ld e, a

	ld hl, MAPOBJECT_X_COORD
	add hl, bc
	ld a, [hl]
	add 1
	sub d
	jr c, .next

	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .next

	ld hl, MAPOBJECT_Y_COORD
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .next

	cp MAPOBJECT_SCREEN_HEIGHT
	jr nc, .next

	push bc
	call CopyObjectStruct
	pop bc
	jp c, .ret

.next
	ld hl, MAPOBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECTS
	jr nz, .loop
	ret

.ret
	ret

CheckObjectEnteringVisibleRange::
	nop
	ld a, [wPlayerStepDirection]
	cp STANDING
	ret z
	ld hl, .dw
	rst JumpTable
	ret

.dw
	dw .Down
	dw .Up
	dw .Left
	dw .Right

.Up:
	ld a, [wYCoord]
	sub 1
	jr .Vertical

.Down:
	ld a, [wYCoord]
	add 9
.Vertical:
	ld d, a
	ld a, [wXCoord]
	ld e, a
	ld bc, wMapObject1
	ld a, 1
.loop_v
	ldh [hMapObjectIndex], a
	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	and a
	jr z, .next_v
	ld hl, MAPOBJECT_Y_COORD
	add hl, bc
	ld a, d
	cp [hl]
	jr nz, .next_v
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp -1
	jr nz, .next_v
	ld hl, MAPOBJECT_X_COORD
	add hl, bc
	ld a, [hl]
	add 1
	sub e
	jr c, .next_v
	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .next_v
	push de
	push bc
	call CopyObjectStruct
	pop bc
	pop de

.next_v
	ld hl, MAPOBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECTS
	jr nz, .loop_v
	ret

.Left:
	ld a, [wXCoord]
	sub 1
	jr .Horizontal

.Right:
	ld a, [wXCoord]
	add 10
.Horizontal:
	ld e, a
	ld a, [wYCoord]
	ld d, a
	ld bc, wMapObject1
	ld a, 1
.loop_h
	ldh [hMapObjectIndex], a
	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	and a
	jr z, .next_h
	ld hl, MAPOBJECT_X_COORD
	add hl, bc
	ld a, e
	cp [hl]
	jr nz, .next_h
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp -1
	jr nz, .next_h
	ld hl, MAPOBJECT_Y_COORD
	add hl, bc
	ld a, [hl]
	add 1
	sub d
	jr c, .next_h
	cp MAPOBJECT_SCREEN_HEIGHT
	jr nc, .next_h
	push de
	push bc
	call CopyObjectStruct
	pop bc
	pop de

.next_h
	ld hl, MAPOBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECTS
	jr nz, .loop_h
	ret

CopyTempObjectToObjectStruct:
	ld a, [wTempObjectCopyMapObjectIndex]
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, de
	ld [hl], a

	ld a, [wTempObjectCopyMovement]
	call CopySpriteMovementData

	ld a, [wTempObjectCopyPalette]
	ld hl, OBJECT_PALETTE
	add hl, de
	or [hl]
	ld [hl], a

	ld a, [wTempObjectCopyY]
	call .InitYCoord

	ld a, [wTempObjectCopyX]
	call .InitXCoord

	ld a, [wTempObjectCopySprite]
	ld hl, OBJECT_SPRITE
	add hl, de
	ld [hl], a

	ld a, [wTempObjectCopySpriteVTile]
	ld hl, OBJECT_SPRITE_TILE
	add hl, de
	ld [hl], a

	ld hl, OBJECT_STEP_TYPE
	add hl, de
	ld [hl], STEP_TYPE_RESET

	ld hl, OBJECT_FACING
	add hl, de
	ld [hl], STANDING

	ld a, [wTempObjectCopyRadius]
	call .InitRadius

	ld a, [wTempObjectCopyRange]
	ld hl, OBJECT_RANGE
	add hl, de
	ld [hl], a

	and a
	ret

.InitYCoord:
	ld hl, OBJECT_INIT_Y
	add hl, de
	ld [hl], a

	ld hl, OBJECT_MAP_Y
	add hl, de
	ld [hl], a

	ld hl, wYCoord
	sub [hl]
	and $f
	swap a
	ld hl, wPlayerBGMapOffsetY
	sub [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, de
	ld [hl], a
	ret

.InitXCoord:
	ld hl, OBJECT_INIT_X
	add hl, de
	ld [hl], a
	ld hl, OBJECT_MAP_X
	add hl, de
	ld [hl], a
	ld hl, wXCoord
	sub [hl]
	and $f
	swap a
	ld hl, wPlayerBGMapOffsetX
	sub [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, de
	ld [hl], a
	ret

.InitRadius:
	ld h, a
	inc a
	and $f
	ld l, a
	ld a, h
	add $10
	and $f0
	or l
	ld hl, OBJECT_RADIUS
	add hl, de
	ld [hl], a
	ret

TrainerOrTalkerWalkToPlayer:
	ldh a, [hLastTalked]
	call InitMovementBuffer
	ld a, movement_step_sleep
	call AppendToMovementBuffer
	ld a, [wSeenTrainerOrTalkerDistance]
	dec a
	jr z, .TerminateStep
	ldh a, [hLastTalked]
	ld b, a
	ld c, PLAYER
	ld d, 1
	call .GetPathToPlayer
	call DecrementMovementBufferCount

.TerminateStep:
	ld a, movement_step_end
	call AppendToMovementBuffer
	ret

.GetPathToPlayer:
	push de
	push bc
; get player object struct, load to de
	ld a, c
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	call GetObjectStruct
	ld d, b
	ld e, c

; get last talked object struct, load to bc
	pop bc
	ld a, b
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	call GetObjectStruct

; get last talked coords, load to bc
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld c, [hl]
	ld b, a

; get player coords, load to de
	ld hl, OBJECT_MAP_X
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, de
	ld e, [hl]
	ld d, a

	pop af
	call ComputePathToWalkToPlayer
	ret

SurfStartStep:
	call InitMovementBuffer
	call .GetMovementData
	call AppendToMovementBuffer
	ld a, movement_step_end
	call AppendToMovementBuffer
	ret

.GetMovementData:
	ld a, [wPlayerDirection]
	srl a
	srl a
	maskbits NUM_DIRECTIONS
	ld e, a
	ld d, 0
	ld hl, .movement_data
	add hl, de
	ld a, [hl]
	ret

.movement_data
	slow_step DOWN
	slow_step UP
	slow_step LEFT
	slow_step RIGHT

FollowNotExact::
	push bc
	ld a, c
	call CheckObjectVisibility
	ld d, b
	ld e, c
	pop bc
	ret c

	ld a, b
	call CheckObjectVisibility
	ret c

; object 2 is now in bc, object 1 is now in de
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld c, [hl]
	ld b, a

	ld hl, OBJECT_MAP_X
	add hl, de
	ld a, [hl]
	cp b
	jr z, .same_x
	jr c, .to_the_left
	inc b
	jr .continue

.to_the_left
	dec b
	jr .continue

.same_x
	ld hl, OBJECT_MAP_Y
	add hl, de
	ld a, [hl]
	cp c
	jr z, .continue
	jr c, .below
	inc c
	jr .continue

.below
	dec c

.continue
	ld hl, OBJECT_MAP_X
	add hl, de
	ld [hl], b
	ld a, b
	ld hl, wXCoord
	sub [hl]
	and $f
	swap a
	ld hl, wPlayerBGMapOffsetX
	sub [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, de
	ld [hl], a
	ld hl, OBJECT_MAP_Y
	add hl, de
	ld [hl], c
	ld a, c
	ld hl, wYCoord
	sub [hl]
	and $f
	swap a
	ld hl, wPlayerBGMapOffsetY
	sub [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, de
	ld [hl], a
	ldh a, [hObjectStructIndex]
	ld hl, OBJECT_RANGE
	add hl, de
	ld [hl], a
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, de
	ld [hl], SPRITEMOVEDATA_FOLLOWNOTEXACT
	ld hl, OBJECT_STEP_TYPE
	add hl, de
	ld [hl], STEP_TYPE_RESET
	ret

GetRelativeFacing::
; Determines which way map object e would have to turn to face map object d.  Returns carry if it's impossible for whatever reason.
	ld a, d
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp NUM_OBJECT_STRUCTS
	jr nc, .carry
	ld d, a
	ld a, e
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp NUM_OBJECT_STRUCTS
	jr nc, .carry
	ld e, a
	call .GetFacing_e_relativeto_d
	ret

.carry
	scf
	ret

.GetFacing_e_relativeto_d:
; Determines which way object e would have to turn to face object d.  Returns carry if it's impossible.
; load the coordinates of object d into bc
	ld a, d
	call GetObjectStruct
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld c, [hl]
	ld b, a
	push bc
; load the coordinates of object e into de
	ld a, e
	call GetObjectStruct
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	pop bc
; |x1 - x2|
	ld a, b
	sub d
	jr z, .same_x_1
	jr nc, .b_right_of_d_1
	cpl
	inc a

.b_right_of_d_1
; |y1 - y2|
	ld h, a
	ld a, c
	sub e
	jr z, .same_y_1
	jr nc, .c_below_e_1
	cpl
	inc a

.c_below_e_1
; |y1 - y2| - |x1 - x2|
	sub h
	jr c, .same_y_1

.same_x_1
; compare the y coordinates
	ld a, c
	cp e
	jr z, .same_x_and_y
	jr c, .c_directly_below_e
; c directly above e
	ld d, DOWN
	and a
	ret

.c_directly_below_e
	ld d, UP
	and a
	ret

.same_y_1
	ld a, b
	cp d
	jr z, .same_x_and_y
	jr c, .b_directly_right_of_d
; b directly left of d
	ld d, RIGHT
	and a
	ret

.b_directly_right_of_d
	ld d, LEFT
	and a
	ret

.same_x_and_y
	scf
	ret

QueueFollowerFirstStep:
	call .QueueFirstStep
	jr c, .same
	ld [wFollowMovementQueue], a
	xor a
	ld [wFollowerMovementQueueLength], a
	ret

.same
	ld a, -1
	ld [wFollowerMovementQueueLength], a
	ret

.QueueFirstStep:
	ld a, [wObjectFollow_Leader]
	call GetObjectStruct
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ld a, [wObjectFollow_Follower]
	call GetObjectStruct
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, d
	cp [hl]
	jr z, .check_y
	jr c, .left
	and a
	ld a, movement_step + RIGHT
	ret

.left
	and a
	ld a, movement_step + LEFT
	ret

.check_y
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, e
	cp [hl]
	jr z, .same_xy
	jr c, .up
	and a
	ld a, movement_step + DOWN
	ret

.up
	and a
	ld a, movement_step + UP
	ret

.same_xy
	scf
	ret

RepositionMockedPlayerObject::
; map setup command called by map setup script MAPSETUP_CONNECTION after LoadBlockData,
; once the new map blocks have been loaded to wOverworldMapBlocks.
; Only applies during BOARDEVENT_VIEW_MAP_MODE
	ldh a, [hCurBoardEvent]
	cp BOARDEVENT_VIEW_MAP_MODE
	ret nz

; if map at wBeforeViewMapMapGroup, wBeforeViewMapMapNumber is not the current map,
; or a map connected to the current map, we are done.
	ld hl, wBeforeViewMapMapGroup
	ld a, [hli]
	ld b, a
	ld c, [hl] ; wBeforeViewMapMapNumber
	ld a, [wMapGroup]
	cp b
	jr nz, .next_map_1
	ld a, [wMapNumber]
	cp c
	jr z, MockPlayerObject
.next_map_1
	ld a, [wNorthConnectedMapGroup]
	cp b
	jr nz, .next_map_2
	ld a, [wNorthConnectedMapNumber]
	cp c
	ld a, 0 ; north connected map
	jr z, .is_connected_map
.next_map_2
	ld a, [wSouthConnectedMapGroup]
	cp b
	jr nz, .next_map_3
	ld a, [wSouthConnectedMapNumber]
	cp c
	ld a, 1 ; south connected map
	jr z, .is_connected_map
.next_map_3
	ld a, [wWestConnectedMapGroup]
	cp b
	jr nz, .next_map_4
	ld a, [wWestConnectedMapNumber]
	cp c
	ld a, 2 ; west connected map
	jr z, .is_connected_map
.next_map_4
	ld a, [wEastConnectedMapGroup]
	cp b
	ret nz
	ld a, [wEastConnectedMapNumber]
	cp c
	ld a, 3 ; east connected map
	ret nz

.is_connected_map
	ld [wTempByteValue], a
	ld hl, .got_sprite_coords
	push hl
	ld a, [wBeforeViewMapXCoord]
	ld d, a
	ld a, [wBeforeViewMapYCoord]
	ld e, a
	jumptable_bc .Jumptable, wTempByteValue

.Jumptable:
	dw GetNorthConnectedSpriteCoords
	dw GetSouthConnectedSpriteCoords
	dw GetWestConnectedSpriteCoords
	dw GetEastConnectedSpriteCoords

.got_sprite_coords
	ret nc ; return if sprite is not in visible part of connected map
	jr MockPlayerObject.loaded_player_mock_coords

MockPlayerObject::
	ld hl, wBeforeViewMapYCoord
	ld de, wPlayerMockYCoord
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a

.loaded_player_mock_coords
; refresh wPlayerObjectYCoord and wPlayerObjectXCoord (not strictly necessary)
	farcall RefreshPlayerCoords
; copy default sprite object to the last object struct
	ld hl, .DefaultPlayerObject
	ld de, wMapObject{d:LAST_OBJECT}
	ld bc, OBJECT_EVENT_SIZE + 1
	call CopyBytes

; adjust sprite id and palette number
	ld hl, .PlayerObjectFields
.loop
	ld a, [wPlayerGender]
	cp [hl]
	inc hl
	jr nz, .next1
	ld a, [wPlayerState]
	cp [hl]
	inc hl
	jr nz, .next2
; found a match
	ld a, [hli] ; sprite
	ld [wMapObject{d:LAST_OBJECT}Sprite], a
	ld a, [hl] ; palette | objecttype
	ld [wMapObject{d:LAST_OBJECT}Palette], a ; also wMapObject{d:LAST_OBJECT}Type
	jr .copy_player_coords
.next1
	inc hl
.next2
	inc hl
	inc hl
	ld a, [hl]
	cp -1
	jr nz, .loop

.copy_player_coords
; copy player's coordinates
	ld hl, wPlayerMockYCoord
	ld de, wMapObject{d:LAST_OBJECT}YCoord
	ld a, [hli]
	add 4
	ld [de], a
	inc de
	ld a, [hl] ; wPlayerMockXCoord
	add 4
	ld [de], a ; wMapObject{d:LAST_OBJECT}XCoord
; set facing direction
	ld a, [wBeforeViewMapDirection]
	srl a
	srl a
	maskbits NUM_DIRECTIONS
	ld b, SPRITEMOVEDATA_STANDING_DOWN
	add b
	ld [wMapObject{d:LAST_OBJECT}Movement], a

; display mocked player object
; it will go to the last wMapObjects slot and to whichever wObjectStructs slot
; wObjectStructs[n][MAPOBJECT_OBJECT_STRUCT_ID] links both structs
	ld a, NUM_OBJECTS - 1
	call UnmaskCopyMapObjectStruct
	ret

.DefaultPlayerObject:
	db -1 ; MAPOBJECT_OBJECT_STRUCT_ID
	object_event  0,  0, SPRITE_CHRIS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED,  OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1

.PlayerObjectFields:
; [wPlayerGender], [wPlayerState], sprite id, palette
	db 0,                          PLAYER_NORMAL, SPRITE_CHRIS,      PAL_NPC_RED << 4 | OBJECTTYPE_SCRIPT
	db 1 << PLAYERGENDER_FEMALE_F, PLAYER_NORMAL, SPRITE_KRIS,       PAL_NPC_BLUE << 4 | OBJECTTYPE_SCRIPT
	db 0,                          PLAYER_SURF,   SPRITE_SURF,       PAL_NPC_RED << 4 | OBJECTTYPE_SCRIPT
	db 1 << PLAYERGENDER_FEMALE_F, PLAYER_SURF,   SPRITE_SURF,       PAL_NPC_BLUE << 4 | OBJECTTYPE_SCRIPT
	db 0,                          PLAYER_BIKE,   SPRITE_CHRIS_BIKE, PAL_NPC_RED << 4 | OBJECTTYPE_SCRIPT
	db 1 << PLAYERGENDER_FEMALE_F, PLAYER_BIKE,   SPRITE_KRIS_BIKE,  PAL_NPC_BLUE << 4 | OBJECTTYPE_SCRIPT
	db -1

GetSouthConnectedSpriteCoords:
; ycoord / 2 <= 2
	ld a, e
	srl a
	cp 3
	ret nc
; [wSouthConnectionStripLocation]
	ld hl, wSouthConnectionStripLocation
	ld a, [hli]
	ld h, [hl]
	ld l, a
; + (xcoord / 2)
	srl d
	ld b, 0
	ld c, d
	add hl, bc
; + ([wMapWidth] + 6) * ycoord / 2
	ld a, [wMapWidth]
	add 6
	ld c, a
	ld b, 0
	srl e
	ld a, e
	and a
	jr z, .done
.loop
	add hl, bc
	dec a
	jr nz, .loop
.done
	call ConvertConnectedOverworldMapBlockAddressToXYCoords
	ret

GetNorthConnectedSpriteCoords:
; wNorthConnectedMapHeight >= 3
; ycoord / 2 >= ([wNorthConnectedMapHeight] - 3)
	ld a, [wNorthConnectedMapHeight]
	sub 3
	jr c, .nope
	ld c, a
	ld a, e
	srl a
	sub c
	jr c, .nope
	ld e, a ; e = ycoord / 2 - ([wNorthConnectedMapHeight] - 3)
; [wNorthConnectionStripLocation]
	ld hl, wNorthConnectionStripLocation
	ld a, [hli]
	ld h, [hl]
	ld l, a
; + (xcoord / 2)
	srl d
	ld b, 0
	ld c, d
	add hl, bc
; + ([wMapWidth] + 6) * {ycoord / 2 - ([wNorthConnectedMapHeight] - 3)} --> + ([wMapWidth] + 6) * e
	ld a, [wMapWidth]
	add 6
	ld c, a
	ld b, 0
	ld a, e
	and a
	jr z, .done
.loop
	add hl, bc
	dec a
	jr nz, .loop
.done
	call ConvertConnectedOverworldMapBlockAddressToXYCoords
	ret
.nope
	xor a
	ret ; nc

GetEastConnectedSpriteCoords:
; xcoord / 2 <= 2
	ld a, d
	srl a
	cp 3
	ret nc
; [wEastConnectionStripLocation]
	ld hl, wEastConnectionStripLocation
	ld a, [hli]
	ld h, [hl]
	ld l, a
; + (xcoord / 2)
	srl d
	ld b, 0
	ld c, d
	add hl, bc
; + ([wMapWidth] + 6) * ycoord / 2
	ld a, [wMapWidth]
	add 6
	ld c, a
	ld b, 0
	srl e
	ld a, e
	and a
	jr z, .done
.loop
	add hl, bc
	dec a
	jr nz, .loop
.done
	call ConvertConnectedOverworldMapBlockAddressToXYCoords
	ret

GetWestConnectedSpriteCoords:
; wWestConnectedMapWidth >= 3
; xcoord / 2 >= ([wWestConnectedMapWidth] - 3)
	ld a, [wWestConnectedMapWidth]
	sub 3
	jr c, .nope
	ld c, a
	ld a, d
	srl a
	sub c
	jr c, .nope
	ld d, a ; d = xcoord / 2 - ([wWestConnectedMapWidth] - 3)
; [wWestConnectionStripLocation]
	ld hl, wWestConnectionStripLocation
	ld a, [hli]
	ld h, [hl]
	ld l, a
; + xcoord / 2 - ([wWestConnectedMapWidth] - 3) --> + d
	ld c, d
	ld b, 0
	add hl, bc
; + ([wMapWidth] + 6) * ycoord / 2
	ld a, [wMapWidth]
	add 6
	ld c, a
	ld b, 0
	srl e
	ld a, e
	and a
	jr z, .done
.loop
	add hl, bc
	dec a
	jr nz, .loop
.done
	call ConvertConnectedOverworldMapBlockAddressToXYCoords
	ret
.nope
	xor a
	ret ; nc

; load into wPlayerMockYCoord and wPlayerMockXCoord the coordinates
; that correspond to wOverworldMapBlocks address at hl.
ConvertConnectedOverworldMapBlockAddressToXYCoords:
	ld bc, -wOverworldMapBlocks + $10000
	add hl, bc
	ld a, [wMapWidth]
	add 6
	xor $ff
	inc a
	ld c, a
	ld b, $ff
	ld d, -2 ;
.calc_y_coord_loop
	inc d    ;
	inc d    ; each block in wOverworldMapBlocks occupies two half-blocks
	add hl, bc
	ld a, h
	cp $ff
	jr nz, .calc_y_coord_loop
; for X, we want the value of l in the second-to-last iteration of the previous loop,
; so undo the last iteration in l by adding [wMapWidth]+6 to it
	ld a, [wMapWidth]
	add 6
	add l
	add a ; each block in wOverworldMapBlocks occupies two half-blocks
; substract 6 tiles from y, substract 6 tiles from x.
; the '6's correspond to the 3 extra blocks in each margin of wOverworldMapBlocks.
	sub 6
	ld [wPlayerMockXCoord], a
	ld a, d
	sub 6
	ld [wPlayerMockYCoord], a
	call CheckPlayerMockSpriteOutOfScreen
	ret ; c or nc

; return nc if either X or Y coord is too negative to be visible in the screen.
; this corresponds to half-block coords -5 and -6, which are visible by wOverworldMapBlocks,
; but not by the map sprite engine when it adds 4 to X and to Y to obtain wPlayerObject coords.
CheckPlayerMockSpriteOutOfScreen:
	ld a, [wPlayerMockXCoord]
	ld b, a
	ld a, [wPlayerMockYCoord]
	ld c, a
	ld a, -5
	cp b
	ret z ; nc
	cp c
	ret z ; nc
	dec a ; -6
	cp b
	ret z ; nc
	cp c
	ret z ; nc
	scf
	ret
