MACRO player
	dw \1 ; ptr to ow state sprites
	db \2 ; ow sprite palette
	dw \3 ; ptr to ow default gfx
	dw \4 ; ptr to ow fishing gfx
	dw \5, \6 ; ptr to (uncompressed) frontpic, ptr to (compressed) backpic
	dw \7 ; ptr to pic palette
ENDM

Players::
; for each argument number across different players, all arguments that are pointers must point to something in the same bank
	player ChrisStateSprites, PAL_OW_RED, ChrisSpriteGFX, FishingGFX, ChrisPic, ChrisBackpic, PlayerPalette   ; PLAYER_CHRIS
	player KrisStateSprites, PAL_OW_BLUE, KrisSpriteGFX, KrisFishingGFX, KrisPic, KrisBackpic, KrisPalette    ; PLAYER_KRIS
	player GreenStateSprites, PAL_OW_GREEN, RivalSpriteGFX, FishingGFX, ChrisPic, ChrisBackpic, PlayerPalette ; PLAYER_GREEN
