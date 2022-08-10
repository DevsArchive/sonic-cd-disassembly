SonicCD_AA_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM2, SonicCD_AA_FM2, $00, $05

SonicCD_AA_FM2:
	smpsSetvoice	$00
	dc.b	nRst, $01
	smpsModSet	$03, $01, $09, $FF

SonicCD_AA_Loop1:
	dc.b	nCs6, $06
	smpsLoop	$00, $03, SonicCD_AA_Loop1
	smpsStop

SonicCD_AA_Voices:
;	Voice $00
;	$3C
;	$00, $44, $02, $02,	$1F, $1F, $1F, $15,	$00, $1F, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$0D, $80, $28, $80
	smpsVcAlgorithm		$04
	smpsVcFeedback		$07
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $04, $00
	smpsVcCoarseFreq	$02, $02, $04, $00
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$15, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $1F, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $28, $80, $0D
	