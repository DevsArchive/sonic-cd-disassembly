SonicCD_B1_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B1_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_B1_FM6, 00h, 04h

SonicCD_B1_FM6:
	smpsSetvoice	00h
	db	nF3, 3Ch
	smpsStop

SonicCD_B1_Voices:
;	Voice 00h
;	83h
;	1Fh, 15h, 1Fh, 1Fh,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 08h
;	00h, 00h, 00h, 0Eh,	1Fh, 1Fh, 1Fh, 1Fh,	0Bh, 16h, 01h, 82h
	smpsVcAlgorithm		03h
	smpsVcFeedback		00h
	smpsVcUnusedBits	02h
	smpsVcDetune		01h, 01h, 01h, 01h
	smpsVcCoarseFreq	0Fh, 0Fh, 05h, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	08h, 00h, 00h, 00h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	0Eh, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	82h, 01h, 16h, 0Bh
	