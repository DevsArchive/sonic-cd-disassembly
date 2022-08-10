SonicCD_BC_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_BC_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM6, SonicCD_BC_FM6, 13h, 0Fh
	smpsHeaderSFXChannel	cFM5, SonicCD_BC_FM6, 00h, 0Fh

SonicCD_BC_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 2Ah, 0FFh
	db	nEb2, 18h, nFs2, 18h, nD3, 18h
	smpsStop

SonicCD_BC_Voices:
;	Voice 00h
;	16h
;	53h, 54h, 30h, 31h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 08h, 06h, 08h
;	05h, 05h, 07h, 05h,	2Fh, 0FFh, 5Fh, 2Fh,	1Eh, 80h, 80h, 80h
	smpsVcAlgorithm		06h
	smpsVcFeedback		02h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 05h, 05h
	smpsVcCoarseFreq	01h, 00h, 04h, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	08h, 06h, 08h, 05h
	smpsVcDecayLevel	02h, 05h, 0Fh, 02h
	smpsVcDecayRate2	05h, 07h, 05h, 05h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 80h, 1Eh
	