BoardSpaceScripts:: ; used only for BANK(BoardSpaceScripts)

BlueSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript
.not_landed
	end

RedSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript
.not_landed
	end

GreenSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript
.not_landed
	end

ItemSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
	scall LandedInRegularSpaceScript
.not_landed
	end

PokemonSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .not_landed
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
	iftrue .not_landed
	wait 600
.not_landed
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
