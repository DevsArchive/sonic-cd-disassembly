SonicCD_A0_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_A0_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_A0_FM4, $00, $00

SonicCD_A0_FM4:
	smpsSetvoice	$00
	dc.b	nBb1, $15
	smpsStop

SonicCD_A0_Voices:
;	Voice $00
;	$3C
;	$05, $00, $00, $00,	$1F, $1F, $1F, $1F,	$00, $0F, $15, $11
;	$00, $0C, $00, $0A,	$0F, $EF, $FF, $EF,	$05, $80, $00, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$00, $00, $00, $05
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$11, $15, $0F, $00
	smpsVcDecayLevel	$0E, $0F, $0E, $00
	smpsVcDecayRate2	$0A, $00, $0C, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $00, $80, $05
	