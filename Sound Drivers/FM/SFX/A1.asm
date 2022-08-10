SonicCD_A1_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A1_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_A1_FM4, 10h, 0Ah

SonicCD_A1_FM4:
	smpsSetvoice	00h
	db	nEb5, 03h, nRst, 02h, nG6, 03h, nRst, 02h
	smpsStop

SonicCD_A1_Voices:
;	Voice 00h
;	0F9h
;	21h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Ch, 06h, 04h, 80h
	smpsVcAlgorithm		01h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 06h, 0Ch
	