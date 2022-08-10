SonicCD_C6_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_C6_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM5, SonicCD_C6_FM5, $00, $05
	smpsHeaderSFXChannel	cFM6, SonicCD_C6_FM6, $00, $05

SonicCD_C6_FM5:
	dc.b	nRst, $05

SonicCD_C6_FM6:
	smpsSetvoice	$00

SonicCD_C6_Loop1:
	dc.b	nG6, $07, nRst, $03
	smpsLoop	$00, $04, SonicCD_C6_Loop1
	smpsStop

SonicCD_C6_Voices:
;	Voice $00
;	$38
;	$0F, $0F, $0F, $0F,	$1F, $1F, $1F, $0E,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $1F,	$1B, $10, $00, $80
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
	smpsVcTotalLevel	$80, $00, $10, $1B
	