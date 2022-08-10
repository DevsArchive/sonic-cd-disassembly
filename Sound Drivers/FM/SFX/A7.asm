SonicCD_A7_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A7_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_A7_FM4, 00h, 03h

SonicCD_A7_FM4:
	smpsSetvoice	00h
	db	nA4, 06h, 15h
	smpsStop

SonicCD_A7_Voices:
;	Voice 00h
;	02h
;	03h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 12h,	12h, 11h, 14h, 0Fh
;	0FAh, 0F3h, 0FAh, 0FDh,	0FFh, 0FFh, 0FFh, 0FFh,	05h, 19h, 05h, 83h
	smpsVcAlgorithm		02h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 00h, 00h, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	12h, 0Fh, 0Fh, 0Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Fh, 14h, 11h, 12h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	0FDh, 0FAh, 0F3h, 0FAh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	83h, 05h, 19h, 05h
	