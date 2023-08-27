; Functions to fade the screen in and out.

RotateFourPalettesRight::
	ld hl, IncGradGBPalTable_00
	ld b, 4
	jr RotatePalettesRight

RotateThreePalettesRight::
	ld hl, IncGradGBPalTable_05
	ld b, 3
RotatePalettesRight::
; Rotate palettes to the right and fill with loaded colors from the left
; If we're already at the leftmost color, fill with the leftmost color
	push de
	ld a, [hli]
	call DmgToCgbBGPals
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	call DmgToCgbObjPals
	ld c, 8
	call DelayFrames
	pop de
	dec b
	jr nz, RotatePalettesRight
	ret

RotateFourPalettesLeft::
	ld hl, IncGradGBPalTable_04 - 1
	ld b, 4
	jr RotatePalettesLeft

RotateThreePalettesLeft::
	ld hl, IncGradGBPalTable_07 - 1
	ld b, 3
RotatePalettesLeft::
; Rotate palettes to the left and fill with loaded colors from the right
; If we're already at the rightmost color, fill with the rightmost color
	push de
	ld a, [hld]
	ld d, a
	ld a, [hld]
	ld e, a
	call DmgToCgbObjPals
	ld a, [hld]
	call DmgToCgbBGPals
	ld c, 8
	call DelayFrames
	pop de
	dec b
	jr nz, RotatePalettesLeft
	ret

IncGradGBPalTable_00:: dc 3,3,3,3, 3,3,3,3, 3,3,3,3
IncGradGBPalTable_01:: dc 3,3,3,2, 3,3,3,2, 3,3,3,2
IncGradGBPalTable_02:: dc 3,3,2,1, 3,3,2,1, 3,3,2,1
IncGradGBPalTable_03:: dc 3,2,1,0, 3,2,1,0, 3,2,1,0

IncGradGBPalTable_04:: dc 3,2,1,0, 3,2,1,0, 3,2,1,0
IncGradGBPalTable_05:: dc 2,1,0,0, 2,1,0,0, 2,1,0,0
IncGradGBPalTable_06:: dc 1,0,0,0, 1,0,0,0, 1,0,0,0

IncGradGBPalTable_07:: dc 0,0,0,0, 0,0,0,0, 0,0,0,0

DoRGBFadeEffect::
	farcall _DoRGBFadeEffect
	ret
