SonicCD_99_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_99_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM2, SonicCD_99_FM2, 00h, 00h

SonicCD_99_FM2:
	smpsSetvoice	00h
	db	nE4, 02h
	smpsStop

SonicCD_99_Voices:
;	Voice 00h
;	07h
;	0Ah, 0Ah, 0Ah, 0Ah,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	88h, 88h, 88h, 88h
	smpsVcAlgorithm		07h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	0Ah, 0Ah, 0Ah, 0Ah
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	88h, 88h, 88h, 88h
	