MapSetupScripts:
; entries correspond to MAPSETUP_* constants (see constants/map_setup_constants.asm)
	table_width 2, MapSetupScripts
	dw MapSetupScript_Warp
	dw MapSetupScript_Continue
	dw MapSetupScript_ReloadMap
	dw MapSetupScript_Teleport
	dw MapSetupScript_Door
	dw MapSetupScript_Fall
	dw MapSetupScript_Connection
	dw MapSetupScript_LinkReturn
	dw MapSetupScript_Train
	dw MapSetupScript_Submenu
	dw MapSetupScript_BadWarp
	dw MapSetupScript_Fly
	dw MapSetupScript_EnterLevel
	dw MapSetupScript_ExitViewMap
	assert_table_length NUM_MAPSETUP_SCRIPTS

; valid commands are listed in MapSetupCommands (see data/maps/setup_script_pointers.asm)
MACRO mapsetup
	db (\1_MapSetupCmd - MapSetupCommands) / 3
ENDM

MapSetupScript_EnterLevel:
; same as MapSetupScript_Warp, but includes ResetLevelScopedEventFlags and ConstructAndEnableOverworldHUD
	mapsetup DisableLCD
	mapsetup InitSound
	mapsetup EnterMapSpawnPoint
	mapsetup LoadMapAttributes
	mapsetup HandleNewMap
	mapsetup ResetLevelScopedEventFlags
	mapsetup SpawnPlayer
	mapsetup RefreshPlayerCoords
	mapsetup GetMapScreenCoords
	mapsetup LoadBlockData
	mapsetup BufferScreen
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup ConstructAndEnableOverworldHUD
	mapsetup LoadMapObjects
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup SpawnInFacingDown
	mapsetup RefreshMapSprites
	mapsetup PlayMapMusicBike
	mapsetup FadeInToMusic
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	db -1 ; end

MapSetupScript_Teleport:
	mapsetup ResetPlayerObjectAction
MapSetupScript_Fly:
	mapsetup FadeOutPalettesToWhite
	mapsetup JumpRoamMons
MapSetupScript_Warp:
	mapsetup DisableLCD
	mapsetup InitSound
	mapsetup BackupMapObjects
	mapsetup EnterMapSpawnPoint
	mapsetup LoadMapAttributes
	mapsetup HandleNewMap
	mapsetup SpawnPlayer
	mapsetup RefreshPlayerCoords
	mapsetup GetMapScreenCoords
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup LoadMapObjects
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup SpawnInFacingDown
	mapsetup RefreshMapSprites
	mapsetup PlayMapMusicBike
	mapsetup FadeInToMusic
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	mapsetup AnchorPointAfterWarp
	db -1 ; end

MapSetupScript_BadWarp:
	mapsetup BackupMapObjects
	mapsetup EnterMapSpawnPoint
	mapsetup LoadMapAttributes
	mapsetup HandleNewMap
	mapsetup SpawnPlayer
	mapsetup RefreshPlayerCoords
	mapsetup GetMapScreenCoords
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup DisableLCD
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup FadeOutMapMusic
	mapsetup EnableLCD
	mapsetup LoadMapObjects
	mapsetup LoadMapPalettes
	mapsetup SpawnInFacingDown
	mapsetup RefreshMapSprites
	mapsetup FadeToMapMusic
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	mapsetup AnchorPointAfterWarp
	db -1 ; end

MapSetupScript_Connection:
	mapsetup SuspendMapAnims
	mapsetup BackupMapObjects
	mapsetup EnterMapConnection
	mapsetup LoadMapAttributes
	mapsetup HandleNewMap
	mapsetup RefreshPlayerCoords
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup LoadMapTileset
	mapsetup SaveScreen
	mapsetup LoadMapObjects
	mapsetup FadeToMapMusic
	mapsetup LoadMapPalettes
	mapsetup ApplyMapPalettes
	mapsetup LoadWildMonData
	mapsetup UpdateRoamMons
	mapsetup ActivateMapAnims
	db -1 ; end

MapSetupScript_Fall:
	mapsetup ResetPlayerObjectAction
MapSetupScript_Door:
	mapsetup FadeOutPalettesToWhite
MapSetupScript_Train:
	mapsetup BackupMapObjects
	mapsetup EnterMapWarp
	mapsetup LoadMapAttributes
	mapsetup GetWarpDestCoords
	mapsetup HandleNewMap
	mapsetup RefreshPlayerCoords
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup DisableLCD
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup FadeOutMapMusic
	mapsetup EnableLCD
	mapsetup LoadMapObjects
	mapsetup LoadMapPalettes
	mapsetup RefreshMapSprites
	mapsetup FadeToMapMusic
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	mapsetup UpdateRoamMons
	mapsetup AnchorPointAfterWarp
	db -1 ; end

MapSetupScript_ReloadMap:
	mapsetup FadeMapMusicAndPalettes
	mapsetup ClearBGPalettes
	mapsetup DisableLCD
	mapsetup InitSound
	mapsetup LoadBlockData
	mapsetup LoadConnectionBlockData
	mapsetup LoadDisabledSpaces
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup EnableOverworldHUD
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup RefreshMapSprites
	mapsetup ForceMapMusic
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	db -1 ; end

MapSetupScript_ExitViewMap:
	mapsetup ClearBGPalettes
	mapsetup DisableLCD
	mapsetup EnterMapSpawnPoint
	mapsetup LoadMapAttributes
	mapsetup SpawnPlayer
	mapsetup RefreshPlayerCoords
	mapsetup GetMapScreenCoords
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup EnableOverworldHUD
	mapsetup LoadMapObjects
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup SpawnInCustomFacing ; restore player's facing if in branch space
	mapsetup RefreshMapSprites
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	db -1 ; end

MapSetupScript_LinkReturn:
	mapsetup FadeMapMusicAndPalettes
	mapsetup DisableLCD
	mapsetup InitSound
	mapsetup HandleNewMap
	mapsetup LoadBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup RefreshMapSprites
	mapsetup PlayMapMusicBike
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	mapsetup EnableTextAcceleration
	db -1 ; end

MapSetupScript_Continue:
	mapsetup DisableLCD
	mapsetup InitSound
	mapsetup LoadMapAttributes_SkipObjects
	mapsetup GetMapScreenCoords
	mapsetup HandleContinueMap
	mapsetup LoadBlockData
	mapsetup LoadConnectionBlockData
	mapsetup LoadDisabledSpaces
	mapsetup BufferScreen
	mapsetup LoadMapGraphics
	mapsetup LoadMapTimeOfDay
	mapsetup ConstructAndEnableOverworldHUD
	mapsetup EnableLCD
	mapsetup LoadMapPalettes
	mapsetup RefreshMapSprites
	mapsetup PlayMapMusicBike
	mapsetup FadeInPalettesFromWhite
	mapsetup ActivateMapAnims
	mapsetup LoadWildMonData
	db -1 ; end

MapSetupScript_Submenu:
	mapsetup LoadBlockData
	mapsetup LoadConnectionBlockData
	mapsetup LoadDisabledSpaces
	db -1 ; end
