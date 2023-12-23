; OAM tile grid
/*
  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 4
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 5
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 6
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 7
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 8
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 9
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |10
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |11
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |12
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |13
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |14
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |15
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |16
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |17
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |18
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |19
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
*/

BoardMenuOAM:
; BOARDMENUITEM_DIE
	dbsprite  2, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE,      PAL_OW_MISC
	dbsprite  3, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  1, PAL_OW_MISC
	dbsprite  4, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  2, PAL_OW_MISC
	dbsprite  2, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  3, PAL_OW_MISC
	dbsprite  3, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  4, PAL_OW_MISC
	dbsprite  4, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  5, PAL_OW_MISC
	dbsprite  2, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  6, PAL_OW_MISC
	dbsprite  3, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  7, PAL_OW_MISC
	dbsprite  4, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE +  8, PAL_OW_MISC
; BOARDMENUITEM_PARTY
	dbsprite  6, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE +  9, PAL_OW_MISC
	dbsprite  7, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 10, PAL_OW_MISC
	dbsprite  8, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 11, PAL_OW_MISC
	dbsprite  6, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 12, PAL_OW_MISC
	dbsprite  7, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 13, PAL_OW_MISC
	dbsprite  8, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 14, PAL_OW_MISC
	dbsprite  6, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 15, PAL_OW_MISC
	dbsprite  7, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 16, PAL_OW_MISC
	dbsprite  8, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 17, PAL_OW_MISC
; BOARDMENUITEM_PACK
	dbsprite  9, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 18, PAL_OW_MISC
	dbsprite 10, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 19, PAL_OW_MISC
	dbsprite 11, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 20, PAL_OW_MISC
	dbsprite  9, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 21, PAL_OW_MISC
	dbsprite 10, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 22, PAL_OW_MISC
	dbsprite 11, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 23, PAL_OW_MISC
	dbsprite  9, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 24, PAL_OW_MISC
	dbsprite 10, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 25, PAL_OW_MISC
	dbsprite 11, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 26, PAL_OW_MISC
; BOARDMENUITEM_POKEGEAR
	dbsprite 13, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 27, PAL_OW_MISC
	dbsprite 14, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 28, PAL_OW_MISC
	dbsprite 15, 16, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 29, PAL_OW_MISC
	dbsprite 13, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 30, PAL_OW_MISC
	dbsprite 14, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 31, PAL_OW_MISC
	dbsprite 15, 17, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 32, PAL_OW_MISC
	dbsprite 13, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 33, PAL_OW_MISC
	dbsprite 14, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 34, PAL_OW_MISC
	dbsprite 15, 18, 0, 0, BOARD_MENU_OAM_FIRST_TILE + 35, PAL_OW_MISC
; BOARDMENUITEM_EXIT
	dbsprite 16, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 36, PAL_OW_MISC
	dbsprite 17, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 37, PAL_OW_MISC
	dbsprite 18, 16, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 38, PAL_OW_MISC
	dbsprite 16, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 39, PAL_OW_MISC
	dbsprite 17, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 40, PAL_OW_MISC
	dbsprite 18, 17, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 41, PAL_OW_MISC
	dbsprite 16, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 42, PAL_OW_MISC
	dbsprite 17, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 43, PAL_OW_MISC
	dbsprite 18, 18, 4, 0, BOARD_MENU_OAM_FIRST_TILE + 44, PAL_OW_MISC

DieRollOAM:
; 1
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE,      PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  1, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 20, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 21, PAL_OW_MISC
; 2
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  2, PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  3, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 22, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 23, PAL_OW_MISC
; 3
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  4, PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  5, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 24, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 25, PAL_OW_MISC
; 4
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  6, PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  7, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 26, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 27, PAL_OW_MISC
; 5
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  8, PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE +  9, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 28, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 29, PAL_OW_MISC
; 6
	dbsprite  9,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 10, PAL_OW_MISC
	dbsprite 10,  7, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 11, PAL_OW_MISC
	dbsprite  9,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 30, PAL_OW_MISC
	dbsprite 10,  8, 0, 0, DIE_ROLL_OAM_FIRST_TILE + 31, PAL_OW_MISC

SpacesLeftNumberOAM:
; 1
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE,      PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  1, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 20, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 21, PAL_OW_MISC
; 2
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  2, PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  3, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 22, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 23, PAL_OW_MISC
; 3
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  4, PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  5, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 24, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 25, PAL_OW_MISC
; 4
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  6, PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  7, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 26, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 27, PAL_OW_MISC
; 5
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  8, PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE +  9, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 28, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 29, PAL_OW_MISC
; 6
	dbsprite  1,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 10, PAL_OW_MISC
	dbsprite  2,  3, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 11, PAL_OW_MISC
	dbsprite  1,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 30, PAL_OW_MISC
	dbsprite  2,  4, 4, 4, DIE_NUMBERS_OAM_FIRST_TILE + 31, PAL_OW_MISC

