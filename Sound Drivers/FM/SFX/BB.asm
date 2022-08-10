SonicCD_BB_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_BB_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_BB_FM6, $00, $06

SonicCD_BB_FM6:
	smpsSetvoice	$00
	smpsModSet	$01, $01, $06, $FF
	dc.b	nAb1, $33
	smpsStop

SonicCD_BB_Voices:
;	Voice $00
;	$28
;	$03, $0B, $11, $03,	$1F, $19, $1F, $1F,	$02, $01, $02, $0E
;	$01, $01, $01, $01,	$1F, $1F, $1F, $1F,	$15, $26, $1C, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$05
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $01, $00, $00
	smpsVcCoarseFreq	$03, $01, $0B, $03
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $19, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0E, $02, $01, $02
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$01, $01, $01, $01
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $1C, $26, $15
	