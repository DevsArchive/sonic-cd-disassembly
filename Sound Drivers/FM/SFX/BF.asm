SonicCD_BF_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_BF_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_BF_FM4, $31, $07

SonicCD_BF_FM4:
	smpsSetvoice	$00
	dc.b	nB1, $06, nB1, $07
	smpsStop

SonicCD_BF_Voices:
;	Voice $00
;	$3C
;	$04, $00, $02, $07,	$1F, $1A, $18, $1C,	$17, $11, $1A, $0E
;	$00, $0F, $14, $10,	$1F, $9F, $9F, $2F,	$08, $84, $05, $89
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$07, $02, $00, $04
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1C, $18, $1A, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0E, $1A, $11, $17
	smpsVcDecayLevel	$02, $09, $09, $01
	smpsVcDecayRate2	$10, $14, $0F, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$89, $05, $84, $08
	