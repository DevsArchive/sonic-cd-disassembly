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

	org	PCMDriver
	dc.b	"SNCBNK28.S28    "
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
	dc.l	Song_TTZPast

; -------------------------------------------------------------------------
; Songs
; -------------------------------------------------------------------------

Song_TTZPast:
	incbin	"Sound Drivers/SMPS-PCM/Music/Tidal Tempest Past.bin"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_Unknown:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Unknown.bin"
	even
SFX_Future:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Future.bin"
	even
SFX_Past:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Past.bin"
	even
SFX_Alright:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Alright.bin"
	even
SFX_OuttaHere:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Outta Here.bin"
	even
SFX_Yes:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Yes.bin"
	even
SFX_Yeah:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Yeah.bin"
	even
SFX_AmyGiggle:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Amy Giggle.bin"
	even
SFX_AmyYelp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Amy Yelp.bin"
	even
SFX_BossStomp:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Boss Stomp.bin"
	even
SFX_Bumper:
	incbin	"Sound Drivers/SMPS-PCM/SFX/Tidal Tempest/Bumper.bin"
	even

; -------------------------------------------------------------------------
; Sample index
; -------------------------------------------------------------------------

SampleIndex:
	SAMPTBLSTART
	dc.l	Samp_Marimba_Metadata
	dc.l	Samp_Piano1_Metadata
	dc.l	Samp_MarimbaChord_Metadata
	dc.l	Samp_Bass_Metadata
	dc.l	Samp_BongoLow_Metadata
	dc.l	Samp_BongoHigh_Metadata
	dc.l	Samp_SynthKick_Metadata
	dc.l	Samp_Snare_Metadata
	dc.l	Samp_Shaker_Metadata
	dc.l	Samp_Harp_Metadata
	dc.l	Samp_Tamborine_Metadata
	dc.l	Samp_Piano2_Metadata
	dc.l	Samp_Piano3_Metadata
	dc.l	Samp_Future_Metadata
	dc.l	Samp_Past_Metadata
	dc.l	Samp_Alright_Metadata
	dc.l	Samp_OuttaHere_Metadata
	dc.l	Samp_Yes_Metadata
	dc.l	Samp_Yeah_Metadata
	SAMPTBLEND

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------

	SAMPLE	Samp_Marimba,		$18FB, 0,   0, 0
	SAMPLE	Samp_Piano1,		$3850, 0,   0, 0
	SAMPLE	Samp_MarimbaChord,	$3C78, $18, 0, 0
	SAMPLE	Samp_Bass,		$25BD, $24, 0, 0
	SAMPLE	Samp_BongoLow,		$1B74, $C,  0, 0
	SAMPLE	Samp_BongoHigh,		$1849, $10, 0, 0
	SAMPLE	Samp_SynthKick,		$0F25, $D,  0, 0
	SAMPLE	Samp_Snare,		$4652, 0,   0, 0
	SAMPLE	Samp_Shaker,		$15C6, $C,  0, 0
	SAMPLE	Samp_Harp,		$2DC5, $1F, 0, 0
	SAMPLE	Samp_Tamborine,		$0C4C, $F,  0, 0
	SAMPLE	Samp_Piano2,		$27CA, $20, 0, 0
	SAMPLE	Samp_Piano3,		$202C, $20, 0, 0
	SAMPLE	Samp_Future,		$0000, 0,   0, 0
	SAMPLE	Samp_Past,		$0000, 0,   0, 0
	SAMPLE	Samp_Alright,		$0000, 0,   0, 0
	SAMPLE	Samp_OuttaHere,		$0000, 0,   0, 0
	SAMPLE	Samp_Yes,		$0000, 0,   0, 0
	SAMPLE	Samp_Yeah,		$0000, 0,   0, 0

; -------------------------------------------------------------------------
; Samples
; -------------------------------------------------------------------------

	SAMPDAT	Samp_Marimba,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Marimba.bin"
	SAMPDAT	Samp_Piano1,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Piano 1.bin"
	SAMPDAT	Samp_MarimbaChord,	"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Marimba Chord.bin"
	SAMPDAT	Samp_Bass,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Bass.bin"
	SAMPDAT	Samp_BongoLow,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Bongo (Low).bin"
	SAMPDAT	Samp_BongoHigh,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Bongo (High).bin"
	SAMPDAT	Samp_SynthKick,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Synth Kick.bin"
	SAMPDAT	Samp_Snare,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Snare.bin"
	SAMPDAT	Samp_Shaker,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Shaker.bin"
	SAMPDAT	Samp_Harp,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Harp.bin"
	SAMPDAT	Samp_Tamborine,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Tamborine.bin"
	SAMPDAT	Samp_Piano2,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Piano 2.bin"
	SAMPDAT	Samp_Piano3,		"Sound Drivers/SMPS-PCM/Samples/Tidal Tempest/Piano 3.bin"
	SAMPDAT	Samp_Future,		"Sound Drivers/SMPS-PCM/Samples/Future.bin"
	SAMPDAT	Samp_Past,		"Sound Drivers/SMPS-PCM/Samples/Past.bin"
	SAMPDAT	Samp_Alright,		"Sound Drivers/SMPS-PCM/Samples/Alright.bin"
	SAMPDAT	Samp_OuttaHere,		"Sound Drivers/SMPS-PCM/Samples/Outta Here.bin"
	SAMPDAT	Samp_Yes,		"Sound Drivers/SMPS-PCM/Samples/Yes.bin"
	SAMPDAT	Samp_Yeah,		"Sound Drivers/SMPS-PCM/Samples/Yeah.bin"

; -------------------------------------------------------------------------
