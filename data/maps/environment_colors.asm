EnvironmentColorsPointers:
; entries correspond to environment constants (see constants/map_data_constants.asm)
	table_width 2, EnvironmentColorsPointers
	dw .GrassyColors   ; unused
	dw .GrassyColors   ; OUTDOOR_GRASSY
	dw .MountainColors ; OUTDOOR_MOUNTAIN
	dw .CoastColors    ; OUTDOOR_COAST
	dw .SeaColors      ; OUTDOOR_SEA
	dw .ForestColors   ; INDOOR_FOREST
	dw .CaveColors     ; INDOOR_CAVE
	dw .IceCaveColors  ; INDOOR_ICE_CAVE
	dw .BuildingColors ; INDOOR_BUILDING
	assert_table_length NUM_ENVIRONMENTS + 1

; Valid indices: $00 - $35 (see gfx/tilesets/bg_tiles.pal)
; assumes that maps with an environment of INDOOR_CAVE and INDOOR_ICE_CAVE always have PALETTE_NITE
.GrassyColors:
	db $00, $01, $02, $28, $04, $05, $06, $2e ; morn
	db $08, $09, $0a, $29, $0c, $0d, $0e, $2e ; day
	db $10, $11, $12, $2a, $14, $15, $16, $2e ; nite
	db $18, $19, $1a, $2b, $1c, $1d, $1e, $2e ; eve

.MountainColors:
	db $00, $01, $02, $28, $04, $05, $06, $2f ; morn
	db $08, $09, $0a, $29, $0c, $0d, $0e, $2f ; day
	db $10, $11, $12, $2a, $14, $15, $16, $2f ; nite
	db $18, $19, $1a, $2b, $1c, $1d, $1e, $2f ; eve

.CoastColors:
	db $00, $01, $02, $28, $04, $05, $06, $30 ; morn
	db $08, $09, $0a, $29, $0c, $0d, $0e, $30 ; day
	db $10, $11, $12, $2a, $14, $15, $16, $30 ; nite
	db $18, $19, $1a, $2b, $1c, $1d, $1e, $30 ; eve

.SeaColors:
	db $00, $01, $02, $28, $04, $05, $06, $31 ; morn
	db $08, $09, $0a, $29, $0c, $0d, $0e, $31 ; day
	db $10, $11, $12, $2a, $14, $15, $16, $31 ; nite
	db $18, $19, $1a, $2b, $1c, $1d, $1e, $31 ; eve

.ForestColors:
	db $00, $01, $02, $03, $04, $05, $06, $32 ; morn
	db $08, $09, $0a, $0b, $0c, $0d, $0e, $32 ; day
	db $10, $11, $12, $13, $14, $15, $16, $32 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $32 ; eve

.CaveColors:
	db $10, $11, $12, $13, $14, $15, $16, $33 ; morn
	db $10, $11, $12, $13, $14, $15, $16, $33 ; day
	db $10, $11, $12, $13, $14, $15, $16, $33 ; nite
	db $10, $11, $12, $13, $14, $15, $16, $33 ; eve

.IceCaveColors:
	db $10, $11, $2c, $13, $14, $15, $2d, $34 ; morn
	db $10, $11, $2c, $13, $14, $15, $2d, $34 ; day
	db $10, $11, $2c, $13, $14, $15, $2d, $34 ; nite
	db $10, $11, $2c, $13, $14, $15, $2d, $34 ; eve

.BuildingColors:
	db $20, $21, $22, $23, $24, $25, $26, $35 ; morn
	db $20, $21, $22, $23, $24, $25, $26, $35 ; day
	db $10, $11, $12, $13, $14, $15, $16, $35 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $35 ; eve
