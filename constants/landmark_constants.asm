; Landmarks indexes (see data/maps/landmarks.asm)
	const_def
	const LANDMARK_LEVEL_1           ; 00
if DEF(_DEBUG)
	const LANDMARK_DEBUGLEVEL_1      ; 00
	const LANDMARK_DEBUGLEVEL_2      ; 01
	const LANDMARK_DEBUGLEVEL_3      ; 02
	const LANDMARK_DEBUGLEVEL_4      ; 03
	const LANDMARK_DEBUGLEVEL_5      ; 04
endc
DEF NUM_LANDMARKS EQU const_value

; used in CaughtData
	const_def $7f, -1
	const LANDMARK_EVENT             ; $7f
	const LANDMARK_GIFT              ; $7e

; Regions
	const_def
	const JOHTO_REGION ; 0
	const KANTO_REGION ; 1
DEF NUM_REGIONS EQU const_value
