; metatile layout constants
DEF FIRST_SPACE_METATILE        EQU $80
DEF FIRST_GREY_SPACE_METATILE   EQU $e0
DEF UNIQUE_SPACE_METATILES_MASK EQU %11111

; End Space effect constants (denotes which stage of the level is cleared by this space; equivalent to STAGE_*_F constants)
	const_def
	const ES1 ; 0
	const ES2 ; 1
	const ES3 ; 2
	const ES4 ; 3

; Branch Space special direction values
	const_def 255, -1
	const BRANCH_DIRECTION_INVALID     ; -1
	const BRANCH_DIRECTION_UNAVAILABLE ; -2

; reserved next space values that signal movement towards anchor point rather than towards space.
; must not overlap with BRANCH_DIRECTION_* constants in order to support GO_* values as next spaces of a branch direction.
	const GO_DOWN  ; 253
	const GO_UP    ; 252
	const GO_LEFT  ; 251
	const GO_RIGHT ; 250
DEF NEXT_SPACE_IS_ANCHOR_POINT EQU const_value + 1

DEF MAX_SPACES_PER_MAP EQU const_value + 1

DEF NUM_DISABLED_SPACES_BACKUPS EQU 10
