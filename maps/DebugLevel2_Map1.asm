	object_const_def

DebugLevel2_Map1_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_ENDMAPSETUP, .FlashAutoScript

.FlashAutoScript:
	callasm UseFlashAuto
	endcallback

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
	object_event  6, 13, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_ROCK, 0, ObjectEvent, -1
	object_event  5, 12, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_ROCK, 0, ObjectEvent, -1

DebugLevel2_Map1_MapSpaces:
	space  6, 16,  $0,  1 ;  0
	space  6, 14,  $0,  2 ;  1
	space  6, 12,  .BS1   ;  2 .BS1
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

	space  4, 12,  $0, 14 ; 13
	space  2, 12,  $0, 15 ; 14
	space  0, 12,  $0, GO_LEFT ; 15

.BS1:
	branchdir LEFT,   13, 0
	branchdir UP,      3, 0
	endbranch
