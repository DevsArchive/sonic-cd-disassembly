; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Tidal Tempest Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK28.S28    "
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
	dc.b	$80				; Tidal Tempest Zone Past
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
	dc.l	Song_TTZPast

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_TTZPast:
	include	"Sound Drivers/PCM/Music/Tidal Tempest Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Tidal Tempest).asm"
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
	SAMPPTR	Marimba
	SAMPPTR	Piano1
	SAMPPTR	MarimbaChord
	SAMPPTR	Bass
	SAMPPTR	BongoLow
	SAMPPTR	BongoHigh
	SAMPPTR	SynthKick
	SAMPPTR	Snare
	SAMPPTR	Shaker
	SAMPPTR	Harp
	SAMPPTR	Tamborine
	SAMPPTR	Piano2
	SAMPPTR	Piano3
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

	SAMPLE	Marimba,	$18FB, 0,   0, 0
	SAMPLE	Piano1,		$3850, 0,   0, 0
	SAMPLE	MarimbaChord,	$3C78, $18, 0, 0
	SAMPLE	Bass,		$25BD, $24, 0, 0
	SAMPLE	BongoLow,	$1B74, $C,  0, 0
	SAMPLE	BongoHigh,	$1849, $10, 0, 0
	SAMPLE	SynthKick,	$0F25, $D,  0, 0
	SAMPLE	Snare,		$4652, 0,   0, 0
	SAMPLE	Shaker,		$15C6, $C,  0, 0
	SAMPLE	Harp,		$2DC5, $1F, 0, 0
	SAMPLE	Tamborine,	$0C4C, $F,  0, 0
	SAMPLE	Piano2,		$27CA, $20, 0, 0
	SAMPLE	Piano3,		$202C, $20, 0, 0
	SAMPLE	Future,		$0000, 0,   0, 0
	SAMPLE	Past,		$0000, 0,   0, 0
	SAMPLE	Alright,	$0000, 0,   0, 0
	SAMPLE	OuttaHere,	$0000, 0,   0, 0
	SAMPLE	Yes,		$0000, 0,   0, 0
	SAMPLE	Yeah,		$0000, 0,   0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Marimba,	"Sound Drivers/PCM/Samples/Tidal Tempest/Marimba.bin"
	SAMPDAT	Piano1,		"Sound Drivers/PCM/Samples/Tidal Tempest/Piano 1.bin"
	SAMPDAT	MarimbaChord,	"Sound Drivers/PCM/Samples/Tidal Tempest/Marimba Chord.bin"
	SAMPDAT	Bass,		"Sound Drivers/PCM/Samples/Tidal Tempest/Bass.bin"
	SAMPDAT	BongoLow,	"Sound Drivers/PCM/Samples/Tidal Tempest/Bongo (Low).bin"
	SAMPDAT	BongoHigh,	"Sound Drivers/PCM/Samples/Tidal Tempest/Bongo (High).bin"
	SAMPDAT	SynthKick,	"Sound Drivers/PCM/Samples/Tidal Tempest/Synth Kick.bin"
	SAMPDAT	Snare,		"Sound Drivers/PCM/Samples/Tidal Tempest/Snare.bin"
	SAMPDAT	Shaker,		"Sound Drivers/PCM/Samples/Tidal Tempest/Shaker.bin"
	SAMPDAT	Harp,		"Sound Drivers/PCM/Samples/Tidal Tempest/Harp.bin"
	SAMPDAT	Tamborine,	"Sound Drivers/PCM/Samples/Tidal Tempest/Tamborine.bin"
	SAMPDAT	Piano2,		"Sound Drivers/PCM/Samples/Tidal Tempest/Piano 2.bin"
	SAMPDAT	Piano3,		"Sound Drivers/PCM/Samples/Tidal Tempest/Piano 3.bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"

; -------------------------------------------------------------------------
