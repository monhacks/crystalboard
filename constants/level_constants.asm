; Level indexes (see data/level_selection_menu.asm)
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
