SonicCD_D7_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D7_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_D7_FM6, $20, $00

SonicCD_D7_FM6:
	smpsSetvoice	$00

SonicCD_D7_Loop1:
	dc.b	nEb1, $03, nRst, $01
	smpsAlterPitch	$01
	smpsFMAlterVol	$03
	smpsLoop	$00, $0A, SonicCD_D7_Loop1
	smpsAlterPitch	$F6
	smpsFMAlterVol	$E2
	smpsLoop	$01, $04, SonicCD_D7_Loop1
	smpsStop

SonicCD_D7_Voices:
;	Voice $00
;	$01
;	$04, $04, $04, $04,	$1F, $1F, $1F, $13,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$7F, $7F, $7F, $80
	smpsVcAlgorithm		$01
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$04, $04, $04, $04
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$13, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $7F, $7F, $7F
	