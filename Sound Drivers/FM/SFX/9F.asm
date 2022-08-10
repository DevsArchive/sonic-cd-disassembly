SonicCD_9F_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_9F_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM5, SonicCD_9F_FM5, $00, $03
	smpsHeaderSFXChannel	cFM6, SonicCD_9F_FM6, $00, $05

SonicCD_9F_FM5:
	smpsSetvoice	$00
	dc.b	nA4, $15
	smpsStop

SonicCD_9F_FM6:
	smpsSetvoice	$01
	dc.b	nA4, $10
	smpsStop

SonicCD_9F_Voices:
;	Voice $00
;	$07
;	$03, $03, $02, $00,	$6F, $4F, $6F, $3F,	$12, $11, $14, $0E
;	$1A, $03, $0A, $0D,	$FF, $FF, $FF, $FF,	$83, $86, $86, $80
	smpsVcAlgorithm		$07
	smpsVcFeedback		$00
	smpsVcUnusedBits	$00
	smpsVcDetune		$00, $00, $00, $00
	smpsVcCoarseFreq	$00, $02, $03, $03
	smpsVcRateScale		$00, $01, $01, $01
	smpsVcAttackRate	$3F, $2F, $0F, $2F
	smpsVcAmpMod		$00, $00, $00, $00
	smpsVcDecayRate1	$0E, $14, $11, $12
	smpsVcDecayLevel	$0F, $0F, $0F, $0F
	smpsVcDecayRate2	$0D, $0A, $03, $1A
	smpsVcReleaseRate	$0F, $0F, $0F, $0F
	smpsVcTotalLevel	$80, $86, $86, $83
	
;	Voice $01
;	$3C
;	$0F, $00, $00, $00,	$1F, $1A, $18, $1C,	$17, $11, $1A, $0E
;	$00, $0F, $14, $10,	$1F, $9F, $9F, $2F,	$07, $80, $16, $80
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
	smpsVcTotalLevel	$80, $16, $80, $07
	