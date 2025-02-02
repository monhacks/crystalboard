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
> wOverworldDelay <= 2 <c>2 is *MaxOverworldDelay*</c>\
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

> DelayFrames(wOverworldDelay)

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
