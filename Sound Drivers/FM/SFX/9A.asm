SonicCD_9A_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_9A_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	04h
	smpsHeaderSFXChannel	cFM4, SonicCD_9A_FM4, 0F5h, 05h
	smpsHeaderSFXChannel	cFM5, SonicCD_9A_FM5, 00h, 00h
	smpsHeaderSFXChannel	cFM3, SonicCD_9A_FM3, 00h, 00h
	smpsHeaderSFXChannel	cFM6, SonicCD_9A_FM6, 00h, 00h

SonicCD_9A_FM6:
	smpsSetvoice	00h
	db	nA0, 08h, nRst, 02h, nA0, 08h
	smpsStop

SonicCD_9A_FM5:
	smpsSetvoice	01h
	db	nRst, 12h, nA5, 55h
	smpsStop

SonicCD_9A_FM4:
	smpsSetvoice	02h
	db	nRst, 02h, nF5, 05h, 04h, 05h, 04h
	smpsStop

SonicCD_9A_FM3:
	smpsSetvoice	01h
	db	nRst, 12h, nA5, 55h
	smpsStop

SonicCD_9A_Voices:
;	Voice 00h
;	3Bh
;	03h, 02h, 03h, 06h,	18h, 1Ah, 1Ah, 96h,	17h, 0Eh, 0Ah, 10h
;	00h, 00h, 00h, 00h,	0FFh, 0FFh, 0FFh, 0FFh,	00h, 28h, 39h, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	06h, 03h, 02h, 03h
	smpsVcRateScale		02h, 00h, 00h, 00h
	smpsVcAttackRate	16h, 1Ah, 1Ah, 18h
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	10h, 0Ah, 0Eh, 17h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 39h, 28h, 00h
	
;	Voice 01h
;	04h
;	37h, 72h, 77h, 49h,	1Fh, 1Fh, 1Fh, 1Fh,	07h, 0Ah, 07h, 0Dh
;	00h, 0Bh, 00h, 0Bh,	1Fh, 0Fh, 1Fh, 0Fh,	23h, 80h, 23h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		04h, 07h, 07h, 03h
	smpsVcCoarseFreq	09h, 07h, 02h, 07h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 07h, 0Ah, 07h
	smpsVcDecayLevel	00h, 01h, 00h, 01h
	smpsVcDecayRate2	0Bh, 00h, 0Bh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 23h, 80h, 23h
	
;	Voice 02h
;	3Ch
;	0Fh, 00h, 00h, 00h,	1Fh, 1Ah, 18h, 1Ch,	17h, 11h, 1Ah, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	07h, 80h, 26h, 8Ch
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
	smpsVcTotalLevel	8Ch, 26h, 80h, 07h
	