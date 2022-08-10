SonicCD_D8_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_D8_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$06
	smpsHeaderSFXChannel	cFM1, SonicCD_D8_FM1, $00, $05
	smpsHeaderSFXChannel	cFM2, SonicCD_D8_FM2, $00, $03
	smpsHeaderSFXChannel	cFM3, SonicCD_D8_FM3, $00, $05
	smpsHeaderSFXChannel	cFM4, SonicCD_D8_FM4, $00, $05
	smpsHeaderSFXChannel	cFM5, SonicCD_D8_FM5, $05, $0B
	smpsHeaderSFXChannel	cFM6, SonicCD_D8_FM6, $05, $0B

SonicCD_D8_FM1:
	smpsSetvoice	$00
	smpsPan		panLeft, $00

SonicCD_D8_Loop1:
	dc.b	nC4, $04
	smpsAlterPitch	$01
	smpsLoop	$00, $12, SonicCD_D8_Loop1
	smpsAlterPitch	$EE
	smpsAlterPitch	$03
	smpsFMAlterVol	$02
	smpsLoop	$01, $05, SonicCD_D8_Loop1
	smpsStop

SonicCD_D8_FM2:
	smpsSetvoice	$01
	smpsPan		panLeft, $00

SonicCD_D8_Loop2:
	dc.b	nF1, $04
	smpsAlterPitch	$01
	smpsLoop	$00, $0F, SonicCD_D8_Loop2

SonicCD_D8_Loop3:
	dc.b	nF1, $02
	smpsAlterPitch	$FF
	smpsLoop	$00, $0F, SonicCD_D8_Loop3
	smpsLoop	$01, $04, SonicCD_D8_Loop2
	smpsStop

SonicCD_D8_FM3:
	smpsSetvoice	$01
	smpsPan		panRight, $00
	dc.b	nRst, $05
	smpsJump	SonicCD_D8_Loop2
	smpsStop	; Unused

SonicCD_D8_FM4:
	smpsSetvoice	$00
	smpsPan		panRight, $00
	dc.b	nRst, $05
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_FM5:
	smpsSetvoice	$01
	smpsPan		panRight, $00
	dc.b	nRst, $03
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_FM6:
	smpsSetvoice	$01
	smpsPan		panLeft, $00
	dc.b	nRst, $04
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_Voices:
;	Voice $00
;	$04
;	$01, $03, $0A, $07,	$0F, $13, $13, $14,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$1F, $1F, $1F, $1F,	$02, $82, $1A, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$07, $0A, $03, $01
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$14, $13, $13, $0F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $1A, $82, $02
	
;	Voice $01
;	$04
;	$00, $04, $00, $01,	$09, $09, $1F, $1F,	$00, $00, $10, $0A
;	$00, $00, $10, $0A,	$1F, $1F, $1F, $1F,	$0F, $80, $0A, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$01, $00, $04, $00
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $09, $09
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0A, $10, $00, $00
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$0A, $10, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $0A, $80, $0F
	