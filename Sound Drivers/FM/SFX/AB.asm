SonicCD_AB_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM1, SonicCD_AB_FM1, 00h, 00h

SonicCD_AB_FM1:
	smpsStop
	smpsStop	; Unused
	