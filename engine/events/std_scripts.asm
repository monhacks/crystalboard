MACRO add_stdscript
\1StdScript::
	dba \1
ENDM

StdScripts::
	add_stdscript PokecenterNurseScript
	add_stdscript DifficultBookshelfScript
	add_stdscript PictureBookshelfScript
	add_stdscript MagazineBookshelfScript
	add_stdscript TeamRocketOathScript
	add_stdscript IncenseBurnerScript
	add_stdscript MerchandiseShelfScript
	add_stdscript TownMapScript
	add_stdscript WindowScript
	add_stdscript TVScript
	add_stdscript HomepageScript ; unused
	add_stdscript Radio1Script
	add_stdscript Radio2Script
	add_stdscript TrashCanScript
	add_stdscript StrengthBoulderScript
	add_stdscript SmashRockScript
	add_stdscript PokecenterSignScript
	add_stdscript MartSignScript
	add_stdscript GoldenrodRocketsScript
	add_stdscript RadioTowerRocketsScript
	add_stdscript ElevatorButtonScript
	add_stdscript DayToTextScript
	add_stdscript BugContestResultsWarpScript
	add_stdscript BugContestResultsScript
	add_stdscript InitializeEventsScript
	add_stdscript AskNumber1MScript
	add_stdscript AskNumber2MScript
	add_stdscript RegisteredNumberMScript
	add_stdscript NumberAcceptedMScript
	add_stdscript NumberDeclinedMScript
	add_stdscript PhoneFullMScript
	add_stdscript RematchMScript
	add_stdscript GiftMScript
	add_stdscript PackFullMScript
	add_stdscript RematchGiftMScript
	add_stdscript AskNumber1FScript
	add_stdscript AskNumber2FScript
	add_stdscript RegisteredNumberFScript
	add_stdscript NumberAcceptedFScript
	add_stdscript NumberDeclinedFScript
	add_stdscript PhoneFullFScript
	add_stdscript RematchFScript
	add_stdscript GiftFScript
	add_stdscript PackFullFScript
	add_stdscript RematchGiftFScript
	add_stdscript GymStatue1Script
	add_stdscript GymStatue2Script
	add_stdscript ReceiveItemScript
	add_stdscript ReceiveTogepiEggScript
	add_stdscript PCScript
	add_stdscript GameCornerCoinVendorScript
	add_stdscript HappinessCheckScript

PokecenterNurseScript:
	opentext
	checktime MORN
	iftrue .morn
	checktime DAY
	iftrue .day
	checktime EVE
	iftrue .eve
	checktime NITE
	iftrue .nite
	sjump .ok

.morn
	farwritetext NurseMornText
	promptbutton
	sjump .ok

.day
	farwritetext NurseDayText
	promptbutton
	sjump .ok

.eve
	farwritetext NurseEveText
	promptbutton
	sjump .ok

.nite
	farwritetext NurseNiteText
	promptbutton
	sjump .ok

.ok
	farwritetext NurseAskHealText
	yesorno
	iffalse .done

	farwritetext NurseTakePokemonText
	pause 20
	turnobject LAST_TALKED, LEFT
	pause 10
	special HealParty
	playmusic MUSIC_NONE
	setval HEALMACHINE_POKECENTER
	special HealMachineAnim
	pause 30
	special RestartMapMusic
	turnobject LAST_TALKED, DOWN
	pause 10

	checkphonecall ; elm already called about pokerus
	iftrue .no
	checkflag ENGINE_CAUGHT_POKERUS
	iftrue .no
	special CheckPokerus
	iftrue .pokerus
.no

	farwritetext NurseReturnPokemonText
	pause 20

.done
	farwritetext NurseGoodbyeText

	turnobject LAST_TALKED, UP
	pause 10
	turnobject LAST_TALKED, DOWN
	pause 10

	waitbutton
	closetext
	end

.pokerus
	farwritetext NursePokerusText
	waitbutton
	closetext
	setflag ENGINE_CAUGHT_POKERUS
	end

DifficultBookshelfScript:
	farjumptext DifficultBookshelfText

PictureBookshelfScript:
	farjumptext PictureBookshelfText

MagazineBookshelfScript:
	farjumptext MagazineBookshelfText

TeamRocketOathScript:
	farjumptext TeamRocketOathText

IncenseBurnerScript:
	farjumptext IncenseBurnerText

MerchandiseShelfScript:
	farjumptext MerchandiseShelfText

TownMapScript:
	opentext
	farwritetext LookTownMapText
	waitbutton
	special OverworldTownMap
	closetext
	end

WindowScript:
	farjumptext WindowText

