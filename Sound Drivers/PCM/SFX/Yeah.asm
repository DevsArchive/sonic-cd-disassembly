Yeah_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Yeah_PCM7, $05, $FF

Yeah_PCM7:
	smpsSetvoice	sYeah
	smpsAlterNote	$15
	dc.b	nFs1, $20
	smpsStop
