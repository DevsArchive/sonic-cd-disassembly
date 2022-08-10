SonicCD_AE_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_AE_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_AE_FM4, $00, $01

SonicCD_AE_FM4:
	smpsSetvoice	$00
	dc.b	nC5, $06, nA4, $16
	smpsStop

SonicCD_AE_Voices:
;	Voice $00
;	$3C
;	$05, $01, $0A, $01,	$56, $5C, $5C, $5C,	$0E, $11, $11, $11
;	$09, $0A, $06, $0A,	$4F, $3F, $3F, $3F,	$17, $80, $20, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$01, $0A, $01, $05
	smpsVcRateScale		$01, $01, $01, $01
	smpsVcAttackRate	$1C, $1C, $1C, $16
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$11, $11, $11, $0E
	smpsVcDecayLevel	$03, $03, $03, $04
	smpsVcDecayRate2	$0A, $06, $0A, $09
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $20, $80, $17
	