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

## Overworld loop (pokecrystal)

```
<f>Primary functions</f> are denoted in red and using indentation
<j>*[j<num>]*</j> means jumping ahead
<k>*r<num>_<ret_value>*</k> means break/return from current function with a return value
Horizontal line means end of loop
Bold denotes not documented yet
<c>This denotes a comment</c>
```

wMapStatus == MAPSTATUS_START:\
$~~~~$wScriptRunning <= 0\
$~~~~$wMapStatus ~ wMapStatusEnd <= 0

wMapStatus == MAPSTATUS_START or wMapStatus == MAPSTATUS_ENTER:\
$~~~~$**RunMapSetupScript**\
$~~~~$hMapEntryMethod == MAPSETUP_CONNECTION:\
$~~~~~~~~$wScriptFlags2 <= \$ff\
$~~~~$hMapEntryMethod <= 0\
$~~~~$wMapStatus <= MAPSTATUS_HANDLE

---

wMapStatus == MAPSTATUS_DONE:\
$~~~~$*Exit overworld loop*

---

wMapStatus == MAPSTATUS_HANDLE: <c>the remainder of the code goes at this level</c>
> hOverworldDelay <= 2 <c>2 is *MaxOverworldDelay*</c>\
> wMapEventStatus == MAPEVENTS_ON:\
>$~~~~$*Get joypad* <c>update hJoyDown, hJoyReleased, hJoyPressed</c>\
>$~~~~$*Refresh pals*

> HandleCmdQueue <c>runs cmds queued by callbacks of type MAPCALLBACK_CMDQUEUE that execute the writecmdqueue script. Used only for stone tables, where any boulder from that table that is on a pit tile is made to disappear.</c>

> <f>MapEvents (wMapEventStatus == MAPEVENTS_ON):</f>

>> <f>PlayerEvents (wScriptRunning == FALSE):</f> <c>wScriptRunning check not to interrupt a running script command with wait/delay mode like applymovement and deactivatefacing</c>

>>> <f>CheckTrainerBattle:</f>\
>>> *if seen by trainer (if any visible sprite is a trainer not yet beaten facing the player within line of sight)*:\
>>>$~~~~$*update wSeenTrainerDistance, wSeenTrainerDirection, wSeenTrainerBank, hLastTalked*\
>>>$~~~~$*load trainer data to wTempTrainer ~ wTempTrainerEnd*\
>>>$~~~~$<j>[j1(PLAYEREVENT_SEENBYTRAINER)]</j>

>>> <f>CheckTileEvent:</f>\
>>> *if warp, coord event, step event, or wild encounter*:\
>>> $~~~~$<j>[j1(PLAYEREVENT_CONNECTION / PLAYEREVENT_FALL / PLAYEREVENT_WARP / PLAYEREVENT_MAPSCRIPT / PLAYEREVENT_HATCH)]</j> <c>step events include: special phone call, repel, poison, happiness, egg, daycare, bike</c>\
>>> $~~~~$*may also* CallScript(<coord_event_script> / Script_ReceivePhoneCall / RepelWoreOffScript / Script_MonFaintedToPoison / WildBattleScript / BugCatchingContestBattleScript)

>>> <f>**RunMemScript**:</f>\
>>> *if any script at wMapReentryScript*: <j>[j1]</j> <c>used for phone scripts</c>

>>> <f>**RunSceneScript**:</f>\
>>> *if scene event (wCurMapSceneScriptCount)*: <j>[j1(PLAYEREVENT_MAPSCRIPT)]</j>

>>> <f>**CheckTimeEvents**:</f>\
>>> *if any time event*: <j>[j1]</j> <c>used for bug contest, daily events</c>

>>> <f>OWPlayerInput:</f>

>>>> <f>PlayerMovement:</f>

>>>>> <f>DoPlayerMovement:</f>

>>>>> wCurInput <= hJoyDown <c>if BIKEFLAGS_DOWNHILL_F and hJoyDown & D_PAD == 0, instead load D_DOWN </c>\
>>>>> wMovementAnimation <= movement_step_sleep\
>>>>> wWalkingIntoEdgeWarp <= FALSE

