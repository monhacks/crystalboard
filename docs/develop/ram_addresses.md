# RAM addresses

- **hCurBoardEvent**: holds a *BOARDEVENT_* value.

- **wTurnData** ~ **wTurnDataEnd**: turn-scoped, not preserved on save, and cleared at the beginning of BoardMenuScript (i.e. on turn begin). It's part of *wMapStatus* ~ *wMapStatusEnd*, so it's also cleared by *StartMap*. Includes:
  - **wDieRoll**
  - **wSpacesLeft**

- Addresses within *wCurMapData* ~ *wCurMapDataEnd*: level-scoped or turn-scoped, preserved on save. Initialized when entering a level if required (in StartMap), and updated accordingly throughout the level. Includes:
  - **wCurTurn**: initialized when entering a level (in StartMap)
  - **wCurSpace**: initialized when entering a level (in StartMap)
  - **wCurLevelCoins**: initialized when entering a level (in StartMap)
  - **wCurLevelExp**: initialized when entering a level (in StartMap)
  - **wCurSpaceStruct**:
    - **wCurSpaceXCoord**
    - **wCurSpaceYCoord**
    - **wCurSpaceEffect** for non-branch spaces, or **wCurSpaceBranchStructPtr** (two bytes) for branch spaces
    - **wCurSpaceNextSpace** for non-branch spaces
  - **wCurOverworldMiscPal**

- Addresses within *wPlayerData* ~ *wPlayerDataEnd*: game-scoped (change between levels or on level start/end, but now within), preserved on save. Includes:
  - **wUnlockedLevels**: flag array that tracks progression regarding which levels have been unlocked.
  - **wClearedLevelsStage\<N\>**: flag array that tracks progression regarding which levels have been cleared. Each level can have up to four stages (clearable endings).
  - **wUnlockedTechniques**: flag array that tracks progression regarding which techniques have been unlocked.
  - **wCurLevel**: initialized in LevelSelectionMenu (where it is also used), and stays static during the level.
  - **wDefaultLevelSelectionMenuLandmark**: used to know in which landmark to place the player when entering level selection menu.
  - **wLevelSelectionMenuEntryEventQueue**: which events have to be triggered the next time the player enters the level selection menu.
  - **wLastUnlockedLevelsCount**, **wLastUnlockedLevels**, **wLastClearedLevelStage**: temporary list of unlocked and cleared levels during post-level screen

- These addresses share memory region with string buffers from *wStringBuffer3* onwards. They are placed in memory in the following order.
  - **wTempSpaceStruct**: Temporary scope. Same structure as *wCurSpaceStruct*
  - **wTempSpaceBranchStruct**: Temporary scope. The structure is four bytes for next space for each direction (R/L/U/D; -1 if unavailable direction) followed by at least four bytes (depending on *NUM_TECHNIQUES*) for required techniques for each direction (R/L/U/D)
  - **wViewMapModeRange**, **wViewMapModeDisplacementY**, **wViewMapModeDisplacementX**: Temporary scope during a Vew Map mode session.
  - **wBeforeViewMapYCoord**, **wBeforeViewMapXCoord**, **wBeforeViewMapMapGroup**, **wBeforeViewMapMapNumber**, **wBeforeViewMapDirection**: Temporary scope during a Vew Map mode session. Used to preserve player state before entering View Map mode.

- Additional addresses for View Map mode, that share memory region with *wCurBattleMon* and *wCurMoveNum*, which are not used outside of battle:
  - **wPlayerMockYCoord**, **wPlayerMockXCoord**: Used to handle the player mock sprite through map connections during View Map mode.

- Addresses for talker events:
  - *wSeenTrainer** addresses have been repurposed as **wSeenTrainerOrTalker***
  - **wSeenTrainerOrTalkerIsTalker**: added right before *wSeenTrainerOrTalker**.
  - **wTempTalker** ~ **wTempTalkerEnd**: allocated to the same address space as *wTempTrainer*. Same scope as *wTempTrainer*, but for talker events.

- Address spaces for backing up the map state (disabled spaces and map objects). Located outside of WRAM banks 0 and 1.
  - **wDisabledSpacesBackups**: preserved on save to **sDisabledSpacesBackups**.
  - **wMapObjectsBackups**: preserved on save to **sMapObjectsBackups**.

- **wLevelSelectionMenu\*** addresses, union under the *"Miscellaneous WRAM 1"* section. Temporary scope during level selection menu (not the case for *wLevelSelectionMenuEntryEventQueue*, which is in *wPlayerData* instead, as mentioned above).

- Other WRAM 0 addresses (not preserved on save):
  - **wText2bpp**
  - **wWhichHUD**
  - **wExitOverworldReason**