SonicCD_A3_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_A3_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$03
	smpsHeaderSFXChannel	cFM4, SonicCD_A3_FM4, $10, $05
	smpsHeaderSFXChannel	cFM5, SonicCD_A3_FM5, $10, $05
	smpsHeaderSFXChannel	cFM6, SonicCD_A3_FM6, $00, $05

SonicCD_A3_FM4:
	smpsPan		panRight, $00
	dc.b	nRst, $02
	smpsJump	SonicCD_A3_FM6

SonicCD_A3_FM5:
	smpsPan		panLeft, $00
	dc.b	nRst, $01

SonicCD_A3_FM6:
	smpsSetvoice	$00
	smpsModSet	$03, $01, $20, $04

SonicCD_A3_Loop1:
	dc.b	nC0, $18
	smpsFMAlterVol	$0A
	smpsLoop	$00, $06, SonicCD_A3_Loop1
	smpsStop

SonicCD_A3_Voices:
;	Voice $00
;	$F9
;	$21, $30, $10, $32,	$1F, $1F, $1F, $1F,	$05, $18, $09, $02
;	$0B, $1F, $10, $05,	$1F, $2F, $4F, $2F,	$0E, $07, $04, $80
	smpsVcAlgorithm		$01
	smpsVcFeedback		$07
	smpsVcUnusedBits	$03
	smpsVcDetune		$03, $01, $03, $02
	smpsVcCoarseFreq	$02, $00, $00, $01
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$02, $09, $18, $05
	smpsVcDecayLevel	$02, $04, $02, $01
	smpsVcDecayRate2	$05, $10, $1F, $0B
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $04, $07, $0E
	