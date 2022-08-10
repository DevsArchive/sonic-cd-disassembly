SonicCD_DF_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_DF_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM5, SonicCD_DF_FM5, $04, $08

SonicCD_DF_FM5:
	smpsSetvoice	$00

SonicCD_DF_Loop1:
	smpsCall	SonicCD_DF_Call1
	smpsAlterPitch	$05
	smpsFMAlterVol	$08
	smpsLoop	$01, $03, SonicCD_DF_Loop1
	smpsAlterPitch	$EC
	smpsFMAlterVol	$E0
	smpsStop

SonicCD_DF_Call1:
	dc.b	nC2, $02
	smpsAlterPitch	$01
	smpsLoop	$00, $0A, SonicCD_DF_Call1
	smpsAlterPitch	$F6
	smpsReturn

	; Unused
	smpsSetvoice	$00
	dc.b	nRst, $0A
	smpsStop

SonicCD_DF_Voices:
;	Voice $00
;	$07
;	$04, $04, $05, $04,	$1F, $1F, $15, $15,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$1F, $1F, $1F, $1F,	$7F, $7F, $80, $80
	smpsVcAlgorithm		$07
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$04, $05, $04, $04
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$15, $15, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$01, $01, $01, $01
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $80, $7F, $7F
	