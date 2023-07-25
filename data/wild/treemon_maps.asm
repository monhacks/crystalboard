MACRO treemon_map
	map_id \1
	db \2 ; treemon set
ENDM

TreeMonMaps:
	treemon_map N_A,             TREEMON_SET_KANTO
	db -1

RockMonMaps:
	treemon_map N_A,             TREEMON_SET_ROCK
	db -1
