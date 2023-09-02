Flypoints:
; entries correspond to FLY_* constants
	; landmark, spawn point
	db LANDMARK_LEVEL_1,    SPAWN_LEVEL_1
if DEF(_DEBUG)
	db LANDMARK_DEBUGLEVEL_1,    SPAWN_DEBUGLEVEL_1
endc
	db -1 ; end
