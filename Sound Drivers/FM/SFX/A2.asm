SonicCD_A2_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_A2_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM3, SonicCD_A2_FM3, $10, $08
	smpsHeaderSFXChannel	cFM4, SonicCD_A2_FM4, $00, $00

SonicCD_A2_FM3:
	smpsSetvoice	$00
	smpsModSet	$03, $01, $20, $04
	dc.b	nC0, $06

SonicCD_A2_Loop1:
	dc.b	nC0, $0E
	smpsFMAlterVol	$0E
	smpsLoop	$00, $04, SonicCD_A2_Loop1
	smpsStop

SonicCD_A2_FM4:
	smpsSetvoice	$01
	dc.b	nCs3, $06, $14
	smpsStop

SonicCD_A2_Voices:
;	Voice $00
;	$F9
;	$21, $30, $10, $32,	$1C, $1F, $1F, $10,	$05, $18, $09, $02
;	$0B, $1F, $10, $05,	$1F, $2F, $4F, $2F,	$0C, $06, $04, $80
	smpsVcAlgorithm		$01
	smpsVcFeedback		$07
	smpsVcUnusedBits	$03
	smpsVcDetune		$03, $01, $03, $02
	smpsVcCoarseFreq	$02, $00, $00, $01
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$10, $1F, $1F, $1C
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$02, $09, $18, $05
	smpsVcDecayLevel	$02, $04, $02, $01
	smpsVcDecayRate2	$05, $10, $1F, $0B
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $04, $06, $0C
	
;	Voice $01
;	$00
;	$00, $03, $02, $00,	$D9, $DF, $1F, $1F,	$12, $11, $14, $0F
;	$0A, $00, $0A, $0D,	$FF, $FF, $FF, $FF,	$22, $07, $27, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$00, $02, $03, $00
	smpsVcRateScale		$00, $00, $03, $03
	smpsVcAttackRate	$1F, $1F, $1F, $19
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0F, $14, $11, $12
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$0D, $0A, $00, $0A
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $27, $07, $22
	