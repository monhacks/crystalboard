_LoadScreenAttrmapPals::
	hlcoord 0, 0
	decoord 0, 0, wAttrmap
	ld b, SCREEN_HEIGHT
.loop
	push bc
	ld c, SCREEN_WIDTH
	call LoadChunkPalettes
	pop bc
	dec b
	jr nz, .loop
	ret

_ScrollBGMapPalettes::
	ld hl, wBGMapBuffer
	ld de, wBGMapPalBuffer
	call LoadChunkPalettes
	ret

LoadChunkPalettes:
.loop
	ld a, [hl]
	push hl
	srl a
	jr c, .UpperNybble

; .LowerNybble
	cp ($100 - (TILESET_FIXED_SPACES_NUM_TILES + TILESET_VARIABLE_SPACES_NUM_TILES)) / 2
	jr c, .lower_nybble_map_tileset
	cp ($100 - TILESET_VARIABLE_SPACES_NUM_TILES) / 2
	ld hl, TilesetFixedSpacesPalMap - ($100 - (TILESET_FIXED_SPACES_NUM_TILES + TILESET_VARIABLE_SPACES_NUM_TILES)) / 2
	jr c, .lower_nybble_spaces_tileset
	ld hl, TilesetVariableSpacesPalMaps
	push af
	ld a, [wTilesetVariableSpaces]
	add a
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	sub ($100 - TILESET_VARIABLE_SPACES_NUM_TILES) / 2
.lower_nybble_spaces_tileset
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a
	ld a, [hl]
	and $f
	jr .next

.lower_nybble_map_tileset
	ld hl, wTilesetPalettes
	add [hl]
	ld l, a
	ld a, [wTilesetPalettes + 1]
	adc 0
	ld h, a
	ld a, [hl]
	and $f
	jr .next

.UpperNybble:
	cp ($100 - (TILESET_FIXED_SPACES_NUM_TILES + TILESET_VARIABLE_SPACES_NUM_TILES)) / 2
	jr c, .upper_nybble_map_tileset
	cp ($100 - TILESET_VARIABLE_SPACES_NUM_TILES) / 2
	ld hl, TilesetFixedSpacesPalMap - ($100 - (TILESET_FIXED_SPACES_NUM_TILES + TILESET_VARIABLE_SPACES_NUM_TILES)) / 2
	jr c, .upper_nybble_spaces_tileset
	ld hl, TilesetVariableSpacesPalMaps
	push af
	ld a, [wTilesetVariableSpaces]
	add a
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	sub ($100 - TILESET_VARIABLE_SPACES_NUM_TILES) / 2
.upper_nybble_spaces_tileset
	add l
	ld l, a
	ld a, h
	adc 0
	ld h, a
	ld a, [hl]
	swap a
	and $f
	jr .next

.upper_nybble_map_tileset
	ld hl, wTilesetPalettes
	add [hl]
	ld l, a
	ld a, [wTilesetPalettes + 1]
	adc 0
	ld h, a
	ld a, [hl]
	swap a
	and $f

.next
	pop hl
	ld [de], a
	res 7, [hl]
	inc hl
	inc de
	dec c
	jp nz, .loop
	ret
