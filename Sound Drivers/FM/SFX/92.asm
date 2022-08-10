SonicCD_92_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_92_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM1, SonicCD_92_FM1, 0EAh, 09h

SonicCD_92_FM1:
	smpsSetvoice	00h
	smpsFMAlterVol	05h
	db	nF3, 04h
	smpsFMAlterVol	0FBh
	smpsModSet	02h, 01h, 34h, 0FFh
	db	nBb3, 15h
	smpsStop

SonicCD_92_Voices:
;	Voice 00h
;	0Ch
;	08h, 08h, 08h, 08h,	1Fh, 1Fh, 1Fh, 1Fh,	00h, 0Ah, 00h, 0Ah
;	00h, 00h, 00h, 0Ah,	0FFh, 0FFh, 0FFh, 0FFh,	55h, 81h, 33h, 81h
	smpsVcAlgorithm		04h
	smpsVcFeedback		01h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	08h, 08h, 08h, 08h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ah, 00h, 0Ah, 00h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	0Ah, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	81h, 33h, 81h, 55h
	