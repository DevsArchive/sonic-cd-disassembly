SonicCD_C0_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_C0_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_C0_FM4, $30, $00

SonicCD_C0_FM4:
	smpsSetvoice	$00
	dc.b	nG3, $07, nEb2, $07
	smpsStop

SonicCD_C0_Voices:
;	Voice $00
;	$3C
;	$02, $03, $03, $04,	$1F, $1A, $18, $1C,	$17, $11, $1A, $0E
;	$00, $0F, $14, $10,	$1F, $9F, $9F, $2F,	$06, $84, $45, $37
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$04, $03, $03, $02
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1C, $18, $1A, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0E, $1A, $11, $17
	smpsVcDecayLevel	$02, $09, $09, $01
	smpsVcDecayRate2	$10, $14, $0F, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$37, $45, $84, $06
	