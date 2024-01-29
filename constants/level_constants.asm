; Level constants (see data/levels/level_selection_menu.asm)
	const_def
	const LEVEL_1           ; 00
if DEF(_DEBUG)
	const DEBUGLEVEL_1      ; 01
	const DEBUGLEVEL_2      ; 02
	const DEBUGLEVEL_3      ; 03
	const DEBUGLEVEL_4      ; 04
	const DEBUGLEVEL_5      ; 05
endc
DEF NUM_LEVELS EQU const_value
assert NUM_LEVELS <= 254

; Level stages
	const_def
	const STAGE_1_F ; 00
	const STAGE_2_F ; 01
	const STAGE_3_F ; 02
	const STAGE_4_F ; 03
DEF NUM_LEVEL_STAGES EQU const_value

DEF STAGE_1 EQU 1 << STAGE_1_F
DEF STAGE_2 EQU 1 << STAGE_2_F
DEF STAGE_3 EQU 1 << STAGE_3_F
DEF STAGE_4 EQU 1 << STAGE_4_F

; requirement types to unlock a given level
	const_def
	const UNLOCK_WHEN_LEVELS_CLEARED             ; 00
	const UNLOCK_WHEN_NUMBER_OF_LEVELS_CLEARED   ; 01
	const UNLOCK_WHEN_TECHNIQUES_CLEARED         ; 02

; maximum amount of levels that can be unlocked in a single level cleared run.
; levels to unlock are processed in level order.
DEF MAX_UNLOCK_LEVELS_AT_ONCE EQU 10
