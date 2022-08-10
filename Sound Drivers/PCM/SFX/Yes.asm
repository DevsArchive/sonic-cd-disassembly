Yes_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Yes_PCM7, $05, $FF

Yes_PCM7:
	smpsSetvoice	sYes
	smpsAlterNote	$10
	dc.b	nCs2, $1B
	smpsStop
