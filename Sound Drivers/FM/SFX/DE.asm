SonicCD_DE_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_DE_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_DE_FM5, 00h, 00h
	smpsHeaderSFXChannel	cFM6, SonicCD_DE_FM6, 00h, 00h

SonicCD_DE_FM6:
	db	nRst, 03h

SonicCD_DE_FM5:
	smpsSetvoice	00h
	db	nA7, 05h, nRst, 06h, nAb7, 11h
	smpsStop

SonicCD_DE_Voices:
;	Voice 00h
;	34h
;	0Ch, 0Ah, 04h, 03h,	1Fh, 1Fh, 1Fh, 1Fh,	0Ch, 0Dh, 09h, 0Ch
;	0Ah, 0Eh, 0Dh, 0Eh,	35h, 1Ah, 55h, 3Ah,	0Fh, 80h, 0Fh, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	03h, 04h, 0Ah, 0Ch
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ch, 09h, 0Dh, 0Ch
	smpsVcDecayLevel	03h, 05h, 01h, 03h
	smpsVcDecayRate2	0Eh, 0Dh, 0Eh, 0Ah
	smpsVcReleaseRate	0Ah, 05h, 0Ah, 05h
	smpsVcTotalLevel	80h, 0Fh, 80h, 0Fh
	