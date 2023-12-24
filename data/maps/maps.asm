MACRO map
;\1: map name: for the MapAttributes pointer (see data/maps/attributes.asm)
;\2: tileset: a TILESET_* constant
;\3: environment: TOWN, ROUTE, INDOOR, CAVE, ENVIRONMENT_5, GATE, or DUNGEON
;\4: location: a LANDMARK_* constant
;\5: music: a MUSIC_* constant
;\6: phone service flag: TRUE to prevent phone calls
;\7: time of day: a PALETTE_* constant
;\8: fishing group: a FISHGROUP_* constant
;\9: base coins: 8-bit value
	db BANK(\1_MapAttributes), \2, \3
	dw \1_MapAttributes
	db \4, \5
	dn \6, \7
	db \8
	db \9
ENDM

MapGroupPointers::
; pointers to the first map of each map group
	table_width 2, MapGroupPointers
	dw MapGroup_Level1      ;  1
;	dw MapGroup_Level2      ;  2
if DEF(_DEBUG)
	dw MapGroup_DebugLevel1 ;  1
	dw MapGroup_DebugLevel2 ;  2
	dw MapGroup_DebugLevel3 ;  3
	dw MapGroup_DebugLevel4 ;  4
	dw MapGroup_DebugLevel5 ;  5
endc
	assert_table_length NUM_MAP_GROUPS

MapGroup_Level1:
	table_width MAP_LENGTH, MapGroup_Level1
	map Level1_Map1, TILESET_PLAYERS_ROOM, INDOOR_BUILDING, LANDMARK_LEVEL_1, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE, 1
;	map Level1_Map2, TILESET_CHAMPIONS_ROOM, INDOOR_CAVE, LANDMARK_LEVEL_2, MUSIC_GYM, TRUE, PALETTE_NITE | IN_DARKNESS, FISHGROUP_SHORE, 1
	assert_table_length NUM_LEVEL_1_MAPS

; MapGroup_Level2:
; 	table_width MAP_LENGTH, MapGroup_Level2
;	map Level2_Map1 ...
; 	assert_table_length NUM_LEVEL_2_MAPS

if DEF(_DEBUG)
MapGroup_DebugLevel1:
	table_width MAP_LENGTH, MapGroup_DebugLevel1
	map DebugLevel1_Map1, TILESET_PLAYERS_ROOM, INDOOR_BUILDING, LANDMARK_DEBUGLEVEL_1, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE, 1
	assert_table_length NUM_DEBUGLEVEL_1_MAPS

MapGroup_DebugLevel2:
	table_width MAP_LENGTH, MapGroup_DebugLevel2
	map DebugLevel2_Map1, TILESET_BOARD_DEBUG_2, INDOOR_CAVE, LANDMARK_DEBUGLEVEL_2, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_NITE, FISHGROUP_SHORE, 2
	map DebugLevel2_Map2, TILESET_BOARD_DEBUG_2, INDOOR_CAVE, LANDMARK_DEBUGLEVEL_2, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_NITE, FISHGROUP_SHORE, 2
	assert_table_length NUM_DEBUGLEVEL_2_MAPS

MapGroup_DebugLevel3:
	table_width MAP_LENGTH, MapGroup_DebugLevel3
	map DebugLevel3_Map1, TILESET_FOREST, INDOOR_FOREST, LANDMARK_DEBUGLEVEL_3, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_SHORE, 3
	assert_table_length NUM_DEBUGLEVEL_3_MAPS

MapGroup_DebugLevel4:
	table_width MAP_LENGTH, MapGroup_DebugLevel4
	map DebugLevel4_Map1, TILESET_BOARD_DEBUG_1, OUTDOOR_GRASSY, LANDMARK_DEBUGLEVEL_4, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_SHORE, 4
	assert_table_length NUM_DEBUGLEVEL_4_MAPS

MapGroup_DebugLevel5:
	table_width MAP_LENGTH, MapGroup_DebugLevel5
	map DebugLevel5_Map1, TILESET_BOARD_DEBUG_1, OUTDOOR_GRASSY, LANDMARK_DEBUGLEVEL_5, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_SHORE, 5
	assert_table_length NUM_DEBUGLEVEL_5_MAPS
endc