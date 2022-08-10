SonicCD_D4_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D4_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM3, SonicCD_D4_FM3, $00, $00
	smpsHeaderSFXChannel	cFM4, SonicCD_D4_FM4, $00, $00

SonicCD_D4_FM4:
	dc.b	nRst, $03

SonicCD_D4_FM3:
	smpsSetvoice	$00
	dc.b	nB6, $05, nRst, $06, nAb7, $11
	smpsStop

SonicCD_D4_Voices:
;	Voice $00
;	$34
;	$0C, $0A, $04, $03,	$1F, $1F, $1F, $1F,	$0C, $0D, $09, $0C
;	$0A, $0E, $0D, $0E,	$35, $1A, $55, $3A,	$0F, $80, $0F, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$06
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$03, $04, $0A, $0C
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0C, $09, $0D, $0C
	smpsVcDecayLevel	$03, $05, $01, $03
	smpsVcDecayRate2	$0E, $0D, $0E, $0A
	smpsVcReleaseRate	$0A, $05, $0A, $05
	smpsVcTotalLevel	$80, $0F, $80, $0F
	