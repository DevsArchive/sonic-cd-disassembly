SonicCD_93_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_93_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM2, SonicCD_93_FM2, $F4, $00

SonicCD_93_FM2:
	smpsSetvoice	$00
	dc.b	nB3, $07, smpsNoAttack, nAb3

SonicCD_93_Loop1:
	dc.b	$01
	smpsFMAlterVol	$01
	smpsLoop	$00, $2F, SonicCD_93_Loop1
	smpsStop

SonicCD_93_Voices:
;	Voice $00
;	$30
;	$30, $30, $30, $30,	$9E, $D8, $DC, $DC,	$0E, $0A, $04, $05
;	$08, $08, $08, $08,	$BF, $BF, $BF, $BF,	$14, $3C, $14, $80
	smpsVcAlgorithm		$00
	smpsVcFeedback		$06
	smpsVcUnusedBits	$00
	smpsVcDetune		$03, $03, $03, $03
	smpsVcCoarseFreq	$00, $00, $00, $00
	smpsVcRateScale		$03, $03, $03, $02
	smpsVcAttackRate	$1C, $1C, $18, $1E
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$05, $04, $0A, $0E
	smpsVcDecayLevel	$0B, $0B, $0B, $0B
	smpsVcDecayRate2	$08, $08, $08, $08
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $14, $3C, $14
	