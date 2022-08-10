SonicCD_CE_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_CE_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM1, SonicCD_CE_FM1, 00h, 00h
	smpsHeaderSFXChannel	cFM2, SonicCD_CE_FM2, 00h, 00h

SonicCD_CE_FM1:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 01h, 01h
	db	nF2, 1Ch
	smpsStop

SonicCD_CE_FM2:
	smpsSetvoice	01h
	smpsModSet	01h, 01h, 0A4h, 56h
	db	nE5, 1Dh
	smpsStop

SonicCD_CE_Voices:
;	Voice 00h
;	3Ch
;	02h, 00h, 01h, 01h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 0Eh, 19h, 10h
;	00h, 0Ch, 00h, 0Fh,	0Fh, 0EFh, 0FFh, 0FFh,	05h, 80h, 00h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	01h, 01h, 00h, 02h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	10h, 19h, 0Eh, 00h
	smpsVcDecayLevel	0Fh, 0Fh, 0Eh, 00h
	smpsVcDecayRate2	0Fh, 00h, 0Ch, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 80h, 05h
	
;	Voice 01h
;	03h
;	02h, 37h, 33h, 31h,	1Fh, 1Fh, 1Fh, 54h,	03h, 05h, 04h, 0Ah
;	02h, 02h, 02h, 03h,	2Fh, 2Fh, 2Fh, 5Fh,	03h, 15h, 22h, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 00h
	smpsVcCoarseFreq	01h, 03h, 07h, 02h
	smpsVcRateScale		01h, 00h, 00h, 00h
	smpsVcAttackRate	14h, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ah, 04h, 05h, 03h
	smpsVcDecayLevel	05h, 02h, 02h, 02h
	smpsVcDecayRate2	03h, 02h, 02h, 02h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 22h, 15h, 03h
	