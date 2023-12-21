BoardSpaceScripts:: ; used only for BANK(BoardSpaceScripts)

BlueSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

RedSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

GreenSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

ItemSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

PokemonSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	wait 200
	loadpikachudata
	startbattle
	reloadmapafterbattle
	wait 100
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

MinigameSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	wait 200
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

EndSpaceScript::
; fading out will kick before reaching HandleMapBackground, so update sprites after any change
	scall ArriveToRegularSpaceScript
	scall LandedInRegularSpaceScript_BeforeSpaceEffect
	playmusic MUSIC_TRAINER_VICTORY
	wait 600
	callasm .FadeOutSlow ; 800 ms
	wait 400
	exitoverworld CLEARED_LEVEL
	endall

.FadeOutSlow:
; clear spaces left sprites
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_SPACES_LEFT_F, [hl]
	call UpdateActiveSprites
; fade out slow to white
	ld b, RGBFADE_TO_WHITE_8BGP_8OBP
	jp DoRGBFadeEffect

GreySpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 300
	turnobject PLAYER, DOWN
	wait 100
	scall LandedInRegularSpaceScript_AfterSpaceEffect
.not_landed
	end

ArriveToRegularSpaceScript:
	playsound SFX_PRESENT
	callasm .ArriveToRegularSpace
	end

.ArriveToRegularSpace:
; load new space
	ld a, [wCurSpaceNextSpace]
	ld [wCurSpace], a
	call LoadCurSpaceData
; decrease wSpacesLeft and copy to hScriptVar
	ld hl, wSpacesLeft
	dec [hl]
	ld a, [hl]
	ld [hScriptVar], a
; if landed, clear spaces left sprites
	and a
	jr nz, .not_landed
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_SPACES_LEFT_F, [hl]
.not_landed
; update sprites
	jp UpdateActiveSprites

LandedInRegularSpaceScript_BeforeSpaceEffect:
	wait 300
	turnobject PLAYER, DOWN
	wait 100
	end

LandedInRegularSpaceScript_AfterSpaceEffect:
	callasm .LandedInRegularSpace
	end

.LandedInRegularSpace:
; disable the space effect (turn the space into a grey space)
	ld a, [wCurSpaceXCoord]
	add 4
	ld d, a
	ld a, [wCurSpaceYCoord]
	add 4
	ld e, a
	call GetBlockLocation
	ld a, [hl]
	and UNIQUE_SPACE_METATILES_MASK
	add FIRST_GREY_SPACE_METATILE
	ld [hl], a
; backup the disabled space to preserve it on map reload
	call BackupDisabledSpace
; trigger end of turn
	ld a, BOARDEVENT_END_TURN
	ldh [hCurBoardEvent], a
	ret

BranchSpaceScript::
	scall ArriveToBranchSpaceScript
BranchSpaceScript_PromptPlayer::
	callasm PromptPlayerToChooseBranchDirection
	iffalse .print_technique_required
	wait 200
	end

.print_technique_required
	opentext
	writetext .TechniqueRequiredText
	waitbutton
	closetext
	sjump BranchSpaceScript_PromptPlayer

.TechniqueRequiredText:
	text "A new TECHNIQUE is"
	line "required!"
	done

ArriveToBranchSpaceScript:
	playsound SFX_TWINKLE
	wait 400
	callasm .ArriveToBranchSpace
	end

.ArriveToBranchSpace:
; load new space
	ld a, [wCurSpaceNextSpace]
	ld [wCurSpace], a
; unlike in other cases, wCurSpaceNextSpace will not yet
; contain the next space after calling LoadCurSpaceData.
; it will be defined after the player has chosen which direction to take.
	call LoadCurSpaceData
; load the space's branch data
	call LoadTempSpaceBranchData
	call .DisableDirectionsRequiringLockedTechniques
; draw arrows for valid directions
	farcall LoadBranchArrowsGFX
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_BRANCH_ARROWS_F, [hl]
; update sprites
	jp UpdateActiveSprites

.DisableDirectionsRequiringLockedTechniques:
; set to BRANCH_DIRECTION_UNAVAILABLE each next space byte of the branch struct
; that has an unavailable direction due to required techniques not yet unlocked.
	ld hl, wTempSpaceBranchStruct + NUM_DIRECTIONS
	ld de, wTempSpaceBranchStruct
	ld bc, wUnlockedTechniques
rept NUM_DIRECTIONS
	ld a, [bc]
	and [hl]
	cp [hl]
	jr z, .next\@
	ld a, BRANCH_DIRECTION_UNAVAILABLE
	ld [de], a
.next\@
	inc hl
	inc de
endr
	ret

PromptPlayerToChooseBranchDirection:
; sample a dpad press or SELECT button
	ld hl, wTempSpaceBranchStruct
	call GetJoypad
	ldh a, [hJoyPressed]
	and D_PAD | SELECT
	jr z, PromptPlayerToChooseBranchDirection

	cp SELECT ; check if SELECT pressed along with no dpad key
	jr nz, .not_select
	jp .EnterViewMapMode

.not_select
; determine the status (ok/invalid/unavailable) of the chosen direction
	bit D_RIGHT_F, a
	jr z, .not_right
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, PromptPlayerToChooseBranchDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_right

	inc hl
	bit D_LEFT_F, a
	jr z, .not_left
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, PromptPlayerToChooseBranchDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_left

	inc hl
	bit D_UP_F, a
	jr z, .not_up
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, PromptPlayerToChooseBranchDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_up

	inc hl
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, PromptPlayerToChooseBranchDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	; fallthrough

.direction_chosen
; save the next space of the chosen direction to wCurSpaceNextSpace
	ld a, [hl]
	ld [wCurSpaceNextSpace], a
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_BRANCH_ARROWS_F, [hl]
	ld a, TRUE
	ldh [hScriptVar], a
	jp PlayClickSFX

.technique_required
	xor a ; FALSE
	ldh [hScriptVar], a
	jp PlayClickSFX

.EnterViewMapMode:
	call BackupMapObjectsOnEnterViewMapMode
	ld a, BOARDEVENT_VIEW_MAP_MODE
	ldh [hCurBoardEvent], a
	ld a, 100
	ld [wViewMapModeRange], a
	ld a, [wMapGroup]
	ld [wBeforeViewMapMapGroup], a
	ld a, [wMapNumber]
	ld [wBeforeViewMapMapNumber], a
	ld a, [wXCoord]
	ld [wBeforeViewMapXCoord], a
	ld a, [wYCoord]
	ld [wBeforeViewMapYCoord], a
	xor a
	ld [wViewMapModeDisplacementY], a
	ld [wViewMapModeDisplacementX], a
	call DisableOverworldHUD
	ld hl, wPlayerFlags
	set INVISIBLE_F, [hl]
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_SPACES_LEFT_F, [hl]
	res SECONDARYSPRITES_BRANCH_ARROWS_F, [hl]
	farcall MockPlayerObject
	call UpdateSprites
	farcall LoadViewMapModeGFX
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_VIEW_MAP_MODE_F, [hl]
	ld a, TRUE
	ldh [hScriptVar], a
	jp PlayClickSFX

UnionSpaceScript::
	callasm .ArriveToUnionSpace
	end

.ArriveToUnionSpace:
; these are just transition spaces, so simply load the next space
	ld a, [wCurSpaceNextSpace]
	ld [wCurSpace], a
	call LoadCurSpaceData
	ret

BackupDisabledSpace::
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
.EastConnectedMap:
	xor a
	ret
