SECTION "HRAM", HRAM

hROMBankBackup:: db
hFarByte::
hTempBank:: db
hSRAMBank:: db

hVBlankCounter:: db

hROMBank:: db
hVBlank:: db
hMapEntryMethod:: db

hMenuReturn:: db

hJoypadReleased:: db
hJoypadPressed::  db
hJoypadDown::     db
hJoypadSum::      db
hJoyReleased::    db
hJoyPressed::     db
hJoyDown::        db
hJoyLast::        db

hInMenu:: db

hPrinter:: db
hGraphicStartTile:: db
hMoveMon:: db

UNION
hMapObjectIndex:: db
hObjectStructIndex:: db
NEXTU
hConnectionStripLength:: db
hConnectedMapWidth:: db
ENDU

hEnemyMonSpeed:: dw

UNION
; math-related values

UNION
; inputs to Multiply
	ds 1
hMultiplicand:: ds 3
hMultiplier::   db
NEXTU
; result of Multiply
hProduct::      ds 4
NEXTU
; inputs to Divide
hDividend::     ds 4
hDivisor::      db
NEXTU
; results of Divide
hQuotient::     ds 4
hRemainder::    db
ENDU

hMathBuffer:: ds 5

NEXTU
; PrintNum scratch space
hPrintNumBuffer:: ds 10

NEXTU
; engine/gfx/rgb_fade.asm
hRGBFadeSourceChannels::
hRGBFadeSourceRChannel:: db
hRGBFadeSourceGChannel:: db
hRGBFadeSourceBChannel:: db
hRGBFadeCapChannels::
hRGBFadeCapRChannel:: db
hRGBFadeCapGChannel:: db
hRGBFadeCapBChannel:: db

ENDU

UNION
hUsedSpriteIndex:: db
hUsedSpriteTile::  db
NEXTU
hCurSpriteXCoord::   db
hCurSpriteYCoord::   db
hCurSpriteXPixel::   db
hCurSpriteYPixel::   db
hCurSpriteTile::     db
hCurSpriteOAMFlags:: db
ENDU

UNION
hCoinsTemp:: ds 3
NEXTU
hMGJoypadPressed::  db
hMGJoypadReleased:: db
hMGPrevTIMA::       db
ENDU

hLCDCPointer::     db
hLYOverrideStart:: db
hLYOverrideEnd::   db

hSerialReceivedNewData::     db
hSerialConnectionStatus::    db
hSerialIgnoringInitialData:: db
hSerialSend::                db
hSerialReceive::             db

hSCX::           db
hSCY::           db
hWX::            db
hWY::            db
hTilesPerCycle:: db
hBGMapMode::     db
hBGMapThird::    db
hBGMapAddress::  dw

hOAMUpdate:: db

hSPBuffer::  dw

hBGMapUpdate::    db
hBGMapTileCount:: db

hMapAnims::      db
hTileAnimFrame:: db

hLastTalked:: db

hRandomAdd:: db
hRandomSub:: db

hBattleTurn::
; Which trainer's turn is it? 0: player, 1: opponent trainer
	db

hCGBPalUpdate:: db
hCGB::          db
hSGB::          db

hDMATransfer:: db
hSystemBooted:: db

if DEF(_DEBUG)
hDebugRoomMenuPage:: db
endc

hWindowHUDLY::
; Window HUD is enabled when non-0.
; Its value indicates the last scanline that the window spans from the top.
	db

hCurBoardEvent:: db
