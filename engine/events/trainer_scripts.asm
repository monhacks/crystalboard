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
	trainerortalkertext TRAINERORTALKERTEXT_TRAINER_SEEN
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
;	playsound SFX_
	showemote EMOTE_TALK, LAST_TALKED, 20
	callasm .TalkOrSkipTalker
	iffalse .skipped
	callasm TrainerOrTalkerWalkToPlayer
	applymovementlasttalked wMovementBuffer
	writeobjectxy LAST_TALKED
	faceobject PLAYER, LAST_TALKED
	callasm .GetTalkerType
	ifequal TALKERTYPE_TEXT,   .Text
	ifequal TALKERTYPE_SCRIPT, .Script
.skipped
	trainerortalkerflagaction SET_FLAG
	end

.Text
	opentext
	trainerortalkertext TRAINERORTALKERTEXT_TALKER
	waitbutton
	closetext
	trainerortalkerflagaction SET_FLAG
	end

.Script
	trainerortalkerflagaction SET_FLAG
	end

.TalkOrSkipTalker:
	ld a, [wTempTalkerType]
	and TALKEREVENTTYPE_MASK
	cp TALKEREVENTTYPE_MANDATORY
	jr z, .skip
	call JoyWaitAorB
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

.GetTalkerType:
	ld a, [wTempTalkerType]
	and TALKERTYPE_MASK
	ld [hScriptVar], a
	ret