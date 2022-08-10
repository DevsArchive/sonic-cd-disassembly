SonicCD_B8_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B8_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_B8_FM3, 05h, 06h
	smpsHeaderSFXChannel	cFM4, SonicCD_B8_FM4, 00h, 03h

SonicCD_B8_FM3:
	smpsStop

SonicCD_B8_FM4:
	smpsSetvoice	01h
	smpsModSet	01h, 01h, 0C5h, 1Ah
	db	nF6, 07h
	smpsAlterPitch		0Ch
	smpsFMAlterVol	05h
	smpsSetvoice	02h
	smpsModSet	03h, 01h, 09h, 0FFh
	db	nE6, 11h
	smpsModSet	00h, 01h, 00h, 00h

SonicCD_B8_Loop1:
	db	smpsNoAttack
	smpsFMAlterVol	03h
	db	nE6, 03h
	smpsLoop	00h, 12h, SonicCD_B8_Loop1
	smpsStop

SonicCD_B8_Voices:
;	Voice 00h
;	3Bh
;	3Ch, 39h, 30h, 31h,	0DFh, 1Fh, 1Fh, 0DFh,	04h, 05h, 04h, 01h
;	04h, 04h, 04h, 02h,	0FFh, 0Fh, 1Fh, 0AFh,	11h, 20h, 0Fh, 84h
	smpsVcAlgorithm		03h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	01h, 00h, 09h, 0Ch
	smpsVcRateScale		03h, 00h, 00h, 03h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	01h, 04h, 05h, 04h
	smpsVcDecayLevel	0Ah, 01h, 00h, 0Fh
	smpsVcDecayRate2	02h, 04h, 04h, 04h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	84h, 0Fh, 20h, 11h
	
;	Voice 01h
;	0FDh
;	09h, 03h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	10h, 0Ch, 0Ch, 0Ch
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	09h, 80h, 8Eh, 88h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 03h, 09h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ch, 0Ch, 0Ch, 10h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	88h, 8Eh, 80h, 09h
	
;	Voice 02h
;	3Ch
;	00h, 44h, 02h, 02h,	1Fh, 1Fh, 1Fh, 15h,	00h, 1Fh, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	0Dh, 80h, 28h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 04h, 00h
	smpsVcCoarseFreq	02h, 02h, 04h, 00h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	15h, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 1Fh, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 28h, 80h, 0Dh
	