BranchArrowsOAM:
; the PAL_ argument is unused (actual palette comes from the player gender)
	dbsprite 11, 10, 4, 0, BRANCH_ARROWS_OAM_FIRST_TILE,     PAL_OW_RED ; right
	dbsprite  7, 10, 4, 0, BRANCH_ARROWS_OAM_FIRST_TILE + 1, PAL_OW_RED ; left
	dbsprite  9,  8, 4, 0, BRANCH_ARROWS_OAM_FIRST_TILE + 2, PAL_OW_RED ; up
	dbsprite  9, 12, 4, 0, BRANCH_ARROWS_OAM_FIRST_TILE + 3, PAL_OW_RED ; down

BranchLegendOAM:
; the PAL_ argument is unused (actual palette comes from the player gender)
	dbsprite  2, 16, 0, 4, BRANCH_LEGEND_OAM_FIRST_TILE +  2, PAL_OW_RED ; dpad icon
	dbsprite  3, 16, 0, 4, BRANCH_LEGEND_OAM_FIRST_TILE +  5, PAL_OW_RED ; "choose" icon
	dbsprite  4, 16, 0, 4, BRANCH_LEGEND_OAM_FIRST_TILE +  6, PAL_OW_RED ;
	dbsprite  5, 16, 0, 4, BRANCH_LEGEND_OAM_FIRST_TILE +  7, PAL_OW_RED ;
	dbsprite  2, 18, 0, 0, BRANCH_LEGEND_OAM_FIRST_TILE +  3, PAL_OW_RED ; select icon
	dbsprite  3, 18, 0, 0, BRANCH_LEGEND_OAM_FIRST_TILE +  8, PAL_OW_RED ; "view" icon
	dbsprite  4, 18, 0, 0, BRANCH_LEGEND_OAM_FIRST_TILE +  9, PAL_OW_RED ;
	dbsprite  5, 18, 0, 0, BRANCH_LEGEND_OAM_FIRST_TILE + 10, PAL_OW_RED ;

ViewMapModeArrowsOAM:
; the PAL_ argument is unused (actual palette comes from the player gender)
	dbsprite 10, 18, 4, 4, VIEW_MAP_MODE_ARROWS_OAM_FIRST_TILE + 3, PAL_OW_RED ; down
	dbsprite 10,  2, 4, 4, VIEW_MAP_MODE_ARROWS_OAM_FIRST_TILE + 2, PAL_OW_RED ; up
	dbsprite  1, 10, 4, 0, VIEW_MAP_MODE_ARROWS_OAM_FIRST_TILE + 1, PAL_OW_RED ; left
	dbsprite 19, 10, 4, 0, VIEW_MAP_MODE_ARROWS_OAM_FIRST_TILE,     PAL_OW_RED ; right

ViewMapModeLegendOAM:
; the PAL_ argument is unused (actual palette comes from the player gender)
	dbsprite  2, 16, 0, 4, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  2, PAL_OW_RED ; dpad icon
	dbsprite  3, 16, 0, 4, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  5, PAL_OW_RED ; "move" icon
	dbsprite  4, 16, 0, 4, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  6, PAL_OW_RED ;
	dbsprite  5, 16, 0, 4, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  7, PAL_OW_RED ;
	dbsprite  2, 18, 0, 0, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  1, PAL_OW_RED ; B icon
	dbsprite  3, 18, 0, 0, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  8, PAL_OW_RED ; "back" icon
	dbsprite  4, 18, 0, 0, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE +  9, PAL_OW_RED ;
	dbsprite  5, 18, 0, 0, VIEW_MAP_MODE_LEGEND_OAM_FIRST_FILE + 10, PAL_OW_RED ;

TalkerEventLegendOAM:
; the PAL_ argument is unused (actual palette comes from the player gender)
	dbsprite  2, 16, 0, 4, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  0, PAL_OW_RED ; A icon
	dbsprite  3, 16, 0, 4, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  5, PAL_OW_RED ; "talk" icon
	dbsprite  4, 16, 0, 4, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  6, PAL_OW_RED ;
	dbsprite  5, 16, 0, 4, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  7, PAL_OW_RED ;
	dbsprite  2, 18, 0, 0, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  1, PAL_OW_RED ; B icon
	dbsprite  3, 18, 0, 0, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  8, PAL_OW_RED ; "skip" icon
	dbsprite  4, 18, 0, 0, TALKER_EVENT_LEGEND_OAM_FIRST_TILE +  9, PAL_OW_RED ;
	dbsprite  5, 18, 0, 0, TALKER_EVENT_LEGEND_OAM_FIRST_TILE + 10, PAL_OW_RED ;