TVScript:
	opentext
	farwritetext TVText
	waitbutton
	closetext
	end

HomepageScript:
	farjumptext HomepageText

Radio1Script:
	opentext
	setval MAPRADIO_POKEMON_CHANNEL
	special MapRadio
	closetext
	end

Radio2Script:
; Lucky Channel
	opentext
	setval MAPRADIO_LUCKY_CHANNEL
	special MapRadio
	closetext
	end

TrashCanScript:
	farjumptext TrashCanText

PCScript:
	opentext
	special PokemonCenterPC
	closetext
	end

ElevatorButtonScript:
	playsound SFX_READ_TEXT_2
	pause 15
	playsound SFX_ELEVATOR_END
	end

StrengthBoulderScript:
	farsjump AskStrengthScript

SmashRockScript:
	farsjump AskRockSmashScript

PokecenterSignScript:
	farjumptext PokecenterSignText

MartSignScript:
	farjumptext MartSignText

DayToTextScript:
	readvar VAR_WEEKDAY
	ifequal MONDAY, .Monday
	ifequal TUESDAY, .Tuesday
	ifequal WEDNESDAY, .Wednesday
	ifequal THURSDAY, .Thursday
	ifequal FRIDAY, .Friday
	ifequal SATURDAY, .Saturday
	getstring STRING_BUFFER_3, .SundayText
	end
.Monday:
	getstring STRING_BUFFER_3, .MondayText
	end
.Tuesday:
	getstring STRING_BUFFER_3, .TuesdayText
	end
.Wednesday:
	getstring STRING_BUFFER_3, .WednesdayText
	end
.Thursday:
	getstring STRING_BUFFER_3, .ThursdayText
	end
.Friday:
	getstring STRING_BUFFER_3, .FridayText
	end
.Saturday:
	getstring STRING_BUFFER_3, .SaturdayText
	end
.SundayText:
	db "SUNDAY@"
.MondayText:
	db "MONDAY@"
.TuesdayText:
	db "TUESDAY@"
.WednesdayText:
	db "WEDNESDAY@"
.ThursdayText:
	db "THURSDAY@"
.FridayText:
	db "FRIDAY@"
.SaturdayText:
	db "SATURDAY@"

GoldenrodRocketsScript:
	end

RadioTowerRocketsScript:
	end

BugContestResultsWarpScript:
	special ClearBGPalettes
	scall BugContestResults_CopyContestantsToResults
	applymovement PLAYER, Movement_ContestResults_WalkAfterWarp

BugContestResultsScript:
	clearflag ENGINE_BUG_CONTEST_TIMER
	clearevent EVENT_CONTEST_OFFICER_HAS_SUN_STONE
	clearevent EVENT_CONTEST_OFFICER_HAS_EVERSTONE
	clearevent EVENT_CONTEST_OFFICER_HAS_GOLD_BERRY
	clearevent EVENT_CONTEST_OFFICER_HAS_BERRY
	opentext
	farwritetext ContestResults_ReadyToJudgeText
	waitbutton
	special BugContestJudging
	getnum STRING_BUFFER_3
	ifequal 1, BugContestResults_FirstPlace
	ifequal 2, BugContestResults_SecondPlace
	ifequal 3, BugContestResults_ThirdPlace
	farwritetext ContestResults_ConsolationPrizeText
	promptbutton
	waitsfx
	verbosegiveitem BERRY
	iffalse BugContestResults_NoRoomForBerry

BugContestResults_DidNotWin:
	farwritetext ContestResults_DidNotWinText
	promptbutton
	sjump BugContestResults_FinishUp

BugContestResults_ReturnAfterWinnersPrize:
	farwritetext ContestResults_JoinUsNextTimeText
	promptbutton

BugContestResults_FinishUp:
	checkevent EVENT_LEFT_MONS_WITH_CONTEST_OFFICER
	iffalse BugContestResults_DidNotLeaveMons
	farwritetext ContestResults_ReturnPartyText
	waitbutton
	special ContestReturnMons
BugContestResults_DidNotLeaveMons:
	special CheckPartyFullAfterContest
	ifequal BUGCONTEST_CAUGHT_MON, BugContestResults_CleanUp
	ifequal BUGCONTEST_NO_CATCH, BugContestResults_CleanUp
	; BUGCONTEST_BOXED_MON
	farwritetext ContestResults_PartyFullText
	waitbutton
