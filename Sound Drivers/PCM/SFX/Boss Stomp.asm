BossStomp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, BossStomp_PCM7, $00, $FF

BossStomp_PCM7:
	smpsSetvoice	sBossStomp
	dc.b	nD1, $04, nCs2, $1E
	smpsStop
