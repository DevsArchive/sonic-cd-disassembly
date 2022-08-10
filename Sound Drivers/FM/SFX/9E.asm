SonicCD_9E_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_9E_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM3, SonicCD_9E_FM3, $0B, $02
	smpsHeaderSFXChannel	cFM4, SonicCD_9E_FM4, $00, $02

SonicCD_9E_FM3:
	smpsSetvoice	$00
	smpsModSet	$03, $01, $20, $04

SonicCD_9E_Loop1:
	dc.b	nC0, $0E
	smpsFMAlterVol	$0E
	smpsLoop	$00, $04, SonicCD_9E_Loop1
	smpsStop

SonicCD_9E_FM4:
	smpsSetvoice	$01
	dc.b	nA3, $13
	smpsStop

SonicCD_9E_Voices:
;	Voice $00
;	$F9
;	$21, $30, $10, $32,	$1F, $1F, $1F, $1F,	$05, $18, $09, $02
;	$0B, $1F, $10, $05,	$1F, $2F, $4F, $2F,	$0E, $06, $04, $80
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
	smpsVcTotalLevel	$80, $04, $06, $0E
	
;	Voice $01
;	$3C
;	$0F, $00, $00, $00,	$1F, $1A, $18, $1C,	$17, $11, $1A, $0E
;	$00, $0F, $14, $10,	$1F, $9F, $9F, $2F,	$07, $80, $26, $80
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
	smpsVcTotalLevel	$80, $26, $80, $07
	