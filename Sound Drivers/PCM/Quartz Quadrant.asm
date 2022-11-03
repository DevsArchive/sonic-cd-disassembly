; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Quartz Quadrant Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK29.S28    "
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
	dc.l	SFX_MechStomp
	dc.l	SFX_Bumper

; -------------------------------------------------------------------------
; Song priority table
; -------------------------------------------------------------------------

SongPriorities:
	dc.b	$80				; Quartz Quadrant Zone Past
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
	dc.b	$70				; Mech stomp
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
	dc.l	Song_QQZPast

; -------------------------------------------------------------------------
; Unknown data
; -------------------------------------------------------------------------

UnkIndex:
	dc.l	.0-UnkIndex
	dc.l	.1-UnkIndex
	
.0:
	dc.b	0, 4, 3, $80, $FF, $7F
	
.1:
	dc.b	1, $A, 3, $80, $FF, $7F

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_QQZPast:
	include	"Sound Drivers/PCM/Music/Quartz Quadrant Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Quartz Quadrant).asm"
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
	include	"Sound Drivers/PCM/SFX/Blank 2.asm"
	even
SFX_AmyYelp:
	include	"Sound Drivers/PCM/SFX/Blank 2.asm"
	even
SFX_MechStomp:
	include	"Sound Drivers/PCM/SFX/Blank 2.asm"
	even
SFX_Bumper:
	include	"Sound Drivers/PCM/SFX/Blank 2.asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	Kick
	SAMPPTR	Snare
	SAMPPTR	Cabasa
	SAMPPTR	Cowbell
	SAMPPTR	Bass
	SAMPPTR	LogDrum
	SAMPPTR	PianoChord1
	SAMPPTR	PianoChord2
	SAMPPTR	PianoHigh
	SAMPPTR	PianoLow
	SAMPPTR	ToyPiano
	SAMPPTR	Choir
	SAMPPTR	Cymbal
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Kick,		$0000, 8, 0, 0
	SAMPLE	Snare,		$0000, 8, 0, 0
	SAMPLE	Cabasa,		$0000, 6, 0, 0
	SAMPLE	Cowbell,	$0000, 9, 0, 0
	SAMPLE	Bass,		$0000, 0, 0, 0
	SAMPLE	LogDrum,	$22C8, 0, 0, 0
	SAMPLE	PianoChord1,	$0000, 0, 0, 0
	SAMPLE	PianoChord2,	$0000, 0, 0, 0
	SAMPLE	PianoHigh,	$0000, 0, 0, 0
	SAMPLE	PianoLow,	$0000, 0, 0, 0
	SAMPLE	ToyPiano,	$2300, 0, 0, 0
	SAMPLE	Choir,		$0000, 0, 0, 0
	SAMPLE	Cymbal,		$2B00, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Kick,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Kick.bin"
	SAMPDAT	Snare,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Snare.bin"
	SAMPDAT	Cabasa,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Cabasa.bin"
	SAMPDAT	Cowbell,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Cowbell.bin"
	SAMPDAT	Bass,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Bass.bin"
	SAMPDAT	LogDrum,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Log Drum.bin"
	SAMPDAT	PianoChord1,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Piano Chord 1.bin"
	SAMPDAT	PianoChord2,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Piano Chord 2.bin"
	SAMPDAT	PianoHigh,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Piano (High).bin"
	SAMPDAT	PianoLow,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Piano (Low).bin"
	SAMPDAT	ToyPiano,	"Sound Drivers/PCM/Samples/Quartz Quadrant/Toy Piano.bin"
	SAMPDAT	Choir,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Choir.bin"
	SAMPDAT	Cymbal,		"Sound Drivers/PCM/Samples/Quartz Quadrant/Cymbal.bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"

; -------------------------------------------------------------------------
