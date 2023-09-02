BankOfMom:
	ldh a, [hInMenu]
	push af
	ld a, $1
	ldh [hInMenu], a
	xor a
	ld [wJumptableIndex], a
.loop
	ld a, [wJumptableIndex]
	bit 7, a
	jr nz, .done
	call .RunJumptable
	jr .loop

.done
	pop af
	ldh [hInMenu], a
	ret

.RunJumptable:
	jumptable .dw, wJumptableIndex

.dw
	dw .CheckIfBankInitialized
	dw .InitializeBank
	dw .IsThisAboutYourCoins
	dw .AccessBankOfMom
	dw .StoreCoins
	dw .TakeCoins
	dw .StopOrStartSavingCoins
	dw .JustDoWhatYouCan
	dw .AskDST

.CheckIfBankInitialized:
	ld a, [wMomSavingCoins]
	bit MOM_ACTIVE_F, a
	jr nz, .savingcoinsalready
	set MOM_ACTIVE_F, a
	ld [wMomSavingCoins], a
	ld a, $1
	jr .done_0

.savingcoinsalready
	ld a, $2

.done_0
	ld [wJumptableIndex], a
	ret

.InitializeBank:
	ld hl, MomLeavingText1
	call PrintText1bpp
	call YesNoBox
	jr c, .DontSaveCoins
	ld hl, MomLeavingText2
	call PrintText1bpp
	ld a, (1 << MOM_ACTIVE_F) | (1 << MOM_SAVING_SOME_COINS_F)
	jr .done_1

.DontSaveCoins:
	ld a, 1 << MOM_ACTIVE_F

.done_1
	ld [wMomSavingCoins], a
	ld hl, MomLeavingText3
	call PrintText1bpp
	ld a, $8
	ld [wJumptableIndex], a
	ret

.IsThisAboutYourCoins:
	ld hl, MomIsThisAboutYourCoinsText
	call PrintText1bpp
	call YesNoBox
	jr c, .nope
	ld a, $3
	jr .done_2

.nope
	ld a, $7

.done_2
	ld [wJumptableIndex], a
	ret

.AccessBankOfMom:
	ld hl, MomBankWhatDoYouWantToDoText
	call PrintText1bpp
	call LoadStandardMenuHeader
	ld hl, BankOfMom_MenuHeader
	call CopyMenuHeader
	call VerticalMenu
	call CloseWindow
	jr c, .cancel
	ld a, [wMenuCursorY]
	cp $1
	jr z, .withdraw
	cp $2
	jr z, .deposit
	cp $3
	jr z, .stopsaving

.cancel
	ld a, $7
	jr .done_3

.withdraw
	ld a, $5
	jr .done_3

.deposit
	ld a, $4
	jr .done_3

.stopsaving
	ld a, $6

.done_3
	ld [wJumptableIndex], a
	ret

.StoreCoins:
	ld hl, MomStoreCoinsText
	call PrintText1bpp
	xor a
	ld hl, wStringBuffer2
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, 5
	ld [wMomBankDigitCursorPosition], a
	call LoadStandardMenuHeader
	call Mom_SetUpDepositMenu
	call Mom_Wait10Frames
	call Mom_WithdrawDepositMenuJoypad
	call CloseWindow
	jr c, .CancelDeposit
	ld hl, wStringBuffer2
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, .CancelDeposit
	ld de, wCoins
	ld bc, wStringBuffer2
	farcall CompareCoins
	jr c, .InsufficientFundsInWallet
	ld hl, wStringBuffer2
	ld de, wStringBuffer2 + 3
	ld bc, 3
	call CopyBytes
	ld bc, wMomsCoins
	ld de, wStringBuffer2
	farcall GiveCoins
	jr c, .NotEnoughRoomInBank
	ld bc, wStringBuffer2 + 3
	ld de, wCoins
	farcall TakeCoins
	ld hl, wStringBuffer2
	ld de, wMomsCoins
	ld bc, 3
	call CopyBytes
	ld de, SFX_TRANSACTION
	call PlaySFX
	call WaitSFX
	ld hl, MomStoredCoinsText
	call PrintText1bpp
	ld a, $8
	jr .done_4

