TalkToTrainerScript::
	faceplayer
	trainerflagaction CHECK_FLAG
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
	trainerflagaction SET_FLAG
	loadmem wRunningTrainerBattleScript, -1

AlreadyBeatenTrainerScript:
	scripttalkafter

SeenByTalkerScript::
	waitsfx ; wait for any pending space-related sfx
	showemote EMOTE_TALK, LAST_TALKED, 20
	callasm TrainerOrTalkerWalkToPlayer
	applymovementlasttalked wMovementBuffer
	writeobjectxy LAST_TALKED
	faceobject PLAYER, LAST_TALKED
	end
