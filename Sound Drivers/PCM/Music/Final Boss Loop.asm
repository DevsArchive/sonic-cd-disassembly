FinalBossLoop_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $06
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_PCM1, $00, $FF
	smpsHeaderPCM		FinalBossLoop_PCM2, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF
	smpsHeaderPCM		FinalBossLoop_Rhythm, $00, $FF

FinalBossLoop_PCM1:
	smpsPan		$F0
	smpsSetvoice	sLoopR
	smpsAlterNote	$27
	dc.b	nB1, $7F, smpsNoAttack, $24
	smpsCDDALoop
	smpsStop

FinalBossLoop_PCM2:
	smpsPan		$0F
	smpsSetvoice	sLoopL
	smpsAlterNote	$27
	dc.b	nB1, $7F, smpsNoAttack, $24
	smpsStop

FinalBossLoop_Rhythm:
	smpsStop
