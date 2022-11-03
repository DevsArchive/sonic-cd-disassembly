; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Collision Chaos Zone)
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

BOSS	EQU	0

	org	PCMDriver
	dc.b	"SNCBNK27.S28    "
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
	dc.b	$80				; Collision Chaos Zone Past
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
	dc.l	Song_CCZPast

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

Song_CCZPast:
	include	"Sound Drivers/PCM/Music/Collision Chaos Past.asm"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	include	"Sound Drivers/PCM/SFX/Unknown (Collision Chaos).asm"
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
	include	"Sound Drivers/PCM/SFX/Mech Stomp.asm"
	even
SFX_Bumper:
	include	"Sound Drivers/PCM/SFX/Bumper.asm"
	even
SFX_Shatter:
	include	"Sound Drivers/PCM/SFX/Shatter.asm"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	SAMPPTR	Synth1
	SAMPPTR	SynthFlute
	SAMPPTR	Snare1
	SAMPPTR	Kick
	SAMPPTR	SynthHit
	SAMPPTR	Snare2
	SAMPPTR	HiHat1
	SAMPPTR	Scratch
	SAMPPTR	Rattle
	SAMPPTR	Synth2
	SAMPPTR	SynthBass
	SAMPPTR	HiHat2
	SAMPPTR	Strings
	SAMPPTR	SynthPiano
	SAMPPTR	Timpani
	SAMPPTR	Squeak
	SAMPPTR	JamesBrownHit
	SAMPPTR	SynthKick
	SAMPPTR	Blip
	SAMPPTR	Future
	SAMPPTR	Past
	SAMPPTR	Bumper
	SAMPPTR	MechStomp
	SAMPPTR	AmyGiggle
	SAMPPTR	AmyYelp
	SAMPPTR	Alright
	SAMPPTR	OuttaHere
	SAMPPTR	Yes
	SAMPPTR	Yeah
	SAMPPTR	Shatter
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Synth1,		$1A63, 0, 0, 0
	SAMPLE	SynthFlute,	$25C8, 0, 0, 0
	SAMPLE	Snare1,		$2685, 0, 0, 0
	SAMPLE	Kick,		$0950, 0, 0, 0
	SAMPLE	SynthHit,	$3AA8, 0, 0, 0
	SAMPLE	Snare2,		$08A0, 0, 0, 0
	SAMPLE	HiHat1,		$0D88, 0, 0, 0
	SAMPLE	Scratch,	$1528, 0, 0, 0
	SAMPLE	Rattle,		$4982, 0, 0, 0
	SAMPLE	Synth2,		$0A97, 0, 0, 0
	SAMPLE	SynthBass,	$19E8, 0, 0, 0
	SAMPLE	HiHat2,		$063B, 0, 0, 0
	SAMPLE	Strings,	$1480, 0, 0, 0
	SAMPLE	SynthPiano,	$1460, 0, 0, 0
	SAMPLE	Timpani,	$1D18, 0, 0, 0
	SAMPLE	Squeak,		$1136, 0, 0, 0
	SAMPLE	JamesBrownHit,	$1880, 0, 0, 0
	SAMPLE	SynthKick,	$0798, 0, 0, 0
	SAMPLE	Blip,		$045B, 0, 0, 0
	SAMPLE	Future,		$0000, 0, 0, 0
	SAMPLE	Past,		$0000, 0, 0, 0
	SAMPLE	Bumper,		$0000, 0, 0, 0
	SAMPLE	MechStomp,	$0000, 0, 0, 0
	SAMPLE	AmyGiggle,	$0000, 0, 0, 0
	SAMPLE	AmyYelp,	$0000, 0, 0, 0
	SAMPLE	Alright,	$0000, 0, 0, 0
	SAMPLE	OuttaHere,	$0000, 0, 0, 0
	SAMPLE	Yes,		$0000, 0, 0, 0
	SAMPLE	Yeah,		$0000, 0, 0, 0
	SAMPLE	Shatter,	$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Synth1,		"Sound Drivers/PCM/Samples/Collision Chaos/Synth 1.bin"
	even
	SAMPDAT	SynthFlute,	"Sound Drivers/PCM/Samples/Collision Chaos/Synth Flute.bin"
	even
	SAMPDAT	Snare1,		"Sound Drivers/PCM/Samples/Collision Chaos/Snare 1.bin"
	even
	SAMPDAT	Kick,		"Sound Drivers/PCM/Samples/Collision Chaos/Kick.bin"
	even
	SAMPDAT	SynthHit,	"Sound Drivers/PCM/Samples/Collision Chaos/Synth Hit.bin"
	even
	SAMPDAT	Snare2,		"Sound Drivers/PCM/Samples/Collision Chaos/Snare 2.bin"
	even
	SAMPDAT	HiHat1,		"Sound Drivers/PCM/Samples/Collision Chaos/Hi-Hat 1.bin"
	even
	SAMPDAT	Scratch,	"Sound Drivers/PCM/Samples/Collision Chaos/Scratch.bin"
	even
	SAMPDAT	Rattle,		"Sound Drivers/PCM/Samples/Collision Chaos/Rattle.bin"
	even
	SAMPDAT	Synth2,		"Sound Drivers/PCM/Samples/Collision Chaos/Synth 2.bin"
	even
	SAMPDAT	SynthBass,	"Sound Drivers/PCM/Samples/Collision Chaos/Synth Bass.bin"
	even
	SAMPDAT	HiHat2,		"Sound Drivers/PCM/Samples/Collision Chaos/Hi-Hat 2.bin"
	even
	SAMPDAT	Strings,	"Sound Drivers/PCM/Samples/Collision Chaos/Strings.bin"
	even
	SAMPDAT	SynthPiano,	"Sound Drivers/PCM/Samples/Collision Chaos/Synth Piano.bin"
	even
	SAMPDAT	Timpani,	"Sound Drivers/PCM/Samples/Collision Chaos/Timpani.bin"
	even
	SAMPDAT	Squeak,		"Sound Drivers/PCM/Samples/Collision Chaos/Squeak.bin"
	even
	SAMPDAT	JamesBrownHit,	"Sound Drivers/PCM/Samples/Collision Chaos/James Brown Is Dead Hit.bin"
	even
	SAMPDAT	SynthKick,	"Sound Drivers/PCM/Samples/Collision Chaos/Synth Kick.bin"
	even
	SAMPDAT	Blip,		"Sound Drivers/PCM/Samples/Collision Chaos/Blip.bin"
	even
	SAMPDAT	Future,		"Sound Drivers/PCM/Samples/Future.bin"
	SAMPDAT	Past,		"Sound Drivers/PCM/Samples/Past.bin"
	SAMPDAT	Bumper,		"Sound Drivers/PCM/Samples/Bumper.bin"
	SAMPDAT	MechStomp,	"Sound Drivers/PCM/Samples/Mech Stomp.bin"
	SAMPDAT	AmyGiggle,	"Sound Drivers/PCM/Samples/Amy Giggle.bin"
	SAMPDAT	AmyYelp,	"Sound Drivers/PCM/Samples/Amy Yelp.bin"
	SAMPDAT	Alright,	"Sound Drivers/PCM/Samples/Alright.bin"
	SAMPDAT	OuttaHere,	"Sound Drivers/PCM/Samples/Outta Here.bin"
	SAMPDAT	Yes,		"Sound Drivers/PCM/Samples/Yes.bin"
	SAMPDAT	Yeah,		"Sound Drivers/PCM/Samples/Yeah.bin"
	SAMPDAT	Shatter,	"Sound Drivers/PCM/Samples/Shatter.bin"

; -------------------------------------------------------------------------
