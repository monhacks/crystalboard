BackupDisabledSpace:
; unlike map objects which are backed up when leaving a map,
; a disabled space is backed up immediately when it is disabled.
	ld a, [wCurSpace]
	push af

	ld hl, wMapGroup
	ld d, [hl]
	inc hl ; wMapNumber
	ld e, [hl]

	ld a, BANK(wDisabledSpacesBackups)
	ld [rSVBK], a

	ld hl, wMap1DisabledSpacesBackup
	ld bc, wMap2DisabledSpacesBackup - wMap1DisabledSpacesBackup - 2
.loop
	ld a, [hl]
	cp GROUP_N_A
	jr z, .found_available_entry
	and a ; cp $00 (terminator found at wDisabledSpacesBackupsEnd, no more room)
	jr z, .done_pop_af
	cp d ; wMap<N>DisabledSpacesMapGroup == wMapGroup?
	jr nz, .next
	inc hl
	ld a, [hl]
	cp e ; wMap<N>DisabledSpacesMapNumber == wMapNumber?
	jr nz, .next2
	inc hl
	jr .found_matching_entry
.next
	inc hl
.next2
	inc hl
	add hl, bc
	jr .loop

.found_available_entry
	ld [hl], d ; wMapGroup
	inc hl
	ld [hl], e ; wMapNumber
	inc hl
.found_matching_entry
; mark the space at wCurSpace as disabled in the entry with <wMapGroup, wMapNumber>
	pop af
	ld e, a
	ld d, 0
	ld b, SET_FLAG
	call FlagAction
	jr .done

.done_pop_af
	pop af
.done
	ld a, 1
	ld [rSVBK], a
	ret

LoadDisabledSpaces:
; map setup command (called after the map setup command LoadBlockData)
; load blocks with disabled spaces in the active map, and in each of its connected maps.
; for connected maps, only blocks that are in visible range from the active map,
; i.e. those that appear in wOverworldMapBlocks while in the active map.
	ld hl, wMapGroup
	ld d, [hl]
	inc hl
	ld e, [hl] ; wMapNumber
	xor a ; active map
	ld [wTempByteValue], a
	call _LoadDisabledSpaces

	ld hl, wNorthConnectedMapGroup
	ld a, [hli]
	cp GROUP_N_A
	jr z, .south
	ld d, a    ; wNorthConnectedMapGroup
	ld e, [hl] ; wNorthConnectedMapNumber
	ld a, 1 ; north connected map
	ld [wTempByteValue], a
	call _LoadDisabledSpaces
.south

	ld hl, wSouthConnectedMapGroup
	ld a, [hli]
	cp GROUP_N_A
	jr z, .west
	ld d, a    ; wSouthConnectedMapGroup
	ld e, [hl] ; wSouthConnectedMapNumber
	ld a, 2 ; south connected map
	ld [wTempByteValue], a
	call _LoadDisabledSpaces
.west

	ld hl, wWestConnectedMapGroup
	ld a, [hli]
	cp GROUP_N_A
	jr z, .east
	ld d, a    ; wWestConnectedMapGroup
	ld e, [hl] ; wWestConnectedMapNumber
	ld a, 3 ; west connected map
	ld [wTempByteValue], a
	call _LoadDisabledSpaces
.east

	ld hl, wEastConnectedMapGroup
	ld a, [hli]
	cp GROUP_N_A
	jr z, .done
	ld d, a    ; wEastConnectedMapGroup
	ld e, [hl] ; wEastConnectedMapNumber
	ld a, 4 ; east connected map
	ld [wTempByteValue], a
	call _LoadDisabledSpaces
.done
	ret

_LoadDisabledSpaces:
	ld a, BANK(wDisabledSpacesBackups)
	ld [rSVBK], a

	ld hl, wMap1DisabledSpacesBackup
	ld bc, wMap2DisabledSpacesBackup - wMap1DisabledSpacesBackup - 2