>>>>> <c>Tile collision checks below consist on reading the current tile *wPlayerTile* and comparing it to a *COLL_* constant or a range of *COLL_* constants.</c>\
>>>>> <c>Tile permission checks below consist on reading the permissions of the tile that the player is walking into: *wTilePermissions* (applies only to *COLL_WALL*s) and *wWalkingTile* (*LAND_TILE*, *WATER_TILE*, or *WALL_TILE* for the tile in the walking direction; *WALL_TILE* permission is not the same as a *COLL_WALL* collision).</c>\
>>>>> wPlayerState == PLAYER_NORMAL or wPlayerState = PLAYER_BIKE:\
>>>>> $~~~~$*if on ice tile and wPlayerTurningDirection != 0: wCurInput <= current direction button*\
>>>>> $~~~~$*update wWalkingDirection, wFacingDirection, wWalkingX, wWalkingY, wWalkingTile, based on wCurInput direction*\
>>>>> $~~~~$*if whirlpool tile: <k>r1_player_movement = PLAYERMOVEMENT_FORCE_TURN</k>*\
>>>>> $~~~~$*if waterfall tile: wWalkingDirection <= direction, DoStep(STEP_WALK), <k>r1_player_movement = PLAYERMOVEMENT_CONTINUE</k>*\
>>>>> $~~~~$*if door/staircase/cave warp tile (non ladder/carpet): wWalkingDirection <= DOWN, DoStep(STEP_WALK), <k>r1_player_movement = PLAYERMOVEMENT_CONTINUE</k>*\
>>>>> $~~~~$*if directions at wWalkingDirection and wPlayerDirection are not the same (turning): DoStep(STEP_TURN), <k>r1_player_movement = PLAYERMOVEMENT_TURN</k>*\
>>>>> $~~~~$*if no bump (land tile permissions or NPC): DoStep(STEP_WALK / STEP_BIKE / STEP_ICE)*\
>>>>> $~~~~~~~~$*if not leaving water: <k>r1_player_movement = PLAYERMOVEMENT_FINISH</k>*\
>>>>> $~~~~~~~~$*if leaving water: wPlayerState <= PLAYER_NORMAL, reload music and sprites, and <k>r1_player_movement = PLAYERMOVEMENT_EXIT_WATER</k>*\
>>>>> $~~~~$*if ledge tile: play sfx, DoStep(STEP_LEDGE), and <k>r1_player_movement = PLAYERMOVEMENT_JUMP</k>*\
>>>>> $~~~~$*if carpet warp tile matching wWalkingDirection: wWalkingIntoEdgeWarp <= TRUE*\
>>>>> $~~~~~~~~$*if directions at wWalkingDirection and wPlayerDirection are the same: load warp data, wPlayerTurningDirection <= 0, wMovementAnimation <= movement_step_sleep, and <k>r1_player_movement = PLAYERMOVEMENT_WARP</k>*\
>>>>> $~~~~$wWalkingDirection == STANDING: wPlayerTurningDirection <= 0, wMovementAnimation <= movement_step_sleep\
>>>>> $~~~~$wWalkingDirection != STANDING: if wWalkingIntoEdgeWarp == FALSE, *play bump sound*, wPlayerTurningDirection <= 0, wMovementAnimation <= movement_step_bump

>>>>> wPlayerState == PLAYER_SURF:\
>>>>> $~~~~$*if on ice tile and wPlayerTurningDirection != 0: wCurInput <= current direction button*\
>>>>> $~~~~$*update wWalkingDirection, wFacingDirection: wWalkingX, wWalkingY, wWalkingTile, based on wCurInput direction*\
>>>>> $~~~~$*if whirlpool tile: <k>r1_player_movement = PLAYERMOVEMENT_FORCE_TURN</k>*\
>>>>> $~~~~$*if waterfall tile: wWalkingDirection <= direction, DoStep(STEP_WALK), <k>r1_player_movement = PLAYERMOVEMENT_CONTINUE</k>*\
>>>>> $~~~~$*if door/staircase/cave warp tile (non ladder/carpet): wWalkingDirection <= DOWN, DoStep(STEP_WALK), <k>r1_player_movement = PLAYERMOVEMENT_CONTINUE</k>*\
>>>>> $~~~~$*if directions at wWalkingDirection and wPlayerDirection are not the same (turning): DoStep(STEP_TURN), <k>r1_player_movement = PLAYERMOVEMENT_TURN</k>*\
>>>>> $~~~~$*if no bump (water tile permissions or NPC): DoStep(STEP_WALK / STEP_BIKE / STEP_ICE)*\
>>>>> $~~~~~~~~$*if not leaving water: <k>r1_player_movement = PLAYERMOVEMENT_FINISH</k>*\
>>>>> $~~~~~~~~$*if leaving water: wPlayerState <= PLAYER_NORMAL, reload music and sprites, and <k>r1_player_movement = PLAYERMOVEMENT_EXIT_WATER</k>*\
>>>>> $~~~~$wWalkingDirection == STANDING: wPlayerTurningDirection <= 0, wMovementAnimation <= movement_step_sleep\
>>>>> $~~~~$wWalkingDirection != STANDING: if wWalkingIntoEdgeWarp == FALSE, *play bump sound*, wPlayerTurningDirection <= 0, wMovementAnimation <= movement_step_bump

