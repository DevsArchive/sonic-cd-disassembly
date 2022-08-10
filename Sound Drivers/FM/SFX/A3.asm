SonicCD_A3_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A3_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	03h
	smpsHeaderSFXChannel	cFM4, SonicCD_A3_FM4, 10h, 05h
	smpsHeaderSFXChannel	cFM5, SonicCD_A3_FM5, 10h, 05h
	smpsHeaderSFXChannel	cFM6, SonicCD_A3_FM6, 00h, 05h

SonicCD_A3_FM4:
	smpsPan		panRight, 00h
	db	nRst, 02h
	smpsJump	SonicCD_A3_FM6

SonicCD_A3_FM5:
	smpsPan		panLeft, 00h
	db	nRst, 01h

SonicCD_A3_FM6:
	smpsSetvoice	00h
	smpsModSet	03h, 01h, 20h, 04h

SonicCD_A3_Loop1:
	db	nC0, 18h
	smpsFMAlterVol	0Ah
	smpsLoop	00h, 06h, SonicCD_A3_Loop1
	smpsStop

SonicCD_A3_Voices:
;	Voice 00h
;	0F9h
;	21h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Eh, 07h, 04h, 80h
	smpsVcAlgorithm		01h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 07h, 0Eh
	