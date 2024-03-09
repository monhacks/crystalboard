; see GetPlayerField (home/player.asm) and Players (data/players/players.asm)

; player characters
	const_def
	const PLAYER_CHRIS
	const PLAYER_KRIS
	const PLAYER_GREEN
DEF NUM_PLAYER_CHARACTERS EQU const_value

; field ids in the Players table
rsreset
DEF PLAYERDATA_STATE_SPRITES  rw
DEF PLAYERDATA_OW_PAL         rb
DEF PLAYERDATA_DEFAULT_SPRITE rw
DEF PLAYERDATA_FISHING_SPRITE rw
DEF PLAYERDATA_FRONTPIC       rw
DEF PLAYERDATA_BACKPIC        rw
DEF PLAYERDATA_PIC_PAL        rw
DEF PLAYERDATA_LENGTH EQU _RS
