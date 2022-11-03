; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Wacky Workbench Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK30.S28    "
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
	dc.l	SFX_Shatter

; -------------------------------------------------------------------------
; Song priority table
; -------------------------------------------------------------------------

SongPriorities:
	dc.b	$80				; Wacky Workbench Zone Past
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
	dc.b	$70				; Shatter
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
	dc.l	Song_WWZPast

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_WWZPast:
	include	"Sound Drivers/PCM/Music/Wacky Workbench Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Wacky Workbench).asm"
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
	include	"Sound Drivers/PCM/SFX/Blank 1.asm"
	even
SFX_Shatter:
	include	"Sound Drivers/PCM/SFX/Shatter.asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	Pad
	SAMPPTR	Kick
	SAMPPTR	Tamborine
	SAMPPTR	Beep
	SAMPPTR	Honk
	SAMPPTR	SynthBass
	SAMPPTR	HatClosed
	SAMPPTR	Snare
	SAMPPTR	Clap
	SAMPPTR	HatOpen
	SAMPPTR	Flute
	SAMPPTR	Piano
	SAMPPTR	SynthBell
	SAMPPTR	Tom
	SAMPPTR	CrashCymbal
	SAMPPTR	Synth
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPPTR	MechStomp
	SAMPPTR	Shatter
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Pad,		$420E, 0, 0, 0
	SAMPLE	Kick,		$0A70, 0, 0, 0
	SAMPLE	Tamborine,	$0C4C, 0, 0, 0
	SAMPLE	Beep,		$11F0, 0, 0, 0
	SAMPLE	Honk,		$33F8, 0, 0, 0
	SAMPLE	SynthBass,	$1462, 0, 0, 0
	SAMPLE	HatClosed,	$0878, 0, 0, 0
	SAMPLE	Snare,		$07B5, 0, 0, 0
	SAMPLE	Clap,		$096E, 0, 0, 0
	SAMPLE	HatOpen,	$149E, 0, 0, 0
	SAMPLE	Flute,		$37CE, 0, 0, 0
	SAMPLE	Piano,		$1C88, 0, 0, 0
	SAMPLE	SynthBell,	$2890, 0, 0, 0
	SAMPLE	Tom,		$106E, 0, 0, 0
	SAMPLE	CrashCymbal,	$3AB0, 0, 0, 0
	SAMPLE	Synth,		$1D75, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0
	SAMPLE	MechStomp,	$0000, 0, 0, 0
	SAMPLE	Shatter,	$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Pad,		"Sound Drivers/PCM/Samples/Wacky Workbench/Pad.bin"
	SAMPDAT	Kick,		"Sound Drivers/PCM/Samples/Wacky Workbench/Kick.bin"
	SAMPDAT	Tamborine,	"Sound Drivers/PCM/Samples/Wacky Workbench/Tamborine.bin"
	SAMPDAT	Beep,		"Sound Drivers/PCM/Samples/Wacky Workbench/Beep.bin"
	SAMPDAT	Honk,		"Sound Drivers/PCM/Samples/Wacky Workbench/Honk.bin"
	SAMPDAT	SynthBass,	"Sound Drivers/PCM/Samples/Wacky Workbench/Synth Bass.bin"
	SAMPDAT	HatClosed,	"Sound Drivers/PCM/Samples/Wacky Workbench/Hi-Hat (Closed).bin"
	SAMPDAT	Snare,		"Sound Drivers/PCM/Samples/Wacky Workbench/Snare.bin"
	SAMPDAT	Clap,		"Sound Drivers/PCM/Samples/Wacky Workbench/Clap.bin"
	SAMPDAT	HatOpen,	"Sound Drivers/PCM/Samples/Wacky Workbench/Hi-Hat (Open).bin"
	SAMPDAT	Flute,		"Sound Drivers/PCM/Samples/Wacky Workbench/Flute.bin"
	SAMPDAT	Piano,		"Sound Drivers/PCM/Samples/Wacky Workbench/Piano.bin"
	SAMPDAT	SynthBell,	"Sound Drivers/PCM/Samples/Wacky Workbench/Synth Bell.bin"
	SAMPDAT	Tom,		"Sound Drivers/PCM/Samples/Wacky Workbench/Tom.bin"
	SAMPDAT	CrashCymbal,	"Sound Drivers/PCM/Samples/Wacky Workbench/Crash Cymbal.bin"
	SAMPDAT	Synth,		"Sound Drivers/PCM/Samples/Wacky Workbench/Synth.bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"
	SAMPDAT	MechStomp,	"Sound Drivers/PCM/Samples/Mech Stomp.bin"
	SAMPDAT	Shatter,	"Sound Drivers/PCM/Samples/Shatter.bin"

; -------------------------------------------------------------------------
