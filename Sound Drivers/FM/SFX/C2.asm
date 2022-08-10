SonicCD_C2_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C2_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_C2_FM4, 15h, 00h

SonicCD_C2_FM4:
	smpsSetvoice	00h
	db	nEb3, 1Fh
	smpsStop

SonicCD_C2_Voices:
;	Voice 00h
;	38h
;	0Fh, 00h, 00h, 00h,	1Fh, 1Ah, 18h, 1Ch,	08h, 06h, 0Ch, 0Eh
;	00h, 0Fh, 14h, 10h,	1Fh, 9Fh, 9Fh, 2Fh,	05h, 80h, 80h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Ch, 18h, 1Ah, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 0Ch, 06h, 08h
	smpsVcDecayLevel	02h, 09h, 09h, 01h
	smpsVcDecayRate2	10h, 14h, 0Fh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 80h, 05h
	