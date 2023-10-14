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
	ld hl, wSpacesLeft
	dec [hl]
	ld a, [hl]
	ld [hScriptVar], a
	and a
	jp nz, UpdateSecondarySprites
	ld hl, wDisplaySecondarySprites
	res SECONDARYSPRITES_SPACES_LEFT_F, [hl]
	ret

LandedInRegularSpaceScript:
	callasm LandedInRegularSpace
	end

LandedInRegularSpace:
	ld a, BOARDEVENT_END_TURN
	ldh [hCurBoardEvent], a
	ret
