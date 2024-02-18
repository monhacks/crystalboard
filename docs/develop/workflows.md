# Overworld workflow

1) ``OverworldLoop`` is called from ``GameMenu_World`` with either ``hMapEntryMethod`` = ``MAPSETUP_ENTERLEVEL`` or ``hMapEntryMethod`` = ``MAPSETUP_CONTINUE``.
2) ``StartMap`` resets ``wCurTurn`` and ``wCurSpace`` if ``MAPSETUP_ENTERLEVEL``. ``StartMap`` sets ``hCurBoardEvent`` to ``BOARDEVENT_DISPLAY_MENU``. ``wEnabledPlayerEvents`` is cleared. ``wMapStatus`` is set to ``MAPSTATUS_HANDLE`` causing ``HandleMap`` to be called.
3) ``MapEvents`` (from ``HandleMap``) calls ``PlayerEvents``. ``CheckBoardEvent`` queues ``BoardMenuScript`` which is executed by ``ScriptEvents``.
4) ``BoardMenuScript.Upkeep`` saves the game, clears ``wTurnData[]``, increases ``wCurTurn``, and loads current space to ``wCurSpaceStruct[]``.
    - If player exits, the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
5) Player rolls die and the animation plays. After the animation, ``wDisplaySecondarySprites.SECONDARYSPRITES_SPACES_LEFT_F`` is set and ``hCurBoardEvent`` is set to ``BOARDEVENT_HANDLE_BOARD``. At the end of this ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_ON`` (``wEnabledPlayerEvents`` is not touched so it remains cleared).
6) In the next ``HandleMap`` iteration, ``CheckBoardEvent`` from ``PlayerEvents`` jumps to ``.board`` and then to ``.no_space_effect`` due to ``wEnabledPlayerEvents[4]`` not being set.
7) Execution continues in ``PlayerEvents``; ``OWPlayerInput`` is eventually called, and thus ``DoPlayerMovement``. Here, ``StepTowardsNextSpace`` computes based on ``wCurSpaceNextSpace`` what direction key to write to ``wCurInput``, causing the player to begin a movement in that direction.
8) The player may need to turn to a different direction through the ``ChangeDirectionScript`` (when ``DoPlayerMovement`` returns with ``PLAYERMOVEMENT_TURN``). Otherwise or after that, ``CheckPlayerState`` sets ``wMapEventStatus`` to ``MAPEVENTS_OFF``,
9) When the step finishes (i.e. ``PLAYERSTEP_STOP_F`` becomes set) in some ``HandleMap`` iteration, ``CheckPlayerState`` sets ``wEnabledPlayerEvents`` to $ff and ``wMapEventStatus`` to ``MAPEVENTS_ON``.
10) In the next ``HandleMap`` iteration, ``CheckBoardEvent.board`` is called with ``wEnabledPlayerEvents[4]`` set.
      - If ``wCurSpaceNextSpace`` matches ``NEXT_SPACE_IS_ANCHOR_POINT``: If player is at a tile with an anchor event, ``wCurSpaceNextSpace`` is updated with the next space byte of salid anchor event. ``wEnabledPlayerEvents[4]`` is reset. **Go back to 7**.
      - If player is not above a tile (``wPlayerTileCollision``) with a space collision: ``wEnabledPlayerEvents[4]`` is reset. **Go back to 7**.
      - If player is above a tile, the corresponding space script is queued to be executed by ``ScriptEvents`` in the current ``HandleMap`` iteration. ``wEnabledPlayerEvents[4]`` is reset. **Continue to 11**.
11) The space script loads the value of ``wCurSpaceNextSpace`` into ``wCurSpace``, and loads the new space data to ``wCurSpaceStruct[]``. Unless the space is a Branch Space or a Union Space, ``wSpacesLeft`` is decreased.
      - If the space is a Branch Space, the branch data is loaded to ``wTempSpaceBranchStruct``. Then the player is prompted to choose a valid direction. ``wCurSpaceNextSpace`` is populated with the next space that corresponds to the chosen direction. **Go back to 6**.
      - If the space is an End Space, a fading out animation plays and then the ``exitoverworld`` script sets ``wMapStatus`` to ``MAPSTATUS_DONE``. This causes ``OverworldLoop`` to return back to the game menu. **Exit this workflow**.
12) If ``wSpacesLeft`` is non-0, **go back to 6**.
13) The script code specific to the space type of the landed-on space is executed.
      - If player whites out in battle, ``Script_BattleWhiteout`` executes ``exitoverworld``. **Exit this workflow**.
14) The landed-on space is disabled by executing a block change that converts it into a Grey Space. ``hCurBoardEvent`` is set to ``BOARDEVENT_END_TURN``. ``CheckBoardEvent`` does nothing in this state. In the first subsequent ``HandleMap`` iteration where no other kind of event triggers causing ``PlayerEvents`` to return early, ``hCurBoardEvent`` is set to ``BOARDEVENT_DISPLAY_MENU``.
15) **Go back to 3**

# View Map mode workflow

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