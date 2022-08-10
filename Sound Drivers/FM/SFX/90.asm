SonicCD_90_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_90_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM1, SonicCD_90_FM1, 0F6h, 10h
	smpsHeaderSFXChannel	cFM2, SonicCD_90_FM2, 0F7h, 10h

SonicCD_90_FM1:
	smpsSetvoice	00h

SonicCD_90_Loop1:
	db	nBb3, 01h, nRst, 01h
	smpsLoop	00h, 0Bh, SonicCD_90_Loop1
	smpsStop

SonicCD_90_FM2:
	smpsSetvoice	00h
	db	nRst, 01h

SonicCD_90_Loop2:
	db	nAb3, 01h, nRst, 01h
	smpsLoop	00h, 0Bh, SonicCD_90_Loop2
	smpsStop

SonicCD_90_Voices:
;	Voice 00h
;	07h
;	07h, 07h, 08h, 08h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	80h, 80h, 80h, 80h
	smpsVcAlgorithm		07h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	08h, 08h, 07h, 07h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 80h, 80h
	