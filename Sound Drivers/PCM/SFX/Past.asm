Past_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Past_PCM7, $00, $FF

Past_PCM7:
	smpsSetvoice	sPast
	dc.b	nC2, $2E
	smpsStop
