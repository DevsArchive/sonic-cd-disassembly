SonicCD_D6_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D6_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h	; BUG: Should be 1
	smpsHeaderSFXChannel	cFM6, SonicCD_D6_FM6, 00h, 04h

SonicCD_D6_FM6:
	smpsSetvoice	00h
	smpsPan		panLeft, 00h
	db	nC2, 02h
	smpsPan		panRight, 00h
	db	nC2
	smpsFMAlterVol	08h
	smpsLoop	00h, 05h, SonicCD_D6_FM6
	smpsStop

SonicCD_D6_Voices:
;	Voice 00h
;	34h
;	06h, 05h, 00h, 01h,	1Fh, 1Fh, 1Fh, 13h,	00h, 00h, 09h, 00h
;	00h, 00h, 0Ah, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 85h, 04h, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	01h, 00h, 05h, 06h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	13h, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 09h, 00h, 00h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	00h, 0Ah, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 85h, 00h
	