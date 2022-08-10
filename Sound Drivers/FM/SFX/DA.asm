SonicCD_DA_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_DA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_DA_FM6, 00h, 00h

SonicCD_DA_FM6:
	smpsSetvoice	00h
	db	nG2, 0Fh
	smpsFMAlterVol	0Fh
	smpsLoop	00h, 04h, SonicCD_DA_FM6
	smpsStop

SonicCD_DA_Voices:
;	Voice 00h
;	04h
;	00h, 01h, 00h, 05h,	0Fh, 1Fh, 0Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	8Fh, 8Fh, 8Fh, 8Fh,	1Fh, 8Dh, 1Fh, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	05h, 00h, 01h, 00h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 0Fh, 1Fh, 0Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	08h, 08h, 08h, 08h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Fh, 8Dh, 1Fh
	