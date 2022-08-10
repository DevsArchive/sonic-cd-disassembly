Future_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Future_PCM7, $00, $FF

Future_PCM7:
	smpsSetvoice	sFuture
	dc.b	nC2, $36
	smpsStop
