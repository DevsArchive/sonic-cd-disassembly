SonicCD_98_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_98_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_98_FM6, 00h, 07h

SonicCD_98_FM6:
	smpsSetvoice	00h
	db	nRst, 01h
	smpsModSet	03h, 01h, 5Dh, 0Fh
	db	nB3, 06h
	smpsModOff
	smpsSetvoice	01h

SonicCD_98_Loop1:
	db	nC5, 02h
	smpsFMAlterVol	01h
	db	smpsNoAttack
	smpsLoop	00h, 19h, SonicCD_98_Loop1
	smpsStop

SonicCD_98_Voices:
;	Voice 00h
;	20h
;	36h, 35h, 30h, 31h,	0DFh, 0DFh, 9Fh, 9Fh,	07h, 06h, 09h, 06h
;	07h, 06h, 06h, 08h,	2Fh, 1Fh, 1Fh, 0FFh,	16h, 30h, 13h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		04h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	01h, 00h, 05h, 06h
	smpsVcRateScale		02h, 02h, 03h, 03h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	06h, 09h, 06h, 07h
	smpsVcDecayLevel	0Fh, 01h, 01h, 02h
	smpsVcDecayRate2	08h, 06h, 06h, 07h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 13h, 30h, 16h
	
;	Voice 01h
;	20h
;	31h, 33h, 30h, 31h,	9Fh, 9Fh, 9Fh, 9Fh,	07h, 06h, 09h, 06h
;	07h, 06h, 06h, 08h,	2Fh, 1Fh, 1Fh, 0FFh,	19h, 23h, 11h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		04h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	01h, 00h, 03h, 01h
	smpsVcRateScale		02h, 02h, 02h, 02h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	06h, 09h, 06h, 07h
	smpsVcDecayLevel	0Fh, 01h, 01h, 02h
	smpsVcDecayRate2	08h, 06h, 06h, 07h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 11h, 23h, 19h
	