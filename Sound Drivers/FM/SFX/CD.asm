SonicCD_CD_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_CD_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM5, SonicCD_CD_FM5, $00, $0D
	smpsHeaderSFXChannel	cFM6, SonicCD_CD_FM6, $0C, $02

SonicCD_CD_FM5:
	smpsSetvoice	$00
	dc.b	nF1, $3F
	smpsStop

SonicCD_CD_FM6:
	smpsSetvoice	$01
	smpsModSet	$01, $01, $83, $0C

SonicCD_CD_Loop1:
	dc.b	nA0, $05, $05
	smpsFMAlterVol	$03
	smpsLoop	$00, $0A, SonicCD_CD_Loop1
	smpsStop

SonicCD_CD_Voices:
;	Voice $00
;	$3D
;	$03, $06, $02, $02,	$0F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$0C, $82, $80, $80
	smpsVcAlgorithm		$05
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$02, $02, $06, $03
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $0F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $80, $82, $0C
	
;	Voice $01
;	$35
;	$14, $1A, $04, $09,	$0E, $10, $11, $0E,	$0C, $15, $03, $06
;	$16, $0E, $09, $10,	$2F, $2F, $4F, $4F,	$2F, $12, $12, $80
	smpsVcAlgorithm		$05
	smpsVcFeedback		$06
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $01, $01
	smpsVcCoarseFreq	$09, $04, $0A, $04
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$0E, $11, $10, $0E
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$06, $03, $15, $0C
	smpsVcDecayLevel	$04, $04, $02, $02
	smpsVcDecayRate2	$10, $09, $0E, $16
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $12, $12, $2F
	