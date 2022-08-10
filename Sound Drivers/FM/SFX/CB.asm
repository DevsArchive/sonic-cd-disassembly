SonicCD_CB_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_CB_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM6, SonicCD_CB_FM6, $00, $17

SonicCD_CB_FM6:
	smpsSetvoice	$00
	smpsModSet	$01, $01, $2F, $09

SonicCD_CB_Loop1:
	dc.b	nG2, $10, smpsNoAttack
	smpsFMAlterVol	$02
	smpsLoop	$00, $10, SonicCD_CB_Loop1

SonicCD_CB_Loop2:
	dc.b	nG2, $10, smpsNoAttack
	smpsFMAlterVol	$FE
	smpsLoop	$00, $10, SonicCD_CB_Loop2
	smpsJump	SonicCD_CB_Loop1
	smpsStop	; Unused

SonicCD_CB_Voices:
;	Voice $00
;	$47
;	$08, $08, $08, $08,	$1F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$FF, $FF, $FF, $FF,	$81, $81, $81, $81
	smpsVcAlgorithm		$07
	smpsVcFeedback		$00
	smpsVcUnusedBits	$01
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$08, $08, $08, $08
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$81, $81, $81, $81
	