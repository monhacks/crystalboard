SECTION "Stack", WRAM0

wStackBottom::
	ds $100 - 1
wStackTop::
	ds 1


SECTION "Audio RAM", WRAM0

; nonzero if playing
wMusicPlaying:: db

wAudio::
; wChannel1 - wChannel8
for n, 1, NUM_CHANNELS + 1
wChannel{d:n}:: channel_struct wChannel{d:n}
endr

	ds 1

wCurTrackDuty:: db
wCurTrackVolumeEnvelope:: db
wCurTrackFrequency:: dw
wUnusedBCDNumber:: db ; BCD value, dummied out
wCurNoteDuration:: db ; used in MusicE0 and LoadNote

wCurMusicByte:: db
wCurChannel:: db
wVolume::
; corresponds to rNR50
; Channel control / ON-OFF / Volume (R/W)
;   bit 7 - Vin->SO2 ON/OFF
;   bit 6-4 - SO2 output level (volume) (# 0-7)
;   bit 3 - Vin->SO1 ON/OFF
;   bit 2-0 - SO1 output level (volume) (# 0-7)
	db
wSoundOutput::
; corresponds to rNR51
; bit 4-7: ch1-4 so2 on/off
; bit 0-3: ch1-4 so1 on/off
	db
wPitchSweep::
; corresponds to rNR10
; bit 7:   unused
; bit 4-6: sweep time
; bit 3:   sweep direction
; but 0-2: sweep shift
	db

wMusicID:: dw
wMusicBank:: db
wNoiseSampleAddress:: dw
wNoiseSampleDelay:: db
	ds 1
wMusicNoiseSampleSet:: db
wSFXNoiseSampleSet:: db

wLowHealthAlarm::
; bit 7: on/off
; bit 4: pitch
; bit 0-3: counter
	db

wMusicFade::
; fades volume over x frames
; bit 7: fade in/out
; bit 0-5: number of frames for each volume level
; $00 = none (default)
	db
wMusicFadeCount:: db
wMusicFadeID:: dw

	ds 5

wCryPitch:: dw
wCryLength:: dw

wLastVolume:: db
wUnusedMusicF9Flag:: db

wSFXPriority::
; if nonzero, turn off music when playing sfx
	db

	ds 1

wChannel1JumpCondition:: db
wChannel2JumpCondition:: db
wChannel3JumpCondition:: db
wChannel4JumpCondition:: db

wStereoPanningMask:: db

wCryTracks::
; plays only in left or right track depending on what side the monster is on
; both tracks active outside of battle
	db

wSFXDuration:: db
wCurSFX::
; id of sfx currently playing
	db

wAudioEnd::

wMapMusic:: db

wDontPlayMapMusicOnReload:: db


SECTION "WRAM", WRAM0

wLZAddress:: dw
wLZBank::    db

wBoxAlignment:: db

wInputType::        db
wAutoInputAddress:: dw
wAutoInputBank::    db
wAutoInputLength::  db

wDebugFlags:: db
wGameLogicPaused:: db
wSpriteUpdatesEnabled:: db

wDisplaySecondarySprites:: db

wMapTimeOfDay:: db

wPrinterConnectionOpen:: db
wPrinterOpcode:: db
wPrevDexEntry:: db
wDisableTextAcceleration:: db

wLinkMode::
; a LINK_* value for the link type
	db

wPlayerNextMovement:: db
wPlayerMovement:: db

wMovementObject::
	db
wMovementDataBank:: db
wMovementDataAddress:: dw
wIndexedMovement2Pointer:: dw

wContinueReadingMovement:: db

UNION
wObjectPriorities:: ds NUM_OBJECT_STRUCTS

NEXTU
wMovementPointer:: dw
wTempObjectCopyMapObjectIndex:: db
wTempObjectCopySprite:: db
wTempObjectCopySpriteVTile:: db
wTempObjectCopyPalette:: db
wTempObjectCopyMovement:: db
wTempObjectCopyRange:: db
wTempObjectCopyX:: db
wTempObjectCopyY:: db
wTempObjectCopyRadius:: db
ENDU

wTileDown::  db
wTileUp::    db
wTileLeft::  db
wTileRight:: db
	assert wTileUp - wTileDown == UP
	assert wTileLeft - wTileDown == LEFT
	assert wTileRight - wTileDown == RIGHT

wTilePermissions::
; set if tile behavior prevents
; you from walking in that direction
; bit 3: down
; bit 2: up
; bit 1: left
; bit 0: right
	db


SECTION "wSpriteAnims", WRAM0

wSpriteAnimData::

wSpriteAnimDict::
; wSpriteAnimDict pairs keys with values
; keys: SPRITE_ANIM_DICT_* indexes (taken from SpriteAnimObjects)
; values: vTiles0 offsets
	ds NUM_SPRITEANIMDICT_ENTRIES * 2

wSpriteAnimationStructs::
; wSpriteAnim1 - wSpriteAnim10
for n, 1, NUM_SPRITE_ANIM_STRUCTS + 1
; field  0:   index
; fields 1-3: loaded from SpriteAnimObjects
wSpriteAnim{d:n}:: sprite_anim_struct wSpriteAnim{d:n}
endr
wSpriteAnimationStructsEnd::

wSpriteAnimCount:: db
wCurSpriteOAMAddr:: db

wCutTreeOAMAddr::
wCurIcon:: db

wCurIconTile:: db
UNION
wSpriteAnimID::
wCurSpriteOAMFlags:: db
NEXTU
wSpriteAnimAddrBackup:: dw
ENDU
wCurAnimVTile:: db
wCurAnimXCoord:: db
wCurAnimYCoord:: db
wCurAnimXOffset:: db
wCurAnimYOffset:: db
wGlobalAnimYOffset:: db
wGlobalAnimXOffset:: db

wSpriteAnimDataEnd::


SECTION "Sprites", WRAM0

wShadowOAM::
; wShadowOAMSprite00 - wShadowOAMSprite39
for n, NUM_SPRITE_OAM_STRUCTS
wShadowOAMSprite{02d:n}:: sprite_oam_struct wShadowOAMSprite{02d:n}
endr
wShadowOAMEnd::


SECTION "Tilemap", WRAM0

wTilemap::
; 20x18 grid of 8x8 tiles
	ds SCREEN_WIDTH * SCREEN_HEIGHT
wTilemapEnd::


; This union spans 480 bytes.
SECTION UNION "Miscellaneous", WRAM0

; surrounding tiles
; This buffer determines the size for the rest of the union;
; it uses exactly 480 bytes.
wSurroundingTiles:: ds SURROUNDING_WIDTH * SURROUNDING_HEIGHT


SECTION UNION "Miscellaneous", WRAM0

; box save buffer
; SaveBoxAddress uses this buffer in three steps because it
; needs more space than the buffer can hold.
wBoxPartialData:: ds 480
wBoxPartialDataEnd::


SECTION UNION "Miscellaneous", WRAM0

; battle data
wBattle::
wEnemyMoveStruct::  move_struct wEnemyMoveStruct
wPlayerMoveStruct:: move_struct wPlayerMoveStruct

wEnemyMonNickname::  ds MON_NAME_LENGTH
wBattleMonNickname:: ds MON_NAME_LENGTH

wBattleMon:: battle_struct wBattleMon

wWildMon:: db

wEnemyTrainerItem1:: db
wEnemyTrainerItem2:: db
wEnemyTrainerBaseReward:: db
wEnemyTrainerAIFlags:: ds 3
wOTClassName:: ds TRAINER_CLASS_NAME_LENGTH

wCurOTMon:: db

wBattleParticipantsNotFainted::
; Bit array.  Bits 0 - 5 correspond to party members 1 - 6.
; Bit set if the mon appears in battle.
; Bit cleared if the mon faints.
; Backed up if the enemy switches.
; All bits cleared if the enemy faints.
	db

wTypeModifier::
; >10: super-effective
;  10: normal
; <10: not very effective
; bit 7: stab
	db

wCriticalHit::
; 0 if not critical
; 1 for a critical hit
; 2 for a OHKO
	db

wAttackMissed::
; nonzero for a miss
	db

wPlayerSubStatus1:: db
wPlayerSubStatus2:: db
wPlayerSubStatus3:: db
wPlayerSubStatus4:: db
wPlayerSubStatus5:: db

wEnemySubStatus1:: db
wEnemySubStatus2:: db
wEnemySubStatus3:: db
wEnemySubStatus4:: db
wEnemySubStatus5:: db

wPlayerRolloutCount:: db
wPlayerConfuseCount:: db
wPlayerToxicCount:: db
wPlayerDisableCount:: db
wPlayerEncoreCount:: db
wPlayerPerishCount:: db
wPlayerFuryCutterCount:: db
wPlayerProtectCount:: db

wEnemyRolloutCount:: db
wEnemyConfuseCount:: db
wEnemyToxicCount:: db
wEnemyDisableCount:: db
wEnemyEncoreCount:: db
wEnemyPerishCount:: db
wEnemyFuryCutterCount:: db
wEnemyProtectCount:: db

wPlayerDamageTaken:: dw
wEnemyDamageTaken::  dw

wBattleReward:: ds 3

wBattleAnimParam:: db

wBattleScriptBuffer:: ds 40

wBattleScriptBufferAddress:: dw

wTurnEnded:: db

wPlayerStats::
wPlayerAttack::  dw
wPlayerDefense:: dw
wPlayerSpeed::   dw
wPlayerSpAtk::   dw
wPlayerSpDef::   dw

wEnemyStats::
wEnemyAttack::  dw
wEnemyDefense:: dw
wEnemySpeed::   dw
wEnemySpAtk::   dw
wEnemySpDef::   dw

wPlayerStatLevels::
wPlayerAtkLevel::  db
wPlayerDefLevel::  db
wPlayerSpdLevel::  db
wPlayerSAtkLevel:: db
wPlayerSDefLevel:: db
wPlayerAccLevel::  db
wPlayerEvaLevel::  db
	ds 1 ; NUM_LEVEL_STATS

wEnemyStatLevels::
wEnemyAtkLevel::  db
wEnemyDefLevel::  db
wEnemySpdLevel::  db
wEnemySAtkLevel:: db
wEnemySDefLevel:: db
wEnemyAccLevel::  db
wEnemyEvaLevel::  db
	ds 1 ; NUM_LEVEL_STATS

wEnemyTurnsTaken::  db
wPlayerTurnsTaken:: db

wPlayerSubstituteHP:: db
wEnemySubstituteHP::  db

wUnusedPlayerLockedMove:: db

wCurPlayerMove:: db
wCurEnemyMove::  db

wLinkBattleRNCount::
; how far through the prng stream
	db

wEnemyItemState:: db

wCurEnemyMoveNum:: db

wEnemyHPAtTimeOfPlayerSwitch:: dw
wPayDayCoins:: ds 3

wSafariMonAngerCount:: db ; unreferenced
wSafariMonEating:: db

wEnemyBackupDVs:: dw ; used when enemy is transformed
wAlreadyDisobeyed:: db

wDisabledMove:: db
wEnemyDisabledMove:: db
wWhichMonFaintedFirst:: db

; exists so you can't counter on switch
wLastPlayerCounterMove:: db
wLastEnemyCounterMove:: db

wEnemyMinimized:: db

wAlreadyFailed:: db

wBattleParticipantsIncludingFainted:: db
wBattleLowHealthAlarm:: db
wPlayerMinimized:: db
wPlayerScreens::
; bit
; 0 spikes
; 1
; 2 safeguard
; 3 light screen
; 4 reflect
; 5-7 unused
	db

wEnemyScreens::
; see wPlayerScreens
	db

wPlayerSafeguardCount:: db
wPlayerLightScreenCount:: db
wPlayerReflectCount:: db

wEnemySafeguardCount:: db
wEnemyLightScreenCount:: db
wEnemyReflectCount:: db

wBattleWeather::
; 00 normal
; 01 rain
; 02 sun
; 03 sandstorm
; 04 rain stopped
; 05 sunliight faded
; 06 sandstorm subsided
	db

wWeatherCount::
; # turns remaining
	db

wLoweredStat:: db
wEffectFailed:: db
wFailedMessage:: db
wEnemyGoesFirst:: db

wPlayerIsSwitching:: db
wEnemyIsSwitching::  db

wPlayerUsedMoves::
; add a move that has been used once by the player
; added in order of use
	ds NUM_MOVES

wEnemyAISwitchScore:: db
wEnemySwitchMonParam:: db
wEnemySwitchMonIndex:: db
wTempLevel:: db
wLastPlayerMon:: db
wLastPlayerMove:: db
wLastEnemyMove:: db

wPlayerFutureSightCount:: db
wEnemyFutureSightCount:: db

wGivingExperienceToExpShareHolders:: db

wBackupEnemyMonBaseStats:: ds NUM_EXP_STATS
wBackupEnemyMonCatchRate:: db
wBackupEnemyMonBaseExp:: db

wPlayerFutureSightDamage:: dw
wEnemyFutureSightDamage:: dw
wPlayerRageCounter:: db
wEnemyRageCounter:: db

wBeatUpHitAtLeastOnce:: db

wPlayerTrappingMove:: db
wEnemyTrappingMove:: db
wPlayerWrapCount:: db
wEnemyWrapCount:: db
wPlayerCharging:: db
wEnemyCharging:: db

wBattleEnded:: db

wWildMonMoves:: ds NUM_MOVES
wWildMonPP:: ds NUM_MOVES

wAmuletCoin:: db

wSomeoneIsRampaging:: db

wPlayerJustGotFrozen:: db
wEnemyJustGotFrozen:: db
wBattleEnd::


SECTION UNION "Miscellaneous", WRAM0

; link patch lists
wPlayerPatchLists:: ds SERIAL_PATCH_LIST_LENGTH
wOTPatchLists:: ds SERIAL_PATCH_LIST_LENGTH


SECTION UNION "Miscellaneous", WRAM0

; This union spans 200 bytes.
UNION
; timeset temp storage
wTimeSetBuffer::
	ds 20
wInitHourBuffer:: db
	ds 9
wInitMinuteBuffer:: db
	ds 19
wTimeSetBufferEnd::

NEXTU
; hall of fame temp struct
wHallOfFameTemp:: hall_of_fame wHallOfFameTemp

NEXTU
; debug mon color picker
wDebugMiddleColors::
wDebugLightColor:: ds 2
wDebugDarkColor::  ds 2
wDebugRedChannel::   db
wDebugGreenChannel:: db
wDebugBlueChannel::  db

NEXTU
; debug tileset color picker
wDebugPalette::
wDebugWhiteTileColor:: ds 2
wDebugLightTileColor:: ds 2
wDebugDarkTileColor::  ds 2
wDebugBlackTileColor:: ds 2

NEXTU
wUnknownGender::     db
wUnknownSpecies::    db
wUnknownReqGender::  db
wUnknownReqSpecies:: db
wUnknownMonSender::  ds NAME_LENGTH_JAPANESE - 1
wUnknownMon::        party_struct wUnknownMon
wUnknownMonOT::      ds NAME_LENGTH_JAPANESE - 1
wUnknownMonNick::    ds NAME_LENGTH_JAPANESE - 1
wUnknownMonMail::    mailmsg_jp wUnknownMonMail
ENDU

; This union spans 280 bytes.
UNION
; pokedex
wPokedexDataStart::
wPokedexOrder:: ds $100 ; >= NUM_POKEMON
wPokedexOrderEnd::
wDexListingScrollOffset:: db ; offset of the first displayed entry from the start
wDexListingCursor:: db ; Dex cursor
wDexListingEnd:: db ; Last mon to display
wDexListingHeight:: db ; number of entries displayed at once in the dex listing
wCurDexMode:: db ; Pokedex Mode
wDexSearchMonType1:: db ; first type to search
wDexSearchMonType2:: db ; second type to search
wDexSearchResultCount:: db
wDexArrowCursorPosIndex:: db
wDexArrowCursorDelayCounter:: db
wDexArrowCursorBlinkCounter:: db
wDexSearchSlowpokeFrame:: db
wUnlockedUnownMode:: db
wDexCurUnownIndex:: db
wDexUnownCount:: db
wDexConvertedMonType:: db ; mon type converted from dex search mon type
wDexListingScrollOffsetBackup:: db
wDexListingCursorBackup:: db
wBackupDexListingCursor:: db
wBackupDexListingPage:: db
wDexCurLocation:: db
wPokedexStatus:: db
wPokedexDataEnd::

NEXTU
; pokegear
wPokegearPhoneDisplayPosition:: db
wPokegearPhoneCursorPosition:: db
wPokegearPhoneScrollPosition:: db
wPokegearPhoneSelectedPerson:: db
wPokegearPhoneSubmenuCursor:: db
wPokegearMapCursorObjectPointer:: dw
wPokegearMapCursorLandmark:: db
wPokegearMapPlayerIconLandmark:: db
wPokegearRadioChannelBank:: db
wPokegearRadioChannelAddr:: dw
wPokegearRadioMusicPlaying:: db

NEXTU
; trade
wPlayerTrademon:: trademon wPlayerTrademon
wOTTrademon::     trademon wOTTrademon
wTradeAnimAddress:: dw
wLinkPlayer1Name:: ds NAME_LENGTH
wLinkPlayer2Name:: ds NAME_LENGTH
wLinkTradeSendmonSpecies:: db
wLinkTradeGetmonSpecies::  db

NEXTU
; naming screen
wNamingScreenDestinationPointer:: dw
wNamingScreenCurNameLength:: db
wNamingScreenMaxNameLength:: db
wNamingScreenType:: db
wNamingScreenCursorObjectPointer:: dw
wNamingScreenLastCharacter:: db
wNamingScreenStringEntryCoord:: dw

NEXTU
; slot machine
wSlots::
wReel1:: slot_reel wReel1
wReel2:: slot_reel wReel2
wReel3:: slot_reel wReel3
wReel1Stopped:: ds 3
wReel2Stopped:: ds 3
wReel3Stopped:: ds 3
wSlotBias:: db
wSlotBet:: db
wFirstTwoReelsMatching:: db
wFirstTwoReelsMatchingSevens:: db
wSlotMatched:: db
wCurReelStopped:: ds 3
wPayout:: dw
wCurReelXCoord:: db
wCurReelYCoord:: db
wSlotBuildingMatch:: db
wSlotsDataEnd::
wSlotsEnd::

NEXTU
; card flip
wDeck:: ds 4 * 6
wDeckEnd::
wCardFlipNumCardsPlayed:: db
wCardFlipFaceUpCard:: db
wDiscardPile:: ds 4 * 6
wDiscardPileEnd::

; beta poker game
wBetaPokerSGBPals:: dw
wBetaPokerSGBAttr:: db
wBetaPokerSGBCol:: db
wBetaPokerSGBRow:: db

NEXTU
; unused memory game
wMemoryGameCards:: ds 9 * 5
wMemoryGameCardsEnd::
wMemoryGameLastCardPicked:: db
wMemoryGameCard1:: db
wMemoryGameCard2:: db
wMemoryGameCard1Location:: db
wMemoryGameCard2Location:: db
wMemoryGameNumberTriesRemaining:: db
wMemoryGameLastMatches:: ds 5
wMemoryGameCounter:: db
wMemoryGameNumCardsMatched:: db

NEXTU
; unown puzzle
wPuzzlePieces:: ds 6 * 6
ENDU


SECTION "Overworld HUD", WRAM0

wOverworldHUDTiles:: ds SCREEN_WIDTH
wOverworldHUDTilesEnd::
	ds 4


SECTION UNION "Overworld Map", WRAM0

; overworld map blocks
wOverworldMapBlocks:: ds 1300
wOverworldMapBlocksEnd::


SECTION UNION "Overworld Map", WRAM0

; temporary list of unlocked levels during post-level screen
wNumTempUnlockedLevels:: db
wTempUnlockedLevels:: ds NUM_LEVELS


SECTION UNION "Overworld Map", WRAM0

; GB Printer data
wGameboyPrinterRAM::
wGameboyPrinter2bppSource:: ds 40 tiles
wGameboyPrinter2bppSourceEnd::
wUnusedGameboyPrinterSafeCancelFlag:: db
wPrinterRowIndex:: db

; Printer data
wPrinterData:: ds 4
wPrinterChecksum:: dw
wPrinterHandshake:: db
wPrinterStatusFlags::
; bit 7: set if error 1 (battery low)
; bit 6: set if error 4 (too hot or cold)
; bit 5: set if error 3 (paper jammed or empty)
; if this and the previous byte are both $ff: error 2 (connection error)
	db

wHandshakeFrameDelay:: db
wPrinterSerialFrameDelay:: db
wPrinterSendByteOffset:: dw
wPrinterSendByteCounter:: dw

; tilemap backup?
wPrinterTilemapBuffer:: ds SCREEN_HEIGHT * SCREEN_WIDTH
wPrinterStatus:: db
; High nibble is for margin before the image, low nibble is for after.
wPrinterMargins:: db
wPrinterExposureTime:: db
wGameboyPrinterRAMEnd::


SECTION UNION "Overworld Map", WRAM0

; bill's pc data
wBillsPCData::
wBillsPCPokemonList::
; (species, box number, list index) x30
	ds 3 * 30
	ds 720
wBillsPC_ScrollPosition:: db
wBillsPC_CursorPosition:: db
wBillsPC_NumMonsInBox:: db
wBillsPC_NumMonsOnScreen:: db
wBillsPC_LoadedBox:: db ; 0 if party, 1 - 14 if box, 15 if active box
wBillsPC_BackupScrollPosition:: db
wBillsPC_BackupCursorPosition:: db
wBillsPC_BackupLoadedBox:: db
wBillsPC_MonHasMail:: db
	ds 5
wBillsPCDataEnd::


SECTION UNION "Overworld Map", WRAM0

; Hall of Fame data
wHallOfFamePokemonList:: hall_of_fame wHallOfFamePokemonList


SECTION UNION "Overworld Map", WRAM0

; debug color picker
wDebugOriginalColors:: ds 256 * 4


SECTION UNION "Overworld Map", WRAM0

; raw link data
wLinkData:: ds 1300
wLinkDataEnd::


SECTION UNION "Overworld Map", WRAM0

; link data members
wLinkPlayerName:: ds NAME_LENGTH
wLinkPartyCount:: db
wLinkPartySpecies:: ds PARTY_LENGTH
wLinkPartyEnd:: db ; older code doesn't check PartyCount

UNION
; link player data
wLinkPlayerData::
; wLinkPlayerPartyMon1 - wLinkPlayerPartyMon6
for n, 1, PARTY_LENGTH + 1
wLinkPlayerPartyMon{d:n}:: party_struct wLinkPlayerPartyMon{d:n}
endr

wLinkPlayerPartyMonOTs::
; wLinkPlayerPartyMon1OT - wLinkPlayerPartyMon6OT
for n, 1, PARTY_LENGTH + 1
wLinkPlayerPartyMon{d:n}OT:: ds NAME_LENGTH
endr

wLinkPlayerPartyMonNicknames::
; wLinkPlayerPartyMon1Nickname - wLinkPlayerPartyMon6Nickname
for n, 1, PARTY_LENGTH + 1
wLinkPlayerPartyMon{d:n}Nickname:: ds MON_NAME_LENGTH
endr

NEXTU
; time capsule party data
wTimeCapsulePlayerData::
; wTimeCapsulePartyMon1 - wTimeCapsulePartyMon6
for n, 1, PARTY_LENGTH + 1
wTimeCapsulePartyMon{d:n}:: red_party_struct wTimeCapsulePartyMon{d:n}
endr

wTimeCapsulePartyMonOTs::
; wTimeCapsulePartyMon1OT - wTimeCapsulePartyMon6OT
for n, 1, PARTY_LENGTH + 1
wTimeCapsulePartyMon{d:n}OT:: ds NAME_LENGTH
endr

wTimeCapsulePartyMonNicknames::
; wTimeCapsulePartyMon1Nickname - wTimeCapsulePartyMon6Nickname
for n, 1, PARTY_LENGTH + 1
wTimeCapsulePartyMon{d:n}Nickname:: ds MON_NAME_LENGTH
endr

ENDU


SECTION UNION "Overworld Map", WRAM0

; link data prep
	ds 1000
wCurLinkOTPartyMonTypePointer:: dw

wLinkOTPartyMonTypes::
; wLinkOTPartyMon1Type - wLinkOTPartyMon6Type
for n, 1, PARTY_LENGTH + 1
wLinkOTPartyMon{d:n}Type:: dw
endr


SECTION UNION "Overworld Map", WRAM0

; link mail data
	ds 500
wLinkPlayerMail::
wLinkPlayerMailPreamble:: ds SERIAL_MAIL_PREAMBLE_LENGTH
wLinkPlayerMailMessages:: ds (MAIL_MSG_LENGTH + 1) * PARTY_LENGTH
wLinkPlayerMailMetadata:: ds (MAIL_STRUCT_LENGTH - (MAIL_MSG_LENGTH + 1)) * PARTY_LENGTH
wLinkPlayerMailPatchSet:: ds 100 + SERIAL_PATCH_PREAMBLE_LENGTH
wLinkPlayerMailEnd::
	ds 10
wLinkOTMail::
wLinkOTMailMessages:: ds (MAIL_MSG_LENGTH + 1) * PARTY_LENGTH
wLinkOTMailMetadata:: ds (MAIL_STRUCT_LENGTH - (MAIL_MSG_LENGTH + 1)) * PARTY_LENGTH
wLinkOTMailPatchSet:: ds 100 + SERIAL_PATCH_PREAMBLE_LENGTH
wLinkOTMailPadding:: ds SERIAL_MAIL_PREAMBLE_LENGTH
wLinkOTMailEnd::
	ds 10


SECTION UNION "Overworld Map", WRAM0

; received link mail data
	ds 500
wLinkReceivedMail:: ds MAIL_STRUCT_LENGTH * PARTY_LENGTH
wLinkReceivedMailEnd:: db


SECTION UNION "Overworld Map", WRAM0

	ds $200

; blank credits tile buffer
wCreditsBlankFrame2bpp:: ds 4 * 4 tiles
wCreditsBlankFrame2bppEnd::


if DEF(_DEBUG)
SECTION UNION "Overworld Map", WRAM0

; debug room RTC values
wDebugRoomRTCSec::  db
wDebugRoomRTCMin::  db
wDebugRoomRTCHour:: db
wDebugRoomRTCDay::  dw
wDebugRoomRTCCurSec::  db
wDebugRoomRTCCurMin::  db
wDebugRoomRTCCurHour:: db
wDebugRoomRTCCurDay::  dw

; debug room paged values
wDebugRoomCurPage::        db
wDebugRoomCurValue::       db
wDebugRoomAFunction::      dw
wDebugRoomStartFunction::  dw
wDebugRoomSelectFunction:: dw
wDebugRoomAutoFunction::   dw
wDebugRoomPageCount::      db
wDebugRoomPagesPointer::   dw

wDebugRoomROMChecksum:: dw
wDebugRoomCurChecksumBank:: db

UNION
; debug room new item values
wDebugRoomItemID::       db
wDebugRoomItemQuantity:: db
NEXTU
; debug room new pokemon values
wDebugRoomMon::    box_struct wDebugRoomMon
wDebugRoomMonBox:: db
NEXTU
; debug room GB ID values
wDebugRoomGBID:: dw
NEXTU
wDebugRoomSFXID:: db
ENDU

endc


SECTION "Video", WRAM0

UNION
; bg map
wBGMapBuffer::    ds 2 * SCREEN_WIDTH
wBGMapPalBuffer:: ds 2 * SCREEN_WIDTH
wBGMapBufferPointers:: ds 20 * 2
wBGMapBufferEnd::

NEXTU
; credits
wCreditsPos:: dw
wCreditsTimer:: db
ENDU

wDefaultCGBLayout:: db

wPlayerHPPal:: db
wEnemyHPPal:: db

wHPPals:: ds PARTY_LENGTH
wCurHPPal:: db

wWhichPartyMonHPPal:: db

wAttrmap::
; 20x18 grid of bg tile attributes for 8x8 tiles
; read horizontally from the top row
;		bit 7: priority
;		bit 6: y flip
;		bit 5: x flip
;		bit 4: pal # (non-cgb)
;		bit 3: vram bank (cgb only)
;		bit 2-0: pal # (cgb only)
	ds SCREEN_WIDTH * SCREEN_HEIGHT
wAttrmapEnd::

wTileAnimBuffer:: ds 1 tiles

; link data
UNION
wOtherPlayerLinkMode:: db
wOtherPlayerLinkAction:: db
	ds 3
wPlayerLinkAction:: db
wUnusedLinkAction:: db
	ds 3
NEXTU
wLinkReceivedSyncBuffer:: ds 5
wLinkPlayerSyncBuffer:: ds 5
ENDU
wLinkTimeoutFrames:: dw
wLinkByteTimeout:: dw

wMonType:: db

wCurSpecies:: db

wNamedObjectType:: db

wJumptableIndex:: db

UNION
; intro data
wIntroSceneFrameCounter:: db
wIntroSceneTimer:: db

NEXTU
; title data
wTitleScreenSelectedOption:: db
wTitleScreenTimer:: dw

NEXTU
; credits data
wCreditsBorderFrame:: db
wCreditsBorderMon:: db
wCreditsLYOverride:: db

NEXTU
; pokedex
wPrevDexEntryJumptableIndex:: db
wPrevDexEntryBackup:: db
wUnusedPokedexByte:: db

NEXTU
; pokegear
wPokegearCard:: db
wPokegearMapRegion:: db
wUnusedPokegearByte:: db

NEXTU
; pack
wPackJumptableIndex:: db
wCurPocket:: db
wPackUsedItem:: db

NEXTU
; trainer card badges
wTrainerCardBadgeFrameCounter:: db
wTrainerCardBadgeTileID:: db
wTrainerCardBadgeAttributes:: db

NEXTU
; slot machine
wSlotsDelay:: db
wUnusedSlotReelIconDelay:: db

NEXTU
; card flip
wCardFlipCursorY:: db
wCardFlipCursorX:: db
wCardFlipWhichCard:: db

NEXTU
; unused memory game
wMemoryGameCardChoice:: db

NEXTU
; magnet train
wMagnetTrainOffset:: db
wMagnetTrainPosition:: db
wMagnetTrainWaitCounter:: db

NEXTU
; unown puzzle data
wHoldingUnownPuzzlePiece:: db
wUnownPuzzleCursorPosition:: db
wUnownPuzzleHeldPiece:: db

NEXTU
; battle transitions
wBattleTransitionCounter:: db
wBattleTransitionSineWaveOffset::
wBattleTransitionSpinQuadrant:: db

if DEF(_DEBUG)
NEXTU
; debug mon color picker
wDebugColorRGBJumptableIndex:: db
wDebugColorCurColor:: db
wDebugColorCurMon:: db

NEXTU
; debug tileset color picker
wDebugTilesetCurPalette:: db
wDebugTilesetRGBJumptableIndex:: db
wDebugTilesetCurColor:: db

endc

NEXTU
; stats screen
wStatsScreenFlags:: db

NEXTU
; miscellaneous
wFrameCounter::
wMomBankDigitCursorPosition::
wNamingScreenLetterCase::
wHallOfFameMonCounter::
wTradeDialog::
	db
wFrameCounter2::
wPrinterQueueLength::
wUnusedSGB1eColorOffset::
	db
wUnusedTradeAnimPlayEvolutionMusic:: db
ENDU

wRequested2bppSize:: db
wRequested2bppSource:: dw
wRequested2bppDest:: dw

wRequested1bppSize:: db
wRequested1bppSource:: dw
wRequested1bppDest:: dw

wMenuMetadata::
wWindowStackPointer:: dw
wMenuJoypad:: db
wMenuSelection:: db
wMenuSelectionQuantity:: db
wWhichIndexSet:: db
wScrollingMenuCursorPosition:: db
wWindowStackSize:: db
	ds 8
wMenuMetadataEnd::

; menu header
wMenuHeader::
wMenuFlags:: db
wMenuBorderTopCoord:: db
wMenuBorderLeftCoord:: db
wMenuBorderBottomCoord:: db
wMenuBorderRightCoord:: db
wMenuDataPointer:: dw
wMenuCursorPosition:: db
	ds 1
wMenuDataBank:: db
	ds 6
wMenuHeaderEnd::

wMenuData::
wMenuDataFlags:: db

UNION
; Vertical Menu/DoNthMenu/SetUpMenu
wMenuDataItems:: db
wMenuDataIndicesPointer:: dw
wMenuDataDisplayFunctionPointer:: dw
wMenuDataPointerTableAddr:: dw

NEXTU
; 2D Menu
wMenuData_2DMenuDimensions:: db
wMenuData_2DMenuSpacing:: db
wMenuData_2DMenuItemStringsBank:: db
wMenuData_2DMenuItemStringsAddr:: dw
wMenuData_2DMenuFunctionBank:: db
wMenuData_2DMenuFunctionAddr:: dw

NEXTU
; Scrolling Menu
wMenuData_ScrollingMenuHeight:: db
wMenuData_ScrollingMenuWidth:: db
wMenuData_ScrollingMenuItemFormat:: db
wMenuData_ItemsPointerBank:: db
wMenuData_ItemsPointerAddr:: dw
wMenuData_ScrollingMenuFunction1:: ds 3
wMenuData_ScrollingMenuFunction2:: ds 3
wMenuData_ScrollingMenuFunction3:: ds 3

NEXTU
; Board Menu
wBoardMenuCursorPosition:: db

ENDU
wMenuDataEnd::

wMoreMenuData::
w2DMenuData::
w2DMenuCursorInitY:: db
w2DMenuCursorInitX:: db
w2DMenuNumRows:: db
w2DMenuNumCols:: db
w2DMenuFlags1::
; bit 7: Disable checking of wMenuJoypadFilter
; bit 6: Enable sprite animations
; bit 5: Wrap around vertically
; bit 4: Wrap around horizontally
; bit 3: Set bit 7 in w2DMenuFlags2 and exit the loop if bit 5 is disabled and we tried to go too far down
; bit 2: Set bit 7 in w2DMenuFlags2 and exit the loop if bit 5 is disabled and we tried to go too far up
; bit 1: Set bit 7 in w2DMenuFlags2 and exit the loop if bit 4 is disabled and we tried to go too far left
; bit 0: Set bit 7 in w2DMenuFlags2 and exit the loop if bit 4 is disabled and we tried to go too far right
	db
w2DMenuFlags2:: db
w2DMenuCursorOffsets:: db
wMenuJoypadFilter:: db
w2DMenuDataEnd::

wMenuCursorY:: db
wMenuCursorX:: db
wCursorOffCharacter:: db
wCursorCurrentTile:: dw
	ds 3
wMoreMenuDataEnd::

wMenuReturn:: db

wPredefID:: db
wPredefHL:: dw
wPredefAddress:: dw
wFarCallBC:: dw

wGameTimer::
; bit 0: game timer paused
; bit 7: something mobile
	db

wJoypadDisable::
; bits 4, 6, or 7 can be used to disable joypad input
; bit 4
; bit 6: ongoing mon faint animation
; bit 7: ongoing sgb data transfer
	db

wInBattleTowerBattle::
; 0 not in BattleTower-Battle
; 1 BattleTower-Battle
	db

wFXAnimID:: dw

wPlaceBallsX:: db
wPlaceBallsY:: db

wTileAnimationTimer:: db

; palette backups?
wBGP:: db
wOBP0:: db
wOBP1:: db

wNumHits:: db

; Time buffer, for counting the amount of time since
; an event began.
wSecondsSince:: db
wMinutesSince:: db
wHoursSince:: db
wDaysSince:: db

wText2bpp:: db

wWhichHUD::
; index to LoadHUD
	db

wExitOverworldReason:: db

wOptions::
; bit 0-2: number of frames to delay when printing text
;   fast 1; mid 3; slow 5
; bit 3: ?
; bit 4: no text delay
; bit 5: stereo off/on
; bit 6: battle style shift/set
; bit 7: battle scene off/on
	db
wSaveFileExists:: db
wTextboxFrame::
; bits 0-2: textbox frame 0-7
	db
wTextboxFlags::
; bit 0: 1-frame text delay
; bit 1: no text delay
; bit 2: 2bpp textbox (and text)
	db
wGBPrinterBrightness::
; bit 0-6: brightness
;   lightest: $00
;   lighter:  $20
;   normal:   $40 (default)
;   darker:   $60
;   darkest:  $7F
	db
wOptions2::
; bit 1: menu account off/on
	db
wOptionsEnd::


SECTION "WRAM 1", WRAMX

wGBCOnlyDecompressBuffer:: ; a $540-byte buffer that continues past this SECTION

wBetaTitleSequenceOpeningType::
; This selected the title screen animation (fire/notes) in pokegold-spaceworld.
	db

wDefaultSpawnpoint:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; mon buffer
wBufferMonNickname:: ds MON_NAME_LENGTH
wBufferMonOT:: ds NAME_LENGTH
wBufferMon:: party_struct wBufferMon
	ds 8
wMonOrItemNameBuffer:: ds NAME_LENGTH
	ds NAME_LENGTH


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; poke seer
wSeerAction:: db
wSeerNickname:: ds MON_NAME_LENGTH
wSeerCaughtLocation:: ds 17
wSeerTimeOfDay:: ds NAME_LENGTH
wSeerOT:: ds NAME_LENGTH
wSeerOTGrammar:: db
wSeerCaughtLevelString:: ds 4
wSeerCaughtLevel:: db
wSeerCaughtData:: db
wSeerCaughtGender:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; mail temp storage
wTempMail:: mailmsg wTempMail


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; bug-catching contest
wBugContestResults::
	bugcontestwinner wBugContestFirstPlace
	bugcontestwinner wBugContestSecondPlace
	bugcontestwinner wBugContestThirdPlace
wBugContestWinnersEnd::
	bugcontestwinner wBugContestTemp
	ds 4
wBugContestWinnerName:: ds NAME_LENGTH


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; mart items
wMartItem1BCD:: ds 3
wMartItem2BCD:: ds 3
wMartItem3BCD:: ds 3
wMartItem4BCD:: ds 3
wMartItem5BCD:: ds 3
wMartItem6BCD:: ds 3
wMartItem7BCD:: ds 3
wMartItem8BCD:: ds 3
wMartItem9BCD:: ds 3
wMartItem10BCD:: ds 3


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; town map data
wTownMapPlayerIconLandmark:: db
UNION
wTownMapCursorLandmark:: db
wTownMapCursorObjectPointer:: dw
NEXTU
wTownMapCursorCoordinates:: dw
wStartFlypoint:: db
wEndFlypoint:: db
ENDU


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; phone call data
wPhoneScriptBank:: db
wPhoneCaller:: dw


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; radio data
wCurRadioLine:: db
wNextRadioLine:: db
wRadioTextDelay:: db
wNumRadioLinesPrinted:: db
wOaksPKMNTalkSegmentCounter:: db
	ds 5
wRadioText:: ds 2 * SCREEN_WIDTH


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; lucky number show
wLuckyNumberDigitsBuffer:: ds 5


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; movement buffer data
wMovementBufferCount:: db
wMovementBufferObject:: db
wUnusedMovementBufferBank:: db
wUnusedMovementBufferPointer:: dw
wMovementBuffer:: ds 55


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; box printing
wWhichBoxMonToPrint:: db
wFinishedPrintingBox:: db
wAddrOfBoxToPrint:: dw
wBankOfBoxToPrint:: db
wWhichBoxToPrint:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; Unown printing
wPrintedUnownTileSource:: ds 1 tiles
wPrintedUnownTileDest:: ds 1 tiles


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; trainer HUD data
	ds 1
wPlaceBallsDirection:: db
wTrainerHUDTiles:: ds 4


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; battle exp gain
wExperienceGained:: ds 3


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; earthquake data buffer
wEarthquakeMovementDataBuffer:: ds 5


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; switching items in pack
wSwitchItemBuffer:: ds 2 ; may store 1 or 2 bytes


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; switching pokemon in party
; may store a name, partymon, or mail
wSwitchMonBuffer::
UNION
	ds NAME_LENGTH
NEXTU
	ds PARTYMON_STRUCT_LENGTH
NEXTU
	ds MAIL_STRUCT_LENGTH
ENDU


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; giving pokemon mail
wMonMailMessageBuffer:: ds MAIL_MSG_LENGTH + 1


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; bill's pc
UNION
wBoxNameBuffer:: ds BOX_NAME_LENGTH
NEXTU
	ds 1
wBillsPCTempListIndex:: db
wBillsPCTempBoxCount:: db
ENDU


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; prof. oak's pc
wTempPokedexSeenCount:: db
wTempPokedexCaughtCount:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; player's room pc
UNION
wDecoNameBuffer:: ds ITEM_NAME_LENGTH
NEXTU
wNumOwnedDecoCategories:: db
wOwnedDecoCategories:: ds 16
ENDU


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; trade
wCurTradePartyMon:: db
wCurOTTradePartyMon:: db
wBufferTrademonNickname:: ds MON_NAME_LENGTH


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; link battle record data
wLinkBattleRecordBuffer::
wLinkBattleRecordName::   ds NAME_LENGTH
wLinkBattleRecordWins::   dw
wLinkBattleRecordLosses:: dw
wLinkBattleRecordDraws::  dw


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; miscellaneous
wTempDayOfWeek::
wPrevPartyLevel::
wCurBeatUpPartyMon::
wUnownPuzzleCornerTile::
wKeepSevenBiasChance::
wPokeFluteCuredSleep::
wTempRestorePPItem::
wApricorns::
wSuicuneFrame::
	db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; debug color picker
wDebugColorIsTrainer:: db
wDebugColorIsShiny:: db
wDebugColorCurTMHM:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; level selection menu
wLevelSelectionMenuCurrentPage:: db
wLevelSelectionMenuCurrentLandmark:: db
wLevelSelectionMenuLandmarkTransitionsPointer:: dw
wLevelSelectionMenuMovementStepsLeft:: db
wLevelSelectionMenuStandingStill:: db


SECTION UNION "Miscellaneous WRAM 1", WRAMX

; Every previous SECTION UNION takes up 60 or fewer bytes,
; except the initial "mon buffer" one.
	ds 60

UNION
; trainer and talker data
wSeenTrainerOrTalkerIsTalker:: db ; TRUE means talker; FALSE means trainer
wSeenTrainerOrTalkerBank:: db
wSeenTrainerOrTalkerDistance:: db
wSeenTrainerOrTalkerDirection:: db

NEXTU
; trainer data
	ds 4
wTempTrainer::
wTempTrainerEventFlag:: dw
wTempTrainerClass:: db
wTempTrainerID:: db
wSeenTextPointer:: dw
wWinTextPointer:: dw
wLossTextPointer:: dw
wScriptAfterPointer:: dw
wRunningTrainerBattleScript:: db
wTempTrainerEnd::

NEXTU
; talker data
	ds 4
wTempTalker::
wTempTalkerEventFlag:: dw
wTempTalkerType:: db
wTempTalkerTextOrScriptPointer:: dw
wTempTalkerEnd::

NEXTU
; menu items list
wMenuItemsList:: ds 16
wMenuItemsListEnd::

NEXTU
; fruit tree data
wCurFruitTree:: db
wCurFruit:: db

NEXTU
; item ball data
wItemBallData::
wItemBallItemID:: db
wItemBallQuantity:: db
wItemBallDataEnd::

NEXTU
; hidden item data
wHiddenItemData::
wHiddenItemEvent:: dw
wHiddenItemID:: db
wHiddenItemDataEnd::

NEXTU
; elevator data
wElevatorData::
wElevatorPointerBank:: db
wElevatorPointer:: dw
wElevatorOriginFloor:: db
wElevatorDataEnd::

NEXTU
; anchor event data
wCurAnchorEvent::
wCurAnchorEventXCoord:: db
wCurAnchorEventYCoord:: db
wCurAnchorEventNextSpace:: db

NEXTU
; coord event data
wCurCoordEvent::
wCurCoordEventSceneID:: db
wCurCoordEventMapY:: db
wCurCoordEventMapX:: db
	ds 1
wCurCoordEventScriptAddr:: dw

NEXTU
; BG event data
wCurBGEvent::
wCurBGEventYCoord:: db
wCurBGEventXCoord:: db
wCurBGEventType:: db
wCurBGEventScriptAddr:: dw

NEXTU
; mart data
wMartType:: db
wMartPointerBank:: db
wMartPointer:: dw
wMartJumptableIndex:: db
wBargainShopFlags:: db

NEXTU
; player movement data
wCurInput::
wFacingTileID:: db
wWalkingIntoNPC:: db
wWalkingIntoLand:: db
wWalkingIntoEdgeWarp:: db
wMovementAnimation:: db
wWalkingDirection:: db
wFacingDirection:: db
wWalkingX:: db
wWalkingY:: db
wWalkingTile:: db
	ds 7
wPlayerTurningDirection:: db

NEXTU
; std script buffer
	ds 1
wJumpStdScriptBuffer:: ds 3

NEXTU
; phone script data
wCheckedTime:: db
wPhoneListIndex:: db
wNumAvailableCallers:: db
wAvailableCallers:: ds CONTACT_LIST_SIZE

NEXTU
; phone caller contact
	ds 1
wCallerContact:: ds PHONE_CONTACT_SIZE

NEXTU
; backup menu data
	ds 7
wMenuCursorPositionBackup:: db
wMenuScrollPositionBackup:: db

NEXTU
; poison step data
wPoisonStepData::
wPoisonStepFlagSum:: db
wPoisonStepPartyFlags:: ds PARTY_LENGTH
wPoisonStepDataEnd::
ENDU


SECTION "More WRAM 1", WRAMX

wStringBuffer1:: ds STRING_BUFFER_LENGTH
wStringBuffer2:: ds STRING_BUFFER_LENGTH

UNION
wStringBuffer3:: ds STRING_BUFFER_LENGTH
wStringBuffer4:: ds STRING_BUFFER_LENGTH
wStringBuffer5:: ds STRING_BUFFER_LENGTH

NEXTU
wTempSpaceStruct:: space_struct wTempSpace
wTempSpaceStructEnd::
wTempSpaceBranchStruct:: ds NUM_DIRECTIONS * 2
wTempSpaceBranchStructEnd::

wViewMapModeRange:: db
; if either displacement (abs) equals the range, player can't move further in that direction
wViewMapModeDisplacementY:: db
wViewMapModeDisplacementX:: db
; coords and map backup to know where to spawn after returning from View Map mode
wBeforeViewMapYCoord::    db
wBeforeViewMapXCoord::    db
wBeforeViewMapDirection:: db
wBeforeViewMapMapGroup::  db
wBeforeViewMapMapNumber:: db
ENDU

wBattleMenuCursorPosition::
wStartMenuLastCursorPosition::
wBoardMenuLastCursorPosition::
	db

UNION

wCurBattleMon::
; index of the player's mon currently in battle (0-5)
	db

wCurMoveNum:: db

NEXTU
; temp variables used within MockPlayerObject during View Map mode
wPlayerMockYCoord:: db
wPlayerMockXCoord:: db
ENDU

wLastPocket:: db

wPCItemsCursor::        db
wPartyMenuCursor::      db
wItemsPocketCursor::    db
wKeyItemsPocketCursor:: db
wBallsPocketCursor::    db
wTMHMPocketCursor::     db

wPCItemsScrollPosition::        db
wItemsPocketScrollPosition::    db
wKeyItemsPocketScrollPosition:: db
wBallsPocketScrollPosition::    db
wTMHMPocketScrollPosition::     db

wSwitchMon::
wSwitchItem::
wSwappingMove::
	db

wMenuScrollPosition:: ds 4

wQueuedScriptBank:: db
wQueuedScriptAddr:: dw

wNumMoves:: db

wFieldMoveSucceeded::
wItemEffectSucceeded::
wBattlePlayerAction::
; 0 - use move
; 1 - use item
; 2 - switch
wSolvedUnownPuzzle::
	db

wVramState::
; bit 0: overworld sprite updating on/off
; bit 1: something to do with sprite updates
; bit 2: do not clear wShadowOAM during DoNextFrameForAllSprites
; bit 6: something to do with text
; bit 7: on when surf initiates
;        flickers when climbing waterfall
	db

wBattleResult::
; WIN, LOSE, or DRAW
; bit 6: caught celebi
; bit 7: box full
	db
wUsingItemWithSelect:: db

UNION
; mart data
wCurMartCount:: db
wCurMartItems:: ds 15

NEXTU
; elevator data
wCurElevatorCount:: db
wCurElevatorFloors:: ds 15

NEXTU
; mailbox data
wCurMessageScrollPosition:: db
wCurMessageIndex:: db
wMailboxCount:: db
wMailboxItems:: ds MAILBOX_CAPACITY
ENDU

wListPointer:: dw
wUnusedNamesPointer:: dw

wItemAttributesPointer:: dw

wCurItem:: db
wCurItemQuantity::
wMartItemID::
	db

wCurPartySpecies:: db

wCurPartyMon::
; index of mon's party location (0-5)
	db

wWhichHPBar::
; 0: Enemy
; 1: Player
; 2: Party Menu
	db

wPokemonWithdrawDepositParameter::
; 0: Take from PC
; 1: Put into PC
; 2: Take from Day-Care
; 3: Put into Day-Care
	db

wItemQuantityChange:: db
wItemQuantity:: db

wTempMon:: party_struct wTempMon

wSpriteFlags:: db

wHandlePlayerStep:: db

wPartyMenuActionText:: db

wItemAttributeValue:: db

wCurPartyLevel:: db

wScrollingMenuListSize:: db

; used when following a map warp
wNextWarp:: db
wNextMapGroup:: db
wNextMapNumber:: db
wPrevWarp:: db
wPrevMapGroup:: db
wPrevMapNumber:: db

wPlayerBGMapOffsetX:: db ; used in FollowNotExact; unit is pixels
wPlayerBGMapOffsetY:: db ; used in FollowNotExact; unit is pixels

; Player movement
wPlayerStepVectorX:: db
wPlayerStepVectorY:: db
wPlayerStepFlags:: db
wPlayerStepDirection:: db

wBGMapAnchor:: dw

UNION
wUsedSprites:: ds SPRITE_GFX_LIST_CAPACITY * 2
wUsedSpritesEnd::

NEXTU
wd173:: db ; related to command queue type 3
ENDU

wOverworldMapAnchor:: dw
wPlayerMetatileY:: db
wPlayerMetatileX:: db

wMapPartial::
wMapAttributesBank:: db
wMapTileset:: db
wEnvironment:: db
wMapAttributesPointer:: dw
wMapPartialEnd::

wMapAttributes::
wMapBorderBlock:: db
; width/height are in blocks (2x2 walkable tiles, 4x4 graphics tiles)
wMapHeight:: db
wMapWidth:: db
wMapBlocksBank:: db
wMapBlocksPointer:: dw
wMapScriptsBank:: db
wMapScriptsPointer:: dw
wMapEventsPointer:: dw
wMapSpacesPointer:: dw
; bit set
wMapConnections:: db
wMapAttributesEnd::

wNorthMapConnection:: map_connection_struct wNorth
wSouthMapConnection:: map_connection_struct wSouth
wWestMapConnection::  map_connection_struct wWest
wEastMapConnection::  map_connection_struct wEast

wTileset::
wTilesetBank:: db
wTilesetAddress:: dw
wTilesetBlocksBank:: db
wTilesetBlocksAddress:: dw
wTilesetCollisionBank:: db
wTilesetCollisionAddress:: dw
wTilesetAnim:: dw ; bank 3f
wTilesetPalettes:: dw ; bank 3f
wTilesetVariableSpaces:: db
wTilesetEnd::
	assert wTilesetEnd - wTileset == TILESET_LENGTH

wEvolvableFlags:: flag_array PARTY_LENGTH

wForceEvolution:: db

UNION
; general-purpose HP buffers
wHPBuffer1:: dw
wHPBuffer2:: dw
wHPBuffer3:: dw

NEXTU
; HP bar animations
wCurHPAnimMaxHP::   dw
wCurHPAnimOldHP::   dw
wCurHPAnimNewHP::   dw
wCurHPAnimPal::     db
wCurHPBarPixels::   db
wNewHPBarPixels::   db
wCurHPAnimDeltaHP:: dw
wCurHPAnimLowHP::   db
wCurHPAnimHighHP::  db

NEXTU
; move AI
wEnemyAIMoveScores:: ds NUM_MOVES

NEXTU
; switch AI
wEnemyEffectivenessVsPlayerMons:: flag_array PARTY_LENGTH
wPlayerEffectivenessVsEnemyMons:: flag_array PARTY_LENGTH

NEXTU
; battle HUD
wBattleHUDTiles:: ds PARTY_LENGTH

NEXTU
; thrown ball data
wFinalCatchRate:: db
wThrownBallWobbleCount:: db

NEXTU
; evolution data
wEvolutionOldSpecies:: db
wEvolutionNewSpecies:: db
wEvolutionPicOffset::  db
wEvolutionCanceled::   db

NEXTU
; experience
wExpToNextLevel:: ds 3

NEXTU
; PP Up
wPPUpPPBuffer:: ds NUM_MOVES

NEXTU
; lucky number show
wMonIDDigitsBuffer:: ds 5

NEXTU
; mon submenu
wMonSubmenuCount:: db
wMonSubmenuItems:: ds NUM_MONMENU_ITEMS + 1

NEXTU
; field move data
wFieldMoveData::
wFieldMoveJumptableIndex:: db
wEscapeRopeOrDigType::
wSurfingPlayerState::
wFishingRodUsed:: db
wCutWhirlpoolOverworldBlockAddr:: dw
wCutWhirlpoolReplacementBlock:: db
wCutWhirlpoolAnimationType::
wStrengthSpecies::
wFishingResult:: db
wFieldMoveDataEnd::

NEXTU
; hidden items
wCurMapScriptBank:: db
wRemainingBGEventCount:: db
wBottomRightYCoord:: db
wBottomRightXCoord:: db

NEXTU
; heal machine anim
wHealMachineAnimType::  db
wHealMachineTempOBP1::  db
wHealMachineAnimState:: db

NEXTU
; decorations
wCurDecoration::          db
wSelectedDecorationSide:: db
wSelectedDecoration::     db
wOtherDecoration::        db
wChangedDecorations::     db
wCurDecorationCategory::  db

NEXTU
; withdraw/deposit items
wPCItemQuantityChange:: db
wPCItemQuantity:: db

NEXTU
; mail
wCurMailAuthorID:: dw
wCurMailIndex:: db

NEXTU
; kurt
wKurtApricornCount:: db
wKurtApricornItems:: ds 10

NEXTU
; tree mons
wTreeMonCoordScore:: db
wTreeMonOTIDScore::  db

NEXTU
; link
wLinkBattleRNPreamble:: ds SERIAL_RN_PREAMBLE_LENGTH
wLinkBattleRNs:: ds SERIAL_RNS_LENGTH

NEXTU
; miscellaneous bytes
wSkipMovesBeforeLevelUp::
wRegisteredPhoneNumbers::
wListMovesLineSpacing:: db
wSwitchMonTo:: db
wSwitchMonFrom:: db
wCurEnemyItem:: db

NEXTU
; miscellaneous words
wBuySellItemPrice::
wMagikarpLength:: dw
ENDU

wTempEnemyMonSpecies::  db
wTempBattleMonSpecies:: db

UNION
wOTLinkBattleRNData:: ds SERIAL_RN_PREAMBLE_LENGTH + SERIAL_RNS_LENGTH
NEXTU
wEnemyMon:: battle_struct wEnemyMon
wEnemyMonBaseStats:: ds NUM_EXP_STATS
wEnemyMonCatchRate:: db
wEnemyMonBaseExp::   db
wEnemyMonEnd::
ENDU

wBattleMode::
; 0: overworld
; 1: wild battle
; 2: trainer battle
	db

wTempWildMonSpecies:: db

wOtherTrainerClass::
; class (Youngster, Bug Catcher, etc.) of opposing trainer
; 0 if opponent is a wild Pokémon, not a trainer
	db

; BATTLETYPE_* values
wBattleType:: db

wOtherTrainerID::
; which trainer of the class that you're fighting
; (Joey, Mikey, Albert, etc.)
	db

wForcedSwitch:: db

wTrainerClass:: db

wUnownLetter:: db

wMoveSelectionMenuType:: db

; corresponds to the data/pokemon/base_stats/*.asm contents
wCurBaseData::
wBaseDexNo:: db
wBaseStats::
wBaseHP:: db
wBaseAttack:: db
wBaseDefense:: db
wBaseSpeed:: db
wBaseSpecialAttack:: db
wBaseSpecialDefense:: db
wBaseType::
wBaseType1:: db
wBaseType2:: db
wBaseCatchRate:: db
wBaseExp:: db
wBaseItems::
wBaseItem1:: db
wBaseItem2:: db
wBaseGender:: db
wBaseUnknown1:: db
wBaseEggSteps:: db
wBaseUnknown2:: db
wBasePicSize:: db
wBaseUnusedFrontpic:: dw
wBaseUnusedBackpic:: dw
wBaseGrowthRate:: db
wBaseEggGroups:: db
wBaseTMHM:: flag_array NUM_TM_HM_TUTOR
wCurBaseDataEnd::
	assert wCurBaseDataEnd - wCurBaseData == BASE_DATA_SIZE

wCurDamage:: dw

wMornEncounterRate::  db
wDayEncounterRate::   db
wNiteEncounterRate::  db
wEveEncounterRate::   db
wWaterEncounterRate:: db
wListMoves_MoveIndicesBuffer:: ds NUM_MOVES
wPutativeTMHMMove:: db
wInitListType:: db
wBattleHasJustStarted:: db

wNamedObjectIndex::
wTextDecimalByte::
wTempByteValue::
wNumSetBits::
wTypeMatchup::
wCurType::
wTempSpecies::
wTempIconSpecies::
wTempTMHM::
wTempPP::
wNextBoxOrPartyIndex::
wChosenCableClubRoom::
wBreedingCompatibility::
wMoveGrammar::
wApplyStatLevelMultipliersToEnemy::
wUsePPUp::
	db

wFailedToFlee:: db
wNumFleeAttempts:: db
wMonTriedToEvolve:: db

wTimeOfDay:: db


SECTION "Enemy Party", WRAMX

UNION
wPokedexShowPointerAddr:: dw
wPokedexShowPointerBank:: db

NEXTU
wUnusedEggHatchFlag:: db

NEXTU
; enemy party
wOTPartyData::
wOTPlayerName:: ds NAME_LENGTH
wOTPlayerID:: dw
wOTPartyCount::   db
wOTPartySpecies:: ds PARTY_LENGTH
wOTPartyEnd::     db ; older code doesn't check PartyCount
ENDU

UNION
; ot party mons
wOTPartyMons::
; wOTPartyMon1 - wOTPartyMon6
for n, 1, PARTY_LENGTH + 1
wOTPartyMon{d:n}:: party_struct wOTPartyMon{d:n}
endr

wOTPartyMonOTs::
; wOTPartyMon1OT - wOTPartyMon6OT
for n, 1, PARTY_LENGTH + 1
wOTPartyMon{d:n}OT:: ds NAME_LENGTH
endr

wOTPartyMonNicknames::
; wOTPartyMon1Nickname - wOTPartyMon6Nickname
for n, 1, PARTY_LENGTH + 1
wOTPartyMon{d:n}Nickname:: ds MON_NAME_LENGTH
endr
wOTPartyDataEnd::

NEXTU
; catch tutorial dude pack
wDudeNumItems:: db
wDudeItems:: ds 2 * 4 + 1

wDudeNumKeyItems:: db
wDudeKeyItems:: ds 18 + 1

wDudeNumBalls:: db
wDudeBalls:: ds 2 * 4 + 1
ENDU

wBattleAction:: db

wLinkBattleSentAction:: db

; wMapStatus ~ wMapStatusEnd is cleared in StartMap
wMapStatus:: db

wMapEventStatus:: db

wScriptFlags::
; bit 3: run deferred script
	db
wScriptFlags2::
; bit 0: count steps
; bit 1: coord events
; bit 2: warps and connections
; bit 3: wild encounters
; bit 4: space effects
	db

wScriptMode:: db
wScriptRunning:: db
wScriptBank:: db
wScriptPos:: dw

wScriptStackSize:: db
wScriptStack:: ds 3 * 5

wScriptDelay:: db

wDeferredScriptBank::
wScriptTextBank::
	db
wDeferredScriptAddr::
wScriptTextAddr::
	dw

wWildEncounterCooldown:: db

wXYComparePointer:: dw

wBattleScriptFlags:: db

wPlayerSpriteSetupFlags::
; bit 7: if set, cancel wPlayerAction
; bit 6: RefreshMapSprites doesn't reload player sprite
; bit 5: if set, set facing according to bits 0-1
; bit 2: female player has been transformed into male
; bits 0-1: direction facing
	db

wMapReentryScriptQueueFlag:: db
wMapReentryScriptBank:: db
wMapReentryScriptAddress:: dw

wTimeCyclesSinceLastCall:: db
wReceiveCallDelay_MinsRemaining:: db
wReceiveCallDelay_StartTime:: ds 2 ; hour, min

wBugContestMinsRemaining:: db
wBugContestSecsRemaining:: db

; TurnData ~ wTurnDataEnd is cleared at the beginning of BoardMenuScript (i.e. on turn begin)
wTurnData::
wDieRoll:: db
wSpacesLeft:: db
wTurnDataEnd::

wMapStatusEnd::

wGameData::
wPlayerData::
wPlayerID:: dw

wPlayerName:: ds NAME_LENGTH
wMomsName::   ds NAME_LENGTH
wRivalName::  ds NAME_LENGTH
wRedsName::   ds NAME_LENGTH
wGreensName:: ds NAME_LENGTH

wPlayerGender::
; bit 0:
;	0 male
;	1 female
	db

wSavedAtLeastOnce:: db
wSaveFileInOverworld:: db

; init time set at newgame
wStartDay::    db
wStartHour::   db
wStartMinute:: db
wStartSecond:: db

wGameTime:: ; used only for BANK(wGameTime)
wGameTimeCap::     db
wGameTimeHours::   dw
wGameTimeMinutes:: db
wGameTimeSeconds:: db
wGameTimeFrames::  db

wCurDay:: db

wObjectFollow_Leader:: db
wObjectFollow_Follower:: db
wCenteredObject:: db
wFollowerMovementQueueLength:: db
wFollowMovementQueue:: ds 5

wObjectStructs::
wPlayerStruct:: object_struct wPlayer ; player is object struct 0
; wObjectStruct1 - wObjectStruct12
for n, 1, NUM_OBJECT_STRUCTS
wObject{d:n}Struct:: object_struct wObject{d:n}
endr

wCmdQueue:: ds CMDQUEUE_CAPACITY * CMDQUEUE_ENTRY_SIZE

wMapObjects::
wPlayerObject:: map_object wPlayerObject ; player is map object 0
; wMapObject1 - wMapObject15
for n, 1, NUM_OBJECTS
wMapObject{d:n}:: map_object wMapObject{d:n}
endr

wObjectMasks:: ds NUM_OBJECTS

wVariableSprites:: ds $100 - SPRITE_VARS

wTimeOfDayPal:: db
wTimeOfDayPalFlags:: db
wTimeOfDayPalset:: db
wCurTimeOfDay:: db

wSecretID:: dw
wStatusFlags::
; bit 0: pokedex
; bit 1: unown dex
; bit 2: flash
; bit 3: caught pokerus
; bit 4: rocket signal
; bit 5: wild encounters on/off
; bit 6: hall of fame
; bit 7: bug contest on
	db

wStatusFlags2::
; bit 0: rockets
; bit 1: safari game (unused)
; bit 2: bug contest timer
; bit 3: unused
; bit 4: bike shop call
; bit 5: can use sweet scent
; bit 6: reached goldenrod
; bit 7: rockets in mahogany
	db

wCoins:: ds 3
wMomsCoins:: ds 3

wMomSavingCoins::
; bit 0: saving some coins
; bit 1: saving half coins (unused)
; bit 2: saving all coins (unused)
; bit 7: active
	db

wChips:: dw

wBadges::
wJohtoBadges:: flag_array NUM_JOHTO_BADGES
wKantoBadges:: flag_array NUM_KANTO_BADGES

wTMsHMs:: ds NUM_TMS + NUM_HMS

wNumItems:: db
wItems:: ds MAX_ITEMS * 2 + 1

wNumKeyItems:: db
wKeyItems:: ds MAX_KEY_ITEMS + 1

wNumBalls:: db
wBalls:: ds MAX_BALLS * 2 + 1

wNumPCItems:: db
wPCItems:: ds MAX_PC_ITEMS * 2 + 1

wPokegearFlags::
; bit 0: map
; bit 1: radio
; bit 2: phone
; bit 3: expn
; bit 7: on/off
	db
wRadioTuningKnob:: db
wLastDexMode:: db

wWhichRegisteredItem:: db
wRegisteredItem:: db

wPlayerState:: db

wHallOfFameCount:: db

wTradeFlags:: flag_array NUM_NPC_TRADES

wMooMooBerries:: db
wUndergroundSwitchPositions:: db
wFarfetchdPosition:: db

wUnlockedLevels:: flag_array NUM_LEVELS
wClearedLevelsStage1:: flag_array NUM_LEVELS
wClearedLevelsStage2:: flag_array NUM_LEVELS
wClearedLevelsStage3:: flag_array NUM_LEVELS
wClearedLevelsStage4:: flag_array NUM_LEVELS

wUnlockedTechniques:: flag_array NUM_TECHNIQUES

; map scene ids (data/maps/scenes.asm:MapScenes)
; wPokecenter2FSceneID::                            db

wEventFlags:: flag_array NUM_EVENTS

wCurBox:: db

wBoxNames:: ds BOX_NAME_LENGTH * NUM_BOXES

wCelebiEvent::
; bit 2: forest is restless
	db

wBikeFlags::
; bit 0: using strength
; bit 1: always on bike
; bit 2: downhill
	db

wCurMapSceneScriptPointer:: dw

wCurCaller:: dw
wCurMapWarpEventCount:: db
wCurMapWarpEventsPointer:: dw
wCurMapAnchorEventCount:: db
wCurMapAnchorEventsPointer:: dw
wCurMapCoordEventCount:: db
wCurMapCoordEventsPointer:: dw
wCurMapBGEventCount:: db
wCurMapBGEventsPointer:: dw
wCurMapObjectEventCount:: db
wCurMapObjectEventsPointer:: dw
wCurMapSceneScriptCount:: db
wCurMapSceneScriptsPointer:: dw
wCurMapCallbackCount:: db
wCurMapCallbacksPointer:: dw

; Sprite id of each decoration
wDecoBed::           db
wDecoCarpet::        db
wDecoPlant::         db
wDecoPoster::        db
wDecoConsole::       db
wDecoLeftOrnament::  db
wDecoRightOrnament:: db
wDecoBigDoll::       db

; Items bought from Mom
wWhichMomItem:: db
wWhichMomItemSet:: db
wMomItemTriggerBalance:: ds 3

wDailyResetTimer:: dw
wDailyFlags1:: db
wDailyFlags2:: db
wSwarmFlags:: db

wFruitTreeFlags:: flag_array NUM_FRUIT_TREES

wLuckyNumberDayTimer:: dw

wSpecialPhoneCallID:: db

wBugContestStartTime:: ds 3 ; hour, min, sec

wBuenasPassword:: db
wBlueCardBalance:: db
wYanmaMapGroup:: db
wYanmaMapNumber:: db

wStepCount:: db
wPoisonStepCount:: db
wHappinessStepCount:: db

wParkBallsRemaining::
wSafariBallsRemaining:: db
wSafariTimeRemaining:: dw

wPhoneList:: ds CONTACT_LIST_SIZE + 1

wLuckyNumberShowFlag:: db
wLuckyIDNumber:: dw

wRepelEffect:: db ; If a Repel is in use, it contains the nr of steps it's still active
wBikeStep:: dw
wKurtApricornQuantity:: db

wCurLevel:: db
wDefaultLevelSelectionMenuLandmark:: db
wCurOverworldMiscPal:: db
wLevelSelectionMenuEntryEventQueue:: flag_array NUM_LSM_EVENTS

wPlayerDataEnd::

wCurMapData::

wVisitedSpawns:: flag_array NUM_SPAWNS

wDigWarpNumber:: db
wDigMapGroup::   db
wDigMapNumber::  db

; used on maps like second floor pokécenter, which are reused, so we know which
; map to return to
wBackupWarpNumber:: db
wBackupMapGroup::   db
wBackupMapNumber::  db

wLastSpawnMapGroup:: db
wLastSpawnMapNumber:: db

wWarpNumber:: db
wMapGroup:: db
wMapNumber:: db
wYCoord:: db
wXCoord:: db
wScreenSave:: ds SCREEN_META_WIDTH * SCREEN_META_HEIGHT

wCurTurn:: dw
wCurSpace:: db
wCurLevelCoins:: ds 3
wCurLevelExp:: ds 3

wCurSpaceStruct:: space_struct wCurSpace
wCurSpaceStructEnd::

wCurMapDataEnd::


SECTION "Party", WRAMX

wPokemonData::

wPartyCount::   db
wPartySpecies:: ds PARTY_LENGTH
wPartyEnd::     db ; older code doesn't check wPartyCount

wPartyMons::
; wPartyMon1 - wPartyMon6
for n, 1, PARTY_LENGTH + 1
wPartyMon{d:n}:: party_struct wPartyMon{d:n}
endr

wPartyMonOTs::
; wPartyMon1OT - wPartyMon6OT
for n, 1, PARTY_LENGTH + 1
wPartyMon{d:n}OT:: ds NAME_LENGTH
endr

wPartyMonNicknames::
; wPartyMon1Nickname - wPartyMon6Nickname
for n, 1, PARTY_LENGTH + 1
wPartyMon{d:n}Nickname:: ds MON_NAME_LENGTH
endr
wPartyMonNicknamesEnd::

wPokedexCaught:: flag_array NUM_POKEMON
wEndPokedexCaught::

wPokedexSeen:: flag_array NUM_POKEMON
wEndPokedexSeen::

wUnownDex:: ds NUM_UNOWN
wUnlockedUnowns:: db
wFirstUnownSeen:: db

wDayCareMan::
; bit 7: active
; bit 6: egg ready
; bit 5: monsters are compatible
; bit 0: monster 1 in day-care
	db

wBreedMon1Nickname:: ds MON_NAME_LENGTH
wBreedMon1OT:: ds NAME_LENGTH
wBreedMon1:: box_struct wBreedMon1

wDayCareLady::
; bit 7: active
; bit 0: monster 2 in day-care
	db

wStepsToEgg::
	db
wBreedMotherOrNonDitto::
;  z: yes
; nz: no
	db

wBreedMon2Nickname:: ds MON_NAME_LENGTH
wBreedMon2OT:: ds NAME_LENGTH
wBreedMon2:: box_struct wBreedMon2

wEggMonNickname:: ds MON_NAME_LENGTH
wEggMonOT:: ds NAME_LENGTH
wEggMon:: box_struct wEggMon

wBugContestSecondPartySpecies:: db
wContestMon:: party_struct wContestMon

wDunsparceMapGroup:: db
wDunsparceMapNumber:: db
wFishingSwarmFlag:: db

wRoamMon1:: roam_struct wRoamMon1
wRoamMon2:: roam_struct wRoamMon2
wRoamMon3:: roam_struct wRoamMon3

wRoamMons_CurMapNumber:: db
wRoamMons_CurMapGroup:: db
wRoamMons_LastMapNumber:: db
wRoamMons_LastMapGroup:: db

wBestMagikarpLengthFeet:: db
wBestMagikarpLengthInches:: db
wMagikarpRecordHoldersName:: ds NAME_LENGTH

wPokemonDataEnd::
wGameDataEnd::

; requirement of GiveCoins
	assert HIGH(wCoins) != HIGH(wCurLevelCoins)

SECTION "Pic Animations", WRAMX

wTempTilemap::
; 20x18 grid of 8x8 tiles
	ds SCREEN_WIDTH * SCREEN_HEIGHT

; PokeAnim data
wPokeAnimStruct::
wPokeAnimSceneIndex:: db
wPokeAnimPointer:: dw
wPokeAnimSpecies:: db
wPokeAnimUnownLetter:: db
wPokeAnimSpeciesOrUnown:: db
wPokeAnimGraphicStartTile:: db
wPokeAnimCoord:: dw
wPokeAnimFrontpicHeight:: db
wPokeAnimIdleFlag:: db
wPokeAnimSpeed:: db
wPokeAnimPointerBank:: db
wPokeAnimPointerAddr:: dw
wPokeAnimFramesBank:: db
wPokeAnimFramesAddr:: dw
wPokeAnimBitmaskBank:: db
wPokeAnimBitmaskAddr:: dw
wPokeAnimFrame:: db
wPokeAnimJumptableIndex:: db
wPokeAnimRepeatTimer:: db
wPokeAnimCurBitmask:: db
wPokeAnimWaitCounter:: db
wPokeAnimCommand:: db
wPokeAnimParameter:: db
	ds 1
wPokeAnimBitmaskCurCol:: db
wPokeAnimBitmaskCurRow:: db
wPokeAnimBitmaskCurBit:: db
wPokeAnimBitmaskBuffer:: ds 7
	ds 2
wPokeAnimStructEnd::


SECTION "Disabled Spaces Backups", WRAMX

wDisabledSpacesBackups::
for n, 1, NUM_DISABLED_SPACES_BACKUPS
	wMap{d:n}DisabledSpacesBackup::
	wMap{d:n}DisabledSpacesBackupMapGroup:: db
	wMap{d:n}DisabledSpacesBackupMapNumber:: db
	wMap{d:n}DisabledSpacesBackupData:: flag_array MAX_SPACES_PER_MAP
endr
wDisabledSpacesBackupsEnd:: db ; list terminator


SECTION "Map Objects Backups", WRAMX

wMapObjectsBackups::
; wMap1ObjectsBackup* - wMap10ObjectsBackup*
; ds (2 + MAPOBJECT_LENGTH * (NUM_OBJECTS - 1)) * NUM_MAP_OBJECTS_BACKUPS
for n, 1, NUM_MAP_OBJECTS_BACKUPS
	wMap{d:n}ObjectsBackup::
	wMap{d:n}ObjectsBackupMapGroup:: db
	wMap{d:n}ObjectsBackupMapNumber:: db
	wMap{d:n}ObjectsBackupData::
	for m, 1, NUM_OBJECTS
		wMap{d:n}ObjectsBackupObject{d:m}:: map_object wMap{d:n}ObjectsBackupObject{d:m}
	endr
endr
wMapObjectsBackupsEnd:: db ; list terminator


SECTION "GBC Video", WRAMX, ALIGN[8]

; eight 4-color palettes each
wGBCPalettes:: ; used only for BANK(wGBCPalettes)
wBGPals1:: ds 8 palettes
wOBPals1:: ds 8 palettes
wBGPals2:: ds 8 palettes
wOBPals2:: ds 8 palettes

	align 8
wLYOverrides:: ds SCREEN_HEIGHT_PX
wLYOverridesEnd::

wMagnetTrain:: ; used only for BANK(wMagnetTrain)
wMagnetTrainDirection:: db
wMagnetTrainInitPosition:: db
wMagnetTrainHoldPosition:: db
wMagnetTrainFinalPosition:: db
wMagnetTrainPlayerSpriteInitX:: db

 ; Used by FadeInPalettesFromWhite
wBGPalsRegularWhiteColors:: ds 8 * PAL_COLOR_SIZE

	ds 91

	align 8
wLYOverridesBackup:: ds SCREEN_HEIGHT_PX
wLYOverridesBackupEnd::


SECTION "Battle Animations", WRAMX

wBattleAnimTileDict::
; wBattleAnimTileDict pairs keys with values
; keys: BATTLE_ANIM_GFX_* indexes (taken from anim_*gfx arguments)
; values: vTiles0 offsets
	ds NUM_BATTLEANIMTILEDICT_ENTRIES * 2

wActiveAnimObjects::
; wAnimObject1 - wAnimObject10
for n, 1, NUM_BATTLE_ANIM_STRUCTS + 1
wAnimObject{d:n}:: battle_anim_struct wAnimObject{d:n}
endr

wActiveBGEffects::
; wBGEffect1 - wBGEffect5
for n, 1, NUM_BG_EFFECTS + 1
wBGEffect{d:n}:: battle_bg_effect wBGEffect{d:n}
endr

wLastAnimObjectIndex:: db

wBattleAnimFlags:: db
wBattleAnimAddress:: dw
wBattleAnimDelay:: db
wBattleAnimParent:: dw
wBattleAnimLoops:: db
wBattleAnimVar:: db
wBattleAnimByte:: db
wBattleAnimOAMPointerLo:: db

UNION
wBattleObjectTempID:: db
wBattleObjectTempXCoord:: db
wBattleObjectTempYCoord:: db
wBattleObjectTempParam:: db

NEXTU
wBattleBGEffectTempID:: db
wBattleBGEffectTempJumptableIndex:: db
wBattleBGEffectTempTurn:: db
wBattleBGEffectTempParam:: db

NEXTU
wBattleAnimTempOAMFlags:: db
wBattleAnimTempFixY:: db
wBattleAnimTempTileID:: db
wBattleAnimTempXCoord:: db
wBattleAnimTempYCoord:: db
wBattleAnimTempXOffset:: db
wBattleAnimTempYOffset:: db
wBattleAnimTempFrameOAMFlags:: db
wBattleAnimTempPalette:: db

NEXTU
wBattleAnimGFXTempTileID::
wBattleAnimGFXTempPicHeight:: db

NEXTU
wBattleSineWaveTempProgress:: db
wBattleSineWaveTempOffset:: db
wBattleSineWaveTempAmplitude:: db
wBattleSineWaveTempTimer:: db

NEXTU
wBattlePicResizeTempBaseTileID:: db
wBattlePicResizeTempPointer:: dw
ENDU

UNION
	ds 50
wBattleAnimEnd::

NEXTU
wSurfWaveBGEffect:: ds $40
wSurfWaveBGEffectEnd::
ENDU


SECTION "Scratch RAM", WRAMX

UNION
wScratchTilemap:: ds BG_MAP_WIDTH * BG_MAP_HEIGHT
wScratchAttrmap:: ds BG_MAP_WIDTH * BG_MAP_HEIGHT

NEXTU
wDecompressScratch:: ds $80 tiles
wDecompressEnemyFrontpic:: ds $80 tiles

NEXTU
; unidentified uses
w6_d000:: ds $1000
ENDU


SECTION "Stack RAM", WRAMX

wWindowStack:: ds $1000 - 1
wWindowStackBottom:: ds 1

ENDSECTION
