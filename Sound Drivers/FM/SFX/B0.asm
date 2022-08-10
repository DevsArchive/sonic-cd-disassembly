SonicCD_B0_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B0_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_B0_FM5, 10h, 07h
	smpsHeaderSFXChannel	cFM6, SonicCD_B0_FM6, 00h, 07h

SonicCD_B0_FM5:
	db	nRst, 01h

SonicCD_B0_FM6:
	smpsSetvoice	00h
	smpsModSet	03h, 01h, 20h, 04h

SonicCD_B0_Loop1:
	db	nC0, 10h
	smpsFMAlterVol	13h
	smpsLoop	00h, 06h, SonicCD_B0_Loop1
	smpsStop

SonicCD_B0_Voices:
;	Voice 00h
;	0F9h
;	21h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Eh, 07h, 04h, 80h
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
	smpsVcTotalLevel	80h, 04h, 07h, 0Eh
	