.find_loop
	ld a, [hl]
	cp GROUP_N_A
	jr z, .no_match
	and a ; cp $00 (terminator found at wDisabledSpacesBackupsEnd)
	jr z, .no_match
	cp d
	jr nz, .next
	inc hl
	ld a, [hl]
	cp e
	jr nz, .next2
	inc hl
	jr .found_matching_entry
.next
	inc hl
.next2
	inc hl
	add hl, bc
	jr .find_loop

.found_matching_entry
; temporarily load wMapScriptsBank, wMapSpacesPointer for this map,
; so that we can later can call LoadTempSpaceData in the context of this map.
	ld a, 1
	ld [rSVBK], a
	ld a, [wMapGroup]
	push af
	ld a, [wMapNumber]
	push af
	ld a, d
	ld [wMapGroup], a
	ld a, e
	ld [wMapNumber], a
	push hl
	call CopyMapPartialAndAttributesPartial
	pop hl
	ld a, BANK(wDisabledSpacesBackups)
	ld [rSVBK], a

; loop through all MAX_SPACES_PER_MAP flags and call .ApplyDisabledSpace in the disabled spaces.
	xor a
.apply_loop_2
	ld e, [hl]
	inc hl
.apply_loop_1
	srl e
	call c, .ApplyDisabledSpace
	inc a
	cp MAX_SPACES_PER_MAP
	jr z, .done ; return when all MAX_SPACES_PER_MAP flags checked
	ld d, a
	and %111
	ld a, d
	jr z, .apply_loop_2 ; jump if done with current batch of 8 flags
	jr .apply_loop_1

.done
	ld a, 1
	ld [rSVBK], a
; restore active map attributes
	pop af
	ld [wMapNumber], a
	pop af
	ld [wMapGroup], a
	call CopyMapPartialAndAttributesPartial
	ret

.no_match
	ld a, 1
	ld [rSVBK], a
	ret

.ApplyDisabledSpace:
	push af
	push de
	push hl
	ld e, a
	ld a, 1
	ld [rSVBK], a
	ld a, e ; a = space to apply as disabled
	call LoadTempSpaceData
	ld hl, .return
	push hl
	jumptable .Jumptable, wTempByteValue
.return
	jr nc, .connected_block_not_in_range
	ld a, [hl]
	and UNIQUE_SPACE_METATILES_MASK
	add FIRST_GREY_SPACE_METATILE
	ld [hl], a
.connected_block_not_in_range
	ld a, BANK(wDisabledSpacesBackups)
	ld [rSVBK], a
	pop hl
	pop de
	pop af
	ret

.Jumptable:
	dw .ActiveMap
	dw .NorthConnectedMap
	dw .SouthConnectedMap
	dw .WestConnectedMap
	dw .EastConnectedMap

.ActiveMap:
	ld a, [wTempSpaceXCoord]
	add 4
	ld d, a
	ld a, [wTempSpaceYCoord]
	add 4
	ld e, a
	call GetBlockLocation
	scf
	ret

.NorthConnectedMap:
	ld a, [wTempSpaceXCoord]
	ld d, a
	ld a, [wTempSpaceYCoord]
	ld e, a
	call GetNorthConnectedBlockLocation
	ret

.SouthConnectedMap:
	ld a, [wTempSpaceXCoord]
	ld d, a
	ld a, [wTempSpaceYCoord]
	ld e, a
	call GetSouthConnectedBlockLocation
	ret

.WestConnectedMap:
	ld a, [wTempSpaceXCoord]
	ld d, a
	ld a, [wTempSpaceYCoord]
	ld e, a
	call GetWestConnectedBlockLocation
	ret

.EastConnectedMap:
	ld a, [wTempSpaceXCoord]
	ld d, a
	ld a, [wTempSpaceYCoord]
	ld e, a
	call GetEastConnectedBlockLocation
	ret

GetSouthConnectedBlockLocation:
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
	scf
	ret ; c

GetNorthConnectedBlockLocation:
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
	scf
	ret ; c
.nope
	xor a
	ret ; nc

GetEastConnectedBlockLocation:
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
	scf
	ret ; c

GetWestConnectedBlockLocation:
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
	scf
	ret ; c
.nope
	xor a
	ret ; nc
