MACRO map
;\1: map name: for the MapAttributes pointer (see data/maps/attributes.asm)
;\2: tileset: a TILESET_* constant
;\3: environment: TOWN, ROUTE, INDOOR, CAVE, ENVIRONMENT_5, GATE, or DUNGEON
;\4: location: a LANDMARK_* constant
;\5: music: a MUSIC_* constant
;\6: phone service flag: TRUE to prevent phone calls
;\7: time of day: a PALETTE_* constant
;\8: fishing group: a FISHGROUP_* constant
	db BANK(\1_MapAttributes), \2, \3
	dw \1_MapAttributes
	db \4, \5
	dn \6, \7
	db \8
ENDM

MapGroupPointers::
; pointers to the first map of each map group
	table_width 2, MapGroupPointers
	dw MapGroup_Level1    ;  1
;	dw MapGroup_Level2    ;  2
	assert_table_length NUM_MAP_GROUPS

MapGroup_Level1:
	table_width MAP_LENGTH, MapGroup_Level1
	map Level1_Map1, TILESET_PLAYERS_ROOM, INDOOR, LANDMARK_LEVEL_1, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE
;	map Level1_Map2, TILESET_CHAMPIONS_ROOM, INDOOR, LANDMARK_LEVEL_2, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE
	assert_table_length NUM_LEVEL_1_MAPS

; MapGroup_Level2:
; 	table_width MAP_LENGTH, MapGroup_Level2
;	map Level2_Map1 ...
; 	assert_table_length NUM_LEVEL_2_MAPS
