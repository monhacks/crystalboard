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

	spawn N_A,                        -1, -1

	assert_table_length NUM_SPAWNS + 1
