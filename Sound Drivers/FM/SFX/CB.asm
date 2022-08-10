SonicCD_CB_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_CB_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_CB_FM6, 00h, 17h

SonicCD_CB_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 2Fh, 09h

SonicCD_CB_Loop1:
	db	nG2, 10h, smpsNoAttack
	smpsFMAlterVol	02h
	smpsLoop	00h, 10h, SonicCD_CB_Loop1

SonicCD_CB_Loop2:
	db	nG2, 10h, smpsNoAttack
	smpsFMAlterVol	0FEh
	smpsLoop	00h, 10h, SonicCD_CB_Loop2
	smpsJump	SonicCD_CB_Loop1
	smpsStop	; Unused

SonicCD_CB_Voices:
;	Voice 00h
;	47h
;	08h, 08h, 08h, 08h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0FFh, 0FFh, 0FFh, 0FFh,	81h, 81h, 81h, 81h
	smpsVcAlgorithm		07h
	smpsVcFeedback		00h
	smpsVcUnusedBits	01h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	08h, 08h, 08h, 08h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	81h, 81h, 81h, 81h
	