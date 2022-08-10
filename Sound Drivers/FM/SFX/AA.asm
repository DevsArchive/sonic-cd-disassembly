SonicCD_AA_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM2, SonicCD_AA_FM2, 00h, 05h

SonicCD_AA_FM2:
	smpsSetvoice	00h
	db	nRst, 01h
	smpsModSet	03h, 01h, 09h, 0FFh

SonicCD_AA_Loop1:
	db	nCs6, 06h
	smpsLoop	00h, 03h, SonicCD_AA_Loop1
	smpsStop

SonicCD_AA_Voices:
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
	