BugContestResults_CleanUp:
	closetext
	setevent EVENT_BUG_CATCHING_CONTESTANT_1A
	setevent EVENT_BUG_CATCHING_CONTESTANT_2A
	setevent EVENT_BUG_CATCHING_CONTESTANT_3A
	setevent EVENT_BUG_CATCHING_CONTESTANT_4A
	setevent EVENT_BUG_CATCHING_CONTESTANT_5A
	setevent EVENT_BUG_CATCHING_CONTESTANT_6A
	setevent EVENT_BUG_CATCHING_CONTESTANT_7A
	setevent EVENT_BUG_CATCHING_CONTESTANT_8A
	setevent EVENT_BUG_CATCHING_CONTESTANT_9A
	setevent EVENT_BUG_CATCHING_CONTESTANT_10A
	setevent EVENT_BUG_CATCHING_CONTESTANT_1B
	setevent EVENT_BUG_CATCHING_CONTESTANT_2B
	setevent EVENT_BUG_CATCHING_CONTESTANT_3B
	setevent EVENT_BUG_CATCHING_CONTESTANT_4B
	setevent EVENT_BUG_CATCHING_CONTESTANT_5B
	setevent EVENT_BUG_CATCHING_CONTESTANT_6B
	setevent EVENT_BUG_CATCHING_CONTESTANT_7B
	setevent EVENT_BUG_CATCHING_CONTESTANT_8B
	setevent EVENT_BUG_CATCHING_CONTESTANT_9B
	setevent EVENT_BUG_CATCHING_CONTESTANT_10B
	setflag ENGINE_DAILY_BUG_CONTEST
	special PlayMapMusic
	end

BugContestResults_FirstPlace:
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	getitemname STRING_BUFFER_4, SUN_STONE
	farwritetext ContestResults_PlayerWonAPrizeText
	waitbutton
	verbosegiveitem SUN_STONE
	iffalse BugContestResults_NoRoomForSunStone
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_SecondPlace:
	getitemname STRING_BUFFER_4, EVERSTONE
	farwritetext ContestResults_PlayerWonAPrizeText
	waitbutton
	verbosegiveitem EVERSTONE
	iffalse BugContestResults_NoRoomForEverstone
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_ThirdPlace:
	getitemname STRING_BUFFER_4, GOLD_BERRY
	farwritetext ContestResults_PlayerWonAPrizeText
	waitbutton
	verbosegiveitem GOLD_BERRY
	iffalse BugContestResults_NoRoomForGoldBerry
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_NoRoomForSunStone:
	farwritetext BugContestPrizeNoRoomText
	promptbutton
	setevent EVENT_CONTEST_OFFICER_HAS_SUN_STONE
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_NoRoomForEverstone:
	farwritetext BugContestPrizeNoRoomText
	promptbutton
	setevent EVENT_CONTEST_OFFICER_HAS_EVERSTONE
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_NoRoomForGoldBerry:
	farwritetext BugContestPrizeNoRoomText
	promptbutton
	setevent EVENT_CONTEST_OFFICER_HAS_GOLD_BERRY
	sjump BugContestResults_ReturnAfterWinnersPrize

BugContestResults_NoRoomForBerry:
	farwritetext BugContestPrizeNoRoomText
	promptbutton
	setevent EVENT_CONTEST_OFFICER_HAS_BERRY
	sjump BugContestResults_DidNotWin

BugContestResults_CopyContestantsToResults:
	checkevent EVENT_BUG_CATCHING_CONTESTANT_1A
	iftrue .skip1
	clearevent EVENT_BUG_CATCHING_CONTESTANT_1B
.skip1
	checkevent EVENT_BUG_CATCHING_CONTESTANT_2A
	iftrue .skip2
	clearevent EVENT_BUG_CATCHING_CONTESTANT_2B
.skip2
	checkevent EVENT_BUG_CATCHING_CONTESTANT_3A
	iftrue .skip3
	clearevent EVENT_BUG_CATCHING_CONTESTANT_3B
.skip3
	checkevent EVENT_BUG_CATCHING_CONTESTANT_4A
	iftrue .skip4
	clearevent EVENT_BUG_CATCHING_CONTESTANT_4B
.skip4
	checkevent EVENT_BUG_CATCHING_CONTESTANT_5A
	iftrue .skip5
	clearevent EVENT_BUG_CATCHING_CONTESTANT_5B
.skip5
	checkevent EVENT_BUG_CATCHING_CONTESTANT_6A
	iftrue .skip6
	clearevent EVENT_BUG_CATCHING_CONTESTANT_6B
.skip6
	checkevent EVENT_BUG_CATCHING_CONTESTANT_7A
	iftrue .skip7
	clearevent EVENT_BUG_CATCHING_CONTESTANT_7B
