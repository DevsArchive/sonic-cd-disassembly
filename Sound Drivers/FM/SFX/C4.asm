SonicCD_C4_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_C4_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_C4_FM6, $00, $05

SonicCD_C4_FM6:
	smpsSetvoice	$00
	dc.b	nG6, $02

SonicCD_C4_Jump1:
	dc.b	smpsNoAttack, $01
	smpsConditionalJumpCD	SonicCD_C4_Jump1

SonicCD_C4_Loop1:
	dc.b	smpsNoAttack, $01
	smpsFMAlterVol	$01
	smpsLoop	$00, $22, SonicCD_C4_Loop1
	dc.b	nRst, $01
	smpsNop		$00
	smpsStop

SonicCD_C4_Voices:
;	Voice $00
;	$38
;	$0F, $0F, $0F, $0F,	$1F, $1F, $1F, $0E,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $1F,	$1A, $0C, $00, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$0F, $0F, $0F, $0F
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$0E, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$01, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $00, $0C, $1A
	