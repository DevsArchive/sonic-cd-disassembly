SonicCD_D0_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D0_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_D0_FM6, $0D, $07

SonicCD_D0_FM6:
	smpsSetvoice	$00
	dc.b	nCs0, $07, nA0, $25
	smpsStop

SonicCD_D0_Voices:
;	Voice $00
;	$3D
;	$13, $75, $13, $30,	$5F, $5F, $5F, $5F,	$0D, $0A, $0A, $0A
;	$0D, $0D, $0D, $0D,	$4F, $0F, $0F, $0F,	$0B, $80, $80, $80
	smpsVcAlgorithm		$05
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $01, $07, $01
	smpsVcCoarseFreq	$00, $03, $05, $03
	smpsVcRateScale		$01, $01, $01, $01
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0A, $0A, $0A, $0D
	smpsVcDecayLevel	$00, $00, $00, $04
	smpsVcDecayRate2	$0D, $0D, $0D, $0D
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $80, $80, $0B
	