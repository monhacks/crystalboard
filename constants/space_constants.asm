; metatile layout constants
DEF FIRST_SPACE_METATILE        EQU $80
DEF FIRST_GREY_SPACE_METATILE   EQU $e0
DEF UNIQUE_SPACE_METATILES_MASK EQU %11111

; reserved next space values that signal movement towards anchor point rather than towards space
	const_def -1, -1
	const GO_DOWN  ; 255
	const GO_UP    ; 254
	const GO_LEFT  ; 253
	const GO_RIGHT ; 252
DEF NEXT_SPACE_IS_ANCHOR_POINT EQU const_value + 1

; Branch Space special direction values
DEF BRANCH_DIRECTION_INVALID     EQU -1
DEF BRANCH_DIRECTION_UNAVAILABLE EQU -2
