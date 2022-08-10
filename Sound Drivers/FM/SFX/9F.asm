SonicCD_9F_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_9F_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_9F_FM5, 00h, 03h
	smpsHeaderSFXChannel	cFM6, SonicCD_9F_FM6, 00h, 05h

SonicCD_9F_FM5:
	smpsSetvoice	00h
	db	nA4, 15h
	smpsStop

SonicCD_9F_FM6:
	smpsSetvoice	01h
	db	nA4, 10h
	smpsStop

SonicCD_9F_Voices:
;	Voice 00h
;	07h
;	03h, 03h, 02h, 00h,	6Fh, 4Fh, 6Fh, 3Fh,	12h, 11h, 14h, 0Eh
;	1Ah, 03h, 0Ah, 0Dh,	0FFh, 0FFh, 0FFh, 0FFh,	83h, 86h, 86h, 80h
	smpsVcAlgorithm		07h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 02h, 03h, 03h
	smpsVcRateScale		00h, 01h, 01h, 01h
	smpsVcAttackRate	3Fh, 2Fh, 0Fh, 2Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 14h, 11h, 12h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	0Dh, 0Ah, 03h, 1Ah
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 86h, 86h, 83h
	
;	Voice 01h
;	3Ch
;	0Fh, 00h, 00h, 00h,	1Fh, 1Ah, 18h, 1Ch,	17h, 11h, 1Ah, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	07h, 80h, 16h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Ch, 18h, 1Ah, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 1Ah, 11h, 17h
	smpsVcDecayLevel	02h, 09h, 09h, 01h
	smpsVcDecayRate2	10h, 14h, 0Fh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 16h, 80h, 07h
	