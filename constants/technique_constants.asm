MACRO technique
    const \1_B
    DEF \1_F EQU \1_B % 8
    DEF \1   EQU 1 << \1_F
ENDM

; technique constants
	const_def
	technique TECHNIQUE_CUT
    technique TECHNIQUE_FLASH
    technique TECHNIQUE_SURF
    technique TECHNIQUE_ROCK_SMASH
    technique TECHNIQUE_WATERFALL
    technique TECHNIQUE_DUMMY_5
    technique TECHNIQUE_DUMMY_6
    technique TECHNIQUE_DUMMY_7
    technique TECHNIQUE_DUMMY_8
    technique TECHNIQUE_DUMMY_9
DEF NUM_TECHNIQUES EQU const_value
