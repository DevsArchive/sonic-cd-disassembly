SonicCD_D0_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D0_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_D0_FM6, 0Dh, 07h

SonicCD_D0_FM6:
	smpsSetvoice	00h
	db	nCs0, 07h, nA0, 25h
	smpsStop

SonicCD_D0_Voices:
;	Voice 00h
;	3Dh
;	13h, 75h, 13h, 30h,	5Fh, 5Fh, 5Fh, 5Fh,	0Dh, 0Ah, 0Ah, 0Ah
;	0Dh, 0Dh, 0Dh, 0Dh,	4Fh, 0Fh, 0Fh, 0Fh,	0Bh, 80h, 80h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 01h, 07h, 01h
	smpsVcCoarseFreq	00h, 03h, 05h, 03h
	smpsVcRateScale		01h, 01h, 01h, 01h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ah, 0Ah, 0Ah, 0Dh
	smpsVcDecayLevel	00h, 00h, 00h, 04h
	smpsVcDecayRate2	0Dh, 0Dh, 0Dh, 0Dh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 80h, 0Bh
	