.InsufficientFundsInWallet:
	ld hl, MomInsufficientFundsInWalletText
	call PrintText1bpp
	ret

.NotEnoughRoomInBank:
	ld hl, MomNotEnoughRoomInBankText
	call PrintText1bpp
	ret

.CancelDeposit:
	ld a, $7

.done_4
	ld [wJumptableIndex], a
	ret

.TakeCoins:
	ld hl, MomTakeCoinsText
	call PrintText1bpp
	xor a
	ld hl, wStringBuffer2
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, 5
	ld [wMomBankDigitCursorPosition], a
	call LoadStandardMenuHeader
	call Mom_SetUpWithdrawMenu
	call Mom_Wait10Frames
	call Mom_WithdrawDepositMenuJoypad
	call CloseWindow
	jr c, .CancelWithdraw
	ld hl, wStringBuffer2
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, .CancelWithdraw
	ld hl, wStringBuffer2
	ld de, wStringBuffer2 + 3
	ld bc, 3
	call CopyBytes
	ld de, wMomsCoins
	ld bc, wStringBuffer2
	farcall CompareCoins
	jr c, .InsufficientFundsInBank
	ld bc, wCoins
	ld de, wStringBuffer2
	farcall GiveCoins
	jr c, .NotEnoughRoomInWallet
	ld bc, wStringBuffer2 + 3
	ld de, wMomsCoins
	farcall TakeCoins
	ld hl, wStringBuffer2
	ld de, wCoins
	ld bc, 3
	call CopyBytes
	ld de, SFX_TRANSACTION
	call PlaySFX
	call WaitSFX
	ld hl, MomTakenCoinsText
	call PrintText1bpp
	ld a, $8
	jr .done_5

.InsufficientFundsInBank:
	ld hl, MomHaventSavedThatMuchText
	call PrintText1bpp
	ret

.NotEnoughRoomInWallet:
	ld hl, MomNotEnoughRoomInWalletText
	call PrintText1bpp
	ret

.CancelWithdraw:
	ld a, $7

.done_5
	ld [wJumptableIndex], a
	ret

.StopOrStartSavingCoins:
	ld hl, MomSaveCoinsText
	call PrintText1bpp
	call YesNoBox
	jr c, .StopSavingCoins
	ld a, (1 << MOM_ACTIVE_F) | (1 << MOM_SAVING_SOME_COINS_F)
	ld [wMomSavingCoins], a
	ld hl, MomStartSavingCoinsText
	call PrintText1bpp
	ld a, $8
	ld [wJumptableIndex], a
	ret

.StopSavingCoins:
	ld a, 1 << MOM_ACTIVE_F
	ld [wMomSavingCoins], a
	ld a, $7
	ld [wJumptableIndex], a
	ret

.JustDoWhatYouCan:
	ld hl, MomJustDoWhatYouCanText
	call PrintText1bpp

.AskDST:
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

Mom_SetUpWithdrawMenu:
	ld de, Mon_WithdrawString
	jr Mom_ContinueMenuSetup

Mom_SetUpDepositMenu:
	ld de, Mom_DepositString
Mom_ContinueMenuSetup:
	push de
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 0
	lb bc, 6, 18
	call Textbox1bpp
	hlcoord 1, 2
	ld de, Mom_SavedString
	call PlaceString
	hlcoord 12, 2
	ld de, wMomsCoins
	lb bc, PRINTNUM_COINS | 3, 6
	call PrintNum
	hlcoord 1, 4
	ld de, Mom_HeldString
	call PlaceString
	hlcoord 12, 4
	ld de, wCoins
	lb bc, PRINTNUM_COINS | 3, 6
	call PrintNum
	hlcoord 1, 6
	pop de
	call PlaceString
	hlcoord 12, 6
	ld de, wStringBuffer2
	lb bc, PRINTNUM_COINS | PRINTNUM_LEADINGZEROS | 3, 6
	call PrintNum
	call UpdateSprites
	call CopyTilemapAtOnce
	ret

Mom_Wait10Frames:
	ld c, 10
	call DelayFrames
	ret

