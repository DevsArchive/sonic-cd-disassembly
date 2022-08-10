SonicCD_C7_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_C7_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_C7_FM6, $00, $0B

SonicCD_C7_FM6:
	smpsSetvoice	$00
	dc.b	nF1, $3F
	smpsStop

SonicCD_C7_Voices:
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
	