SonicCD_B9_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_B9_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM3, SonicCD_B9_FM3, $18, $00
	smpsHeaderSFXChannel	cFM4, SonicCD_B9_FM3, $10, $03

SonicCD_B9_FM3:
	smpsSetvoice	$00
	smpsModSet	$01, $01, $31, $FF
	dc.b	nEb5, $06, nRst, $02, nEb5, $14
	smpsStop

SonicCD_B9_Voices:
;	Voice $00
;	$3B
;	$3C, $39, $30, $31,	$DF, $1F, $1F, $DF,	$04, $05, $04, $01
;	$04, $04, $04, $02,	$FF, $0F, $1F, $AF,	$0D, $20, $0C, $80
	smpsVcAlgorithm		$03
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $03, $03, $03
	smpsVcCoarseFreq	$01, $00, $09, $0C
	smpsVcRateScale		$03, $00, $00, $03
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$01, $04, $05, $04
	smpsVcDecayLevel	$0A, $01, $00, $0F
	smpsVcDecayRate2	$02, $04, $04, $04
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $0C, $20, $0D
	