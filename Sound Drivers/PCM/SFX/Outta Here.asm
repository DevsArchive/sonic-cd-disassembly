OuttaHere_Header:
	smpsHeaderStartSong	$06
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, OuttaHere_PCM7, $05, $FF

OuttaHere_PCM7:
	smpsSetvoice	sOuttaHere
	smpsAlterNote	$20
	dc.b	nFs1, $2D
	smpsStop
