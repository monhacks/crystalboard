	object_const_def

DebugLevel4_Map1_MapScripts:
	def_scene_scripts

	def_callbacks

DebugLevel4_Map1_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  1, DEBUGLEVEL_2_MAP_1, 1

	def_anchor_events
	anchor_event  4,  7,  0

	def_coord_events

	def_bg_events

	def_object_events

DebugLevel4_Map1_MapSpaces:
	space  4,  6,  $0,  1 ;  0
	space  4,  4,  $0,  2 ;  1
	space  4,  2,  $0,  GO_UP ;  2
