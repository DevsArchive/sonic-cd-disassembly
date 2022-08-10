SonicCD_B4_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B4_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM6, SonicCD_B4_FM6, 10h, 07h
	smpsHeaderSFXChannel	cFM5, SonicCD_B4_FM5, 00h, 00h

SonicCD_B4_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 60h, 01h
	db	nD3, 05h, nRst, 08h
	smpsModOff
	smpsSetvoice	01h
	smpsAlterPitch		0F0h
	smpsFMAlterVol	0FCh
	db	nEb0, 22h
	smpsStop

SonicCD_B4_FM5:
	db	nRst, 05h
	smpsSetvoice	01h
	db	nEb0, 22h
	smpsStop

SonicCD_B4_Voices:
;	Voice 00h
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
	
;	Voice 01h
;	0FAh
;	31h, 30h, 10h, 32h,	1Fh, 1Fh, 1Fh, 1Fh,	05h, 18h, 05h, 10h
;	0Bh, 1Fh, 10h, 10h,	1Fh, 2Fh, 1Fh, 2Fh,	0Dh, 00h, 01h, 80h
	smpsVcAlgorithm		02h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 03h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	10h, 05h, 18h, 05h
	smpsVcDecayLevel	02h, 01h, 02h, 01h
	smpsVcDecayRate2	10h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 01h, 00h, 0Dh
	