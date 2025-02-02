HandleNewMap:
	call ResetMapBufferEventFlags
	call ResetFlashIfOutOfCave
	call GetCurrentMapSceneID
	call ResetBikeFlags
	ld a, MAPCALLBACK_NEWMAP
	call RunMapCallback
HandleContinueMap:
	farcall ClearCmdQueue
	ld a, MAPCALLBACK_CMDQUEUE
	call RunMapCallback
	call GetMapTimeOfDay
	ld [wMapTimeOfDay], a
	ret

EnterMapConnection:
; Return carry if a connection has been entered.
	ld a, [wPlayerStepDirection]
	and a ; DOWN
	jp z, .south
	cp UP
	jp z, .north
	cp LEFT
	jp z, .west
	cp RIGHT
	jp z, .east
	ret

.west
	ld a, [wWestConnectedMapGroup]
	ld [wMapGroup], a
	ld a, [wWestConnectedMapNumber]
	ld [wMapNumber], a
	ld a, [wWestConnectionStripXOffset]
	ld [wXCoord], a
	ld a, [wWestConnectionStripYOffset]
	ld hl, wYCoord
	add [hl]
	ld [hl], a
	ld c, a
	ld hl, wWestConnectionWindow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	srl c
	jr z, .skip_to_load
	ld a, [wWestConnectedMapWidth]
	add 6
	ld e, a
	ld d, 0

.loop
	add hl, de
	dec c
	jr nz, .loop

.skip_to_load
	ld a, l
	ld [wOverworldMapAnchor], a
	ld a, h
	ld [wOverworldMapAnchor + 1], a
	jp .done

.east
	ld a, [wEastConnectedMapGroup]
	ld [wMapGroup], a
	ld a, [wEastConnectedMapNumber]
	ld [wMapNumber], a
	ld a, [wEastConnectionStripXOffset]
	ld [wXCoord], a
	ld a, [wEastConnectionStripYOffset]
	ld hl, wYCoord
	add [hl]
	ld [hl], a
	ld c, a
	ld hl, wEastConnectionWindow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	srl c
	jr z, .skip_to_load2
	ld a, [wEastConnectedMapWidth]
	add 6
	ld e, a
	ld d, 0

.loop2
	add hl, de
	dec c
	jr nz, .loop2

.skip_to_load2
	ld a, l
	ld [wOverworldMapAnchor], a
	ld a, h
	ld [wOverworldMapAnchor + 1], a
	jp .done

.north
	ld a, [wNorthConnectedMapGroup]
	ld [wMapGroup], a
	ld a, [wNorthConnectedMapNumber]
	ld [wMapNumber], a
	ld a, [wNorthConnectionStripYOffset]
	ld [wYCoord], a
	ld a, [wNorthConnectionStripXOffset]
	ld hl, wXCoord
	add [hl]
	ld [hl], a
	ld c, a
	ld hl, wNorthConnectionWindow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, 0
	srl c
	add hl, bc
	ld a, l
	ld [wOverworldMapAnchor], a
	ld a, h
	ld [wOverworldMapAnchor + 1], a
	jp .done

.south
	ld a, [wSouthConnectedMapGroup]
	ld [wMapGroup], a
	ld a, [wSouthConnectedMapNumber]
	ld [wMapNumber], a
	ld a, [wSouthConnectionStripYOffset]
	ld [wYCoord], a
	ld a, [wSouthConnectionStripXOffset]
	ld hl, wXCoord
	add [hl]
	ld [hl], a
	ld c, a
	ld hl, wSouthConnectionWindow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, 0
	srl c
	add hl, bc
	ld a, l
	ld [wOverworldMapAnchor], a
	ld a, h
	ld [wOverworldMapAnchor + 1], a

.done
	scf
	ret

EnterMapWarp:
	call .SaveDigWarp
	call .SetSpawn
	ld a, [wNextWarp]
	ld [wWarpNumber], a
	ld a, [wNextMapGroup]
	ld [wMapGroup], a
	ld a, [wNextMapNumber]
	ld [wMapNumber], a
	ret

.SaveDigWarp:
	call GetMapEnvironment
	call CheckOutdoorMap
	ret nz
	ld a, [wNextMapGroup]
	ld b, a
	ld a, [wNextMapNumber]
	ld c, a
	call GetAnyMapEnvironment
	call CheckIndoorMap
	ret nz

	ld a, [wPrevWarp]
	ld [wDigWarpNumber], a
	ld a, [wPrevMapGroup]
	ld [wDigMapGroup], a
	ld a, [wPrevMapNumber]
	ld [wDigMapNumber], a
	ret

.SetSpawn:
	call GetMapEnvironment
	call CheckOutdoorMap
	ret nz
	ld a, [wNextMapGroup]
	ld b, a
	ld a, [wNextMapNumber]
	ld c, a
	call GetAnyMapEnvironment
	call CheckIndoorMap
	ret nz
	ld a, [wNextMapGroup]
	ld b, a
	ld a, [wNextMapNumber]
	ld c, a

; Respawn in Pokémon Centers.
	call GetAnyMapTileset
	ld a, c
	cp TILESET_POKECENTER
	jr z, .pokecenter_pokecom
	cp TILESET_POKECOM_CENTER
	jr z, .pokecenter_pokecom
	ret
