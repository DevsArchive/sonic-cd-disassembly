SonicCD_9E_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_9E_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_9E_FM3, 0Bh, 02h
	smpsHeaderSFXChannel	cFM4, SonicCD_9E_FM4, 00h, 02h

SonicCD_9E_FM3:
	smpsSetvoice	00h
	smpsModSet	03h, 01h, 20h, 04h

SonicCD_9E_Loop1:
	db	nC0, 0Eh
	smpsFMAlterVol	0Eh
	smpsLoop	00h, 04h, SonicCD_9E_Loop1
	smpsStop

SonicCD_9E_FM4:
	smpsSetvoice	01h
	db	nA3, 13h
	smpsStop

SonicCD_9E_Voices:
;	Voice 00h
;	0F9h
;	21h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Eh, 06h, 04h, 80h
	smpsVcAlgorithm		01h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 06h, 0Eh
	
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
	