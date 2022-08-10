SonicCD_A9_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$02
	smpsHeaderSFXChannel	cFM5, SonicCD_A9_FM5, $00, $00
	smpsHeaderSFXChannel	cFM6, SonicCD_A9_FM6, $00, $0D

SonicCD_A9_FM5:
	smpsStop

SonicCD_A9_FM6:
	smpsStop
	