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
	include	"Sound Drivers/SMPS-PCM/_Driver.asm"

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
	dc.b	$70				; Music loop (unused)
	dc.b	$70				; "Future"
	dc.b	$70				; "Past"
	dc.b	$70				; "Alright"
	dc.b	$70				; "I'm outta here"
	dc.b	$70				; "Yes"
	dc.b	$70				; "Yeah"
	dc.b	$70				; Amy giggle
	dc.b	$70				; Amy yelp
	dc.b	$70				; Boss stomp
	dc.b	$70				; Bumper (invalid)
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
	incbin	"Sound Drivers/SMPS-PCM/Music/Palmtree Panic Past.bin"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Unknown.bin"
	even
SFX_Future:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Future.bin"
	even
SFX_Past:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Past.bin"
	even
SFX_Alright:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Alright.bin"
	even
SFX_OuttaHere:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Outta Here.bin"
	even
SFX_Yes:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Yes.bin"
	even
SFX_Yeah:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Yeah.bin"
	even
SFX_AmyGiggle:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Amy Giggle.bin"
	even
SFX_AmyYelp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Amy Yelp.bin"
	even
SFX_BossStomp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Boss Stomp.bin"
	even
SFX_Bumper:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Bumper.bin"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	dc.l	Samp_DrumLoop_Metadata
	dc.l	Samp_Bass_Metadata
	dc.l	Samp_Flute_Metadata
	dc.l	Samp_Piano_Metadata
	dc.l	Samp_TomDrum_Metadata
	dc.l	Samp_ElecPianoLow_Metadata
	dc.l	Samp_ElecPianoHigh_Metadata
	dc.l	Samp_Strings_Metadata
	dc.l	Samp_Future_Metadata
	dc.l	Samp_Past_Metadata
	dc.l	Samp_BossStomp_Metadata
	dc.l	Samp_AmyGiggle_Metadata
	dc.l	Samp_AmyYelp_Metadata
	dc.l	Samp_Alright_Metadata
	dc.l	Samp_OuttaHere_Metadata
	dc.l	Samp_Yes_Metadata
	dc.l	Samp_Yeah_Metadata
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Samp_DrumLoop,		$0000, 0, 0, 0
	SAMPLE	Samp_Bass,		$0000, 0, 0, 0
	SAMPLE	Samp_Flute,		$0FA3, 0, 0, 0
	SAMPLE	Samp_Piano,		$22CD, 0, 0, 0
	SAMPLE	Samp_TomDrum,		$0000, 0, 0, 0
	SAMPLE	Samp_ElecPianoLow,	$2EE9, 0, 0, 0
	SAMPLE	Samp_ElecPianoHigh,	$3240, 0, 0, 0
	SAMPLE	Samp_Strings,		$06CC, 0, 0, 0
	SAMPLE	Samp_Future,		$0000, 0, 0, 0
	SAMPLE	Samp_Past,		$0000, 0, 0, 0
	SAMPLE	Samp_BossStomp,		$0000, 0, 0, 0
	SAMPLE	Samp_AmyGiggle,		$0000, 0, 0, 0
	SAMPLE	Samp_AmyYelp,		$0000, 0, 0, 0
	SAMPLE	Samp_Alright,		$0000, 0, 0, 0
	SAMPLE	Samp_OuttaHere,		$0000, 0, 0, 0
	SAMPLE	Samp_Yes,		$0000, 0, 0, 0
	SAMPLE	Samp_Yeah,		$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Samp_DrumLoop,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Drum Loop.bin"
	even
	SAMPDAT	Samp_Bass,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Bass.bin"
	even
	SAMPDAT	Samp_Flute,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Flute.bin"
	even
	SAMPDAT	Samp_Piano,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Piano.bin"
	even
	SAMPDAT	Samp_TomDrum,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Tom Drum.bin"
	even
	SAMPDAT	Samp_ElecPianoLow,	"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Electric Piano (Low).bin"
	even
	SAMPDAT	Samp_ElecPianoHigh,	"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Electric Piano (High).bin"
	even
	SAMPDAT	Samp_Strings,		"Sound Drivers/SMPS-PCM/Samples/Palmtree Panic/Strings.bin"
	even

	SAMPDAT	Samp_Future,		"Sound Drivers/SMPS-PCM/Samples/Future.bin"
	SAMPDAT	Samp_Past,		"Sound Drivers/SMPS-PCM/Samples/past.bin"
	SAMPDAT	Samp_BossStomp,		"Sound Drivers/SMPS-PCM/Samples/Boss Stomp.bin"
	SAMPDAT	Samp_AmyGiggle,		"Sound Drivers/SMPS-PCM/Samples/Amy Giggle.bin"
	SAMPDAT	Samp_AmyYelp,		"Sound Drivers/SMPS-PCM/Samples/Amy Yelp.bin"
	SAMPDAT	Samp_Alright,		"Sound Drivers/SMPS-PCM/Samples/Alright.bin"
	SAMPDAT	Samp_OuttaHere,		"Sound Drivers/SMPS-PCM/Samples/Outta Here.bin"
	SAMPDAT	Samp_Yes,		"Sound Drivers/SMPS-PCM/Samples/Yes.bin"
	SAMPDAT	Samp_Yeah,		"Sound Drivers/SMPS-PCM/Samples/Yeah.bin"

; -------------------------------------------------------------------------
