SonicCD_D2_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D2_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_D2_FM4, $00, $05

SonicCD_D2_FM4:
	smpsSetvoice	$00
	smpsModSet	$20, $01, $05, $05
	dc.b	nA5, $45
	smpsStop

SonicCD_D2_Voices:
;	Voice $00
;	$04
;	$27, $02, $07, $47,	$1F, $1F, $1F, $1F,	$07, $0A, $07, $0D
;	$00, $0B, $00, $0B,	$1F, $0F, $1F, $0F,	$1F, $80, $23, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$04, $00, $00, $02
	smpsVcCoarseFreq	$07, $07, $02, $07
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0D, $07, $0A, $07
	smpsVcDecayLevel	$00, $01, $00, $01
	smpsVcDecayRate2	$0B, $00, $0B, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $23, $80, $1F
	