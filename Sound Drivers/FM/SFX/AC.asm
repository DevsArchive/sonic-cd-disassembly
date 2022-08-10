SonicCD_AC_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AC_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_AC_FM3, 0E0h, 00h
	smpsHeaderSFXChannel	cFM4, SonicCD_AC_FM4, 0E3h, 02h

SonicCD_AC_FM3:
	smpsSetvoice	00h
	db	nC4, 30h
	smpsStop

SonicCD_AC_FM4:
	db	nRst, 02h
	smpsSetvoice	00h
	db	nC4, 30h
	smpsStop

SonicCD_AC_Voices:
;	Voice 00h
;	3Bh
;	05h, 32h, 00h, 00h,	5Fh, 5Fh, 5Fh, 5Fh,	04h, 15h, 1Ah, 0Bh
;	00h, 04h, 00h, 00h,	0Fh, 6Fh, 0FFh, 0FFh,	10h, 10h, 00h, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 03h, 00h
	smpsVcCoarseFreq	00h, 00h, 02h, 05h
	smpsVcRateScale		01h, 01h, 01h, 01h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Bh, 1Ah, 15h, 04h
	smpsVcDecayLevel	0Fh, 0Fh, 06h, 00h
	smpsVcDecayRate2	00h, 00h, 04h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 10h, 10h
	