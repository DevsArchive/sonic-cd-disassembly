SonicCD_D2_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D2_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_D2_FM4, 00h, 05h

SonicCD_D2_FM4:
	smpsSetvoice	00h
	smpsModSet	20h, 01h, 05h, 05h
	db	nA5, 45h
	smpsStop

SonicCD_D2_Voices:
;	Voice 00h
;	04h
;	27h, 02h, 07h, 47h,	1Fh, 1Fh, 1Fh, 1Fh,	07h, 0Ah, 07h, 0Dh
;	00h, 0Bh, 00h, 0Bh,	1Fh, 0Fh, 1Fh, 0Fh,	1Fh, 80h, 23h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		04h, 00h, 00h, 02h
	smpsVcCoarseFreq	07h, 07h, 02h, 07h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 07h, 0Ah, 07h
	smpsVcDecayLevel	00h, 01h, 00h, 01h
	smpsVcDecayRate2	0Bh, 00h, 0Bh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 23h, 80h, 1Fh
	