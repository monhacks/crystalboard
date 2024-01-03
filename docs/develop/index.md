<style>
  c { color: #8f8f8f }
  f { color: #bf1f1f }
  j { color: #1f1fbf }
  k { color: #1f7f1f }
</style>

## Functions

#### Apply VRAM/OAM

- **SafeUpdateSprites**: Set BG map mode to 0 (disabled) and disable OAM update + UpdateSprites + enable OAM update + DelayFrame + restore original state of BG map mode and OAM update
- **UpdateSprites**: Compute state of overworld sprites to wShadowOAM. Disable OAM update while editing wShadowOAM, and restore its original state when finished
- **ApplyPals**: Copy wBGPals1 into wBGPals2 and wOBPals1 into wOBPals2. Does not request pal update during vblank by itself
- **ApplyAttrmap**: Set BG map mode to 2 (pals) and delay 4 frames, and finally restore original state BG map mode. If LCD disabled instead copy all pals at once immediately
- **ApplyTilemap**: Set BG map mode to 1 (tiles) and delay 4 frames. If wSpriteUpdatesEnabled is non-0, instead call CopyTilemapAtOnce to do it all in one frame. This delays the next vblank to LY ~$7f

#### Load font

- **LoadFont_NoOAMUpdate**: LoadFrame + Hide Window + LoadStandardFont with OAM update disabled
- **LoadOverworldFont_NoOAMUpdate**: LoadOverworldFontAndFrame + hide Window with OAM update disabled

#### Textboxes

- **Textbox1bpp**: TextboxBorder + TextboxAttributes1bpp
- **Textbox2bpp**: _OverworldTextbox + TextboxAttributes2bpp
- **SpeechTextbox1bpp**: Textbox1bpp with speech location and dimensions
- **SpeechTextbox2bpp**: Textbox2bpp with speech location and dimensions
- **ClearTextbox**: Clear the inside of a speech textbox (fill with " ")
- **PrintTextboxText**: Print text in speech textbox coordinates with letter delay
- **PrintText1bpp**, **FarPrintText1bpp**: SpeechTextbox1bpp + UpdateSprites + ApplyTilemap + ClearTextbox + PrintTextboxText
- **PrintText2bpp**: SpeechTextbox2bpp + UpdateSprites + ApplyTilemap + ClearTextbox + PrintTextboxText
- **MapTextbox**: ClearTextbox + redraw tile behind cursor + SafeUpdateSprites + disable OAM update + ApplyTilemap + PrintTextboxText + enable OAM update
- **MenuBox**: Calls Textbox1bpp or Textbox2bpp, depending on the value of wText2bpp, with menu location and dimensions.

#### Overworld map scrolling

- **LoadScreenTilemap**: From the metatile-based 24x20 map in wSurroundingTiles, load the corresponding 20x18 tiles to wTilemap. Later, BackupBGMap* from ScrollMap* copies new row/column from wTilemap to wBGMapBuffer. _ScrollBGMapPalettes populates wBGMapPalBuffer based on the tiles at wBGMapBuffer. These are read during vblank by UpdateBGMapBuffer.
- **LoadScreenAttrmapPals**: Load wAttrmap palette numbers based on the tileset palettes of the current map. Called only by LoadScreenTilemapAndAttrmapPals.
- **LoadScreenTilemapAndAttrmapPals**: LoadScreenTilemap + LoadScreenAttrmapPals. Often used to reload screen after closing a text box.

#### Overworld map anchoring

- **ReanchorBGMap_NoOAMUpdate**: LoadScreenTilemapAndAttrmapPals + HDMATransferTilemapAndAttrmap_OpenAndCloseMenu, then fill BG map with all black while Window is displayed, finally anchor map and objects. Shall by followed by CopyTilemapAtOnce or by a HDMATransferTilemapAndAttrmap_* to redraw the screen.
- **OpenText1bpp**, **OpenText2bpp**: ClearMenuAndWindowData + ReanchorBGMap_NoOAMUpdate + SpeechTextbox1bpp + HDMATransferTilemapAndAttrmap_OpenAndCloseMenu + hide Window
  - **OpenText1bpp**: Loads 1bpp font (LoadFont_NoOAMUpdate)
  - **OpenText2bpp**: Doesn't load 2bpp font
- **RefreshScreen**: Same as OpenText functions but doesn't call any SpeechTextbox

#### VRAM transfer

- **Request1bpp**, **Request2bpp**: Copy 1bpp or 2bpp tiles at a rate of TILES_PER_CYCLE (8) per frame during vblank. Wait until complete
- **Copy1bpp**, **Copy2bpp**: Copy 1bpp or 2bpp tiles immediately
- **Get1bpp**, **Get2bpp**: Call Copy1bpp or Copy2bpp if LCD disabled. Request1bpp or Request2bpp otherwise
- **HDMATransfer1bpp**: Copy 1bpp tiles via HDMA. Maximum 16 tiles per frame
- **HDMATransfer2bpp**: Copy 2bpp tiles via HDMA. No hardcoded limit. Timing considers 1 tile per hblank
- **Get1bppViaHDMA**, **Get2bppViaHDMA**: Call Copy1bpp or Copy2bpp if LCD disabled. HDMATransfer1bpp or HDMATransfer2bpp otherwise
- **HDMATransferTilemapAndAttrmap_OpenAndCloseMenu**, **HDMATransferTilemapAndAttrmap_OverworldEffect**: Similar, but with slightly different scanline timing. So they're essentially like RefreshScreen minus the anchoring part.

#### HUD

- **EnableWindowHUD**: Configure LCD interrupt in LYC=LY mode with corresponding LYC.
- **DisableWindowHUD**: Configure LCD interrupt in hblank mode
- **LoadHUD**: Load the HUD at wWhichHUD to the top of wTilemap and wAttrmap
- **LoadWindowHUD**: Like LoadHUD, but for HUDs that require a Window overlay. Only does anything if hWindowHUDLY is non-0
- **ConstructOverworldHUDTilemap**: Draw the overworld HUD's tilemap into wOverworldHUDTiles
- **TransferOverworldHUDToBGMap**: Transfer overworld HUD to vBGMap1/vBGMap3 during v/hblank(s). Tilemap is read from wOverworldHUDTiles, attrmap is all PAL_BG_TEXT | PRIORITY.
- **RefreshOverworldHUD**: ConstructOverworldHUDTilemap + TransferOverworldHUDToBGMap

## Scripts

- **refreshscreen**: RefreshScreen
- **reloadmappart**: LoadScreenTilemapAndAttrmapPals + GetMovementPermissions + HDMATransferTilemapAndAttrmap_OverworldEffect + UpdateSprites. Similar to refreshscreen, but does not reanchor. On the other hand, it refreshes movement permissions. Often used after a block change or field move, which can affect collisions.

## Changes

### RAM addresses

- **hCurBoardEvent**: holds a *BOARDEVENT_* value.

- **wTurnData** ~ **wTurnDataEnd**: not preserved on save, and cleared at the beginning of BoardMenuScript (i.e. on turn begin). It's part of *wMapStatus* ~ *wMapStatusEnd*, so it's also cleared by *StartMap*. Includes:
  - **wDieRoll**
  - **wSpacesLeft**

- Addresses within *wCurMapData* ~ *wCurMapDataEnd*: preserved on save. Initialized when entering a level, and updated accordingly throughout the level. Includes:
  - **wCurTurn**
  - **wCurSpace**
  - **wCurLevelCoins**
  - **wCurLevelExp**
  - **wCurSpaceStruct**:
    - **wCurSpaceXCoord**
    - **wCurSpaceYCoord**
    - **wCurSpaceEffect** for non-branch spaces, or **wCurSpaceBranchStructPtr** (two bytes) for branch spaces
    - **wCurSpaceNextSpace** for non-branch spaces

- Addresses within *wPlayerData* ~ *wPlayerDataEnd*: preserved on save. Includes:
  - **wUnlockedLevels**: flag array that tracks progression regarding which levels have been unlocked.
  - **wUnlockedTechniques**: flag array that tracks progression regarding which techniques have been unlocked.
  - **wCurOverworldMiscPal**

- These addresses share memory region with string buffers from *wStringBuffer3* onwards. They are placed in memory in the following order.
  - **wTempSpaceStruct**: Temporary scope. Same structure as *wCurSpaceStruct*
  - **wTempSpaceBranchStruct**: Temporary scope. The structure is four bytes for next space for each direction (R/L/U/D; -1 if unavailable direction) followed by four bytes for required techniques for each direction (R/L/U/D)
  - **wViewMapModeRange**, **wViewMapModeDisplacementY**, **wViewMapModeDisplacementX**: Temporary scope during a Vew Map mode session.
  - **wBeforeViewMapYCoord**, **wBeforeViewMapXCoord**, **wBeforeViewMapMapGroup**, **wBeforeViewMapMapNumber**: Temporary scope during a Vew Map mode session. Used to preserve previous player state.

- Addresses for talker events:
  - *wSeenTrainer** addresses have been repurposed as **wSeenTrainerOrTalker***
  - **wSeenTrainerOrTalkerIsTalker**: added right before *wSeenTrainerOrTalker**.
  - **wTempTalker** ~ **wTempTalkerEnd**: allocated to the same address space as *wTempTrainer*. Same scope as *wTempTrainer*, but for talker events.

- Address spaces for backing up the map state (disabled spaces and map objects). Located outside of WRAM banks 0 and 1.
  - **wDisabledSpacesBackups**: preserved on save to **sDisabledSpacesBackups**.
  - **wMapObjectsBackups**: preserved on save to **sMapObjectsBackups**.

### Overworld workflow

1) ``OverworldLoop`` is called from ``GameMenu_WorldMap`` with either ``hMapEntryMethod`` = ``MAPSETUP_ENTERLEVEL`` or ``hMapEntryMethod`` = ``MAPSETUP_CONTINUE``.
2) ``StartMap`` resets ``wCurTurn`` and ``wCurSpace`` if ``MAPSETUP_ENTERLEVEL``. ``StartMap`` sets ``hCurBoardEvent`` to ``BOARDEVENT_DISPLAY_MENU``. ``wScriptFlags2`` is cleared. ``wMapStatus`` is set to ``MAPSTATUS_HANDLE`` causing ``HandleMap`` to be called.
3) ``MapEvents`` (from ``HandleMap``) calls ``PlayerEvents``. ``CheckBoardEvent`` queues ``BoardMenuScript`` which is executed by ``ScriptEvents``.
4) ``BoardMenuScript.Upkeep`` saves the game, clears ``wTurnData[]``, increases ``wCurTurn``, and loads current space to ``wCurSpaceStruct[]``.
    - If player exits, the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
