SonicCD_CE_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_CE_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM1, SonicCD_CE_FM1, $00, $00
	smpsHeaderSFXChannel	cFM2, SonicCD_CE_FM2, $00, $00

SonicCD_CE_FM1:
	smpsSetvoice	$00
	smpsModSet	$01, $01, $01, $01
	dc.b	nF2, $1C
	smpsStop

SonicCD_CE_FM2:
	smpsSetvoice	$01
	smpsModSet	$01, $01, $A4, $56
	dc.b	nE5, $1D
	smpsStop

SonicCD_CE_Voices:
;	Voice $00
;	$3C
;	$02, $00, $01, $01,	$1F, $1F, $1F, $1F,	$00, $0E, $19, $10
;	$00, $0C, $00, $0F,	$0F, $EF, $FF, $FF,	$05, $80, $00, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$01, $01, $00, $02
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$10, $19, $0E, $00
	smpsVcDecayLevel	$0F, $0F, $0E, $00
	smpsVcDecayRate2	$0F, $00, $0C, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $00, $80, $05
	
;	Voice $01
;	$03
;	$02, $37, $33, $31,	$1F, $1F, $1F, $54,	$03, $05, $04, $0A
;	$02, $02, $02, $03,	$2F, $2F, $2F, $5F,	$03, $15, $22, $80
	smpsVcAlgorithm		$03
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $03, $03, $00
	smpsVcCoarseFreq	$01, $03, $07, $02
	smpsVcRateScale		$01, $00, $00, $00
	smpsVcAttackRate	$14, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0A, $04, $05, $03
	smpsVcDecayLevel	$05, $02, $02, $02
	smpsVcDecayRate2	$03, $02, $02, $02
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $22, $15, $03
	