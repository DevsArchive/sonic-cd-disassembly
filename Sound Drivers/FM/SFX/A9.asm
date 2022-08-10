SonicCD_A9_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_A9_FM5, 00h, 00h
	smpsHeaderSFXChannel	cFM6, SonicCD_A9_FM6, 00h, 0Dh

SonicCD_A9_FM5:
	smpsStop

SonicCD_A9_FM6:
	smpsStop
	