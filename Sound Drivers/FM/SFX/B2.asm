SonicCD_B2_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B2_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_B2_FM6, 0FCh, 02h

SonicCD_B2_FM6:
	smpsSetvoice	00h
	db	nD4, 05h, nRst, 01h, nD4, 05h, nRst, 01h
	db	nD4, 09h
	smpsStop

SonicCD_B2_Voices:
;	Voice 00h
;	83h
;	12h, 10h, 13h, 1Eh,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	02h, 02h, 02h, 02h,	2Fh, 2Fh, 0FFh, 3Fh,	05h, 10h, 34h, 87h
	smpsVcAlgorithm		03h
	smpsVcFeedback		00h
	smpsVcUnusedBits	02h
	smpsVcDetune		01h, 01h, 01h, 01h
	smpsVcCoarseFreq	0Eh, 03h, 00h, 02h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	03h, 0Fh, 02h, 02h
	smpsVcDecayRate2	02h, 02h, 02h, 02h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	87h, 34h, 10h, 05h
	