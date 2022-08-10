SonicCD_99_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_99_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM2, SonicCD_99_FM2, $00, $00

SonicCD_99_FM2:
	smpsSetvoice	$00
	dc.b	nE4, $02
	smpsStop

SonicCD_99_Voices:
;	Voice $00
;	$07
;	$0A, $0A, $0A, $0A,	$1F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$88, $88, $88, $88
	smpsVcAlgorithm		$07
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$0A, $0A, $0A, $0A
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$88, $88, $88, $88
	