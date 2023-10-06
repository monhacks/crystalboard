MACRO tileset
	dba \1GFX, \1Meta, \1Coll
	dw \1Anim
	dw \1PalMap
	db TILESET_VARIABLE_SPACES_\2
ENDM

; Associated data:
; - The *GFX, *Meta, and *Coll are defined in gfx/tilesets.asm
; - The *PalMap are defined in gfx/tileset_palette_maps.asm
; - The *Anim are defined in engine/tilesets/tileset_anims.asm
; - TILESET_VARIABLE_SPACES_* points to an entry of TilesetVariableSpacesPointers in gfx/tilesets.asm

Tilesets::
; entries correspond to TILESET_* constants (see constants/tileset_constants.asm)
	table_width TILESET_LENGTH, Tilesets
	tileset Tileset0, 1
	tileset TilesetJohto, 1
	tileset TilesetJohtoModern, 1
	tileset TilesetKanto, 1
	tileset TilesetBattleTowerOutside, 1
	tileset TilesetHouse, 1
	tileset TilesetPlayersHouse, 1
	tileset TilesetPokecenter, 1
	tileset TilesetGate, 1
	tileset TilesetPort, 1
	tileset TilesetLab, 1
	tileset TilesetFacility, 1
	tileset TilesetMart, 1
	tileset TilesetMansion, 1
	tileset TilesetGameCorner, 1
	tileset TilesetEliteFourRoom, 1
	tileset TilesetTraditionalHouse, 1
	tileset TilesetTrainStation, 1
	tileset TilesetChampionsRoom, 1
	tileset TilesetLighthouse, 1
	tileset TilesetPlayersRoom, 1
	tileset TilesetPokeComCenter, 1
	tileset TilesetBattleTowerInside, 1
	tileset TilesetTower, 1
	tileset TilesetCave, 1
	tileset TilesetPark, 1
	tileset TilesetRuinsOfAlph, 1
	tileset TilesetRadioTower, 1
	tileset TilesetUnderground, 1
	tileset TilesetIcePath, 1
	tileset TilesetDarkCave, 1
	tileset TilesetForest, 1
	tileset TilesetBetaWordRoom, 1
	tileset TilesetHoOhWordRoom, 1
	tileset TilesetKabutoWordRoom, 1
	tileset TilesetOmanyteWordRoom, 1
	tileset TilesetAerodactylWordRoom, 1
if DEF(_DEBUG)
	tileset TilesetBoardDebug1, 1
endc
	assert_table_length NUM_TILESETS + 1
