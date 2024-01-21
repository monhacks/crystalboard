; TILE_WIDTH represents the top/left border tile, $8/$10 represent the OAM screen position offsets,
; and 4 are custom offsets to make the player sprite centered in a 8x8 tile rather than in a 16x16 square.
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_X EQU TILE_WIDTH +  $8 + 4
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_Y EQU TILE_WIDTH + $10 + 4

MACRO level_selection_menu_landmark
; page number, xcoord (in tiles), ycoord (in tiles), ptr to name, spawn point (SPAWN_*)
; xcoord ranges between 0 and 17 (SCREEN_WIDTH points minus two)
;  when crossing pages, x=17 and x=0 are adjacent (one tile apart)
; ycoord ranges between 0 and 13 (SCREEN_HEIGH points minus four)
;  when crossing pages, y=13 and y=0 are adjacent (one tile apart)
	db \1
	db LEVELSELECTIONMENU_LANDMARK_OFFSET_X + \2 * TILE_WIDTH
	db LEVELSELECTIONMENU_LANDMARK_OFFSET_Y + \3 * TILE_WIDTH
	dw \4
	db \5
ENDM

MACRO level_selection_menu_landmark_name
	assert STRLEN(\1) == LSMTEXTBOX_MAX_TEXT_ROW_LENGTH
	assert STRLEN(\2) == LSMTEXTBOX_MAX_TEXT_ROW_LENGTH
	db STRRPL(\1, " ", "<LSMTEXTBOX_BLACK_TILE>"), STRRPL(\2, " ", "<LSMTEXTBOX_BLACK_TILE>"),
ENDM

LevelSelectionMenu_Landmarks:
	table_width 6, LevelSelectionMenu_Landmarks
.landmark1
	level_selection_menu_landmark 0, 16, 11, .Level1LandmarkName, SPAWN_LEVEL_1 ; LANDMARK_LEVEL_1
.landmark2
if DEF(_DEBUG)
	level_selection_menu_landmark 0, 16, 10, .DebugLevel1LandmarkName, SPAWN_DEBUGLEVEL_1 ; LANDMARK_DEBUGLEVEL_1
	level_selection_menu_landmark 0, 11,  8, .DebugLevel2LandmarkName, SPAWN_DEBUGLEVEL_2 ; LANDMARK_DEBUGLEVEL_2
	level_selection_menu_landmark 0,  9, 10, .DebugLevel3LandmarkName, SPAWN_DEBUGLEVEL_3 ; LANDMARK_DEBUGLEVEL_3
	level_selection_menu_landmark 1, 16, 10, .DebugLevel4LandmarkName, SPAWN_DEBUGLEVEL_4 ; LANDMARK_DEBUGLEVEL_4
	level_selection_menu_landmark 2,  9,  4, .DebugLevel5LandmarkName, SPAWN_DEBUGLEVEL_5 ; LANDMARK_DEBUGLEVEL_5
endc
	assert_table_length NUM_LANDMARKS

.Level1LandmarkName: level_selection_menu_landmark_name "  THE FIRST  ", "    LEVEL    "
if DEF(_DEBUG)
.DebugLevel1LandmarkName: level_selection_menu_landmark_name "    DEBUG    ", "    DUMMY    "
.DebugLevel2LandmarkName: level_selection_menu_landmark_name "    DEBUG    ", "    CAVE     "
.DebugLevel3LandmarkName: level_selection_menu_landmark_name "    DEBUG    ", "   FOREST    "
.DebugLevel4LandmarkName: level_selection_menu_landmark_name "    DEBUG    ", "    TEST2    "
.DebugLevel5LandmarkName: level_selection_menu_landmark_name "    DEBUG    ", "    TEST1    "
endc

MACRO level_selection_menu_landmark_transition
; any number of (direction, num_steps (in tiles)) pairs
	const_skip

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
; the transitions are arranged by direction according to wWalkingDirection constants
	const_def

; LANDMARK_LEVEL_1
	level_selection_menu_landmark_transition DOWN, FALSE
if !DEF(_DEBUG)
	level_selection_menu_landmark_transition UP, FALSE
else
	level_selection_menu_landmark_transition UP, 1, LANDMARK_DEBUGLEVEL_1
endc
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, FALSE

if DEF(_DEBUG)
; LANDMARK_DEBUGLEVEL_1
	level_selection_menu_landmark_transition DOWN, 1, LANDMARK_LEVEL_1
	level_selection_menu_landmark_transition UP, FALSE
	level_selection_menu_landmark_transition LEFT, 5, UP, 2, LANDMARK_DEBUGLEVEL_2
	level_selection_menu_landmark_transition RIGHT, FALSE

; LANDMARK_DEBUGLEVEL_2
	level_selection_menu_landmark_transition DOWN, 2, RIGHT, 5, LANDMARK_DEBUGLEVEL_1
	level_selection_menu_landmark_transition UP, 3, LEFT, 2, DOWN, 5, LANDMARK_DEBUGLEVEL_3
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, FALSE

; LANDMARK_DEBUGLEVEL_3
	level_selection_menu_landmark_transition DOWN, 7, LANDMARK_DEBUGLEVEL_5
	level_selection_menu_landmark_transition UP, 5, RIGHT, 2, DOWN, 3, LANDMARK_DEBUGLEVEL_2
	level_selection_menu_landmark_transition LEFT, 7, LEFT, 4, LANDMARK_DEBUGLEVEL_4
	level_selection_menu_landmark_transition RIGHT, 7, LANDMARK_DEBUGLEVEL_1

; LANDMARK_DEBUGLEVEL_4
	level_selection_menu_landmark_transition DOWN, FALSE
	level_selection_menu_landmark_transition UP, FALSE
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, 7, RIGHT, 4, LANDMARK_DEBUGLEVEL_3

; LANDMARK_DEBUGLEVEL_5
	level_selection_menu_landmark_transition DOWN, FALSE
	level_selection_menu_landmark_transition UP, 7, LANDMARK_DEBUGLEVEL_3
	level_selection_menu_landmark_transition LEFT, FALSE
	level_selection_menu_landmark_transition RIGHT, FALSE
endc

assert const_value == NUM_LANDMARKS * NUM_DIRECTIONS

LevelSelectionMenu_PageGrid:
	db -1, -1, -1, -1
	db -1,  1,  0, -1
	db -1,  3,  2, -1
	db -1, -1, -1, -1

DEF LEVELSELECTIONMENU_PAGE_GRID_WIDTH  EQU 4
DEF LEVELSELECTIONMENU_PAGE_GRID_HEIGHT EQU 4

LandmarkToLevelTable:
; the usual level:landmark relation is expected to be 1:1, but 1:n is
; also supported, for levels that may have alternative starting points.
	table_width 1, LandmarkToLevelTable
	db LEVEL_1 ; LANDMARK_LEVEL_1
if DEF(_DEBUG)
	db DEBUGLEVEL_1 ; LANDMARK_DEBUGLEVEL_1
	db DEBUGLEVEL_2 ; LANDMARK_DEBUGLEVEL_2
	db DEBUGLEVEL_3 ; LANDMARK_DEBUGLEVEL_3
	db DEBUGLEVEL_4 ; LANDMARK_DEBUGLEVEL_4
	db DEBUGLEVEL_5 ; LANDMARK_DEBUGLEVEL_5
endc
	assert_table_length NUM_LANDMARKS