.skip7
	checkevent EVENT_BUG_CATCHING_CONTESTANT_8A
	iftrue .skip8
	clearevent EVENT_BUG_CATCHING_CONTESTANT_8B
.skip8
	checkevent EVENT_BUG_CATCHING_CONTESTANT_9A
	iftrue .skip9
	clearevent EVENT_BUG_CATCHING_CONTESTANT_9B
.skip9
	checkevent EVENT_BUG_CATCHING_CONTESTANT_10A
	iftrue .skip10
	clearevent EVENT_BUG_CATCHING_CONTESTANT_10B
.skip10
	end

InitializeEventsScript:
	setevent EVENT_INITIALIZED_EVENTS
	endcallback

AskNumber1MScript:
	special RandomPhoneMon
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackAskNumber1Text
; 	end
; .Huey:
; 	farwritetext HueyAskNumber1Text
; 	end

AskNumber2MScript:
	special RandomPhoneMon
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackAskNumber2Text
; 	end
; .Huey:
; 	farwritetext HueyAskNumber2Text
; 	end

RegisteredNumberMScript:
	farwritetext RegisteredNumber1Text
	playsound SFX_REGISTER_PHONE_NUMBER
	waitsfx
	promptbutton
	end

NumberAcceptedMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackNumberAcceptedText
; 	waitbutton
; 	closetext
; 	end
; .Huey:
; 	farwritetext HueyNumberAcceptedText
; 	waitbutton
; 	closetext
; 	end

NumberDeclinedMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackNumberDeclinedText
; 	waitbutton
; 	closetext
; 	end
; .Huey:
; 	farwritetext HueyNumberDeclinedText
; 	waitbutton
; 	closetext
; 	end

PhoneFullMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackPhoneFullText
; 	waitbutton
; 	closetext
; 	end
; .Huey:
; 	farwritetext HueyPhoneFullText
; 	waitbutton
; 	closetext
; 	end

RematchMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_SCHOOLBOY_JACK, .Jack
	; ifequal PHONE_SAILOR_HUEY, .Huey
	end

; .Jack:
; 	farwritetext JackRematchText
; 	waitbutton
; 	closetext
; 	end
; .Huey:
; 	farwritetext HueyRematchText
; 	waitbutton
; 	closetext
; 	end

GiftMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_BIRDKEEPER_JOSE, .Jose
	; ifequal PHONE_BUG_CATCHER_WADE, .Wade
	end

; .Jose:
; 	farwritetext JoseGiftText
; 	promptbutton
; 	end
; .Wade:
; 	farwritetext WadeGiftText
; 	promptbutton
; 	end

PackFullMScript:
	readvar VAR_CALLERID
	; ifequal PHONE_SAILOR_HUEY, .Huey
	; ifequal PHONE_BIRDKEEPER_JOSE, .Jose
	end

; .Huey:
; 	farwritetext HueyPackFullText
; 	waitbutton
; 	closetext
; 	end
; .Jose:
; 	farwritetext JosePackFullText
; 	waitbutton
; 	closetext
; 	end

RematchGiftMScript:
	opentext
	readvar VAR_CALLERID
	; ifequal PHONE_SAILOR_HUEY, .Huey
	; ifequal PHONE_YOUNGSTER_JOEY, .Joey
	end

; .Huey:
; 	farwritetext HueyRematchGiftText
; 	promptbutton
; 	end
; .Joey:
; 	farwritetext JoeyRematchGiftText
; 	promptbutton
; 	end

AskNumber1FScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	end

; .Beverly:
; 	farwritetext BeverlyAskNumber1Text
; 	end
; .Beth:
; 	farwritetext BethAskNumber1Text
; 	end

AskNumber2FScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	end

; .Beverly:
; 	farwritetext BeverlyAskNumber2Text
; 	end
; .Beth:
; 	farwritetext BethAskNumber2Text
; 	end

RegisteredNumberFScript:
	farwritetext RegisteredNumber2Text
	playsound SFX_REGISTER_PHONE_NUMBER
	waitsfx
	promptbutton
	end

NumberAcceptedFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	end

; .Beverly:
; 	farwritetext BeverlyNumberAcceptedText
; 	waitbutton
; 	closetext
; 	end
; .Beth:
; 	farwritetext BethNumberAcceptedText
; 	waitbutton
; 	closetext
; 	end

NumberDeclinedFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	end

; .Beverly:
; 	farwritetext BeverlyNumberDeclinedText
; 	waitbutton
; 	closetext
; 	end
; .Beth:
; 	farwritetext BethNumberDeclinedText
; 	waitbutton
; 	closetext
; 	end

PhoneFullFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	end

