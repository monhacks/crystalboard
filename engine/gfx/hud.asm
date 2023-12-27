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
; layout
	ld hl, .Tilemap
	ld de, wOverworldHUDTiles
	ld bc, .TilemapEnd - .Tilemap ; SCREEN_WIDTH
	call CopyBytes
; turn
	ld hl, wCurTurn + 1
	ld a, [hld]
	or [hl]
	jr z, .next1 ; skip if turn is 0 (not yet started)
	ld d, h
	ld e, l
	ld hl, wOverworldHUDTiles + 1
	lb bc, 2 | 1 << 6, 3 ; 2 bytes, left aligned, no leading zeros, 3 digits
	call PrintNum
.next1
; current roll
	ld de, wDieRoll
	ld a, [de]
	and a
	jr z, .next2 ; skip if wDieRoll is 0
	ld hl, wOverworldHUDTiles + 5
	lb bc, 1 | 1 << 6, 2 ; 1 byte, left aligned, no leading zeros, 2 digits
	call PrintNum
.next2
; coins
	ld de, wCurLevelCoins
	ld hl, wOverworldHUDTiles + 8
	lb bc, 3 | 1 << 6, MAX_DELTA_COINS_DIGITS ; 3 bytes, left aligned, no leading zeros, 5 digits
	call PrintNum
; exp points
	ld de, wCurLevelExp
	ld hl, wOverworldHUDTiles + 15
	lb bc, 3 | 1 << 6, 5 ; 3 bytes, left aligned, no leading zeros, 5 digits
	jp PrintNum

.Tilemap:
	db "<TURN><N_A>  <DIE><N_A> <COIN>0     <XP>0    "
.TilemapEnd:
	assert .TilemapEnd - .Tilemap == wOverworldHUDTilesEnd - wOverworldHUDTiles
