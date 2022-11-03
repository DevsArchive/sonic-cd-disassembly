Bumper_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Bumper_PCM7, $05, $FF

Bumper_PCM7:
	smpsSetvoice	sBumper
	dc.b	nA1, $1C
	smpsStop
