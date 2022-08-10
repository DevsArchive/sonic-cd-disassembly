SonicCD_D6_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D6_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02	; BUG: Should be 1
	smpsHeaderSFXChannel	cFM6, SonicCD_D6_FM6, $00, $04

SonicCD_D6_FM6:
	smpsSetvoice	$00
	smpsPan		panLeft, $00
	dc.b	nC2, $02
	smpsPan		panRight, $00
	dc.b	nC2
	smpsFMAlterVol	$08
	smpsLoop	$00, $05, SonicCD_D6_FM6
	smpsStop

SonicCD_D6_Voices:
;	Voice $00
;	$34
;	$06, $05, $00, $01,	$1F, $1F, $1F, $13,	$00, $00, $09, $00
;	$00, $00, $0A, $00,	$1F, $1F, $1F, $1F,	$00, $85, $04, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$06
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$01, $00, $05, $06
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$13, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $09, $00, $00
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$00, $0A, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $04, $85, $00
	