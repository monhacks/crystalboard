; Valid sprite IDs for each map group.
; Maps with environment ROUTE or TOWN can only use these sprites.

OutdoorSprites:
; entries correspond to MAPGROUP_* constants
	table_width 2, OutdoorSprites
	dw Level1GroupSprites
;	dw Level2GroupSprites
	assert_table_length NUM_MAP_GROUPS

Level1GroupSprites:
; Level2GroupSprites:
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
	; max 3 of 10 still sprites
	db 0 ; end
