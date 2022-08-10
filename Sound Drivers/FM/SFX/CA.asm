SonicCD_CA_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_CA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_CA_FM4, 00h, 07h

SonicCD_CA_FM4:
	smpsSetvoice	00h
	db	nAb6, 30h
	smpsStop

SonicCD_CA_Voices:
;	Voice 00h
;	34h
;	03h, 02h, 03h, 04h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	08h, 0Eh, 8Ah, 8Ah
	smpsVcAlgorithm		04h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	04h, 03h, 02h, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	8Ah, 8Ah, 0Eh, 08h
	