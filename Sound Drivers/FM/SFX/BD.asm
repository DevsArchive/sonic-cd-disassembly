SonicCD_BD_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_BD_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_BD_FM6, $07, $05

SonicCD_BD_FM6:
	smpsSetvoice	$00

SonicCD_BD_Loop1:
	dc.b	nEb5, $09
	smpsLoop	$00, $08, SonicCD_BD_Loop1
	smpsStop

SonicCD_BD_Voices:
;	Voice $00
;	$02
;	$02, $51, $20, $01,	$1E, $1E, $1E, $1E,	$10, $0A, $14, $13
;	$01, $00, $00, $00,	$FF, $FF, $FF, $FF,	$24, $0E, $1F, $80
	smpsVcAlgorithm		$02
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $02, $05, $00
	smpsVcCoarseFreq	$01, $00, $01, $02
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1E, $1E, $1E, $1E
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$13, $14, $0A, $10
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$00, $00, $00, $01
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $1F, $0E, $24
	