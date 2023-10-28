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
	callasm .PromptPlayerToChooseDirection
	wait 200
	end

.ArriveToBranchSpaceScript:
	playsound SFX_TWINKLE
	wait 400
	callasm .ArriveToBranchSpace
	end

.ArriveToBranchSpace:
; load new space
	ld a, [wCurSpaceNextSpace]
	ld [wCurSpace], a
	call LoadCurSpaceData
; load its branch data
	call LoadTempSpaceBranchData
	call .DisableDirectionsRequiringLockedTechniques
; draw arrows for valid directions
	farcall LoadBranchArrowsGFX
	ld hl, wDisplaySecondarySprites
	set SECONDARYSPRITES_BRANCH_ARROWS_F, [hl]
; update sprites
	jp UpdateActiveSprites

.DisableDirectionsRequiringLockedTechniques:
	ret

.PromptPlayerToChooseDirection:
; compute available directions in b as joypad dpad flags
	ld hl, wTempSpaceBranchStruct
	ld b, 0
	ld a, [hli]
	cp -1
	jr z, .not_right
	set D_RIGHT_F, b
.not_right
	ld a, [hli]
	cp -1
	jr z, .not_left
	set D_LEFT_F, b
.not_left
	ld a, [hli]
	cp -1
	jr z, .not_up
	set D_UP_F, b
.not_up
	ld a, [hli]
	cp -1
	jr z, .joypad_loop
	set D_DOWN_F, b

; sample input of an available direction
.joypad_loop
	call GetJoypad
	ldh a, [hJoyPressed]
	and b
	jr z, .joypad_loop

; load the next space for the chosen direction
	ld hl, wTempSpaceBranchStruct
	bit D_RIGHT_F, a
	jr nz, .ok
	inc hl
	bit D_LEFT_F, a
	jr nz, .ok
	inc hl
	bit D_UP_F, a
	jr nz, .ok
	inc hl
.ok
	ld a, [hl]
	ld [wCurSpaceNextSpace], a
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_BRANCH_ARROWS_F, [hl]
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
