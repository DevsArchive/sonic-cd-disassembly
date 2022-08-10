SonicCD_90_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_90_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM1, SonicCD_90_FM1, $F6, $10
	smpsHeaderSFXChannel	cFM2, SonicCD_90_FM2, $F7, $10

SonicCD_90_FM1:
	smpsSetvoice	$00

SonicCD_90_Loop1:
	dc.b	nBb3, $01, nRst, $01
	smpsLoop	$00, $0B, SonicCD_90_Loop1
	smpsStop

SonicCD_90_FM2:
	smpsSetvoice	$00
	dc.b	nRst, $01

SonicCD_90_Loop2:
	dc.b	nAb3, $01, nRst, $01
	smpsLoop	$00, $0B, SonicCD_90_Loop2
	smpsStop

SonicCD_90_Voices:
;	Voice $00
;	$07
;	$07, $07, $08, $08,	$1F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$80, $80, $80, $80
	smpsVcAlgorithm		$07
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$08, $08, $07, $07
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $80, $80, $80
	