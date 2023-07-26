MACRO four_pals
	dw PREDEFPAL_\1, PREDEFPAL_\2, PREDEFPAL_\3, PREDEFPAL_\4
ENDM

FourPals_MagnetTrain:
	four_pals BETA_SHINY_GREENMON, CGB_BADGE, RB_BROWNMON, ROUTES

FourPals_UnownPuzzle:
	four_pals UNOWN_PUZZLE, UNOWN_PUZZLE, UNOWN_PUZZLE, UNOWN_PUZZLE

FourPals_Pack:
	four_pals PACK, ROUTES, ROUTES, ROUTES

FourPals_BetaPikachuMinigame:
	four_pals GS_INTRO_JIGGLYPUFF_PIKACHU_OB, ROUTES, ROUTES, ROUTES

FourPals_PartyMenu:
	four_pals PARTY_ICON, HP_GREEN, HP_YELLOW, HP_RED

FourPals_BattleGrayscale:
	four_pals BLACKOUT, BLACKOUT, BLACKOUT, BLACKOUT

FourPals_BetaTitleScreen:
	four_pals BETA_LOGO_1, BETA_LOGO_2, DIPLOMA, RB_PURPLEMON

FourPals_Diploma:
	four_pals DIPLOMA, ROUTES, ROUTES, ROUTES

FourPals_TradeTube:
	four_pals TRADE_TUBE, ROUTES, ROUTES, ROUTES
