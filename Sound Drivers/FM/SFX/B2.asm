SonicCD_B2_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_B2_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_B2_FM6, $FC, $02

SonicCD_B2_FM6:
	smpsSetvoice	$00
	dc.b	nD4, $05, nRst, $01, nD4, $05, nRst, $01
	dc.b	nD4, $09
	smpsStop

SonicCD_B2_Voices:
;	Voice $00
;	$83
;	$12, $10, $13, $1E,	$1F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$02, $02, $02, $02,	$2F, $2F, $FF, $3F,	$05, $10, $34, $87
	smpsVcAlgorithm		$03
	smpsVcFeedback		$00
	smpsVcUnusedBits	$02
	smpsVcDetune		$01, $01, $01, $01
	smpsVcCoarseFreq	$0E, $03, $00, $02
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$03, $0F, $02, $02
	smpsVcDecayRate2	$02, $02, $02, $02
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$87, $34, $10, $05
	