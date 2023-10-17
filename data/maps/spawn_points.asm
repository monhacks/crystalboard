MACRO spawn
; map, x, y
	map_id \1
	db \2, \3
ENDM

SpawnPoints:
; entries correspond to SPAWN_* constants (see constants/map_data_constants.asm)
	table_width 4, SpawnPoints

	spawn LEVEL_1_MAP_1,               3,  3  ; SPAWN_LEVEL_1
;	spawn LEVEL_2_MAP_1,               5,  3  ; SPAWN_LEVEL_2
if DEF(_DEBUG)
	spawn DEBUGLEVEL_1_MAP_1,          3,  3  ; SPAWN_DEBUGLEVEL_1
	spawn DEBUGLEVEL_2_MAP_1,          3,  3  ; SPAWN_DEBUGLEVEL_2
	spawn DEBUGLEVEL_3_MAP_1,          3,  3  ; SPAWN_DEBUGLEVEL_3
	spawn DEBUGLEVEL_4_MAP_1,          3,  3  ; SPAWN_DEBUGLEVEL_4
	spawn DEBUGLEVEL_5_MAP_1,          2,  4  ; SPAWN_DEBUGLEVEL_5
endc
	spawn N_A,                        -1, -1

	assert_table_length NUM_SPAWNS + 1