; .Beverly:
; 	farwritetext BeverlyPhoneFullText
; 	waitbutton
; 	closetext
; 	end
; .Beth:
; 	farwritetext BethPhoneFullText
; 	waitbutton
; 	closetext
; 	end

RematchFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_COOLTRAINERF_BETH, .Beth
	; ifequal PHONE_COOLTRAINERF_REENA, .Reena
	end

; .Beth:
; 	farwritetext BethRematchText
; 	waitbutton
; 	closetext
; 	end
; .Reena:
; 	farwritetext ReenaRematchText
; 	waitbutton
; 	closetext
; 	end

GiftFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_PICNICKER_GINA, .Gina
	end

; .Beverly:
; 	farwritetext BeverlyGiftText
; 	promptbutton
; 	end
; .Gina:
; 	farwritetext GinaGiftText
; 	promptbutton
; 	end

PackFullFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_POKEFAN_BEVERLY, .Beverly
	; ifequal PHONE_PICNICKER_GINA, .Gina
	end

; .Beverly:
; 	farwritetext BeverlyPackFullText
; 	waitbutton
; 	closetext
; 	end
; .Gina:
; 	farwritetext GinaPackFullText
; 	waitbutton
; 	closetext
; 	end

RematchGiftFScript:
	readvar VAR_CALLERID
	; ifequal PHONE_PICNICKER_ERIN, .Erin
	end

; .Erin:
; 	opentext
; 	farwritetext ErinRematchGiftText
; 	promptbutton
; 	end

GymStatue1Script:
	getcurlandmarkname STRING_BUFFER_3
	opentext
	farwritetext GymStatue_CityGymText
	waitbutton
	closetext
	end

GymStatue2Script:
	getcurlandmarkname STRING_BUFFER_3
	opentext
	farwritetext GymStatue_CityGymText
	promptbutton
	farwritetext GymStatue_WinningTrainersText
	waitbutton
	closetext
	end

ReceiveItemScript:
	waitsfx
	farwritetext ReceivedItemText
	playsound SFX_ITEM
	waitsfx
	end

ReceiveTogepiEggScript:
	waitsfx
	farwritetext ReceivedItemText
	playsound SFX_GET_EGG
	waitsfx
	end

GameCornerCoinVendorScript:
	faceplayer
	opentext
	farwritetext CoinVendor_WelcomeText
	promptbutton
	checkitem COIN_CASE
	iftrue CoinVendor_IntroScript
	farwritetext CoinVendor_NoCoinCaseText
	waitbutton
	closetext
	end

CoinVendor_IntroScript:
	farwritetext CoinVendor_IntroText

.loop
	special DisplayMoneyAndCoinBalance
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Buy50
	ifequal 2, .Buy500
	sjump .Cancel

.Buy50:
	checkcoins MAX_COINS - 50
	ifequal HAVE_MORE, .CoinCaseFull
	checkmoney YOUR_MONEY, 1000
	ifequal HAVE_LESS, .NotEnoughMoney
	givecoins 50
	takemoney YOUR_MONEY, 1000
	waitsfx
	playsound SFX_TRANSACTION
	farwritetext CoinVendor_Buy50CoinsText
	waitbutton
	sjump .loop

.Buy500:
	checkcoins MAX_COINS - 500
	ifequal HAVE_MORE, .CoinCaseFull
	checkmoney YOUR_MONEY, 10000
	ifequal HAVE_LESS, .NotEnoughMoney
	givecoins 500
	takemoney YOUR_MONEY, 10000
	waitsfx
	playsound SFX_TRANSACTION
	farwritetext CoinVendor_Buy500CoinsText
	waitbutton
	sjump .loop

.NotEnoughMoney:
	farwritetext CoinVendor_NotEnoughMoneyText
	waitbutton
	closetext
	end

.CoinCaseFull:
	farwritetext CoinVendor_CoinCaseFullText
	waitbutton
	closetext
	end

.Cancel:
	farwritetext CoinVendor_CancelText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 4, 15, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db " 50 :  ¥1000@"
	db "500 : ¥10000@"
	db "CANCEL@"

HappinessCheckScript:
	faceplayer
	opentext
	special GetFirstPokemonHappiness
	ifless 50, .Unhappy
	ifless 150, .KindaHappy
	farwritetext HappinessText3
	waitbutton
	closetext
	end

.KindaHappy:
	farwritetext HappinessText2
	waitbutton
	closetext
	end

.Unhappy:
	farwritetext HappinessText1
	waitbutton
	closetext
	end

Movement_ContestResults_WalkAfterWarp:
	step RIGHT
	step DOWN
	turn_head UP
	step_end
