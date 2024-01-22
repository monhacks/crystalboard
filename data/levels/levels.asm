MACRO level_unlock_req

; a list of levels that must be cleared (each must be in the form of: <Level>, STAGE_*_F)
if !STRCMP("\1", "LEVELS_CLEARED")
	db UNLOCK_WHEN_\1
	rept (_NARG - 1) / 2
		db \2, \3
		shift
		shift
	endr

; an amount of levels that must be cleared (regardless of stage)
elif !STRCMP("\1", "NUMBER_OF_LEVELS_CLEARED")
	db UNLOCK_WHEN_\1
	db \2

; a bitfield list of techniques that must be cleared
elif !STRCMP("\1", "TECHNIQUES_CLEARED")
	db UNLOCK_WHEN_\1
	assert (_NARG - 1) == (NUM_TECHNIQUES + 7) / 8
	rept _NARG - 1
		db \2
		shift
	endr

; else no requirements
endc
	db $ff
	REDEF x += 1
ENDM

LevelUnlockRequirements:
DEF x = 0
	level_unlock_req NONE ; LEVEL_1 (irrelevant)
if DEF(_DEBUG)
	level_unlock_req NONE ; DEBUGLEVEL_1
	level_unlock_req LEVELS_CLEARED, DEBUGLEVEL_1, STAGE_1_F ; DEBUGLEVEL_2
	level_unlock_req LEVELS_CLEARED, DEBUGLEVEL_2, STAGE_1_F ; DEBUGLEVEL_3
;	level_unlock_req LEVELS_CLEARED, DEBUGLEVEL_3, STAGE_1_F ; DEBUGLEVEL_4
;	level_unlock_req LEVELS_CLEARED, DEBUGLEVEL_4, STAGE_1_F ; DEBUGLEVEL_5
	level_unlock_req NUMBER_OF_LEVELS_CLEARED, 3 ; DEBUGLEVEL_4
	level_unlock_req TECHNIQUES_CLEARED, TECHNIQUE_FLASH | TECHNIQUE_WATERFALL ; DEBUGLEVEL_5
endc
	assert x == NUM_LEVELS
