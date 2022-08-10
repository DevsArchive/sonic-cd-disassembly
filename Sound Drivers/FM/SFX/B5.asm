SonicCD_B5_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B5_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_B5_FM4, 0D0h, 0Dh

SonicCD_B5_FM4:
	smpsSetvoice	00h
	db	nF1, 03h, nCs2, 10h
	smpsStop

SonicCD_B5_Voices:
;	Voice 00h
;	3Dh
;	12h, 70h, 13h, 30h,	5Fh, 5Fh, 5Fh, 5Fh,	0Dh, 0Dh, 0Dh, 0Dh
;	0Dh, 0Fh, 0Fh, 0Fh,	4Fh, 4Fh, 4Fh, 4Fh,	14h, 80h, 80h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 01h, 07h, 01h
	smpsVcCoarseFreq	00h, 03h, 00h, 02h
	smpsVcRateScale		01h, 01h, 01h, 01h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 0Dh, 0Dh, 0Dh
	smpsVcDecayLevel	04h, 04h, 04h, 04h
	smpsVcDecayRate2	0Fh, 0Fh, 0Fh, 0Dh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 80h, 14h
	