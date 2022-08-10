SonicCD_CA_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_CA_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM4, SonicCD_CA_FM4, $00, $07

SonicCD_CA_FM4:
	smpsSetvoice	$00
	dc.b	nAb6, $30
	smpsStop

SonicCD_CA_Voices:
;	Voice $00
;	$34
;	$03, $02, $03, $04,	$1F, $1F, $1F, $1F,	$00, $00, $00, $00
;	$00, $00, $00, $00,	$0F, $0F, $0F, $0F,	$08, $0E, $8A, $8A
	smpsVcAlgorithm		$04
	smpsVcFeedback		$06
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$04, $03, $02, $03
	smpsVcRateScale		$00, $00, $00, $00
	smpsVcAttackRate	$1F, $1F, $1F, $1F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$00, $00, $00, $00
	smpsVcDecayLevel	$00, $00, $00, $00
	smpsVcDecayRate2	$00, $00, $00, $00
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$8A, $8A, $0E, $08
	