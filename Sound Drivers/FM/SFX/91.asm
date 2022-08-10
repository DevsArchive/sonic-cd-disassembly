SonicCD_91_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_91_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM1, SonicCD_91_FM1, 00h, 0Ah
	smpsHeaderSFXChannel	cFM2, SonicCD_91_FM2, 00h, 00h

SonicCD_91_FM1:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 20h, 08h
	db	nRst, 0Ah

SonicCD_91_Loop1:
	db	nG0, 0Fh
	smpsLoop	00h, 03h, SonicCD_91_Loop1

SonicCD_91_Loop2:
	db	nG0, 0Ah
	smpsFMAlterVol	05h
	smpsLoop	00h, 06h, SonicCD_91_Loop2
	smpsStop

SonicCD_91_FM2:
	smpsSetvoice	01h
	smpsModSet	01h, 01h, 0C5h, 1Ah
	db	nE6, 07h
	smpsAlterPitch		0Ch
	smpsFMAlterVol	09h
	smpsSetvoice	02h
	smpsModSet	03h, 01h, 09h, 0FFh
	db	nCs6, 25h
	smpsModSet	00h, 01h, 00h, 00h

SonicCD_91_Loop3:
	db	smpsNoAttack
	smpsFMAlterVol	01h
	db	nD6, 02h
	smpsLoop	00h, 2Ah, SonicCD_91_Loop3
	smpsStop

SonicCD_91_Voices:
;	Voice 00h
;	0FAh
;	21h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	06h, 0Fh, 06h, 02h,	1Fh, 2Fh, 4Fh, 2Fh,	0Fh, 1Ah, 0Eh, 80h
	smpsVcAlgorithm		02h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	02h, 06h, 0Fh, 06h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 0Eh, 1Ah, 0Fh
	
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
	