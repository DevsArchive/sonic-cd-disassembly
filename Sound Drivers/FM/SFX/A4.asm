SonicCD_A4_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A4_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_A4_FM6, 0F4h, 00h

SonicCD_A4_FM6:
	smpsSetvoice	00h
	db	nD2, 04h, nRst, nG2, 06h
	smpsStop

SonicCD_A4_Voices:
;	Voice 00h
;	3Ch
;	00h, 00h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 16h, 0Fh, 0Fh
;	00h, 00h, 00h, 00h,	0Fh, 0AFh, 0FFh, 0FFh,	00h, 80h, 0Ah, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 00h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Fh, 0Fh, 16h, 00h
	smpsVcDecayLevel	0Fh, 0Fh, 0Ah, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 0Ah, 80h, 00h
	