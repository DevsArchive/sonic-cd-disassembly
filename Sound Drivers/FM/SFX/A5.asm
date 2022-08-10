SonicCD_A5_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_A5_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_A5_FM6, $00, $08

SonicCD_A5_FM6:
	smpsSetvoice	$00
	dc.b	nEb5, $0B
	smpsStop

SonicCD_A5_Voices:
;	Voice $00
;	$3D
;	$01, $03, $03, $03,	$14, $0E, $0E, $0D,	$08, $35, $02, $91
;	$00, $50, $60, $56,	$1F, $1F, $1F, $1F,	$18, $82, $97, $80
	smpsVcAlgorithm		$05
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$03, $03, $03, $01
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$0D, $0E, $0E, $14
	smpsVcAmpMod		$01, $00, $00, $00
	smpsVcDecayRate1	$11, $02, $35, $08
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$56, $60, $50, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $97, $82, $18
	