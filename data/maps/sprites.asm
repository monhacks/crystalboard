; Valid sprite IDs for each map group.
; Maps with environment ROUTE or TOWN can only use these sprites.

MapSprites:
; entries correspond to MAPGROUP_* constants
	table_width 2, MapSprites
	dw Level1GroupSprites
;	dw Level2GroupSprites
if DEF(_DEBUG)
	dw DebugLevel1GroupSprites
	dw DebugLevel2GroupSprites
	dw DebugLevel3GroupSprites
	dw DebugLevel4GroupSprites
	dw DebugLevel5GroupSprites
endc
	assert_table_length NUM_MAP_GROUPS

Level1GroupSprites:
	db SPRITE_YOUNGSTER
	db SPRITE_BUG_CATCHER
	db SPRITE_FISHER
	db SPRITE_COOLTRAINER_M
	db SPRITE_COOLTRAINER_F
	db SPRITE_SUPER_NERD
	db SPRITE_GRAMPS
	db SPRITE_TEACHER
	db SPRITE_LASS
	; max 9 of 9 walking sprites
	db SPRITE_POKE_BALL
	db SPRITE_FRUIT_TREE
	db SPRITE_ROCK
	db SPRITE_CUT_TREE
	; max 4 of 10 still sprites
	db 0 ; end

; Level2GroupSprites:
;	db 0 ; end

if DEF(_DEBUG)
DebugLevel1GroupSprites:
DebugLevel2GroupSprites:
DebugLevel3GroupSprites:
DebugLevel4GroupSprites:
DebugLevel5GroupSprites:
	db SPRITE_YOUNGSTER
	db SPRITE_BUG_CATCHER
	db SPRITE_FISHER
	db SPRITE_COOLTRAINER_M
	db SPRITE_COOLTRAINER_F
	db SPRITE_SUPER_NERD
	db SPRITE_GRAMPS
	db SPRITE_TEACHER
	db SPRITE_LASS
	; max 9 of 9 walking sprites
	db SPRITE_POKE_BALL
	db SPRITE_FRUIT_TREE
	db SPRITE_ROCK
	db SPRITE_CUT_TREE
	; max 4 of 10 still sprites
	db 0 ; end
endc
