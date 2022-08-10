; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Palmtree Panic Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

	org	PCMDriver
	dc.b	"SNCBNK25.S28    "
	include	"Sound Drivers/PCM/_Driver.asm"

; -------------------------------------------------------------------------
; Sound effect index
; -------------------------------------------------------------------------

SFXIndex:
	dc.l	SFX_Unknown
	dc.l	SFX_Future
	dc.l	SFX_Past
	dc.l	SFX_Alright
	dc.l	SFX_OuttaHere
	dc.l	SFX_Yes
	dc.l	SFX_Yeah
	dc.l	SFX_AmyGiggle
	dc.l	SFX_AmyYelp
	dc.l	SFX_BossStomp
	dc.l	SFX_Bumper

; -------------------------------------------------------------------------
; Song priority table
; -------------------------------------------------------------------------

SongPriorities:
	dc.b	$80				; Palmtree Panic Zone Past
	dc.b	$80				; Invalid
	dc.b	$80				; Invalid
	even

; -------------------------------------------------------------------------
; Sound effect priority table
; -------------------------------------------------------------------------

SFXPriorities:
	dc.b	$70				; Unknown
	dc.b	$70				; "Future"
	dc.b	$70				; "Past"
	dc.b	$70				; "Alright"
	dc.b	$70				; "I'm outta here"
	dc.b	$70				; "Yes"
	dc.b	$70				; "Yeah"
	dc.b	$70				; Amy giggle
	dc.b	$70				; Amy yelp
	dc.b	$70				; Boss stomp
	dc.b	$70				; Bumper
	even

; -------------------------------------------------------------------------
; Command priority table
; -------------------------------------------------------------------------

CmdPriorities:
	dc.b	$80				; Fade out
	dc.b	$80				; Stop
	dc.b	$80				; Pause
	dc.b	$80				; Unpause
	dc.b	$80				; Mute
	even

; -------------------------------------------------------------------------
; Song index
; -------------------------------------------------------------------------

SongIndex:
	dc.l	Song_PPZPast

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_PPZPast:
	incbin	"Sound Drivers/PCM/Music/Palmtree Panic Past.bin"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Palmtree Panic).asm"
	even
SFX_Future:
	include	"Sound Drivers/PCM/SFX/Future.asm"
	even
SFX_Past:
	include	"Sound Drivers/PCM/SFX/Past.asm"
	even
SFX_Alright:
	include	"Sound Drivers/PCM/SFX/Alright.asm"
	even
SFX_OuttaHere:
	include	"Sound Drivers/PCM/SFX/Outta Here.asm"
	even
SFX_Yes:
	include	"Sound Drivers/PCM/SFX/Yes.asm"
	even
SFX_Yeah:
	include	"Sound Drivers/PCM/SFX/Yeah.asm"
	even
SFX_AmyGiggle:
	include	"Sound Drivers/PCM/SFX/Amy Giggle.asm"
	even
SFX_AmyYelp:
	include	"Sound Drivers/PCM/SFX/Amy Yelp.asm"
	even
SFX_BossStomp:
	include	"Sound Drivers/PCM/SFX/Boss Stomp.asm"
	even
SFX_Bumper:
	include	"Sound Drivers/PCM/SFX/Blank 1.asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	DrumLoop
	SAMPPTR	Bass
	SAMPPTR	Flute
	SAMPPTR	Piano
	SAMPPTR	TomDrum
	SAMPPTR	ElecPianoLow
	SAMPPTR	ElecPianoHigh
	SAMPPTR	Strings
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	BossStomp
	SAMPPTR	AmyGiggle
	SAMPPTR	AmyYelp
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	DrumLoop,	$0000, 0, 0, 0
	SAMPLE	Bass,		$0000, 0, 0, 0
	SAMPLE	Flute,		$0FA3, 0, 0, 0
	SAMPLE	Piano,		$22CD, 0, 0, 0
	SAMPLE	TomDrum,	$0000, 0, 0, 0
	SAMPLE	ElecPianoLow,	$2EE9, 0, 0, 0
	SAMPLE	ElecPianoHigh,	$3240, 0, 0, 0
	SAMPLE	Strings,	$06CC, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	BossStomp,	$0000, 0, 0, 0
	SAMPLE	AmyGiggle,	$0000, 0, 0, 0
	SAMPLE	AmyYelp,	$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	DrumLoop,	"Sound Drivers/PCM/Samples/Palmtree Panic/Drum Loop.bin"
	even
	SAMPDAT	Bass,		"Sound Drivers/PCM/Samples/Palmtree Panic/Bass.bin"
	even
	SAMPDAT	Flute,		"Sound Drivers/PCM/Samples/Palmtree Panic/Flute.bin"
	even
	SAMPDAT	Piano,		"Sound Drivers/PCM/Samples/Palmtree Panic/Piano.bin"
	even
	SAMPDAT	TomDrum,	"Sound Drivers/PCM/Samples/Palmtree Panic/Tom Drum.bin"
	even
	SAMPDAT	ElecPianoLow,	"Sound Drivers/PCM/Samples/Palmtree Panic/Electric Piano (Low).bin"
	even
	SAMPDAT	ElecPianoHigh,	"Sound Drivers/PCM/Samples/Palmtree Panic/Electric Piano (High).bin"
	even
	SAMPDAT	Strings,	"Sound Drivers/PCM/Samples/Palmtree Panic/Strings.bin"
	even
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	BossStomp,	"Sound Drivers/PCM/Samples/Boss Stomp.bin"
	SAMPDAT	AmyGiggle,	"Sound Drivers/PCM/Samples/Amy Giggle.bin"
	SAMPDAT	AmyYelp,	"Sound Drivers/PCM/Samples/Amy Yelp.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"

; -------------------------------------------------------------------------
