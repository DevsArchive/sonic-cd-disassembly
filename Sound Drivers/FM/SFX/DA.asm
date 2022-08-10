SonicCD_DA_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_DA_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_DA_FM6, $00, $00

SonicCD_DA_FM6:
	smpsSetvoice	$00
	dc.b	nG2, $0F
	smpsFMAlterVol	$0F
	smpsLoop	$00, $04, SonicCD_DA_FM6
	smpsStop

SonicCD_DA_Voices:
;	Voice $00
;	$04
;	$00, $01, $00, $05,	$0F, $1F, $0F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$8F, $8F, $8F, $8F,	$1F, $8D, $1F, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$05, $00, $01, $00
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $0F, $1F, $0F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$08, $08, $08, $08
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $1F, $8D, $1F
	