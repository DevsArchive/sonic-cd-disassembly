SonicCD_CD_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_CD_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_CD_FM5, 00h, 0Dh
	smpsHeaderSFXChannel	cFM6, SonicCD_CD_FM6, 0Ch, 02h

SonicCD_CD_FM5:
	smpsSetvoice	00h
	db	nF1, 3Fh
	smpsStop

SonicCD_CD_FM6:
	smpsSetvoice	01h
	smpsModSet	01h, 01h, 83h, 0Ch

SonicCD_CD_Loop1:
	db	nA0, 05h, 05h
	smpsFMAlterVol	03h
	smpsLoop	00h, 0Ah, SonicCD_CD_Loop1
	smpsStop

SonicCD_CD_Voices:
;	Voice 00h
;	3Dh
;	03h, 06h, 02h, 02h,	0Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	0Ch, 82h, 80h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	02h, 02h, 06h, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 0Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 82h, 0Ch
	
;	Voice 01h
;	35h
;	14h, 1Ah, 04h, 09h,	0Eh, 10h, 11h, 0Eh,	0Ch, 15h, 03h, 06h
;	16h, 0Eh, 09h, 10h,	2Fh, 2Fh, 4Fh, 4Fh,	2Fh, 12h, 12h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 01h, 01h
	smpsVcCoarseFreq	09h, 04h, 0Ah, 04h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	0Eh, 11h, 10h, 0Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	06h, 03h, 15h, 0Ch
	smpsVcDecayLevel	04h, 04h, 02h, 02h
	smpsVcDecayRate2	10h, 09h, 0Eh, 16h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 12h, 12h, 2Fh
	