DefaultOptions:
; wOptions: med text speed
	db TEXT_DELAY_MED
; wSaveFileExists: no
	db FALSE
; wTextboxFrame: frame 1
	db FRAME_1
; wTextboxFlags: use text speed
	db 1 << FAST_TEXT_DELAY_F
; wGBPrinterBrightness: normal
	db GBPRINTER_NORMAL
; wOptions2: menu account on
	db 1 << MENU_ACCOUNT
.End
	assert DefaultOptions.End - DefaultOptions == wOptionsEnd - wOptions
