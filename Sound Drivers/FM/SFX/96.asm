SonicCD_96_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_96_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_96_FM3, 00h, 00h
	smpsHeaderSFXChannel	cFM4, SonicCD_96_FM4, 00h, 0Bh

SonicCD_96_FM3:
	smpsModSet	03h, 01h, 72h, 0Bh
	smpsSetvoice	00h
	db	nA4, 16h
	smpsStop

SonicCD_96_FM4:
	smpsSetvoice	01h
	db	nB3, 13h
	smpsStop

SonicCD_96_Voices:
;	Voice 00h
;	3Ch
;	0Fh, 01h, 03h, 01h,	1Fh, 1Fh, 1Fh, 1Fh,	19h, 12h, 19h, 0Eh
;	05h, 12h, 00h, 0Fh,	0Fh, 7Fh, 0FFh, 0FFh,	00h, 80h, 00h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	01h, 03h, 01h, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 19h, 12h, 19h
	smpsVcDecayLevel	0Fh, 0Fh, 07h, 00h
	smpsVcDecayRate2	0Fh, 00h, 12h, 05h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 80h, 00h
	
;	Voice 01h
;	3Ch
;	0Fh, 00h, 00h, 00h,	1Fh, 1Ah, 18h, 1Ch,	17h, 11h, 1Ah, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	07h, 80h, 26h, 80h
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
	smpsVcTotalLevel	80h, 26h, 80h, 07h
	