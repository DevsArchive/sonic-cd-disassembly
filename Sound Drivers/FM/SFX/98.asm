SonicCD_98_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_98_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_98_FM6, $00, $07

SonicCD_98_FM6:
	smpsSetvoice	$00
	dc.b	nRst, $01
	smpsModSet	$03, $01, $5D, $0F
	dc.b	nB3, $06
	smpsModOff
	smpsSetvoice	$01

SonicCD_98_Loop1:
	dc.b	nC5, $02
	smpsFMAlterVol	$01
	dc.b	smpsNoAttack
	smpsLoop	$00, $19, SonicCD_98_Loop1
	smpsStop

SonicCD_98_Voices:
;	Voice $00
;	$20
;	$36, $35, $30, $31,	$DF, $DF, $9F, $9F,	$07, $06, $09, $06
;	$07, $06, $06, $08,	$2F, $1F, $1F, $FF,	$16, $30, $13, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$04
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $03, $03, $03
	smpsVcCoarseFreq	$01, $00, $05, $06
	smpsVcRateScale		$02, $02, $03, $03
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$06, $09, $06, $07
	smpsVcDecayLevel	$0F, $01, $01, $02
	smpsVcDecayRate2	$08, $06, $06, $07
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $13, $30, $16
	
;	Voice $01
;	$20
;	$31, $33, $30, $31,	$9F, $9F, $9F, $9F,	$07, $06, $09, $06
;	$07, $06, $06, $08,	$2F, $1F, $1F, $FF,	$19, $23, $11, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$04
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $03, $03, $03
	smpsVcCoarseFreq	$01, $00, $03, $01
	smpsVcRateScale		$02, $02, $02, $02
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$06, $09, $06, $07
	smpsVcDecayLevel	$0F, $01, $01, $02
	smpsVcDecayRate2	$08, $06, $06, $07
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $11, $23, $19
	