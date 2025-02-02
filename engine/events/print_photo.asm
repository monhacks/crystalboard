PhotoStudio:
	ld hl, .WhichMonPhotoText
	call PrintText2bpp
	farcall SelectMonFromParty
	jr c, .cancel
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg

	ld hl, .HoldStillText
	call PrintText2bpp
	call DisableSpriteUpdates
	farcall PrintPartymon
	call ReturnToMapWithSpeechTextbox
	ldh a, [hPrinter]
	and a
	jr nz, .cancel
	ld hl, .PrestoAllDoneText
	jr .print_text

.cancel
	ld hl, .NoPhotoText
	jr .print_text

.egg
	ld hl, .EggPhotoText

.print_text
	call PrintText2bpp
	ret

.WhichMonPhotoText:
	text_far _WhichMonPhotoText
	text_end

.HoldStillText:
	text_far _HoldStillText
	text_end

.PrestoAllDoneText:
	text_far _PrestoAllDoneText
	text_end

.NoPhotoText:
	text_far _NoPhotoText
	text_end

.EggPhotoText:
	text_far _EggPhotoText
	text_end
