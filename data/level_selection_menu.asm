; TILE_WIDTH represents the top/left border tile, $8/$10 represent the OAM screen position offsets, and 4 are custom offsets
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_X EQU TILE_WIDTH +  $8 + 4
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_Y EQU TILE_WIDTH + $10 + 4

MACRO level_selection_menu_landmark
; page number, xcoord (in tiles), ycoord (in tiles), ptr to name, spawn point (SPAWN_*)
	db \1
	db LEVELSELECTIONMENU_LANDMARK_OFFSET_X + \2 * TILE_WIDTH
	db LEVELSELECTIONMENU_LANDMARK_OFFSET_Y + \3 * TILE_WIDTH
	dw \4
	db \5
ENDM

LevelSelectionMenu_Landmarks:
.landmark1
	level_selection_menu_landmark 0, 16, 11, .Level1LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_1
.landmark2
	level_selection_menu_landmark 0, 11,  9, .Level2LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_2
	level_selection_menu_landmark 0,  9, 11, .Level3LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_3
	level_selection_menu_landmark 1, 16, 11, .Level4LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_4
	level_selection_menu_landmark 2,  9,  5, .Level5LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_5

.Level1LandmarkName: db "LEVEL 1@"
.Level2LandmarkName: db "LEVEL 2@"
.Level3LandmarkName: db "LEVEL 3@"
.Level4LandmarkName: db "LEVEL 4@"
.Level5LandmarkName: db "LEVEL 5@"

MACRO level_selection_menu_landmark_transition
; any number of (direction, num_steps (in tiles)) pairs

if (\2 != FALSE)
rept ((_NARG + -1) / 2) ; repeat once for each (direction, num_steps) pair
	db (\1 << 6) | (\2 * TILE_WIDTH)
	shift
	shift
endr
	db \1
endc
	db -1
ENDM

LevelSelectionMenu_LandmarkTransitions:
; LANDMARK_LEVEL_1
	level_selection_menu_landmark_transition DOWN, FALSE
	level_selection_menu_landmark_transition UP, FALSE
	level_selection_menu_landmark_transition LEFT, 5, UP, 2, LANDMARK_LEVEL_2
	level_selection_menu_landmark_transition RIGHT, FALSE

; LANDMARK_LEVEL_2
	level_selection_menu_landmark_transition DOWN, 2, RIGHT, 5, LANDMARK_LEVEL_1
	level_selection_menu_landmark_transition UP, 3, LEFT, 2, DOWN, 5, LANDMARK_LEVEL_3
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, FALSE

; LANDMARK_LEVEL_3
	level_selection_menu_landmark_transition DOWN, 6, LANDMARK_LEVEL_5
	level_selection_menu_landmark_transition UP, 5, RIGHT, 2, DOWN, 3, LANDMARK_LEVEL_2
	level_selection_menu_landmark_transition LEFT, 7, LEFT, 2, LANDMARK_LEVEL_4
	level_selection_menu_landmark_transition RIGHT, 7, LANDMARK_LEVEL_1

; LANDMARK_LEVEL_4
	level_selection_menu_landmark_transition DOWN, FALSE
	level_selection_menu_landmark_transition UP, FALSE
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, 7, RIGHT, 2, LANDMARK_LEVEL_3

; LANDMARK_LEVEL_5
	level_selection_menu_landmark_transition DOWN, FALSE
	level_selection_menu_landmark_transition UP, 6, LANDMARK_LEVEL_3
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, FALSE

LevelSelectionMenu_PageGrid:
	db -1, -1, -1, -1
	db -1,  2,  3, -1
	db -1,  0,  1, -1
	db -1, -1, -1, -1

DEF LEVELSELECTIONMENU_PAGE_GRID_WIDTH EQU 4
