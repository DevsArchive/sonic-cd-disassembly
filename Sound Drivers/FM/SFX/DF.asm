SonicCD_DF_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_DF_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM5, SonicCD_DF_FM5, 04h, 08h

SonicCD_DF_FM5:
	smpsSetvoice	00h

SonicCD_DF_Loop1:
	smpsCall	SonicCD_DF_Call1
	smpsAlterPitch		05h
	smpsFMAlterVol	08h
	smpsLoop	01h, 03h, SonicCD_DF_Loop1
	smpsAlterPitch		0ECh
	smpsFMAlterVol	0E0h
	smpsStop

SonicCD_DF_Call1:
	db	nC2, 02h
	smpsAlterPitch		01h
	smpsLoop	00h, 0Ah, SonicCD_DF_Call1
	smpsAlterPitch		0F6h
	smpsReturn

	; Unused
	smpsSetvoice	00h
	db	nRst, 0Ah
	smpsStop

SonicCD_DF_Voices:
;	Voice 00h
;	07h
;	04h, 04h, 05h, 04h,	1Fh, 1Fh, 15h, 15h,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	7Fh, 7Fh, 80h, 80h
	smpsVcAlgorithm		07h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	04h, 05h, 04h, 04h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	15h, 15h, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 80h, 7Fh, 7Fh
	