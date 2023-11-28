TalkToTrainerScript::
	faceplayer
	trainerortalkerflagaction CHECK_FLAG
	iftrue AlreadyBeatenTrainerScript
	loadtemptrainer
	encountermusic
	sjump StartBattleWithMapTrainerScript

SeenByTrainerScript::
	loadtemptrainer
	waitsfx ; wait for any pending space-related sfx
	encountermusic
	showemote EMOTE_SHOCK, LAST_TALKED, 30
	callasm TrainerOrTalkerWalkToPlayer
	applymovementlasttalked wMovementBuffer
	writeobjectxy LAST_TALKED
	faceobject PLAYER, LAST_TALKED
	sjump StartBattleWithMapTrainerScript

StartBattleWithMapTrainerScript:
	opentext
	trainertext TRAINERTEXT_SEEN
	waitbutton
	closetext
	loadtemptrainer
	startbattle
	reloadmapafterbattle
	trainerortalkerflagaction SET_FLAG
	loadmem wRunningTrainerBattleScript, -1

AlreadyBeatenTrainerScript:
	scripttalkafter

SeenByTalkerScript::
	waitsfx ; wait for any pending space-related sfx
	showemote EMOTE_TALK, LAST_TALKED, 20
	callasm .TalkOrSkipTalker
	iffalse .skipped
	callasm TrainerOrTalkerWalkToPlayer
	applymovementlasttalked wMovementBuffer
	writeobjectxy LAST_TALKED
	faceobject PLAYER, LAST_TALKED
.skipped
	end

.TalkOrSkipTalker:
	ld a, [wTempTalkerType]
	and %1
	cp TALKEREVENTTYPE_MANDATORY
	jr z, .skip
	call WaitButton
	call PlayClickSFX
	call WaitSFX
	ldh a, [hJoyPressed]
	bit A_BUTTON_F, a
	jr z, .skip ; jump if b was pressed
	ld a, TRUE
	jr .done
.skip
	xor a ; FALSE
.done
	ld [hScriptVar], a
	ret
