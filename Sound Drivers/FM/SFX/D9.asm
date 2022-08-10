SonicCD_D9_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D9_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	03h
	smpsHeaderSFXChannel	cFM5, SonicCD_D9_FM5, 00h, 00h
	smpsHeaderSFXChannel	cFM6, SonicCD_D9_FM6, 0FBh, 03h
	smpsHeaderSFXChannel	cFM4, SonicCD_D9_FM4, 00h, 03h

SonicCD_D9_FM5:
	smpsSetvoice	00h

SonicCD_D9_Jump1:
	db	nG2, 05h, nC3, nD3, nG3, nC4, nD4

SonicCD_D9_Loop1:
	db	nG4, nC5, nD5
	smpsFMAlterVol	03h
	smpsLoop	00h, 0Dh, SonicCD_D9_Loop1
	smpsStop

SonicCD_D9_FM6:
	smpsSetvoice	00h
	smpsPan		panRight, 00h
	db	nRst, 01h
	smpsFMAlterVol	06h
	smpsAlterPitch		0F9h
	smpsJump	SonicCD_D9_Jump1
	smpsStop	; Unused

SonicCD_D9_FM4:
	smpsSetvoice	00h
	smpsPan		panLeft, 00h
	smpsAlterPitch		0F9h
	smpsJump	SonicCD_D9_Jump1
	smpsStop	; Unused

SonicCD_D9_Voices:
;	Voice 00h
;	13h
;	46h, 36h, 36h, 56h,	1Fh, 1Fh, 1Fh, 1Fh,	0Ch, 0Dh, 0Eh, 0Dh
;	0Ch, 0Ch, 0Ch, 0Fh,	1Fh, 1Fh, 1Fh, 1Fh,	24h, 10h, 0Fh, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		02h
	smpsVcUnusedBits	00h
	smpsVcDetune		05h, 03h, 03h, 04h
	smpsVcCoarseFreq	06h, 06h, 06h, 06h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 0Eh, 0Dh, 0Ch
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	0Fh, 0Ch, 0Ch, 0Ch
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 0Fh, 10h, 24h
	