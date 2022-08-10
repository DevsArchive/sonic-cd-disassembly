SonicCD_C8_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C8_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_C8_FM6, 00h, 02h

SonicCD_C8_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 50h, 02h
	db	nEb6, 65h
	smpsStop

SonicCD_C8_Voices:
;	Voice 00h
;	20h
;	36h, 35h, 30h, 31h,	41h, 49h, 3Bh, 4Bh,	09h, 06h, 09h, 08h
;	01h, 03h, 02h, 0A9h,	0Fh, 0Fh, 0Fh, 0Fh,	29h, 27h, 23h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		04h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	01h, 00h, 05h, 06h
	smpsVcRateScale		01h, 00h, 01h, 01h
	smpsVcAttackRate	0Bh, 3Bh, 09h, 01h
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	08h, 09h, 06h, 09h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	0A9h, 02h, 03h, 01h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 23h, 27h, 29h
	