; TILE_WIDTH represents the top/left border tile, $8/$10 represent the OAM screen position offsets, and 10 are custom offsets
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_X EQU TILE_WIDTH + $8 + 10
DEF LEVELSELECTIONMENU_LANDMARK_OFFSET_Y EQU TILE_WIDTH + $10 + 10

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
	level_selection_menu_landmark 0, 16, 11, DefaultLandmarkName, SPAWN_LEVEL_1
.landmark2
	level_selection_menu_landmark 0, 11,  9, DefaultLandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 0,  9, 11, DefaultLandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 1, 16, 11, DefaultLandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 2,  9,  5, DefaultLandmarkName, SPAWN_LEVEL_1

LevelSelectionMenu_PageGrid:
	db -1, -1, -1, -1
	db -1,  2,  3, -1
	db -1,  0,  1, -1
	db -1, -1, -1, -1

DEF LEVELSELECTIONMENU_PAGE_GRID_WIDTH EQU 4

DefaultLandmarkName: db "LANDMARK NAME@"
