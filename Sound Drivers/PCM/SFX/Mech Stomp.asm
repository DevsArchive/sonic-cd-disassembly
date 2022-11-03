MechStomp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, MechStomp_PCM7, $00, $FF

MechStomp_PCM7:
	smpsSetvoice	sMechStomp
	dc.b	nD1, $04, nCs2, $1E
	smpsStop
