; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Stardust Speedway Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK31.S28    "
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
	dc.b	$80				; Stardust Speedway Zone Past
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
	dc.l	Song_SSZPast

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

Song_SSZPast:
	include	"Sound Drivers/PCM/Music/Stardust Speedway Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Stardust Speedway).asm"
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
	SAMPPTR	HatOpen
	SAMPPTR	HatClosed
	SAMPPTR	Bass
	SAMPPTR	PianoChord1
	SAMPPTR	PianoChord2
	SAMPPTR	Tom
	SAMPPTR	HueHueHue
	SAMPPTR	Saxophone
	SAMPPTR	VoxClav
	SAMPPTR	Scratch1
	SAMPPTR	Scratch2
	SAMPPTR	Piano
	SAMPPTR	PadChord1
	SAMPPTR	PadChord2
	SAMPPTR	Organ1
	SAMPPTR	Organ2
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPPTR	AmyGiggle
	SAMPPTR	AmyYelp
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Kick,		$0CA9, 0, 0, 0
	SAMPLE	Snare,		$08D8, 0, 0, 0
	SAMPLE	HatOpen,	$0ED0, 0, 0, 0
	SAMPLE	HatClosed,	$05F3, 0, 0, 0
	SAMPLE	Bass,		$1815, 0, 0, 0
	SAMPLE	PianoChord1,	$0000, 0, 0, 0
	SAMPLE	PianoChord2,	$0000, 0, 0, 0
	SAMPLE	Tom,		$0FDC, 0, 0, 0
	SAMPLE	HueHueHue,	$0000, 0, 0, 0
	SAMPLE	Saxophone,	$0000, 0, 0, 0
	SAMPLE	VoxClav,	$0000, 0, 0, 0
	SAMPLE	Scratch1,	$09BB, 0, 0, 0
	SAMPLE	Scratch2,	$0000, 0, 0, 0
	SAMPLE	Piano,		$33E0, 0, 0, 0
	SAMPLE	PadChord1,	$0000, 0, 0, 0
	SAMPLE	PadChord2,	$3F80, 0, 0, 0
	SAMPLE	Organ1,		$0950, 0, 0, 0
	SAMPLE	Organ2,		$09D0, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0
	SAMPLE	AmyGiggle,	$0000, 0, 0, 0
	SAMPLE	AmyYelp,	$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Kick,		"Sound Drivers/PCM/Samples/Stardust Speedway/Kick.bin"
	SAMPDAT	Snare,		"Sound Drivers/PCM/Samples/Stardust Speedway/Snare.bin"
	SAMPDAT	HatOpen,	"Sound Drivers/PCM/Samples/Stardust Speedway/Hi-Hat (Open).bin"
	SAMPDAT	HatClosed,	"Sound Drivers/PCM/Samples/Stardust Speedway/Hi-Hat (Closed).bin"
	SAMPDAT	Bass,		"Sound Drivers/PCM/Samples/Stardust Speedway/Bass.bin"
	SAMPDAT	PianoChord1,	"Sound Drivers/PCM/Samples/Stardust Speedway/Piano Chord 1.bin"
	SAMPDAT	PianoChord2,	"Sound Drivers/PCM/Samples/Stardust Speedway/Piano Chord 2.bin"
	SAMPDAT	Tom,		"Sound Drivers/PCM/Samples/Stardust Speedway/Tom.bin"
	SAMPDAT	HueHueHue,	"Sound Drivers/PCM/Samples/Stardust Speedway/Hue Hue Hue.bin"
	SAMPDAT	Saxophone,	"Sound Drivers/PCM/Samples/Stardust Speedway/Saxophone.bin"
	SAMPDAT	VoxClav,	"Sound Drivers/PCM/Samples/Stardust Speedway/Vox + Clav.bin"
	SAMPDAT	Scratch1,	"Sound Drivers/PCM/Samples/Stardust Speedway/Scratch 1.bin"
	SAMPDAT	Scratch2,	"Sound Drivers/PCM/Samples/Stardust Speedway/Scratch 2.bin"
	SAMPDAT	Piano,		"Sound Drivers/PCM/Samples/Stardust Speedway/Piano.bin"
	SAMPDAT	PadChord1,	"Sound Drivers/PCM/Samples/Stardust Speedway/Pad Chord 1.bin"
	SAMPDAT	PadChord2,	"Sound Drivers/PCM/Samples/Stardust Speedway/Pad Chord 2.bin"
	SAMPDAT	Organ1,		"Sound Drivers/PCM/Samples/Stardust Speedway/Organ 1.bin"
	SAMPDAT	Organ2,		"Sound Drivers/PCM/Samples/Stardust Speedway/Organ 2.bin"
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"
	SAMPDAT	AmyGiggle,	"Sound Drivers/PCM/Samples/Amy Giggle.bin"
	SAMPDAT	AmyYelp,	"Sound Drivers/PCM/Samples/Amy Yelp.bin"

; -------------------------------------------------------------------------
