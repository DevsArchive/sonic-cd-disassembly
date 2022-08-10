SonicCD_94_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_94_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_94_FM3, 00h, 05h
	smpsHeaderSFXChannel	cFM4, SonicCD_94_FM4, 00h, 08h

SonicCD_94_FM3:
	smpsSetvoice	00h
	db	nA5, 02h, 05h, 05h, 05h, 05h, 05h, 05h
	db	3Ah
	smpsStop

SonicCD_94_FM4:
	smpsSetvoice	00h
	db	nRst, 02h, nG5, 02h, 05h, 15h, 02h, 05h
	db	32h
	smpsStop

SonicCD_94_Voices:
;	Voice 00h
;	04h
;	37h, 72h, 77h, 49h,	1Fh, 1Fh, 1Fh, 1Fh,	07h, 0Ah, 07h, 0Dh
;	00h, 0Bh, 00h, 0Bh,	1Fh, 0Fh, 1Fh, 0Fh,	23h, 80h, 23h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		04h, 07h, 07h, 03h
	smpsVcCoarseFreq	09h, 07h, 02h, 07h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 07h, 0Ah, 07h
	smpsVcDecayLevel	00h, 01h, 00h, 01h
	smpsVcDecayRate2	0Bh, 00h, 0Bh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 23h, 80h, 23h
	