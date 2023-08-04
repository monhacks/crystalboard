_InitMG_Mobile_LinkTradePalMap:
	hlcoord 0, 0, wAttrmap
	lb bc, 16, 2
	ld a, $4
	call FillBoxCGB
	ld a, $3
	ldcoord_a 0, 1, wAttrmap
	ldcoord_a 0, 14, wAttrmap
	hlcoord 2, 0, wAttrmap
	lb bc, 8, 18
	ld a, $5
	call FillBoxCGB
	hlcoord 2, 8, wAttrmap
	lb bc, 8, 18
	ld a, $6
	call FillBoxCGB
	hlcoord 0, 16, wAttrmap
	lb bc, 2, SCREEN_WIDTH
	ld a, $4
	call FillBoxCGB
	ld a, $3
	lb bc, 6, 1
	hlcoord 6, 1, wAttrmap
	call FillBoxCGB
	ld a, $3
	lb bc, 6, 1
	hlcoord 17, 1, wAttrmap
	call FillBoxCGB
	ld a, $3
	lb bc, 6, 1
	hlcoord 6, 9, wAttrmap
	call FillBoxCGB
	ld a, $3
	lb bc, 6, 1
	hlcoord 17, 9, wAttrmap
	call FillBoxCGB
	ld a, $2
	hlcoord 2, 16, wAttrmap
	ld [hli], a
	ld a, $7
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld a, $2
	ld [hl], a
	hlcoord 2, 17, wAttrmap
	ld a, $3
	ld bc, 6
	call ByteFill
	ret

_LoadTradeRoomBGPals:
	ld hl, TradeRoomPalette
	ld de, wBGPals1 palette PAL_BG_GREEN
	ld bc, 6 palettes
	ld a, BANK(wBGPals1)
	call FarCopyWRAM
	farcall ApplyPals
	ret

TradeRoomPalette:
INCLUDE "gfx/trade/border.pal"

InitMG_Mobile_LinkTradePalMap:
	call _InitMG_Mobile_LinkTradePalMap
	ret
