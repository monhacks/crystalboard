; Landmarks indexes (see data/level_selection_menu.asm)
	const_def
	const LANDMARK_LEVEL_1           ; 00
if DEF(_DEBUG)
	const LANDMARK_DEBUGLEVEL_1      ; 01
	const LANDMARK_DEBUGLEVEL_2      ; 02
	const LANDMARK_DEBUGLEVEL_3      ; 03
	const LANDMARK_DEBUGLEVEL_4      ; 04
	const LANDMARK_DEBUGLEVEL_5      ; 05
endc
DEF NUM_LANDMARKS EQU const_value

; used in CaughtData (legacy)
	const_def $7f, -1
	const LANDMARK_EVENT             ; $7f
	const LANDMARK_GIFT              ; $7e

; Regions (legacy)
	const_def
	const JOHTO_REGION ; 0
	const KANTO_REGION ; 1
DEF NUM_REGIONS EQU const_value