5) Player rolls die and the animation plays. After the animation, ``wDisplaySecondarySprites.SECONDARYSPRITES_SPACES_LEFT_F`` is set and ``hCurBoardEvent`` is set to ``BOARDEVENT_HANDLE_BOARD``. At the end of this ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_ON`` (``wScriptFlags2`` is not touched so it remains cleared).
6) In the next ``HandleMap`` iteration, ``CheckBoardEvent`` from ``PlayerEvents`` jumps to ``.board`` and then to ``.no_space_effect`` due to ``wScriptFlags2[4]`` not being set.
7) Execution continues in ``PlayerEvents``; ``OWPlayerInput`` is eventually called, and thus ``DoPlayerMovement``. Here, ``StepTowardsNextSpace`` computes based on ``wCurSpaceNextSpace`` what direction key to write to ``wCurInput``, causing the player to begin a movement in that direction.
8) The player may need to turn to a different direction through the ``ChangeDirectionScript`` (when ``DoPlayerMovement`` returns with ``PLAYERMOVEMENT_TURN``). Otherwise or after that, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_OFF``,
9) When the step finishes (i.e. ``PLAYERSTEP_STOP_F`` becomes set) in some ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wScriptFlags2`` to $ff and ``wMapEventStatus`` to ``MAPEVENTS_ON``.
10) In the next ``HandleMap`` iteration, ``CheckBoardEvent.board`` is called with ``wScriptFlags2[4]`` set.
      - If ``wCurSpaceNextSpace`` matches ``NEXT_SPACE_IS_ANCHOR_POINT``: If player is at a tile with an anchor event, ``wCurSpaceNextSpace`` is updated with the next space byte of salid anchor event. ``wScriptFlags2[4]`` is reset. **Go back to 7**.
      - If player is not above a tile (``wPlayerTile``) with a space collision: ``wScriptFlags2[4]`` is reset. **Go back to 7**.
      - If player is above a tile, the corresponding space script is queued to be executed by ``ScriptEvents`` in the current ``HandleMap`` iteration. ``wScriptFlags2[4]`` is reset. **Continue to 11**.
