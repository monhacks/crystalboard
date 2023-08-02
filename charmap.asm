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

; Actual characters (from gfx/font/font_extra.png)

	; charmap "<BOLD_A>",  $60 ; unused
	; charmap "<BOLD_B>",  $61 ; unused
	; charmap "<BOLD_C>",  $62 ; unused
	; charmap "<BOLD_D>",  $63 ; unused
	; charmap "<BOLD_E>",  $64 ; unused
	; charmap "<BOLD_F>",  $65 ; unused
	; charmap "<BOLD_G>",  $66 ; unused
	; charmap "<BOLD_H>",  $67 ; unused
	; charmap "<BOLD_I>",  $68 ; unused
	; charmap "<BOLD_V>",  $69 ; unused
	; charmap "<BOLD_S>",  $6a ; unused
	; charmap "<BOLD_L>",  $6b ; unused
	; charmap "<BOLD_M>",  $6c ; unused
	; charmap "<COLON>",   $6d ; unused (colon with tinier dots than ":")
	; charmap "ぃ",         $6e ; hiragana small i, unused
	; charmap "ぅ",         $6f ; hiragana small u, unused
	charmap "<PO>",      $63
	charmap "<KE>",      $64
	charmap "“",         $65 ; opening quote
	charmap "”",         $66 ; closing quote
	; charmap "·",         $74 ; middle dot, unused
	charmap "…",         $67 ; ellipsis
	; charmap "ぁ",         $76 ; hiragana small a, unused
	; charmap "ぇ",         $77 ; hiragana small e, unused
	; charmap "ぉ",         $78 ; hiragana small o, unused

	charmap "┌",         $79
	charmap "─",         $7a
	charmap "┐",         $7b
	charmap "│",         $7c
	charmap "└",         $7d
	charmap "┘",         $7e
	charmap " ",         $7f

; Actual characters (from gfx/font/font_battle_extra.png)

	charmap "<LV>",      $6e

	charmap "<DO>",      $70 ; hiragana small do, unused
	charmap "◀",         $71
	charmap "『",         $72 ; Japanese opening quote, unused
	charmap "<ID>",      $73
	charmap "№",         $74

; Actual characters (from other graphics files)

	; needed for _LoadFontsExtra1 (see engine/gfx/load_font.asm)
	charmap "■",         $60 ; gfx/font/black.2bpp
	charmap "▲",         $61 ; gfx/font/up_arrow.png
	charmap "☎",         $62 ; gfx/font/phone_icon.2bpp

	; needed for MagikarpHouseSign (see engine/events/magikarp.asm)
	charmap "′",         $6e ; gfx/font/feet_inches.png
	charmap "″",         $6f ; gfx/font/feet_inches.png

	; needed for StatsScreen_PlaceShinyIcon and PrintPartyMonPage1
	charmap "⁂",         $3f ; gfx/stats/stats_tiles.png, tile 14

; Actual characters (from gfx/font/font.png)

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

	; charmap "Ä",         $c0
	; charmap "Ö",         $c1
	; charmap "Ü",         $c2
	; charmap "ä",         $c3
	; charmap "ö",         $c4
	; charmap "ü",         $c5

	charmap "'d",        $d0
	charmap "'l",        $d1
	charmap "'m",        $d2
	charmap "'r",        $d3
	charmap "'s",        $d4
	charmap "'t",        $d5
	charmap "'v",        $d6

	charmap "←",         $df
	charmap "'",         $e0
	charmap "<PK>",      $e1
	charmap "<MN>",      $e2
	charmap "-",         $e3

	charmap "?",         $e6
	charmap "!",         $e7
	charmap ".",         $e8
	charmap "&",         $e9

	charmap "é",         $ea
	charmap "→",         $eb
	charmap "▷",         $ec
	charmap "▶",         $ed
	charmap "▼",         $ee
	charmap "♂",         $ef
	charmap "¥",         $f0
	charmap "×",         $f1
	; charmap "<DOT>",     $f2 ; decimal point; same as "." in English
	charmap "/",         $f3
	charmap ",",         $f4
	charmap "♀",         $f5

	charmap "0",         $f6
	charmap "1",         $f7
	charmap "2",         $f8
	charmap "3",         $f9
	charmap "4",         $fa
	charmap "5",         $fb
	charmap "6",         $fc
	charmap "7",         $fd
	charmap "8",         $fe
	charmap "9",         $ff

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
