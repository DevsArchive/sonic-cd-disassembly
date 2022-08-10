SonicCD_BE_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_BE_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_BE_FM4, $03, $00

SonicCD_BE_FM4:
	smpsSetvoice	$00
	dc.b	nEb5, $10
	smpsStop

SonicCD_BE_Voices:
;	Voice $00
;	$02
;	$02, $03, $23, $01,	$1E, $1E, $1E, $1E,	$10, $0A, $12, $12
;	$01, $00, $00, $13,	$FF, $FF, $FF, $FF,	$08, $0E, $1F, $80
	smpsVcAlgorithm		$02
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $02, $00, $00
	smpsVcCoarseFreq	$01, $03, $03, $02
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1E, $1E, $1E, $1E
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$12, $12, $0A, $10
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$13, $00, $00, $01
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $1F, $0E, $08
	