	object_const_def

DebugLevel2_Map1_MapScripts:
	def_scene_scripts

	def_callbacks

DebugLevel2_Map1_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  6, 17, DEBUGLEVEL_4_MAP_1, 1
	warp_event  6,  8, DEBUGLEVEL_2_MAP_1, 3
	warp_event 19,  2, DEBUGLEVEL_2_MAP_1, 2
	warp_event 27,  2, DEBUGLEVEL_2_MAP_1, 5
	warp_event 27, 17, DEBUGLEVEL_2_MAP_1, 4

	def_anchor_events
	anchor_event  6, 17,  0
	anchor_event 19,  2,  4
	anchor_event 27, 17,  GO_UP
	anchor_event 27, 14,  7

	def_coord_events

	def_bg_events

	def_object_events

DebugLevel2_Map1_MapSpaces:
	space  6, 16,  $0,  1 ;  0
	space  6, 14,  $0,  2 ;  1
	space  6, 12,  $0,  3 ;  2
	space  6, 10,  $0,  GO_UP ;  3
	space 20,  2,  $0,  5 ;  4
	space 22,  2,  $0,  6 ;  5
	space 24,  2,  $0,  GO_RIGHT ;  6
	space 26, 14,  $0,  8 ;  7
	space 24, 14,  $0,  9 ;  8
	space 22, 14,  $0, 10 ;  9
	space 20, 14,  $0, 11 ; 10
	space 20, 16,  $0, 12 ; 11
	space 20, 18,  $0, 12 ; 12
