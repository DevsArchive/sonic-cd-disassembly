SonicCD_BF_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_BF_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_BF_FM4, 31h, 07h

SonicCD_BF_FM4:
	smpsSetvoice	00h
	db	nB1, 06h, nB1, 07h
	smpsStop

SonicCD_BF_Voices:
;	Voice 00h
;	3Ch
;	04h, 00h, 02h, 07h,	1Fh, 1Ah, 18h, 1Ch,	17h, 11h, 1Ah, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	08h, 84h, 05h, 89h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	07h, 02h, 00h, 04h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Ch, 18h, 1Ah, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 1Ah, 11h, 17h
	smpsVcDecayLevel	02h, 09h, 09h, 01h
	smpsVcDecayRate2	10h, 14h, 0Fh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	89h, 05h, 84h, 08h
	