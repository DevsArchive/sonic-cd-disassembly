SonicCD_C0_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C0_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_C0_FM4, 30h, 00h

SonicCD_C0_FM4:
	smpsSetvoice	00h
	db	nG3, 07h, nEb2, 07h
	smpsStop

SonicCD_C0_Voices:
;	Voice 00h
;	3Ch
;	02h, 03h, 03h, 04h,	1Fh, 1Ah, 18h, 1Ch,	17h, 11h, 1Ah, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	06h, 84h, 45h, 37h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	04h, 03h, 03h, 02h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Ch, 18h, 1Ah, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 1Ah, 11h, 17h
	smpsVcDecayLevel	02h, 09h, 09h, 01h
	smpsVcDecayRate2	10h, 14h, 0Fh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	37h, 45h, 84h, 06h
	