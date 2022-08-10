SonicCD_C6_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C6_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_C6_FM5, 00h, 05h
	smpsHeaderSFXChannel	cFM6, SonicCD_C6_FM6, 00h, 05h

SonicCD_C6_FM5:
	db	nRst, 05h

SonicCD_C6_FM6:
	smpsSetvoice	00h

SonicCD_C6_Loop1:
	db	nG6, 07h, nRst, 03h
	smpsLoop	00h, 04h, SonicCD_C6_Loop1
	smpsStop

SonicCD_C6_Voices:
;	Voice 00h
;	38h
;	0Fh, 0Fh, 0Fh, 0Fh,	1Fh, 1Fh, 1Fh, 0Eh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 1Fh,	1Bh, 10h, 00h, 80h
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
	smpsVcTotalLevel	80h, 00h, 10h, 1Bh
	