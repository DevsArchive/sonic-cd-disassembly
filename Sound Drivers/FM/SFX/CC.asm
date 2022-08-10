SonicCD_CC_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_CC_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_CC_FM4, $00, $02

SonicCD_CC_FM4:
	smpsSetvoice	$00
	smpsModSet	$01, $01, $23, $30
	dc.b	nEb4, $07, nFs4
	smpsAlterPitch	$05
	smpsLoop	$00, $03, SonicCD_CC_FM4
	smpsStop

SonicCD_CC_Voices:
;	Voice $00
;	$13
;	$0F, $07, $07, $04,	$1F, $1E, $1E, $13,	$1A, $13, $11, $10
;	$00, $00, $00, $00,	$FF, $FF, $FF, $FF,	$16, $26, $23, $80
	smpsVcAlgorithm		$03
	smpsVcFeedback		$02
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$04, $07, $07, $0F
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$13, $1E, $1E, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$10, $11, $13, $1A
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $23, $26, $16
	