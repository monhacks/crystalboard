; $00-$16 are TX_* constants (see macros/scripts/text.asm)

; Control characters (see home/text.asm)

	charmap "<NULL>",    $00
	charmap "<MOBILE>",  $15
	charmap "<CR>",      $16
	charmap "¯",         $1f ; soft linebreak
	charmap "<LF>",      $22
	charmap "<POKE>",    $24 ; "<PO><KE>"
	charmap "%",         $25 ; soft linebreak in landmark names
	charmap "<RED>",     $38 ; wRedsName
	charmap "<GREEN>",   $39 ; wGreensName
	charmap "<ENEMY>",   $3f
	charmap "<MOM>",     $49 ; wMomsName
	charmap "<PKMN>",    $4a ; "<PK><MN>"
	charmap "<_CONT>",   $4b ; implements "<CONT>"
	charmap "<SCROLL>",  $4c
	charmap "<NEXT>",    $4e
	charmap "<LINE>",    $4f
	charmap "@",         $50 ; string terminator
	charmap "<PARA>",    $51
	charmap "<PLAYER>",  $52 ; wPlayerName
	charmap "<RIVAL>",   $53 ; wRivalName
	charmap "#",         $54 ; "POKé"
	charmap "<CONT>",    $55
	charmap "<……>",      $56 ; "……"
	charmap "<DONE>",    $57
	charmap "<PROMPT>",  $58
	charmap "<TARGET>",  $59
	charmap "<USER>",    $5a
	charmap "<PC>",      $5b ; "PC"
	charmap "<TM>",      $5c ; "TM"
	charmap "<TRAINER>", $5d ; "TRAINER"
	charmap "<ROCKET>",  $5e ; "ROCKET"
	charmap "<DEXEND>",  $5f

; Actual characters (from gfx/font/font_battle_extra.png)

	charmap "<LV>",      $6e

	charmap "<DO>",      $70 ; hiragana small do, unused
	charmap "◀",         $71
	charmap "『",         $72 ; Japanese opening quote, unused
	charmap "<ID>",      $73
	charmap "№",         $74

; Actual characters (from other graphics files)

	; needed for StatsScreen_PlaceShinyIcon and PrintPartyMonPage1
	charmap "⁂",         $3f ; gfx/stats/stats_tiles.png, tile 14

; Actual characters (from gfx/font/font.png)

	charmap " ",         $7f

	charmap "A",         $80
	charmap "B",         $81
	charmap "C",         $82
	charmap "D",         $83
	charmap "E",         $84
	charmap "F",         $85
	charmap "G",         $86
	charmap "H",         $87
	charmap "I",         $88
	charmap "J",         $89
	charmap "K",         $8a
	charmap "L",         $8b
	charmap "M",         $8c
	charmap "N",         $8d
	charmap "O",         $8e
	charmap "P",         $8f
	charmap "Q",         $90
	charmap "R",         $91
	charmap "S",         $92
	charmap "T",         $93
	charmap "U",         $94
	charmap "V",         $95
	charmap "W",         $96
	charmap "X",         $97
	charmap "Y",         $98
	charmap "Z",         $99
	charmap "(",         $9a
	charmap ")",         $9b
	charmap ":",         $9c
	charmap ";",         $9d
	charmap "[",         $9e
	charmap "]",         $9f
	charmap "a",         $a0
	charmap "b",         $a1
	charmap "c",         $a2
	charmap "d",         $a3
	charmap "e",         $a4
	charmap "f",         $a5
	charmap "g",         $a6
	charmap "h",         $a7
	charmap "i",         $a8
	charmap "j",         $a9
	charmap "k",         $aa
	charmap "l",         $ab
	charmap "m",         $ac
	charmap "n",         $ad
	charmap "o",         $ae
	charmap "p",         $af
	charmap "q",         $b0
	charmap "r",         $b1
	charmap "s",         $b2
	charmap "t",         $b3
	charmap "u",         $b4
	charmap "v",         $b5
	charmap "w",         $b6
	charmap "x",         $b7
	charmap "y",         $b8
	charmap "z",         $b9
	charmap "■",         $ba
	charmap "▲",         $bb
	charmap "☎",         $bc
	charmap "“",         $bd
	charmap "”",         $be
	charmap "…",         $bf
	charmap "'d",        $c0
	charmap "'l",        $c1
	charmap "'m",        $c2
	charmap "'r",        $c3
	charmap "'s",        $c4
	charmap "'t",        $c5
	charmap "'v",        $c6
	charmap "′",         $c7
	charmap "″",         $c8
	charmap "¥",         $c9
	charmap "'",         $d0
	charmap "<PK>",      $d1
	charmap "<MN>",      $d2
	charmap "-",         $d3
	charmap "<PO>",      $d4
	charmap "<KE>",      $d5
	charmap "?",         $d6
	charmap "!",         $d7
	charmap ".",         $d8
	charmap "&",         $d9
	charmap "é",         $da
	charmap "→",         $db
	charmap "▷",         $dc
	charmap "▶",         $dd
	charmap "▼",         $de
	charmap "♂",         $df
	charmap "←",         $e0
	charmap "×",         $e1
	; charmap "<DOT>",     $e2 ; decimal point; same as "." in English
	charmap "/",         $e3
	charmap ",",         $e4
	charmap "♀",         $e5
	charmap "0",         $e6
	charmap "1",         $e7
	charmap "2",         $e8
	charmap "3",         $e9
	charmap "4",         $ea
	charmap "5",         $eb
	charmap "6",         $ec
	charmap "7",         $ed
	charmap "8",         $ee
	charmap "9",         $ef

; Textbox frame (from gfx/frame/*)
	charmap "┌",         $f0
	charmap "─",         $f1
	charmap "┐",         $f2
	charmap "│",         $f3
	charmap "└",         $f4
	charmap "┘",         $f5

; ASCII charmap, for mobile functions
pushc
	newcharmap ascii
	DEF PRINTABLE_ASCII EQUS " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz\{|}~"
	for i, STRLEN("{PRINTABLE_ASCII}")
		charmap STRSUB("{PRINTABLE_ASCII}", i + 1, 1), i + $20
	endr
	charmap "\t", $09
	charmap "\n", $0a
	charmap "\r", $0d
popc

; Significant tile equivalences
DEF OVERWORLD_FRAME_FIRST_TILE EQU "┌"
DEF BOARD_MENU_BG_FIRST_TILE EQU "A"
DEF BOARD_MENU_OAM_FIRST_TILE EQU BOARD_MENU_BG_FIRST_TILE + 18 * 3
