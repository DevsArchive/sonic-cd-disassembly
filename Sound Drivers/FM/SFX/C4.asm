SonicCD_C4_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_C4_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_C4_FM6, 00h, 05h

SonicCD_C4_FM6:
	smpsSetvoice	00h
	db	nG6, 02h

SonicCD_C4_Jump1:
	db	smpsNoAttack, 01h
	smpsConditionalJumpCD	SonicCD_C4_Jump1

SonicCD_C4_Loop1:
	db	smpsNoAttack, 01h
	smpsFMAlterVol	01h
	smpsLoop	00h, 22h, SonicCD_C4_Loop1
	db	nRst, 01h
	smpsNop		00h
	smpsStop

SonicCD_C4_Voices:
;	Voice 00h
;	38h
;	0Fh, 0Fh, 0Fh, 0Fh,	1Fh, 1Fh, 1Fh, 0Eh,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	0Fh, 0Fh, 0Fh, 1Fh,	1Ah, 0Ch, 00h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	0Eh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	01h, 00h, 00h, 00h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 00h, 0Ch, 1Ah
	