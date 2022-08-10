SonicCD_B6_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B6_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM1, SonicCD_B6_FM1, 0Ch, 03h
	smpsHeaderSFXChannel	cFM2, SonicCD_B6_FM2, 0Eh, 03h

SonicCD_B6_FM1:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 83h, 0Ch

SonicCD_B6_Loop1:
	db	nA0, 05h, 05h
	smpsFMAlterVol	03h
	smpsLoop	00h, 0Ah, SonicCD_B6_Loop1
	smpsStop

SonicCD_B6_FM2:
	db	nRst, 04h
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 6Fh, 0Eh

SonicCD_B6_Loop2:
	db	nC1, 04h, 05h
	smpsFMAlterVol	03h
	smpsLoop	00h, 0Ah, SonicCD_B6_Loop2
	smpsStop

SonicCD_B6_Voices:
;	Voice 00h
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
	