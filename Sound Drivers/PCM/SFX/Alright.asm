Alright_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Alright_PCM7, $05, $FF

Alright_PCM7:
	smpsSetvoice	sAlright
	smpsAlterNote	$15
	dc.b	nBb1, $2E
	smpsStop
