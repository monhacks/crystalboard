MACRO player
	dw \1 ; ptr to ow state sprites
	db \2 ; ow sprite palette
	dw \3 ; ptr to ow fishing gfx
	dw \4, \5 ; ptr to (uncompressed) frontpic, ptr to (compressed) backpic
	dw \6 ; ptr to pic pallete
ENDM

Players::
	player ChrisStateSprites, PAL_NPC_RED, FishingGFX, ChrisPic, ChrisBackpic, PlayerPalette   ; PLAYER_CHRIS
	player KrisStateSprites, PAL_NPC_BLUE, KrisFishingGFX, KrisPic, KrisBackpic, KrisPalette  ; PLAYER_KRIS
	player GreenStateSprites, PAL_NPC_GREEN, FishingGFX, ChrisPic, ChrisBackpic, PlayerPalette ; PLAYER_GREEN
	db $ff
