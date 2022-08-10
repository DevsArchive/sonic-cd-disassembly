Unknown_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Unknown_PCM7, $00, $FF

Unknown_PCM7:
	smpsUnkFE	$00, $09
	dc.b	nC0
	smpsStop
