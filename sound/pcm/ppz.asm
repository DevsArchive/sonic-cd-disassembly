; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver (Palmtree Panic Zone)
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/subcpu.i"
	include	"_inc/sound.i"

; -------------------------------------------------------------------------
; Driver
; -------------------------------------------------------------------------

	org	PCMDriver
	dc.b	"SNCBNK25.S28    "
	include	"sound/pcm/driver/driver.asm"

; -------------------------------------------------------------------------
; Sound effect index
; -------------------------------------------------------------------------

SFXIndex:
	dc.l	SFX_MusicLoop
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
	incbin	"sound/pcm/music/ppzpast.mus"
	even

; -------------------------------------------------------------------------
; Sound effects
; -------------------------------------------------------------------------

SFX_MusicLoop:
	incbin	"sound/pcm/sfx/musicloop.sfx"
	even
SFX_Future:
	incbin	"sound/pcm/sfx/future.sfx"
	even
SFX_Past:
	incbin	"sound/pcm/sfx/past.sfx"
	even
SFX_Alright:
	incbin	"sound/pcm/sfx/alright.sfx"
	even
SFX_OuttaHere:
	incbin	"sound/pcm/sfx/outtahere.sfx"
	even
SFX_Yes:
	incbin	"sound/pcm/sfx/yes.sfx"
	even
SFX_Yeah:
	incbin	"sound/pcm/sfx/yeah.sfx"
	even
SFX_AmyGiggle:
	incbin	"sound/pcm/sfx/amygiggle.sfx"
	even
SFX_AmyYelp:
	incbin	"sound/pcm/sfx/amyyelp.sfx"
	even
SFX_BossStomp:
	incbin	"sound/pcm/sfx/bossstomp.sfx"
	even
SFX_Bumper:
	incbin	"sound/pcm/sfx/bumper.sfx"
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

	SAMPDAT	Samp_DrumLoop,		"sound/pcm/samples/ppz/drumloop.smp"
	even
	SAMPDAT	Samp_Bass,		"sound/pcm/samples/ppz/bass.smp"
	even
	SAMPDAT	Samp_Flute,		"sound/pcm/samples/ppz/flute.smp"
	even
	SAMPDAT	Samp_Piano,		"sound/pcm/samples/ppz/piano.smp"
	even
	SAMPDAT	Samp_TomDrum,		"sound/pcm/samples/ppz/tomdrum.smp"
	even
	SAMPDAT	Samp_ElecPianoLow,	"sound/pcm/samples/ppz/elecpianolow.smp"
	even
	SAMPDAT	Samp_ElecPianoHigh,	"sound/pcm/samples/ppz/elecpianohigh.smp"
	even
	SAMPDAT	Samp_Strings,		"sound/pcm/samples/ppz/strings.smp"
	even

	SAMPDAT	Samp_Future,		"sound/pcm/samples/future.smp"
	SAMPDAT	Samp_Past,		"sound/pcm/samples/past.smp"
	SAMPDAT	Samp_BossStomp,		"sound/pcm/samples/bossstomp.smp"
	SAMPDAT	Samp_AmyGiggle,		"sound/pcm/samples/amygiggle.smp"
	SAMPDAT	Samp_AmyYelp,		"sound/pcm/samples/amyyelp.smp"
	SAMPDAT	Samp_Alright,		"sound/pcm/samples/alright.smp"
	SAMPDAT	Samp_OuttaHere,		"sound/pcm/samples/outtahere.smp"
	SAMPDAT	Samp_Yes,		"sound/pcm/samples/yes.smp"
	SAMPDAT	Samp_Yeah,		"sound/pcm/samples/yeah.smp"

; -------------------------------------------------------------------------