Mom_WithdrawDepositMenuJoypad:
.loop
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	and B_BUTTON
	jr nz, .pressedB
	ld a, [hl]
	and A_BUTTON
	jr nz, .pressedA
	call .dpadaction
	xor a
	ldh [hBGMapMode], a
	hlcoord 12, 6
	ld bc, 7
	ld a, " "
	call ByteFill
	hlcoord 12, 6
	ld de, wStringBuffer2
	lb bc, PRINTNUM_COINS | PRINTNUM_LEADINGZEROS | 3, 6
	call PrintNum
	ldh a, [hVBlankCounter]
	and $10
	jr nz, .skip
	hlcoord 13, 6
	ld a, [wMomBankDigitCursorPosition]
	ld c, a
	ld b, 0
	add hl, bc
	ld [hl], " "

.skip
	call WaitBGMap
	jr .loop

.pressedB
	scf
	ret

.pressedA
	and a
	ret

.dpadaction
	ld hl, hJoyLast
	ld a, [hl]
	and D_UP
	jr nz, .incrementdigit
	ld a, [hl]
	and D_DOWN
	jr nz, .decrementdigit
	ld a, [hl]
	and D_LEFT
	jr nz, .movecursorleft
	ld a, [hl]
	and D_RIGHT
	jr nz, .movecursorright
	and a
	ret

.movecursorleft
	ld hl, wMomBankDigitCursorPosition
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret

.movecursorright
	ld hl, wMomBankDigitCursorPosition
	ld a, [hl]
	cp 5
	ret nc
	inc [hl]
	ret

.incrementdigit
	ld hl, .DigitQuantities
	call .getdigitquantity
	ld c, l
	ld b, h
	ld de, wStringBuffer2
	farcall GiveCoins
	ret

.decrementdigit
	ld hl, .DigitQuantities
	call .getdigitquantity
	ld c, l
	ld b, h
	ld de, wStringBuffer2
	farcall TakeCoins
	ret

.getdigitquantity
	ld a, [wMomBankDigitCursorPosition]
	push de
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	add hl, de
	pop de
	ret

.DigitQuantities:
	dt 100000
	dt 10000
	dt 1000
	dt 100
	dt 10
	dt 1

	dt 100000
	dt 10000
	dt 1000
	dt 100
	dt 10
	dt 1

	dt 900000
	dt 90000
	dt 9000
	dt 900
	dt 90
	dt 9

MomLeavingText1:
	text_far _MomLeavingText1
	text_end

MomLeavingText2:
	text_far _MomLeavingText2
	text_end

MomLeavingText3:
	text_far _MomLeavingText3
	text_end

MomIsThisAboutYourCoinsText:
	text_far _MomIsThisAboutYourCoinsText
	text_end

MomBankWhatDoYouWantToDoText:
	text_far _MomBankWhatDoYouWantToDoText
	text_end

MomStoreCoinsText:
	text_far _MomStoreCoinsText
	text_end

MomTakeCoinsText:
	text_far _MomTakeCoinsText
	text_end

MomSaveCoinsText:
	text_far _MomSaveCoinsText
	text_end

MomHaventSavedThatMuchText:
	text_far _MomHaventSavedThatMuchText
	text_end

MomNotEnoughRoomInWalletText:
	text_far _MomNotEnoughRoomInWalletText
	text_end

MomInsufficientFundsInWalletText:
	text_far _MomInsufficientFundsInWalletText
	text_end

MomNotEnoughRoomInBankText:
	text_far _MomNotEnoughRoomInBankText
	text_end

MomStartSavingCoinsText:
	text_far _MomStartSavingCoinsText
	text_end

MomStoredCoinsText:
	text_far _MomStoredCoinsText
	text_end

MomTakenCoinsText:
	text_far _MomTakenCoinsText
	text_end

MomJustDoWhatYouCanText:
	text_far _MomJustDoWhatYouCanText
	text_end

Mom_SavedString:
	db "SAVED@"

Mon_WithdrawString:
	db "WITHDRAW@"

Mom_DepositString:
	db "DEPOSIT@"

Mom_HeldString:
	db "HELD@"

BankOfMom_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 10
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "GET@"
	db "SAVE@"
	db "CHANGE@"
	db "CANCEL@"
