SonicCD_C7_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C7_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_C7_FM6, 00h, 0Bh

SonicCD_C7_FM6:
	smpsSetvoice	00h
	db	nF1, 3Fh
	smpsStop

SonicCD_C7_Voices:
;	Voice 00h
;	3Dh
;	03h, 06h, 02h, 02h,	0Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	0Ch, 82h, 80h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	02h, 02h, 06h, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 0Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 82h, 0Ch
	