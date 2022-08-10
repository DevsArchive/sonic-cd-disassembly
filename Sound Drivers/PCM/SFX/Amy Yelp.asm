AmyYelp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, AmyYelp_PCM7, $05, $FF

AmyYelp_PCM7:
	smpsSetvoice	sAmyYelp
	dc.b	nBb1, $09
	smpsStop
