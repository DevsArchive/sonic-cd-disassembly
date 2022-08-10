SonicCD_C9_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C9_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_C9_FM4, 00h, 02h

SonicCD_C9_FM4:
	smpsSetvoice	00h
	smpsModSet	03h, 01h, 09h, 0FFh
	db	nCs6, 25h
	smpsModSet	00h, 01h, 00h, 00h

SonicCD_C9_Loop1:
	db	smpsNoAttack
	smpsFMAlterVol	01h
	db	nD6, 02h
	smpsLoop	00h, 2Ah, SonicCD_C9_Loop1
	smpsStop

SonicCD_C9_Voices:
;	Voice 00h
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
	