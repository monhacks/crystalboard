BoardSpaceScripts:: ; used only for BANK(BoardSpaceScripts)

BlueSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .done
.done
	end

RedSpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .done
.done
	end

GreySpaceScript::
	scall ArriveToRegularSpaceScript
	iftrue .done
.done
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
