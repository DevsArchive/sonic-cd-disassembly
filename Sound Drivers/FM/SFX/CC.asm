SonicCD_CC_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_CC_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_CC_FM4, 00h, 02h

SonicCD_CC_FM4:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 23h, 30h
	db	nEb4, 07h, nFs4
	smpsAlterPitch		05h
	smpsLoop	00h, 03h, SonicCD_CC_FM4
	smpsStop

SonicCD_CC_Voices:
;	Voice 00h
;	13h
;	0Fh, 07h, 07h, 04h,	1Fh, 1Eh, 1Eh, 13h,	1Ah, 13h, 11h, 10h
;	00h, 00h, 00h, 00h,	0FFh, 0FFh, 0FFh, 0FFh,	16h, 26h, 23h, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		02h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	04h, 07h, 07h, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	13h, 1Eh, 1Eh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	10h, 11h, 13h, 1Ah
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 23h, 26h, 16h
	