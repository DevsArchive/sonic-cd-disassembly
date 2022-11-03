; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Final Boss)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	1

	org	PCMDriver
	dc.b	"SNCBNK36.S28    "
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
	dc.b	$80				; Final Boss loop
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
	dc.l	Song_FinalBossLoop

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_FinalBossLoop:
	include	"Sound Drivers/PCM/Music/Final Boss Loop.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Final Boss).asm"
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
	include	"Sound Drivers/PCM/SFX/Blank 1.asm"
	even
SFX_AmyYelp:
	include	"Sound Drivers/PCM/SFX/Blank 2.asm"
	even
SFX_MechStomp:
	include	"Sound Drivers/PCM/SFX/Mech Stomp (Boss).asm"
	even
SFX_Bumper:
	include	"Sound Drivers/PCM/SFX/Blank 1.asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	LoopR
	SAMPPTR	LoopL
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPPTR	MechStomp
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	LoopR,		$0000, 0, 0, 0
	SAMPLE	LoopL,		$0000, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0
	SAMPLE	MechStomp,	$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	LoopR,		"Sound Drivers/PCM/Samples/Final Boss/Loop (Right).bin"
	SAMPDAT	LoopL,		"Sound Drivers/PCM/Samples/Final Boss/Loop (Left).bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"
	SAMPDAT	MechStomp,	"Sound Drivers/PCM/Samples/Mech Stomp.bin"
	
; -------------------------------------------------------------------------
