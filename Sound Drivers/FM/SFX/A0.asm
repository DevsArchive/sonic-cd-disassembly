SonicCD_A0_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A0_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_A0_FM4, 00h, 00h

SonicCD_A0_FM4:
	smpsSetvoice	00h
	db	nBb1, 15h
	smpsStop

SonicCD_A0_Voices:
;	Voice 00h
;	3Ch
;	05h, 00h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 0Fh, 15h, 11h
;	00h, 0Ch, 00h, 0Ah,	0Fh, 0EFh, 0FFh, 0EFh,	05h, 80h, 00h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 05h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	11h, 15h, 0Fh, 00h
	smpsVcDecayLevel	0Eh, 0Fh, 0Eh, 00h
	smpsVcDecayRate2	0Ah, 00h, 0Ch, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 80h, 05h
	