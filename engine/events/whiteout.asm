Script_BattleWhiteout::
	callasm BattleBGMap
	sjump Script_Whiteout

OverworldWhiteoutScript::
	refreshscreen
	callasm OverworldBGMap

Script_Whiteout:
	writetext .WhitedOutText
	waitbutton
	special FadeOutPalettesToWhite
	pause 40
	special HealParty
	checkflag ENGINE_BUG_CONTEST_TIMER
	iftrue .bug_contest
	callasm HalveCoins
	farscall Script_AbortBugContest
	exitoverworld WHITED_OUT_IN_LEVEL
	endall

.bug_contest
	jumpstd BugContestResultsWarpScript

.WhitedOutText:
	text_far _WhitedOutText
	text_end

OverworldBGMap:
	call ClearPalettes
	call ClearScreen
	call WaitBGMap2
	call DisableOverworldHUD
	xor a
	ld [wDisplaySecondarySprites], a
	farcall ClearSpriteAnims
	call ClearSprites
	call LoadStandardFont
	call LoadFrame
	call RotateThreePalettesLeft
	ld a, FALSE
	ld [wText2bpp], a
	jp SpeechTextbox1bpp

BattleBGMap:
	ld b, CGB_BATTLE_GRAYSCALE
	call GetCGBLayout
	call SetPalettes
	ret

HalveCoins:
; Halve the player's coins.
	ld hl, wCoins
	ld a, [hl]
	srl a
	ld [hli], a
	ld a, [hl]
	rra
	ld [hli], a
	ld a, [hl]
	rra
	ld [hl], a
	ret

GetWhiteoutSpawn:
	ld a, [wLastSpawnMapGroup]
	ld d, a
	ld a, [wLastSpawnMapNumber]
	ld e, a
	farcall IsSpawnPoint
	ld a, c
	jr c, .yes
	xor a ; SPAWN_LEVEL_1

.yes
	ld [wDefaultSpawnpoint], a
	ret
