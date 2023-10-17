	object_const_def
	const LEVEL1_MAP1_CONSOLE
	const LEVEL1_MAP1_DOLL_1
	const LEVEL1_MAP1_DOLL_2
	const LEVEL1_MAP1_BIG_DOLL
	const LEVEL1_MAP1_TRAINER

Level1_Map1_MapScripts:
	def_scene_scripts

	def_callbacks

Level1_Map1_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7,  0, LEVEL_1_MAP_1, 1

	def_coord_events

	def_bg_events
	bg_event  2,  1, BGEVENT_UP, Level1_Map1_PCScript
	bg_event  3,  1, BGEVENT_READ, Level1_Map1_RadioScript
	bg_event  5,  1, BGEVENT_READ, Level1_Map1_BookshelfScript
	bg_event  6,  0, BGEVENT_IFSET, Level1_Map1_PosterScript

	def_object_events
	object_event  4,  2, SPRITE_CONSOLE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Level1_Map1_GameConsoleScript, -1
	object_event  4,  4, SPRITE_DOLL_1, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Level1_Map1_Doll1Script, -1
	object_event  5,  4, SPRITE_DOLL_2, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Level1_Map1_Doll2Script, -1
	object_event  0,  1, SPRITE_BIG_DOLL, SPRITEMOVEDATA_BIGDOLL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Level1_Map1_BigDollScript, -1
	object_event  6,  6, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, Level1_Map1_TrainerYoungsterMikey, -1

Level1_Map1_MapSpaces:

Level1_Map1_Doll1Script::
	opentext
	callasm .BoardMenu
	waitbutton
	pokemart MARTTYPE_STANDARD, MART_AZALEA
	closetext
	end
.BoardMenu:
	farcall BoardMenu
	ret
;	describedecoration DECODESC_LEFT_DOLL

Level1_Map1_Doll2Script:
	jumpstd PokecenterNurseScript
;	describedecoration DECODESC_RIGHT_DOLL

Level1_Map1_BigDollScript:
	jumpstd PCScript
;	describedecoration DECODESC_BIG_DOLL

Level1_Map1_GameConsoleScript:
	randomwildmon
	startbattle
	reloadmapafterbattle
	end
;	describedecoration DECODESC_CONSOLE

Level1_Map1_PosterScript:
	describedecoration DECODESC_POSTER

Level1_Map1_RadioScript:
	jumpstd Radio1Script

Level1_Map1_BookshelfScript:
	jumpstd PictureBookshelfScript

Level1_Map1_PCScript:
	opentext
	special PlayersHousePC
	iftrue .Warp
	closetext
	end
.Warp:
	warp NONE, 0, 0
	end

Level1_Map1_TrainerYoungsterMikey:
	trainer YOUNGSTER, MIKEY, EVENT_DECO_BED_1, .YoungsterMikeySeenText, .YoungsterMikeyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext .YoungsterMikeyAfterText
	waitbutton
	closetext
	end


.YoungsterMikeySeenText:
	text "You're a #MON"
	line "trainer, right?"

	para "Then you have to"
	line "battle!"
	done

.YoungsterMikeyBeatenText:
	text "That's strange."
	line "I won before."
	done

.YoungsterMikeyAfterText:
	text "Becoming a good"
	line "trainer is really"
	cont "tough."

	para "I'm going to bat-"
	line "tle other people"
	cont "to get better."
	done
