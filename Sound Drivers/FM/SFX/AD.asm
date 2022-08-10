SonicCD_AD_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AD_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM2, SonicCD_AD_FM2, 0Ch, 00h

SonicCD_AD_FM2:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 21h, 6Eh
	db	nCs3, 07h, nRst, 06h
	smpsModSet	01h, 01h, 44h, 1Eh
	db	nAb3, 08h
	smpsStop

SonicCD_AD_Voices:
;	Voice 00h
;	35h
;	05h, 09h, 08h, 07h,	1Eh, 0Dh, 0Dh, 0Eh,	0Ch, 15h, 03h, 06h
;	16h, 0Eh, 09h, 10h,	2Fh, 2Fh, 1Fh, 1Fh,	15h, 12h, 12h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	07h, 08h, 09h, 05h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	0Eh, 0Dh, 0Dh, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	06h, 03h, 15h, 0Ch
	smpsVcDecayLevel	01h, 01h, 02h, 02h
	smpsVcDecayRate2	10h, 09h, 0Eh, 16h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 12h, 12h, 15h
	