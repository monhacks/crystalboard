	object_const_def

DebugLevel5_Map1_MapScripts:
	def_scene_scripts

	def_callbacks

DebugLevel5_Map1_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_anchor_events
	anchor_event 10,  1, GO_RIGHT
	anchor_event 12,  1, 39

	def_coord_events

	def_bg_events

	def_object_events
	object_event 10,  2, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, .DebugLevel5_Map1TrainerYoungsterMikey1, -1
	object_event  9,  2, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TALKER,  2, .DebugLevel5_Map1Talker1, -1
	object_event  6,  1, SPRITE_CUT_TREE, SPRITEMOVEDATA_CUTTABLE_TREE, 0, 0, -1, -1, PAL_NPC_TREE, OBJECTTYPE_TREE, 0, ObjectEvent, -1
	object_event  9,  4, SPRITE_CUT_TREE, SPRITEMOVEDATA_CUTTABLE_TREE, 0, 0, -1, -1, PAL_NPC_TREE, OBJECTTYPE_TREE, 0, ObjectEvent, -1

.DebugLevel5_Map1TrainerYoungsterMikey1:
	trainer YOUNGSTER, MIKEY, EVENT_LEVEL_SCOPED_1, .YoungsterMikeySeenText, .YoungsterMikeyBeatenText, 0, .Script

.DebugLevel5_Map1TrainerYoungsterMikey2:
	trainer YOUNGSTER, MIKEY, EVENT_LEVEL_SCOPED_2, .YoungsterMikeySeenText, .YoungsterMikeyBeatenText, 0, .Script

.DebugLevel5_Map1Talker1:
	talker EVENT_TURN_SCOPED_1, OPTIONAL, SCRIPT, .Script

.Text:
	text "I'm a talker!"
	done

.Script:
	endifjustbattled
	opentext
	writetext .YoungsterMikeyAfterText
	waitbutton
	closetext
	end

.YoungsterMikeySeenText:
	text "You're a #MON"
	line "trainer, right?"

	para "Then you have to"
	line "battle!"
	done

.YoungsterMikeyBeatenText:
	text "That's strange."
	line "I won before."
	done

.YoungsterMikeyAfterText:
	text "Becoming a good"
	line "trainer is really"
	cont "tough."

	para "I'm going to bat-"
	line "tle other people"
	cont "to get better."
	done

DebugLevel5_Map1_MapSpaces:
	space  2,  4,  $0,  1 ;  0
	space  4,  4,  $0,  2 ;  1
	space  6,  4,  .BS2   ;  2

	space  8,  4,  $0,  4 ;  3
	space 10,  4,  $0,  5 ;  4
	space 12,  4,  $0,  6 ;  5
	space 14,  4,  $0,  7 ;  6
	space 16,  4,  $0,  8 ;  7

	space 18,  4,  $0,  9 ;  8
	space 20,  4,  $0, 10 ;  9
	space 22,  4,  $0, 11 ; 10
	space 24,  4,  $0, 12 ; 11
	space 24,  6,  $0, 13 ; 12
	space 24,  8,  $0, 14 ; 13
	space 24, 10,  $0, 15 ; 14
	space 24, 12,  $0, 16 ; 15
	space 24, 14,  $0, 17 ; 16
	space 22, 14,  $0, 18 ; 17
	space 20, 14,  $0, 19 ; 18
	space 18, 14,  $0, 20 ; 19
	space 16, 14,  $0, 21 ; 20
	space 14, 14,  $0, 22 ; 21
	space 12, 14,  $0, 23 ; 22
	space 10, 14,  $0, 24 ; 23
	space  8, 14,  $0, 25 ; 24
	space  6, 14,  $0, 26 ; 25
	space  4, 14,  $0, 27 ; 26
	space  4, 12,  $0, 28 ; 27
	space  4, 10,  $0, 29 ; 28
	space  4,  8,  $0, 30 ; 29
	space  6,  8,  $0, 31 ; 30
	space  8,  8,  $0, 32 ; 31
	space 10,  8,  $0, 33 ; 32
	space 12,  8,  $0, 34 ; 33
	space 14,  8, ES1, 34 ; 34

	space  6,  2,  $0, 36 ; 35
	space  6,  0,  .BS36  ; 36
	space  8,  0,  $0, 38 ; 37
	space 10,  0,  $0, GO_DOWN ; 38
	space 12,  0,  $0, 40 ; 39
	space 14,  0,  $0, 41 ; 40
	space 16,  0,  $0, 42 ; 41
	space 16,  2,  $0, 43 ; 42
	space 16,  4,  $0,  8 ; 43

.BS2:
	branchdir RIGHT,   3, 0
	branchdir UP,     35, 0
	endbranch

.BS36:
	branchdir RIGHT,  37, 0
	branchdir UP,     GO_UP, 0
	endbranch
