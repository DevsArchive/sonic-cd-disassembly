SonicCD_AB_Header:
	smpsHeaderStartSong	$06
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM1, SonicCD_AB_FM1, $00, $00

SonicCD_AB_FM1:
	smpsStop
	smpsStop	; Unused
	