>>>>> wPlayerNextMovement <= wMovementAnimation\
>>>>> <k>r1_player_movement = PLAYERMOVEMENT_NORMAL</k>

>>>> r1_player_movement == PLAYERMOVEMENT_NORMAL or r1_player_movement == PLAYERMOVEMENT_JUMP or r1_player_movement == PLAYERMOVEMENT_FINISH: <k>r2_player_event = 0</k>\
>>>> r1_player_movement == PLAYERMOVEMENT_WARP: <k>r2_player_event = PLAYEREVENT_WARP</k>\
>>>> r1_player_movement == PLAYERMOVEMENT_TURN: <k>r2_player_event = PLAYEREVENT_JOYCHANGEFACING</k>\
>>>> r1_player_movement == PLAYERMOVEMENT_FORCE_TURN: CallScript(Script_ForcedMovement), <k>r2_player_event = PLAYEREVENT_MAPSCRIPT</k> <c>CallScript returns PLAYEREVENT_MAPSCRIPT always</c>\
>>>> r1_player_movement == PLAYERMOVEMENT_CONTINUE or r1_player_movement == PLAYERMOVEMENT_EXIT_WATER: <k>r2_player_event = -1</k>

>>> r2_player_event == -1: <k>r3_player_event = 0</k> <c>in this case, apart from r2_player_event = -1, PlayerMovement has also returned nc</c>\
>>> r2_player_event == 0: <c>in this case, apart from r2_player_event = 0, PlayerMovement has also returned nc</c>\
>>> $~~~~$*if on ice tile and wPlayerTurningDirection != 0*: <j>[j2]</j>\
>>> $~~~~$if A_BUTTON in hJoyPressed:\
>>> $~~~~~~~~$*if facing to object event*: CallScript(<object's script>) and <k>r3_player_event = PLAYEREVENT_MAPSCRIPT</k> / <k>r3_player_event = PLAYEREVENT_ITEMBALL</k> / *load trainer data* and <k>r3_player_event = PLAYEREVENT_TALKTOTRAINER</k> <c>includes rock and boulder objects (PLAYEREVENT_MAPSCRIPT case)</c>\
>>> $~~~~~~~~$*if bg event (signpost) in current coords and facing, and event's flag set if any*: CallScript(<event's script> / HiddenItemScript) and <k>r3_player_event = PLAYEREVENT_MAPSCRIPT</k>\
>>> $~~~~~~~~$*if facing to collision event (use cut, whirlpool, waterfall, headbutt, surf)*: *call TryXOW, which returns with CallScript(AskXOW / CantXOW) and thus <k>r3_player_event = PLAYEREVENT_MAPSCRIPT</k>*\
>>> $~~~~$hJoyPressed[SELECT_F] == TRUE:\
>>> $~~~~~~~~$CallScript(SelectMenuScript) and <k>r3_player_event = PLAYEREVENT_MAPSCRIPT</k>\
>>> $~~~~$hJoyPressed[START_F] == TRUE:\
>>> $~~~~~~~~$CallScript(StartMenuScript) and <k>r3_player_event = PLAYEREVENT_MAPSCRIPT</k>\
>>> <k>r3_player_event = r2_player_event</k> <c>in these instances is where PlayerMovement returned carry, so OWPlayerInput returns early</c>

>>> r3_player_event == 0: <j>[j2]</j>

>> <j>**[j1]**</j>\
>> wScriptMode <= SCRIPT_READ\
>> wScriptRunning <= *loaded script from whatever jumped straight to [j1] OR r3_player_event*

>>> <f>DoPlayerEvent (wScriptRunning == TRUE and wScriptRunning != PLAYEREVENT_MAPSCRIPT):</f> <c>if there is a non-PLAYEREVENT_MAPSCRIPT script requested during this loop iteration, DoPlayerEvent pushes it to make it be executed by ScriptEvents. So the code up to [j2] below here **is actually executed by ScriptEvents and *NOT* right now**.</c>\
>>> <c>All scripts below finish with the *end* script unless otherwise stated (e.g. by the *endall* script)</c>

>>> wScriptRunning == PLAYEREVENT_SEENBYTRAINER:\
>>> $~~~~$SeenByTrainerScript + StartBattleWithMapTrainerScript

>>> wScriptRunning == PLAYEREVENT_TALKTOTRAINER:\
>>> $~~~~$TalkToTrainerScript + StartBattleWithMapTrainerScript

>>> wScriptRunning == PLAYEREVENT_ITEMBALL:\
>>> $~~~~$FindItemInBallScript

>>> wScriptRunning == PLAYEREVENT_CONNECTION:\
>>> $~~~~$hMapEntryMethod <= MAPSETUP_CONNECTION\
>>> $~~~~$wMapStatus <= MAPSTATUS_ENTER\
>>> $~~~~$wScriptFlags[SCRIPT_RUNNING] = FALSE

>>> wScriptRunning == PLAYEREVENT_WARP:\
>>> $~~~~$*play warp sound*\
>>> $~~~~$hMapEntryMethod <= MAPSETUP_DOOR\
>>> $~~~~$wMapStatus <= MAPSTATUS_ENTER\
>>> $~~~~$wScriptFlags[SCRIPT_RUNNING] = FALSE <c>this write is exactly what the 'end' script also does</c>

>>> wScriptRunning == PLAYEREVENT_FALL:\
>>> $~~~~$hMapEntryMethod <= MAPSETUP_FALL\
>>> $~~~~$wMapStatus <= MAPSTATUS_ENTER\
>>> $~~~~$wScriptFlags[SCRIPT_RUNNING] = FALSE\
>>> $~~~~$*play fall sound 1*\
>>> $~~~~$*apply fall movement*\
>>> $~~~~$*play fall sound 2*

>>> wScriptRunning == PLAYEREVENT_WHITEOUT:\
>>> $~~~~$OverworldWhiteoutScript + Script_Whiteout <c>ends with hMapEntryMethod <= MAPSETUP_WARP + wMapStatus <= MAPSTATUS_ENTER + *endall*</c>

>>> wScriptRunning == PLAYEREVENT_HATCH:\
>>> $~~~~$OverworldHatchEgg

>>> wScriptRunning == PLAYEREVENT_JOYCHANGEFACING:\
>>> $~~~~$wScriptDelay <= 3\
>>> $~~~~$wScriptMode <= SCRIPT_WAIT\
>>> $~~~~$wScriptFlags[SCRIPT_RUNNING] = FALSE\
>>> $~~~~$wScriptFlags2[4] == TRUE <c>enable wild encounters</c>

>> <j>**[j2]**</j>\
>> wScriptFlags2 <= 0

>> <f>ScriptEvents:</f> <c>executes scripts requested this loop by CallScript (PLAYEREVENT_MAPSCRIPT)</c>

>> wScriptFlags[SCRIPT_RUNNING] = TRUE\
>> while wScriptFlags[SCRIPT_RUNNING] == TRUE: <c>breaks after *end* or similar script command</c>

>> $~~~~$wScriptMode == SCRIPT_OFF:\
>> $~~~~~~~~$wScriptFlags[SCRIPT_RUNNING] = FALSE

>> $~~~~$wScriptMode == SCRIPT_READ:\
>> $~~~~~~~~$**(...)**

>> $~~~~$wScriptMode == SCRIPT_WAIT_MOVEMENT:\
>> $~~~~~~~~$**(...)**

>> $~~~~$wScriptMode == SCRIPT_WAIT:\
>> $~~~~~~~~$**(...)**

> wMapStatus != MAPSTATUS_HANDLE: <j>[j3]</j> <c>jump if any script during this iteration changed wMapStatus (some warp ocurred)</c>

> <f>**HandleMapObjects**:</f>

>> **HandleNPCStep** <c>**Includes player object!** At the beginning of each object, clears wPlayerStepVectorX, wPlayerStepVectorY, and wPlayerStepFlags, and sets wPlayerStepDirection to STANDING. HandleObjectStep is called for each visible object. This calls HandleStepType, which processes StepTypesJumptable by STEP_TYPE_. These functions manipulate wPlayerStepFlags among other things.</c>

>> <f>_HandlePlayerStep (wPlayerStepFlags != 0):</f>

>>> wPlayerStepFlags(PLAYERSTEP_START_F) == TRUE:\
>>> $~~~~$wHandlePlayerStep <= 4\
>>> $~~~~$*Scroll map in the direction at wPlayerStepDirection*\
>>> $~~~~$wHandlePlayerStep <= wHandlePlayerStep - 1
>>> $~~~~$wPlayerBGMapOffsetX <= wPlayerBGMapOffsetX - wPlayerStepVectorX\
>>> $~~~~$wPlayerBGMapOffsetY <= wPlayerBGMapOffsetY - wPlayerStepVectorY\
>>> else wPlayerStepFlags(PLAYERSTEP_STOP_F) == TRUE:\
>>> $~~~~$*Increase or decrease wYCoord or wXCoord according to wPlayerStepDirection*\
>>> $~~~~$wHandlePlayerStep <= wHandlePlayerStep - 1\
>>> $~~~~$wHandlePlayerStep == 1: BufferScreen\
>>> $~~~~$wHandlePlayerStep == 0: GetMovementPermissions <c>Update *wPlayerTile*, *wTilePermissions*, *wTileDown*, *wTileUp*, *wTileLeft*, and/or *wTileRight*</c>\
>>> $~~~~$wPlayerBGMapOffsetX <= wPlayerBGMapOffsetX - wPlayerStepVectorX\
>>> $~~~~$wPlayerBGMapOffsetY <= wPlayerBGMapOffsetY - wPlayerStepVectorY\
>>> else wPlayerStepFlags(PLAYERSTEP_CONTINUE_F) == TRUE: <c>same as PLAYERSTEP_STOP_F case except don't update *wYCoord* or *wXCoord*</c>\
>>> $~~~~$wHandlePlayerStep <= wHandlePlayerStep - 1\
>>> $~~~~$wHandlePlayerStep == 1: BufferScreen\
>>> $~~~~$wHandlePlayerStep == 0: GetMovementPermissions <c>Update wPlayerTile, wTilePermissions, wTileDown, wTileUp, wTileLeft, and/or wTileRight</c>\
>>> $~~~~$wPlayerBGMapOffsetX <= wPlayerBGMapOffsetX - wPlayerStepVectorX\
>>> $~~~~$wPlayerBGMapOffsetY <= wPlayerBGMapOffsetY - wPlayerStepVectorY

>> **CheckObjectEnteringVisibleRange** (wPlayerStepFlags[PLAYERSTEP_STOP_F] == TRUE)

> DelayFrames(hOverworldDelay)

> <f>**HandleMapBackground**</f> <c>UpdateActiveSprites + ScrollScreen</c>

> <f>CheckPlayerState:</f>\
> wPlayerStepFlags[PLAYERSTEP_CONTINUE_F] == FALSE:\
> $~~~~$wMapEventStatus <= MAPEVENTS_ON\
> wPlayerStepFlags[PLAYERSTEP_CONTINUE_F] == TRUE and (wPlayerStepFlags[PLAYERSTEP_STOP_F] == FALSE or wPlayerStepFlags[PLAYERSTEP_MIDAIR_F] == TRUE):\
> $~~~~$wMapEventStatus <= MAPEVENTS_OFF\
> else:\
> $~~~~$wScriptFlags2 <= \$ff\
> $~~~~$wMapEventStatus <= MAPEVENTS_ON

> <j>**[j3]**</j>

---
<c>***End of overworld loop. The remainder are intermediate functions***</c>

---

<c>Every script executed by ScriptEvents finishes with the some form of the **end** command. It returns (by updating wScriptPos and wScriptBank) to a parent script if any, and otherwise:</c>\
wScriptRunning <= FALSE\
wScriptMode <= SCRIPT_OFF\
wScriptFlags[SCRIPT_RUNNING] = FALSE\
<c>The **endall** command is like *end*, but also finishes parent scripts regardless.</c>

---

<f>DoStep:</f>

wWalkingDirection == STANDING:\
$~~~~$wPlayerTurningDirection <= 0\
$~~~~$wMovementAnimation <= movement_step_sleep\
else:\
$~~~~$wMovementAnimation <= <step (type, direction)>\
$~~~~$wPlayerTurningDirection <= \<direction> | 1 << 7\
$~~~~$<c>then always returns PLAYERMOVEMENT_FINISH but often is overwritten by caller</c>

---

## Board behavior

### RAM addresses

- **hCurBoardEvent**: holds a *BOARDEVENT_* value.

- **wTurnData** ~ **wTurnDataEnd**: not preserved on save, and cleared at the beginning of BoardMenuScript (i.e. on turn begin). It's part of *wMapStatus* ~ *wMapStatusEnd*, so it's also cleared by *StartMap*. Includes:
  - **wDieRoll**
  - **wSpacesLeft**

- Addresses within *wCurMapData* ~ *wCurMapDataEnd*: preserved on save. Includes:
  - **wCurTurn**
  - **wCurSpace**
  - **wCurSpaceStruct**:
    - **wCurSpaceXCoord**
    - **wCurSpaceYCoord**
    - **wCurSpaceEffect**
    - **wCurSpaceNextSpace**.

- **wTempSpaceStruct**: shares memory region with string buffers from *wStringBuffer3* onwards. Temporary scope. Same structure as *wCurSpaceStruct*

### Workflow

1) ``OverworldLoop`` is called from ``GameMenu_WorldMap`` with either ``hMapEntryMethod`` = ``MAPSETUP_ENTERLEVEL`` or ``hMapEntryMethod`` = ``MAPSETUP_CONTINUE``.
2) ``StartMap`` resets ``wCurTurn`` and ``wCurSpace`` if ``MAPSETUP_ENTERLEVEL``. ``StartMap`` sets ``hCurBoardEvent`` to ``BOARDEVENT_DISPLAY_MENU``. ``wScriptFlags2`` is cleared. ``wMapStatus`` is set to ``MAPSTATUS_HANDLE`` causing ``HandleMap`` to be called.
3) ``MapEvents`` (from ``HandleMap``) calls ``PlayerEvents``. ``CheckBoardEvent`` queues ``BoardMenuScript`` which is executed by ``ScriptEvents``.
4) ``BoardMenuScript``.``Upkeep`` saves the game, clears ``wTurnData[]``, increases ``wCurTurn``, and loads current space to ``wCurSpaceStruct[]``.
    - If player exits, the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
