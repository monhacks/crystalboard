; Landmarks indexes (see data/levels/level_selection_menu.asm)
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
assert NUM_LANDMARKS <= 254

; constants used in Level Selection Menu
DEF LSMTEXTBOX_WIDTH   EQU 18
DEF LSMTEXTBOX_HEIGHT  EQU  2
DEF LSMTEXTBOX_X_COORD EQU  1
DEF LSMTEXTBOX_Y_COORD EQU 15
DEF LSMTEXTBOX_MAX_TEXT_ROW_LENGTH EQU LSMTEXTBOX_WIDTH - 5
DEF LSMTEXTBOX_BLACK_TILE EQU "<LSMTEXTBOX_BLACK_TILE>"
DEF LSMTEXTBOX_LEVEL_INDICATOR_TILE     EQU $30
DEF LSMTEXTBOX_LEVEL_NUMBERS_FIRST_TILE EQU $31
	const_def $3b ; $31 + 10
	; these must be consecutive
	const LSMTEXTBOX_STAGE_1_INDICATOR_TILE ; $3b
	const LSMTEXTBOX_STAGE_2_INDICATOR_TILE ; $3c
	const LSMTEXTBOX_STAGE_3_INDICATOR_TILE ; $3d
	const LSMTEXTBOX_STAGE_4_INDICATOR_TILE ; $3e

; used in CaughtData (legacy)
	const_def $7f, -1
	const LANDMARK_EVENT             ; $7f
	const LANDMARK_GIFT              ; $7e

; Regions (legacy)
	const_def
	const JOHTO_REGION ; 0
	const KANTO_REGION ; 1
DEF NUM_REGIONS EQU const_value
