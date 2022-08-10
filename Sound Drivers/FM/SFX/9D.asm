SonicCD_9D_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_9D_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM5, SonicCD_9D_FM5, 27h, 03h
	smpsHeaderSFXChannel	cFM6, SonicCD_9D_FM6, 27h, 00h

SonicCD_9D_FM5:
	db	nRst, 04h

SonicCD_9D_FM6:
	smpsSetvoice	00h

SonicCD_9D_Loop1:
	db	nEb4, 05h
	smpsFMAlterVol	04h
	smpsLoop	00h, 08h, SonicCD_9D_Loop1
	smpsStop

SonicCD_9D_Voices:
;	Voice 00h
;	0F4h
;	06h, 04h, 0Fh, 0Eh,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 00h, 0Bh, 0Bh
;	00h, 00h, 05h, 08h,	0Fh, 0Fh, 0FFh, 0FFh,	0Ch, 85h, 00h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		06h
	smpsVcUnusedBits	03h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	0Eh, 0Fh, 04h, 06h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Bh, 0Bh, 00h, 00h
	smpsVcDecayLevel	0Fh, 0Fh, 00h, 00h
	smpsVcDecayRate2	08h, 05h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 85h, 0Ch
	