11) The space script loads the value of ``wCurSpaceNextSpace`` into ``wCurSpace``, and loads the new space data to ``wCurSpaceStruct[]``. Unless the space is a Branch Space or a Union Space, ``wSpacesLeft`` is decreased.
      - If the space is a Branch Space, the branch data is loaded to ``wTempSpaceBranchStruct``. Then the player is prompted to choose a valid direction. ``wCurSpaceNextSpace`` is populated with the next space that corresponds to the chosen direction. **Go back to 6**.
      - If the space is an End Space, a fading out animation plays and then the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
12) If ``wSpacesLeft`` is non-0, **go back to 6**.
13) The script code specific to the space type of the landed-on space is executed.
      - If player whites out in battle, ``Script_BattleWhiteout`` executes ``exitoverworld``. **Exit this workflow**.
14) The landed-on space is disabled by executing a block change that converts it into a Grey Space. ``hCurBoardEvent`` is set to ``BOARDEVENT_END_TURN``. ``CheckBoardEvent`` does nothing in this state. In the first subsequent ``HandleMap`` iteration where no other kind of event triggers causing ``PlayerEvents`` to return early, ``hCurBoardEvent`` is set to ``BOARDEVENT_DISPLAY_MENU``.
15) **Go back to 3**

### View Map mode workflow

