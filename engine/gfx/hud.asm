_LoadHUD::
	jumptable .Jumptable, wWhichHUD

.Jumptable:
; entries correspond to HUD_* constants (see constants/gfx_constants.asm)
	table_width 2, _LoadHUD.Jumptable
	dw .None
	dw _LoadOverworldHUDTilemapAndAttrmap
	assert_table_length NUM_HUD_TYPES + 1

.None:
	ret

_LoadOverworldHUDTilemapAndAttrmap:
	call _LoadOverworldHUDAttrmap
	; fallthrough

_LoadOverworldHUDTilemap:
	; overworld HUD reads SCREEN_WIDTH tiles from wOverworldHUDTiles
	ld hl, wOverworldHUDTiles
	decoord 0, 0, wTilemap
	ld bc, wOverworldHUDTilesEnd - wOverworldHUDTiles ; SCREEN_WIDTH
	jp CopyBytes

_LoadOverworldHUDAttrmap:
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_WIDTH
	ld a, PAL_BG_TEXT | PRIORITY
	jp ByteFill

_ConstructOverworldHUDTilemap::
	ld hl, .Tilemap
	ld de, wOverworldHUDTiles
	ld bc, .TilemapEnd - .Tilemap ; SCREEN_WIDTH
	call CopyBytes
	ret

.Tilemap:
	db "<TURN><N_A>  <DIE><N_A> <COIN>0     <XP>0    "
.TilemapEnd:
	assert .TilemapEnd - .Tilemap == wOverworldHUDTilesEnd - wOverworldHUDTiles
