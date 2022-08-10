SonicCD_B0_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_B0_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM5, SonicCD_B0_FM5, $10, $07
	smpsHeaderSFXChannel	cFM6, SonicCD_B0_FM6, $00, $07

SonicCD_B0_FM5:
	dc.b	nRst, $01

SonicCD_B0_FM6:
	smpsSetvoice	$00
	smpsModSet	$03, $01, $20, $04

SonicCD_B0_Loop1:
	dc.b	nC0, $10
	smpsFMAlterVol	$13
	smpsLoop	$00, $06, SonicCD_B0_Loop1
	smpsStop

SonicCD_B0_Voices:
;	Voice $00
;	$F9
;	$21, $30, $10, $32,	$1F, $1F, $1F, $1F,	$05, $18, $09, $02
;	$0B, $1F, $10, $05,	$1F, $2F, $4F, $2F,	$0E, $07, $04, $80
	smpsVcAlgorithm		$01
	smpsVcFeedback		$07
	smpsVcUnusedBits	$03
	smpsVcDetune		$03, $01, $03, $02
	smpsVcCoarseFreq	$02, $00, $00, $01
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$02, $09, $18, $05
	smpsVcDecayLevel	$02, $04, $02, $01
	smpsVcDecayRate2	$05, $10, $1F, $0B
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $04, $07, $0E
	