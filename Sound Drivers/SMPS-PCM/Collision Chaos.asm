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

	org	PCMDriver
	dc.b	"SNCBNK27.S28    "
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
	dc.b	$70				; Boss stomp
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
	incbin	"Sound Drivers/SMPS-PCM/Music/Collision Chaos Past.bin"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Unknown.bin"
	even
SFX_Future:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Future.bin"
	even
SFX_Past:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Past.bin"
	even
SFX_Alright:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Alright.bin"
	even
SFX_OuttaHere:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Outta Here.bin"
	even
SFX_Yes:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Yes.bin"
	even
SFX_Yeah:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Yeah.bin"
	even
SFX_AmyGiggle:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Amy Giggle.bin"
	even
SFX_AmyYelp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Amy Yelp.bin"
	even
SFX_BossStomp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Boss Stomp.bin"
	even
SFX_Bumper:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Bumper.bin"
	even
SFX_Shatter:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Collision Chaos/Shatter.bin"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	dc.l	Samp_Synth1_Metadata
	dc.l	Samp_SynthFlute_Metadata
	dc.l	Samp_Snare1_Metadata
	dc.l	Samp_Kick_Metadata
	dc.l	Samp_SynthHit_Metadata
	dc.l	Samp_Snare2_Metadata
	dc.l	Samp_HiHat1_Metadata
	dc.l	Samp_Scratch_Metadata
	dc.l	Samp_Rattle_Metadata
	dc.l	Samp_Synth2_Metadata
	dc.l	Samp_SynthBass_Metadata
	dc.l	Samp_HiHat2_Metadata
	dc.l	Samp_Strings_Metadata
	dc.l	Samp_SynthPiano_Metadata
	dc.l	Samp_Timpani_Metadata
	dc.l	Samp_Squeak_Metadata
	dc.l	Samp_JamesBrownHit_Metadata
	dc.l	Samp_SynthKick_Metadata
	dc.l	Samp_Blip_Metadata
	dc.l	Samp_Future_Metadata
	dc.l	Samp_Past_Metadata
	dc.l	Samp_Bumper_Metadata
	dc.l	Samp_BossStomp_Metadata
	dc.l	Samp_AmyGiggle_Metadata
	dc.l	Samp_AmyYelp_Metadata
	dc.l	Samp_Alright_Metadata
	dc.l	Samp_OuttaHere_Metadata
	dc.l	Samp_Yes_Metadata
	dc.l	Samp_Yeah_Metadata
	dc.l	Samp_Shatter_Metadata
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Samp_Synth1,		$1A63, 0, 0, 0
	SAMPLE	Samp_SynthFlute,	$25C8, 0, 0, 0
	SAMPLE	Samp_Snare1,		$2685, 0, 0, 0
	SAMPLE	Samp_Kick,		$0950, 0, 0, 0
	SAMPLE	Samp_SynthHit,		$3AA8, 0, 0, 0
	SAMPLE	Samp_Snare2,		$08A0, 0, 0, 0
	SAMPLE	Samp_HiHat1,		$0D88, 0, 0, 0
	SAMPLE	Samp_Scratch,		$1528, 0, 0, 0
	SAMPLE	Samp_Rattle,		$4982, 0, 0, 0
	SAMPLE	Samp_Synth2,		$0A97, 0, 0, 0
	SAMPLE	Samp_SynthBass,		$19E8, 0, 0, 0
	SAMPLE	Samp_HiHat2,		$063B, 0, 0, 0
	SAMPLE	Samp_Strings,		$1480, 0, 0, 0
	SAMPLE	Samp_SynthPiano,	$1460, 0, 0, 0
	SAMPLE	Samp_Timpani,		$1D18, 0, 0, 0
	SAMPLE	Samp_Squeak,		$1136, 0, 0, 0
	SAMPLE	Samp_JamesBrownHit,	$1880, 0, 0, 0
	SAMPLE	Samp_SynthKick,		$0798, 0, 0, 0
	SAMPLE	Samp_Blip,		$045B, 0, 0, 0
	SAMPLE	Samp_Future,		$0000, 0, 0, 0
	SAMPLE	Samp_Past,		$0000, 0, 0, 0
	SAMPLE	Samp_Bumper,		$0000, 0, 0, 0
	SAMPLE	Samp_BossStomp,		$0000, 0, 0, 0
	SAMPLE	Samp_AmyGiggle,		$0000, 0, 0, 0
	SAMPLE	Samp_AmyYelp,		$0000, 0, 0, 0
	SAMPLE	Samp_Alright,		$0000, 0, 0, 0
	SAMPLE	Samp_OuttaHere,		$0000, 0, 0, 0
	SAMPLE	Samp_Yes,		$0000, 0, 0, 0
	SAMPLE	Samp_Yeah,		$0000, 0, 0, 0
	SAMPLE	Samp_Shatter,		$0000, 0, 0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Samp_Synth1,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth 1.bin"
	even
	SAMPDAT	Samp_SynthFlute,	"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth Flute.bin"
	even
	SAMPDAT	Samp_Snare1,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Snare 1.bin"
	even
	SAMPDAT	Samp_Kick,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Kick.bin"
	even
	SAMPDAT	Samp_SynthHit,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth Hit.bin"
	even
	SAMPDAT	Samp_Snare2,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Snare 2.bin"
	even
	SAMPDAT	Samp_HiHat1,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Hi-Hat 1.bin"
	even
	SAMPDAT	Samp_Scratch,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Scratch.bin"
	even
	SAMPDAT	Samp_Rattle,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Rattle.bin"
	even
	SAMPDAT	Samp_Synth2,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth 2.bin"
	even
	SAMPDAT	Samp_SynthBass,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth Bass.bin"
	even
	SAMPDAT	Samp_HiHat2,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Hi-Hat 2.bin"
	even
	SAMPDAT	Samp_Strings,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Strings.bin"
	even
	SAMPDAT	Samp_SynthPiano,	"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth Piano.bin"
	even
	SAMPDAT	Samp_Timpani,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Timpani.bin"
	even
	SAMPDAT	Samp_Squeak,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Squeak.bin"
	even
	SAMPDAT	Samp_JamesBrownHit,	"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/James Brown Is Dead Hit.bin"
	even
	SAMPDAT	Samp_SynthKick,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Synth Kick.bin"
	even
	SAMPDAT	Samp_Blip,		"Sound Drivers/SMPS-PCM/Samples/Collision Chaos/Blip.bin"
	even
	SAMPDAT	Samp_Future,		"Sound Drivers/SMPS-PCM/Samples/Future.bin"
	SAMPDAT	Samp_Past,		"Sound Drivers/SMPS-PCM/Samples/Past.bin"
	SAMPDAT	Samp_Bumper,		"Sound Drivers/SMPS-PCM/Samples/Bumper.bin"
	SAMPDAT	Samp_BossStomp,		"Sound Drivers/SMPS-PCM/Samples/Boss Stomp.bin"
	SAMPDAT	Samp_AmyGiggle,		"Sound Drivers/SMPS-PCM/Samples/Amy Giggle.bin"
	SAMPDAT	Samp_AmyYelp,		"Sound Drivers/SMPS-PCM/Samples/Amy Yelp.bin"
	SAMPDAT	Samp_Alright,		"Sound Drivers/SMPS-PCM/Samples/Alright.bin"
	SAMPDAT	Samp_OuttaHere,		"Sound Drivers/SMPS-PCM/Samples/Outta Here.bin"
	SAMPDAT	Samp_Yes,		"Sound Drivers/SMPS-PCM/Samples/Yes.bin"
	SAMPDAT	Samp_Yeah,		"Sound Drivers/SMPS-PCM/Samples/Yeah.bin"
	SAMPDAT	Samp_Shatter,		"Sound Drivers/SMPS-PCM/Samples/Shatter.bin"

; -------------------------------------------------------------------------
