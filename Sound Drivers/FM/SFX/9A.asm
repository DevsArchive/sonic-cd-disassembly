SonicCD_9A_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_9A_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$04
	smpsHeaderSFXChannel	cFM4, SonicCD_9A_FM4, $F5, $05
	smpsHeaderSFXChannel	cFM5, SonicCD_9A_FM5, $00, $00
	smpsHeaderSFXChannel	cFM3, SonicCD_9A_FM3, $00, $00
	smpsHeaderSFXChannel	cFM6, SonicCD_9A_FM6, $00, $00

SonicCD_9A_FM6:
	smpsSetvoice	$00
	dc.b	nA0, $08, nRst, $02, nA0, $08
	smpsStop

SonicCD_9A_FM5:
	smpsSetvoice	$01
	dc.b	nRst, $12, nA5, $55
	smpsStop

SonicCD_9A_FM4:
	smpsSetvoice	$02
	dc.b	nRst, $02, nF5, $05, $04, $05, $04
	smpsStop

SonicCD_9A_FM3:
	smpsSetvoice	$01
	dc.b	nRst, $12, nA5, $55
	smpsStop

SonicCD_9A_Voices:
;	Voice $00
;	$3B
;	$03, $02, $03, $06,	$18, $1A, $1A, $96,	$17, $0E, $0A, $10
;	$00, $00, $00, $00,	$FF, $FF, $FF, $FF,	$00, $28, $39, $80
	smpsVcAlgorithm		$03
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$06, $03, $02, $03
	smpsVcRateScale		$02, $00, $00, $00
	smpsVcAttackRate	$16, $1A, $1A, $18
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$10, $0A, $0E, $17
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $39, $28, $00
	
;	Voice $01
;	$04
;	$37, $72, $77, $49,	$1F, $1F, $1F, $1F,	$07, $0A, $07, $0D
;	$00, $0B, $00, $0B,	$1F, $0F, $1F, $0F,	$23, $80, $23, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$04, $07, $07, $03
	smpsVcCoarseFreq	$09, $07, $02, $07
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0D, $07, $0A, $07
	smpsVcDecayLevel	$00, $01, $00, $01
	smpsVcDecayRate2	$0B, $00, $0B, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $23, $80, $23
	
;	Voice $02
;	$3C
;	$0F, $00, $00, $00,	$1F, $1A, $18, $1C,	$17, $11, $1A, $0E
;	$00, $0F, $14, $10,	$1F, $9F, $9F, $2F,	$07, $80, $26, $8C
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$00, $00, $00, $0F
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1C, $18, $1A, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0E, $1A, $11, $17
	smpsVcDecayLevel	$02, $09, $09, $01
	smpsVcDecayRate2	$10, $14, $0F, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$8C, $26, $80, $07
	