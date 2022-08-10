SonicCD_D7_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D7_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_D7_FM6, 20h, 00h

SonicCD_D7_FM6:
	smpsSetvoice	00h

SonicCD_D7_Loop1:
	db	nEb1, 03h, nRst, 01h
	smpsAlterPitch		01h
	smpsFMAlterVol	03h
	smpsLoop	00h, 0Ah, SonicCD_D7_Loop1
	smpsAlterPitch		0F6h
	smpsFMAlterVol	0E2h
	smpsLoop	01h, 04h, SonicCD_D7_Loop1
	smpsStop

SonicCD_D7_Voices:
;	Voice 00h
;	01h
;	04h, 04h, 04h, 04h,	1Fh, 1Fh, 1Fh, 13h,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 0Fh,	7Fh, 7Fh, 7Fh, 80h
	smpsVcAlgorithm		01h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	04h, 04h, 04h, 04h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	13h, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	00h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 7Fh, 7Fh, 7Fh
	