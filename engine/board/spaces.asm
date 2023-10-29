BoardSpaceScripts:: ; used only for BANK(BoardSpaceScripts)

BlueSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 400
	scall LandedInRegularSpaceScript
.not_landed
	end

RedSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 400
	scall LandedInRegularSpaceScript
.not_landed
	end

GreenSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 400
	scall LandedInRegularSpaceScript
.not_landed
	end

ItemSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 400
	scall LandedInRegularSpaceScript
.not_landed
	end

PokemonSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 600
	loadpikachudata
	startbattle
	reloadmapafterbattle
	wait 100
	scall LandedInRegularSpaceScript
.not_landed
	end

MinigameSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	wait 600
	scall LandedInRegularSpaceScript
.not_landed
	end

EndSpaceScript::
; fading out will kick before reaching HandleMapBackground, so update sprites after any change
	scall ArriveToRegularSpaceScript
	wait 400
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
	scall LandedInRegularSpaceScript
.not_landed
	end

ArriveToRegularSpaceScript:
	playsound SFX_PRESENT
	callasm ArriveToRegularSpace
	end

ArriveToRegularSpace:
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

LandedInRegularSpaceScript:
	callasm LandedInRegularSpace
	end

LandedInRegularSpace:
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
; trigger end of turn
	ld a, BOARDEVENT_END_TURN
	ldh [hCurBoardEvent], a
	ret

BranchSpaceScript::
	scall .ArriveToBranchSpaceScript
.prompt_player
	callasm .PromptPlayerToChooseDirection
	iffalse .print_technique_required
	wait 200
	end

.print_technique_required
	opentext
	writetext .TechniqueRequiredText
	waitbutton
	closetext
	sjump .prompt_player

.TechniqueRequiredText:
	text "A new TECHNIQUE is"
	line "required!"
	done

.ArriveToBranchSpaceScript:
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

.PromptPlayerToChooseDirection:
; sample a dpad press
	ld hl, wTempSpaceBranchStruct
	call GetJoypad
	ldh a, [hJoyPressed]
	and D_PAD
	jr z, .PromptPlayerToChooseDirection

; determine the status (ok/invalid/unavailable) of the chosen direction
	bit D_RIGHT_F, a
	jr z, .not_right
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, .PromptPlayerToChooseDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_right

	inc hl
	bit D_LEFT_F, a
	jr z, .not_left
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, .PromptPlayerToChooseDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_left

	inc hl
	bit D_UP_F, a
	jr z, .not_up
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, .PromptPlayerToChooseDirection
	inc a ; cp BRANCH_DIRECTION_UNAVAILABLE
	jr z, .technique_required
	jr .direction_chosen
.not_up

	inc hl
	ld a, [hl]
	inc a ; cp BRANCH_DIRECTION_INVALID
	jr z, .PromptPlayerToChooseDirection
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

UnionSpaceScript::
	callasm .ArriveToUnionSpace
	end

.ArriveToUnionSpace:
; these are just transition spaces, so simply load the next space
	ld a, [wCurSpaceNextSpace]
	ld [wCurSpace], a
	call LoadCurSpaceData
	end
