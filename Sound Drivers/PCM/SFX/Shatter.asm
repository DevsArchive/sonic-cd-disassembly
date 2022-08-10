Shatter_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Shatter_PCM7, $00, $FF

Shatter_PCM7:
	smpsSetvoice	sShatter
	dc.b	nB1, $29
	smpsStop
