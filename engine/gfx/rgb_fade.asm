; at normal speed:
; each color takes around 3.2 scanlines to fade
; up to 10 (11?) colors can be faded per frame

FadeStepColorsToBlack:
.loop
	push de
	push bc
	call FadeStepColorToBlack
	pop bc
	pop de
	inc de
	inc de
	dec c
	jr nz, .loop
	ret

FadeStepColorsToDarker:
; decrease rgb channels of a color by 2 points each
; input
;	 c: number of consecutive colors to fade
;   de: pointer to c long array of 2-byte rgb colors to fade
;   hl: pointer to c long array of 2-byte rgb colors with cap values for each channel
.loop
	push hl
	push de
	push bc
	call FadeStepColorToDarker
	pop bc
	pop de
	pop hl
	inc de
	inc de
	inc hl
	inc hl
	dec c
	jr nz, .loop
	ret

FadeStepColorToBlack:
	ld hl, BlackRGB
	; fallthrough

FadeStepColorToDarker:
; decrease rgb channels of a color by 2 points each
; input
;   de: pointer to 2-byte rgb color to fade
;   hl: pointer to 2-byte rgb color with cap values for each channel
	push de

; convert source and cap colors to channels
	push hl
	ld hl, hRGBFadeSourceChannels
	call RGBColorToChannels
	pop de
	ld hl, hRGBFadeCapChannels
	call RGBColorToChannels

; apply fading to source channels accounting for caps
	ldh a, [hRGBFadeCapRChannel]
	ld b, a
	ldh a, [hRGBFadeSourceRChannel]
	sub 2
	jr c, .nok1
	cp b
	jr nc, .ok1
.nok1
	ld a, b
.ok1
	ldh [hRGBFadeSourceRChannel], a
	ldh a, [hRGBFadeCapGChannel]
	ld b, a
	ldh a, [hRGBFadeSourceGChannel]
	sub 2
	jr c, .nok2
	cp b
	jr nc, .ok2
.nok2
	ld a, b
.ok2
	ldh [hRGBFadeSourceGChannel], a
	ldh a, [hRGBFadeCapBChannel]
	ld b, a
	ldh a, [hRGBFadeSourceBChannel]
	sub 2
	jr c, .nok3
	cp b
	jr nc, .ok3
.nok3
	ld a, b
.ok3
	ldh [hRGBFadeSourceBChannel], a

; convert faded source channels to color
	pop de

	ld hl, hRGBFadeSourceChannels
	call RGBChannelsToColor
	ret

FadeStepColorsToWhite:
	ld hl, WhiteRGB
.loop
	push de
	push bc
	call FadeStepColorToWhite
	pop bc
	pop de
	inc de
	inc de
	dec c
	jr nz, .loop
	ret

FadeStepColorsToLighter:
; increase rgb channels of a color by 2 points each
; input
;	 c: number of consecutive colors to fade
;   de: pointer to c long array of 2-byte rgb colors to fade
;   hl: pointer to c long array of 2-byte rgb colors with cap values for each channel
.loop
	push hl
	push de
	push bc
	call FadeStepColorToLighter
	pop bc
	pop de
	pop hl
	inc de
	inc de
	inc hl
	inc hl
	dec c
	jr nz, .loop
	ret

FadeStepColorToWhite:
	ld hl, WhiteRGB
	; fallthrough

FadeStepColorToLighter:
; increase rgb channels of a color by 2 points each
; input
;   de: pointer to 2-byte rgb color to fade
;   hl: pointer to 2-byte rgb color with cap values for each channel
	push de

; convert source and cap colors to channels
	push hl
	ld hl, hRGBFadeSourceChannels
	call RGBColorToChannels
	pop de
	ld hl, hRGBFadeCapChannels
	call RGBColorToChannels

; apply fading to source channels accounting for caps
	ldh a, [hRGBFadeCapRChannel]
	ld b, a
	ldh a, [hRGBFadeSourceRChannel]
	add 2
	cp b
	jr c, .ok1
	ld a, b
.ok1
	ldh [hRGBFadeSourceRChannel], a
	ldh a, [hRGBFadeCapGChannel]
	ld b, a
	ldh a, [hRGBFadeSourceGChannel]
	add 2
	cp b
	jr c, .ok2
	ld a, b
.ok2
	ldh [hRGBFadeSourceGChannel], a
	ldh a, [hRGBFadeCapBChannel]
	ld b, a
	ldh a, [hRGBFadeSourceBChannel]
	add 2
	cp b
	jr c, .ok3
	ld a, b
.ok3
	ldh [hRGBFadeSourceBChannel], a

; convert faded source channels to color
	pop de

	ld hl, hRGBFadeSourceChannels
	call RGBChannelsToColor
	ret

RGBColorToChannels:
; convert 2-byte rgb color at de to rgb channels into hl
; red channel
	ld a, [de]
	ld c, a
	and %00011111
	ld [hli], a
; green channel
	inc de
	ld a, [de]
	and %00000011
	swap a
	srl a
	ld b, a ; 000gg000
	ld a, c
	and %11100000
	swap a
	srl a ; 00000ggg
	add b
	ld [hli], a
; blue channel
	ld a, [de]
	and %01111100
	srl a
	srl a
	ld [hl], a
	ret

RGBChannelsToColor:
; convert rgb channels at hl to 2-byte rgb color into de
; first byte: gggrrrrr
	ld a, [hli]
	ld c, a
	ld a, [hl]
	and %00000111
	swap a
	sla a
	add c
	ld [de], a
; second byte: 0bbbbbgg
	inc de
	ld a, [hli]
	and %00011000
	srl a
	srl a
	srl a
	ld c, a
	ld a, [hl]
	sla a
	sla a
	add c
	ld [de], a
	ret

BlackRGB:
	RGB 00, 00, 00

WhiteRGB:
	RGB 31, 31, 31