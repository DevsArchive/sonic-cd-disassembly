SonicCD_B7_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B7_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM6, SonicCD_B7_FM6, 00h, 0Ah
	smpsHeaderSFXChannel	cFM5, SonicCD_B7_FM5, 00h, 00h

SonicCD_B7_FM6:
	smpsSetvoice	01h
	smpsModSet	01h, 01h, 60h, 01h
	db	nC4, 05h
	smpsModOff
	smpsSlideSpeed	0Ah
	smpsFMAlterVol	0F6h
	smpsJump	SonicCD_B7_Jump1

SonicCD_B7_FM5:
	db	nRst, 05h

SonicCD_B7_Jump1:
	smpsSetvoice	00h
	db	nFs7, 01h, nRst, 01h, nFs7, 11h
	smpsStop

SonicCD_B7_Voices:
;	Voice 00h
;	34h
;	09h, 0Fh, 01h, 0D7h,	1Fh, 1Fh, 1Fh, 1Fh,	0Ch, 11h, 09h, 0Fh
;	0Ah, 0Eh, 0Dh, 0Eh,	35h, 1Ah, 55h, 3Ah,	0Ch, 80h, 0Fh, 80h
	smpsVcAlgorithm		04h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		0Dh, 00h, 00h, 00h
	smpsVcCoarseFreq	07h, 01h, 0Fh, 09h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Fh, 09h, 11h, 0Ch
	smpsVcDecayLevel	03h, 05h, 01h, 03h
	smpsVcDecayRate2	0Eh, 0Dh, 0Eh, 0Ah
	smpsVcReleaseRate	0Ah, 05h, 0Ah, 05h
	smpsVcTotalLevel	80h, 0Fh, 80h, 0Ch
	
;	Voice 01h
;	0FAh
;	21h, 3Ah, 19h, 30h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Eh, 07h, 04h, 80h
	smpsVcAlgorithm		02h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	00h, 09h, 0Ah, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 07h, 0Eh
	