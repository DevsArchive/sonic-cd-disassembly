AmyGiggle_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, AmyGiggle_PCM7, $00, $FF

AmyGiggle_PCM7:
	smpsSetvoice	sAmyGiggle
	dc.b	nB1, $18
	smpsStop
