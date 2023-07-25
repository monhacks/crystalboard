MACRO landmark
; x, y, name
	db \1 + 8, \2 + 16
	dw \3
ENDM

Landmarks:
; entries correspond to constants/landmark_constants.asm
	table_width 4, Landmarks
	landmark 140, 100, Level1LandmarkName
	assert_table_length NUM_LANDMARKS

Level1LandmarkName:     db "LEVEL 1@"
