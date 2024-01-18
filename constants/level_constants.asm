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
	const STAGE_1 ; 00
	const STAGE_2 ; 01
	const STAGE_3 ; 02
	const STAGE_4 ; 03

; requirement types to unlock a given level
	const_def
	const UNLOCK_WHEN_LEVELS_CLEARED             ; 00
	const UNLOCK_WHEN_NUMBER_OF_LEVELS_CLEARED   ; 01
	const UNLOCK_WHEN_TECHNIQUES_CLEARED         ; 02
