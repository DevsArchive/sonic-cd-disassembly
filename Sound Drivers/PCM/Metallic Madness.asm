; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Metallic Madness Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK32.S28    "
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
	dc.b	$80				; Metallic Madness Zone Past
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
	dc.l	Song_MMZPast

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_MMZPast:
	include	"Sound Drivers/PCM/Music/Metallic Madness Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Metallic Madness).asm"
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
	include	"Sound Drivers/PCM/SFX/Mech Stomp.asm"
	even
SFX_Bumper:
	include	"Sound Drivers/PCM/SFX/Bumper (Metallic Madness).asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	Fantasia
	SAMPPTR	Kick1
	SAMPPTR	Snare1
	SAMPPTR	Bass
	SAMPPTR	Snare2
	SAMPPTR	OrchHit1
	SAMPPTR	Synth
	SAMPPTR	Woosh
	SAMPPTR	PianoChord1
	SAMPPTR	PianoChord2
	SAMPPTR	Piano
	SAMPPTR	OrchHitCrash
	SAMPPTR	Pad
	SAMPPTR	OrchHit2
	SAMPPTR	Snare3
	SAMPPTR	Kick2
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPPTR	MechStomp
	SAMPPTR	Bumper
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Fantasia,	$30DE, 0, 0, 0
	SAMPLE	Kick1,		$0B00, 0, 0, 0
	SAMPLE	Snare1,		$0000, 0, 0, 0
	SAMPLE	Bass,		$0000, 0, 0, 0
	SAMPLE	Snare2,		$0F3E, 0, 0, 0
	SAMPLE	OrchHit1,	$2081, 0, 0, 0
	SAMPLE	Synth,		$0EFE, 0, 0, 0
	SAMPLE	Woosh,		$1AD8, 0, 0, 0
	SAMPLE	PianoChord1,	$1C26, 0, 0, 0
	SAMPLE	PianoChord2,	$1AC6, 0, 0, 0
	SAMPLE	Piano,		$1748, 0, 0, 0
	SAMPLE	OrchHitCrash,	$29B4, 0, 0, 0
	SAMPLE	Pad,		$1FC5, 0, 0, 0
	SAMPLE	OrchHit2,	$291E, 0, 0, 0
	SAMPLE	Snare3,		$08D1, 0, 0, 0
	SAMPLE	Kick2,		$1E17, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0
	SAMPLE	MechStomp,	$0000, 0, 0, 0
	SAMPLE	Bumper,		$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Fantasia,	"Sound Drivers/PCM/Samples/Metallic Madness/Fantasia.bin"
	SAMPDAT	Kick1,		"Sound Drivers/PCM/Samples/Metallic Madness/Kick 1.bin"
	SAMPDAT	Snare1,		"Sound Drivers/PCM/Samples/Metallic Madness/Snare 1.bin"
	SAMPDAT	Bass,		"Sound Drivers/PCM/Samples/Metallic Madness/Bass.bin"
	SAMPDAT	Snare2,		"Sound Drivers/PCM/Samples/Metallic Madness/Snare 2.bin"
	SAMPDAT	OrchHit1,	"Sound Drivers/PCM/Samples/Metallic Madness/Orchestra Hit 1.bin"
	SAMPDAT	Synth,		"Sound Drivers/PCM/Samples/Metallic Madness/Synth.bin"
	SAMPDAT	Woosh,		"Sound Drivers/PCM/Samples/Metallic Madness/Woosh.bin"
	SAMPDAT	PianoChord1,	"Sound Drivers/PCM/Samples/Metallic Madness/Piano Chord 1.bin"
	SAMPDAT	PianoChord2,	"Sound Drivers/PCM/Samples/Metallic Madness/Piano Chord 2.bin"
	SAMPDAT	Piano,		"Sound Drivers/PCM/Samples/Metallic Madness/Piano.bin"
	SAMPDAT	OrchHitCrash,	"Sound Drivers/PCM/Samples/Metallic Madness/Orchestra Hit + Crash.bin"
	SAMPDAT	Pad,		"Sound Drivers/PCM/Samples/Metallic Madness/Pad.bin"
	SAMPDAT	OrchHit2,	"Sound Drivers/PCM/Samples/Metallic Madness/Orchestra Hit 2.bin"
	SAMPDAT	Snare3,		"Sound Drivers/PCM/Samples/Metallic Madness/Snare 3.bin"
	SAMPDAT	Kick2,		"Sound Drivers/PCM/Samples/Metallic Madness/Kick 2.bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"
	SAMPDAT	MechStomp,	"Sound Drivers/PCM/Samples/Mech Stomp.bin"
	SAMPDAT	Bumper,		"Sound Drivers/PCM/Samples/Bumper.bin"
	
; -------------------------------------------------------------------------
