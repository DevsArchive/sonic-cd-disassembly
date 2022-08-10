SonicCD_D8_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D8_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	06h
	smpsHeaderSFXChannel	cFM1, SonicCD_D8_FM1, 00h, 05h
	smpsHeaderSFXChannel	cFM2, SonicCD_D8_FM2, 00h, 03h
	smpsHeaderSFXChannel	cFM3, SonicCD_D8_FM3, 00h, 05h
	smpsHeaderSFXChannel	cFM4, SonicCD_D8_FM4, 00h, 05h
	smpsHeaderSFXChannel	cFM5, SonicCD_D8_FM5, 05h, 0Bh
	smpsHeaderSFXChannel	cFM6, SonicCD_D8_FM6, 05h, 0Bh

SonicCD_D8_FM1:
	smpsSetvoice	00h
	smpsPan		panLeft, 00h

SonicCD_D8_Loop1:
	db	nC4, 04h
	smpsAlterPitch		01h
	smpsLoop	00h, 12h, SonicCD_D8_Loop1
	smpsAlterPitch		0EEh
	smpsAlterPitch		03h
	smpsFMAlterVol	02h
	smpsLoop	01h, 05h, SonicCD_D8_Loop1
	smpsStop

SonicCD_D8_FM2:
	smpsSetvoice	01h
	smpsPan		panLeft, 00h

SonicCD_D8_Loop2:
	db	nF1, 04h
	smpsAlterPitch		01h
	smpsLoop	00h, 0Fh, SonicCD_D8_Loop2

SonicCD_D8_Loop3:
	db	nF1, 02h
	smpsAlterPitch		0FFh
	smpsLoop	00h, 0Fh, SonicCD_D8_Loop3
	smpsLoop	01h, 04h, SonicCD_D8_Loop2
	smpsStop

SonicCD_D8_FM3:
	smpsSetvoice	01h
	smpsPan		panRight, 00h
	db	nRst, 05h
	smpsJump	SonicCD_D8_Loop2
	smpsStop	; Unused

SonicCD_D8_FM4:
	smpsSetvoice	00h
	smpsPan		panRight, 00h
	db	nRst, 05h
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_FM5:
	smpsSetvoice	01h
	smpsPan		panRight, 00h
	db	nRst, 03h
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_FM6:
	smpsSetvoice	01h
	smpsPan		panLeft, 00h
	db	nRst, 04h
	smpsJump	SonicCD_D8_Loop1
	smpsStop	; Unused

SonicCD_D8_Voices:
;	Voice 00h
;	04h
;	01h, 03h, 0Ah, 07h,	0Fh, 13h, 13h, 14h,	00h, 00h, 00h, 00h
;	00h, 00h, 00h, 00h,	1Fh, 1Fh, 1Fh, 1Fh,	02h, 82h, 1Ah, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	07h, 0Ah, 03h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	14h, 13h, 13h, 0Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	00h, 00h, 00h, 00h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	00h, 00h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Ah, 82h, 02h
	
;	Voice 01h
;	04h
;	00h, 04h, 00h, 01h,	09h, 09h, 1Fh, 1Fh,	00h, 00h, 10h, 0Ah
;	00h, 00h, 10h, 0Ah,	1Fh, 1Fh, 1Fh, 1Fh,	0Fh, 80h, 0Ah, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	01h, 00h, 04h, 00h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 09h, 09h
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Ah, 10h, 00h, 00h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	0Ah, 10h, 00h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 0Ah, 80h, 0Fh
	