5) Player rolls die and the animation plays. After the animation, ``wDisplaySecondarySprites``.``SECONDARYSPRITES_SPACES_LEFT_F`` is set and ``hCurBoardEvent`` is set to ``BOARDEVENT_HANDLE_BOARD``. At the end of this ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_ON`` (``wScriptFlags2`` is not touched so it remains cleared).
6) In the next ``HandleMap`` iteration, ``CheckBoardEvent`` from ``PlayerEvents`` jumps to ``.board`` and then to ``.no_space_effect`` due to ``wScriptFlags2[4]`` not being set.
7) Execution continues in ``PlayerEvents``; ``OWPlayerInput`` is eventually called, and thus ``DoPlayerMovement``. Here, ``StepTowardsNextSpace`` computes based on ``wCurSpaceNextSpace`` what direction key to write to ``wCurInput``, causing the player to begin a movement in that direction.
8) The player may need to turn to a different direction through the ``ChangeDirectionScript`` (when ``DoPlayerMovement`` returns with ``PLAYERMOVEMENT_TURN``). Otherwise or after that, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_OFF``,
9) When the step finishes (i.e. ``PLAYERSTEP_STOP_F`` becomes set) in some ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wScriptFlags2`` to $ff and ``wMapEventStatus`` to ``MAPEVENTS_ON``.
10) In the next ``HandleMap`` iteration, ``CheckBoardEvent.board`` is called with ``wScriptFlags2[4]`` set.
      - If player is not above a tile (``wPlayerTile``) with a space collision: ``wScriptFlags2[4]`` is reset. **Go back to 7**.
      - If player is above a tile, the corresponding space script is queued to be executed by ``ScriptEvents`` in the current ``HandleMap`` iteration. ``wScriptFlags2[4]`` is reset. **Continue to 11**.
11) The space script loads the value of ``wCurSpaceNextSpace`` into ``wCurSpace``, loads the new space data to ``wCurSpaceStruct[]``, and decreases ``wSpacesLeft``.
      - If the space is an End Space, a fading out animation plays and then the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
      - If ``wSpacesLeft`` is non-0, **go back to 6**.
12) The script code specific to the space type of the landed-on space is executed.
      - If player whites out in battle, ``Script_BattleWhiteout`` executes ``exitoverworld``. **Exit this workflow**.
13) The landed-on space is disabled by executing a block change that converts it into a Grey Space. ``hCurBoardEvent`` is set to ``BOARDEVENT_END_TURN``. ``CheckBoardEvent`` does nothing in this state. In the first subsequent ``HandleMap`` iteration where no other kind of event triggers causing ``PlayerEvents`` to return early, ``hCurBoardEvent`` is set to ``BOARDEVENT_DISPLAY_MENU``.
14) **Go back to 3**