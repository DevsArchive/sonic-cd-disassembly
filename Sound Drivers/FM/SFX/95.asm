SonicCD_95_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_95_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_95_FM4, 00h, 05h

SonicCD_95_FM4:
	smpsRingSwap
	smpsSetvoice	00h
	smpsPan		panRight, 00h
	db	nE5, 05h, nG5, 05h, nC6, 1Bh
	smpsStop

SonicCD_95_Voices:
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
	