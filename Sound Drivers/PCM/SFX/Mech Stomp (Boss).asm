MechStomp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, MechStomp_PCM7, $05, $FF

MechStomp_PCM7:
	smpsSetvoice	sMechStomp
	dc.b	nA1, $1C
	smpsStop
