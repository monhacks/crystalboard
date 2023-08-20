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
	level_selection_menu_landmark 0, 16, 11, .Level1LandmarkName, SPAWN_LEVEL_1
.landmark2
	level_selection_menu_landmark 0, 11,  9, .Level2LandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 0,  9, 11, .Level3LandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 1, 16, 11, .Level4LandmarkName, SPAWN_LEVEL_1
	level_selection_menu_landmark 2,  9,  5, .Level5LandmarkName, SPAWN_LEVEL_1

.Level1LandmarkName: db "LEVEL 1@"
.Level2LandmarkName: db "LEVEL 2@"
.Level3LandmarkName: db "LEVEL 3@"
.Level4LandmarkName: db "LEVEL 4@"
.Level5LandmarkName: db "LEVEL 5@"

LevelSelectionMenu_PageGrid:
	db -1, -1, -1, -1
	db -1,  2,  3, -1
	db -1,  0,  1, -1
	db -1, -1, -1, -1

DEF LEVELSELECTIONMENU_PAGE_GRID_WIDTH EQU 4
