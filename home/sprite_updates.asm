DisableSpriteUpdates::
	xor a
	ldh [hMapAnims], a
	ld a, [wStateFlags]
	res 0, a
	ld [wStateFlags], a
	ld a, $0
	ld [wSpriteUpdatesEnabled], a
	ret

EnableSpriteUpdates::
	ld a, $1
	ld [wSpriteUpdatesEnabled], a
	ld a, [wStateFlags]
	set 0, a
	ld [wStateFlags], a
	ld a, $1
	ldh [hMapAnims], a
	ret
