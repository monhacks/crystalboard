DEF PAL_LEVELSELECTIONMENU_BORDER EQU 0 | 1 << OAM_PRIORITY
	const_def 0
	const PAL_LEVELSELECTIONMENU_STAGES   ; 0
	const PAL_LEVELSELECTIONMENU_EARTH    ; 1
	const PAL_LEVELSELECTIONMENU_MOUNTAIN ; 2
	const PAL_LEVELSELECTIONMENU_CITY     ; 3
	const PAL_LEVELSELECTIONMENU_POI      ; 4
	const PAL_LEVELSELECTIONMENU_POI_MTN  ; 5

MACRO levelselectionmenupals
rept _NARG
	db PAL_LEVELSELECTIONMENU_\1
	shift
endr
ENDM

; gfx/level_selection_menu/background.png
; some are aligned to specific LSMTEXTBOX_* tile constants (constants/landmark_constants.asm)
	levelselectionmenupals EARTH,    EARTH,    EARTH,    MOUNTAIN, MOUNTAIN, MOUNTAIN, BORDER,   BORDER
	levelselectionmenupals EARTH,    EARTH,    CITY,     EARTH,    POI,      POI_MTN,  POI,      POI_MTN
	levelselectionmenupals EARTH,    EARTH,    EARTH,    MOUNTAIN, MOUNTAIN, MOUNTAIN, BORDER,   BORDER
	levelselectionmenupals EARTH,    EARTH,    EARTH,    EARTH,    EARTH,    BORDER,   BORDER,   BORDER
	levelselectionmenupals EARTH,    EARTH,    EARTH,    MOUNTAIN, MOUNTAIN, MOUNTAIN, BORDER,   BORDER
	levelselectionmenupals BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER
	levelselectionmenupals BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER
	levelselectionmenupals BORDER,   BORDER,   BORDER,   STAGES,   STAGES,   STAGES,   STAGES,   BORDER
	levelselectionmenupals BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER
	levelselectionmenupals BORDER,   BORDER,   BORDER,   STAGES,   STAGES,   STAGES,   STAGES,   BORDER
rept 22
	levelselectionmenupals BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER,   BORDER
endr
