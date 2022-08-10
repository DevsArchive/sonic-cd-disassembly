SonicCD_C1_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C1_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_C1_FM4, 00h, 04h

SonicCD_C1_FM4:
	smpsSetvoice	00h
	db	nC7, 06h, 40h
	smpsStop

SonicCD_C1_Voices:
;	Voice 00h
;	38h
;	01h, 00h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	09h, 09h, 09h, 0Bh
;	00h, 00h, 00h, 00h,	0FFh, 0FFh, 0FFh, 0FFh,	5Ch, 22h, 27h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Bh, 09h, 09h, 09h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 27h, 22h, 5Ch
	