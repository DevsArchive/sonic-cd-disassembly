SonicCD_AE_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AE_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_AE_FM4, 00h, 01h

SonicCD_AE_FM4:
	smpsSetvoice	00h
	db	nC5, 06h, nA4, 16h
	smpsStop

SonicCD_AE_Voices:
;	Voice 00h
;	3Ch
;	05h, 01h, 0Ah, 01h,	56h, 5Ch, 5Ch, 5Ch,	0Eh, 11h, 11h, 11h
;	09h, 0Ah, 06h, 0Ah,	4Fh, 3Fh, 3Fh, 3Fh,	17h, 80h, 20h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	01h, 0Ah, 01h, 05h
	smpsVcRateScale		01h, 01h, 01h, 01h
	smpsVcAttackRate	1Ch, 1Ch, 1Ch, 16h
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	11h, 11h, 11h, 0Eh
	smpsVcDecayLevel	03h, 03h, 03h, 04h
	smpsVcDecayRate2	0Ah, 06h, 0Ah, 09h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 20h, 80h, 17h
	