1) Pressing SELECT in the board menu triggers View Map mode. ``hCurBoardEvent`` is set to ``BOARDEVENT_VIEW_MAP_MODE``, player state (coordinates as well as current map in order to support connected maps) is backed up, ``wPlayerFlags[INVISIBLE_F]`` is set, and a static mockup of the player object is loaded to the last ``wMapObject`` and, in the background, to the first ``wObjectStruct`` is available.
2) The board event handler in ``CheckBoardEvent`` listens for the B button being pressed (except when a DPAD key is simultaneously held). When B is pressed, a script (a single ``reloadmapafterviewmapmode``) to exit from View Map mode is queued to be executed by ``ScriptEvents``. Otherwise, ``DoPlayerMovement.ViewMapMode`` handles movement input in this mode.
3) When requested exit of View Map mode via B button, ``reloadmapafterviewmapmode`` sets ``hMapEntryMethod`` to ``MAPSETUP_EXITVIEWMAP``, ``hMapEntryMethod`` to ``SPAWN_FROM_RAM`` (required by the map setup command ``EnterMapSpawnPoint`` to restore the backed up player state), loads ``MAPSTATUS_ENTER`` tp ``wMapStatus``, and resets ``wPlayerFlags[INVISIBLE_F]`` (the mocked player object naturally disappears when the map reloads).
4) Then:
      a) If View Map mode was entered from the board menu, ``BOARDEVENT_REDISPLAY_MENU`` is loaded. It is the same as ``BOARDEVENT_DISPLAY_MENU`` but skips ``BoardMenuScript.Upkeep``.
      b) If View Map mode was entered from the branch menu, instead ``BOARDEVENT_RESUME_BRANCH`` is loaded, using ``wPlayerSpriteSetupFlags[PLAYERSPRITESETUP_CUSTOM_FACING_F]`` to maintain the facing direction according to the direction (``SPRITEMOVEDATA_*``) of the mocked player object. ``BOARDEVENT_RESUME_BRANCH`` makes sure to shortcut the branch space script by calling ``BranchSpaceScript_PromptPlayer`` directly and avoiding the recomputation of the branch struct that would cause corruption. ``BOARDEVENT_HANDLE_BOARD`` is loaded immediately by ``BOARDEVENT_RESUME_BRANCH``.

- In View Map mode, regular collisions except for ``COLL_OUT_OF_BOUNDS`` are ignored whereas going off-limits (i.e. outside of the map limits in a direction where there is no connected map) or off-range is accounted for.
- Events other than warpless connections are ignored in View Map mode (as well as button actions, like while in ``BOARDEVENT_HANDLE_BOARD``).
- ``wTileDown``, ``wTileUp``, etc., otherwise unused, are borrowed by in order to signal valid directions to ``InitSecondarySprites`` (e.g. ``wTileDown=COLL_OUT_OF_BOUNDS`` means that DOWN direction is not valid).
- In View Map mode, the overworld delay is 1 rather than 2.
- ``UpdatePlayerCoords`` tracks the displacement during View Map mode in the X and Y axes in order to monitor the allowed range.