.pokecenter_pokecom

	ld a, [wPrevMapGroup]
	ld [wLastSpawnMapGroup], a
	ld a, [wPrevMapNumber]
	ld [wLastSpawnMapNumber], a
	ret

LoadMapTimeOfDay:
	ld hl, wStateFlags
	res 6, [hl]
	ld a, $1
	ld [wSpriteUpdatesEnabled], a
	farcall ReplaceTimeOfDayPals
	farcall UpdateTimeOfDayPal
	call LoadOverworldTilemapAndAttrmapPals
	call .ClearBGMap
	call .PushAttrmap
	ret

.ClearBGMap:
	ld a, HIGH(vBGMap0)
	ld [wBGMapAnchor + 1], a
	xor a ; LOW(vBGMap0)
	ld [wBGMapAnchor], a
	ldh [hSCY], a
	ldh [hSCX], a
	farcall ApplyBGMapAnchorToObjects

	ldh a, [rVBK]
	push af
	ld a, $1
	ldh [rVBK], a

	xor a
	call FillBGMap0or2

	pop af
	ldh [rVBK], a

	ld a, "■"
	call FillBGMap0or2
	ret

.PushAttrmap:
	decoord 0, 0
	call .copy
	decoord 0, 0, wAttrmap
	ld a, $1
	ldh [rVBK], a
.copy
	hlbgcoord 0, 0
	ld c, SCREEN_WIDTH
	ld b, SCREEN_HEIGHT
.row
	push bc
.column
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .column
	ld bc, BG_MAP_WIDTH - SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .row
	ld a, $0
	ldh [rVBK], a
	ret

LoadMapGraphics:
	call LoadMapTileset
	call LoadTilesetGFX
	xor a
	ldh [hMapAnims], a
	xor a
	ldh [hTileAnimFrame], a
	farcall RefreshSprites
	call LoadOverworldFontAndFrame
	ret

LoadMapPalettes:
	ld b, CGB_MAPPALS
	jp GetCGBLayout

RefreshMapSprites:
	call ClearSprites
	xor a
	ldh [hBGMapMode], a
	call GetMovementPermissions
	farcall RefreshPlayerSprite
	farcall CheckUpdatePlayerSprite
	ld hl, wPlayerSpriteSetupFlags
	bit PLAYERSPRITESETUP_SKIP_RELOAD_GFX_F, [hl]
	jr nz, .skip
	ld hl, wStateFlags
	set 0, [hl]
	call SafeUpdateSprites
.skip
	ld a, [wPlayerSpriteSetupFlags]
	and (1 << 3) | (1 << 4)
	ld [wPlayerSpriteSetupFlags], a
	ret

CheckMovingOffEdgeOfMap::
	ld a, [wPlayerStepDirection]
	cp STANDING
	ret z
	and a ; DOWN
	jr z, .down
	cp UP
	jr z, .up
	cp LEFT
	jr z, .left
	cp RIGHT
	jr z, .right
	and a
	ret

.down
	ld a, [wPlayerMapY]
	sub 4
	ld b, a
	ld a, [wMapHeight]
	add a
	cp b
	jr z, .ok
	and a
	ret

.up
	ld a, [wPlayerMapY]
	sub 4
	cp -1
	jr z, .ok
	and a
	ret

.left
	ld a, [wPlayerMapX]
	sub 4
	cp -1
	jr z, .ok
	and a
	ret

.right
	ld a, [wPlayerMapX]
	sub 4
	ld b, a
	ld a, [wMapWidth]
	add a
	cp b
	jr z, .ok
	and a
	ret

.ok
	scf
	ret

GetMapScreenCoords::
	ld hl, wOverworldMapBlocks
	ld a, [wXCoord]
	bit 0, a
	jr nz, .odd_x
; even x
	srl a
	add 1
	jr .got_block_x
.odd_x
	add 1
	srl a
.got_block_x
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wMapWidth]
	add MAP_CONNECTION_PADDING_WIDTH * 2
	ld c, a
	ld b, 0
	ld a, [wYCoord]
	bit 0, a
	jr nz, .odd_y
; even y
	srl a
	add 1
	jr .got_block_y
.odd_y
	add 1
	srl a
.got_block_y
	call AddNTimes
	ld a, l
	ld [wOverworldMapAnchor], a
	ld a, h
	ld [wOverworldMapAnchor + 1], a
	ld a, [wYCoord]
	and 1
	ld [wPlayerMetatileY], a
	ld a, [wXCoord]
	and 1
	ld [wPlayerMetatileX], a
	ret

AnchorPointAfterWarp:
; if wCurSpaceNextSpace is not an anchor point, override any anchor point we pass through
	ld a, [wCurSpaceNextSpace]
	cp NEXT_SPACE_IS_ANCHOR_POINT
	ret c
	ld a, [wCurMapAnchorEventCount]
	and a
	ret z
; if we have arrived to an anchor point, load its associated next space to wCurSpaceNextSpace right now.
; note that the next space of an anchor point could be another anchor point.
	ld c, a
	ld hl, wCurMapAnchorEventsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wXCoord]
	ld d, a
	ld a, [wYCoord]
	ld e, a
	jp CheckAndApplyAnchorPoint
