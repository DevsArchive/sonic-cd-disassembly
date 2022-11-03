BossLoop_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $06
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_PCM1, $00, $FF
	smpsHeaderPCM		BossLoop_PCM2, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		BossLoop_Rhythm, $00, $FF

BossLoop_PCM1:
	smpsPan		$FF
	smpsSetvoice	sLoop
	smpsAlterNote	$FF
	dc.b	nF2, $7F, smpsNoAttack, $52
	smpsCDDALoop
	smpsStop

BossLoop_PCM2:
	smpsPan		$FF
	smpsSetvoice	sLoop
	smpsAlterNote	$FF
	dc.b	nF2, $7F, smpsNoAttack, $52
	smpsStop

BossLoop_Rhythm:
	smpsStop
