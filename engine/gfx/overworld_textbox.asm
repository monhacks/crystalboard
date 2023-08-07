	const_def "┌" ; $f0
	const OW_TEXTBOX_FRAME_WHITE
	const OW_TEXTBOX_FRAME_TOP_LEFT_CORNER
	const OW_TEXTBOX_FRAME_TOP_2
	const OW_TEXTBOX_FRAME_TOP_1
	const OW_TEXTBOX_FRAME_TOP_RIGHT_CORNER
	const OW_TEXTBOX_FRAME_LEFT_1
	const OW_TEXTBOX_FRAME_LEFT_2
	const OW_TEXTBOX_FRAME_BOTTOM_LEFT_CORNER
	const OW_TEXTBOX_FRAME_BOTTOM_2
	const OW_TEXTBOX_FRAME_BOTTOM_1
	const OW_TEXTBOX_FRAME_BOTTOM_RIGHT_CORNER
	const OW_TEXTBOX_FRAME_RIGHT_1
	const OW_TEXTBOX_FRAME_RIGHT_2
	const OW_TEXTBOX_FRAME_BACKGROUND

OW_TEXTBOX_FRAME_MIN_HEIGHT EQU 4
OW_TEXTBOX_FRAME_MIN_WIDTH  EQU 6

OverworldTextbox::
; Draw a textbox at de with room for b rows and c columns using the 2bpp overworld frame tiles.
	ld a, b
	cp OW_TEXTBOX_FRAME_MIN_HEIGHT - 2
	jr nc, .got_height
	ld b, OW_TEXTBOX_FRAME_MIN_HEIGHT - 2
.got_height
	ld a, c
	cp OW_TEXTBOX_FRAME_MIN_WIDTH - 2
	jr nc, .got_width
	ld c, OW_TEXTBOX_FRAME_MIN_WIDTH - 2
.got_width
	ld h, d
	ld l, e
; top row
	ld [hl], OW_TEXTBOX_FRAME_TOP_LEFT_CORNER
	inc hl
	ld e, 0
	call .GetTileArrangementPointer
	call .CopyHorizontalTiles
	ld [hl], OW_TEXTBOX_FRAME_TOP_RIGHT_CORNER
; left column
	inc hl
	push hl
	ld e, 4
	call .GetTileArrangementPointer
	call .CopyVerticalTiles
	pop hl
; right column
	push hl
	ld de, SCREEN_WIDTH - 1
	add hl, de
	ld e, 6
	call .GetTileArrangementPointer
	call .CopyVerticalTiles
; bottom row
	; we are in the bottom right corner, so first go back to the start of the line
	ld de, -(SCREEN_WIDTH - 1)
	add hl, de
	ld [hl], OW_TEXTBOX_FRAME_BOTTOM_LEFT_CORNER
	inc hl
	ld e, 2
	call .GetTileArrangementPointer
	call .CopyHorizontalTiles
	ld [hl], OW_TEXTBOX_FRAME_BOTTOM_RIGHT_CORNER
; background
	pop hl
	inc hl
	ld a, OW_TEXTBOX_FRAME_BACKGROUND
	jp FillBoxWithByte

.CopyHorizontalTiles:
; copy horizontally c tiles from the ow_textbox_tiles pattern at de to hl
	push bc
	push de
.loop_h
	ld a, [de]
	cp -1
	jr nz, .next_h
	pop de
	ld a, [de]
	push de
.next_h
	ld [hli], a
	inc de
	dec c
	jr nz, .loop_h
	pop de
	pop bc
	ret

.CopyVerticalTiles:
; copy vertically b tiles from the ow_textbox_tiles pattern at de to hl
	push bc
	push de
.loop_v
	ld a, [de]
	cp -1
	jr nz, .next_v
	pop de
	ld a, [de]
	push de
.next_v
	ld [hl], a
	push bc
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	inc de
	dec b
	jr nz, .loop_v
	pop de
	pop bc
	ret

.GetTileArrangementPointer:
; return de pointing to an address from .TileArrangementPointers according to wEnvironment and offset in e
	push hl
	push bc
	ld a, [wEnvironment]
	maskbits NUM_ENVIRONMENTS
	ld hl, .TileArrangementPointers
	ld d, 0
	add hl, de
	ld bc, 2 * 4
	call AddNTimes
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop bc
	pop hl
	ret

MACRO ow_textbox_tiles
	rept _NARG
		db OW_TEXTBOX_FRAME_\1
		shift
	endr
	db -1
ENDM

.TileArrangementPointers:
; entries correspond to environment constants (see constants/map_data_constants.asm)
	table_width 2 * 4, .TileArrangementPointers
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; OUTDOOR_GRASSY
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; OUTDOOR_MOUNTAIN
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; OUTDOOR_COAST
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; OUTDOOR_SEA
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; INDOOR_FOREST
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; INDOOR_CAVE
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; INDOOR_ICE_CAVE
	dw .TilesTop1, .TilesBottom1, .TilesLeft1, .TilesRight1 ; INDOOR_BUILDING
	assert_table_length NUM_ENVIRONMENTS

.TilesTop1:
	ow_textbox_tiles TOP_1, TOP_1, TOP_2, TOP_2
.TilesBottom1:
	ow_textbox_tiles BOTTOM_1, BOTTOM_1, BOTTOM_2, BOTTOM_2
.TilesLeft1:
	ow_textbox_tiles LEFT_1, LEFT_2
.TilesRight1:
	ow_textbox_tiles RIGHT_1, RIGHT_2
