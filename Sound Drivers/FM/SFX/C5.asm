SonicCD_C5_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C5_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_C5_FM6, 00h, 05h

SonicCD_C5_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 02h, 02h
	db	nEb5, 33h
	smpsStop

SonicCD_C5_Voices:
;	Voice 00h
;	38h
;	0Fh, 0Fh, 0Fh, 0Fh,	1Fh, 1Fh, 1Fh, 0Eh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 1Fh,	2Eh, 10h, 00h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	0Eh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	01h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 10h, 2Eh
	