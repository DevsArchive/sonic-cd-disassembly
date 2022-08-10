SonicCD_A5_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A5_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_A5_FM6, 00h, 08h

SonicCD_A5_FM6:
	smpsSetvoice	00h
	db	nEb5, 0Bh
	smpsStop

SonicCD_A5_Voices:
;	Voice 00h
;	3Dh
;	01h, 03h, 03h, 03h,	14h, 0Eh, 0Eh, 0Dh,	08h, 35h, 02h, 91h
;	00h, 50h, 60h, 56h,	1Fh, 1Fh, 1Fh, 1Fh,	18h, 82h, 97h, 80h
	smpsVcAlgorithm		05h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	03h, 03h, 03h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	0Dh, 0Eh, 0Eh, 14h
	smpsVcAmpMod		01h, 00h, 00h, 00h
	smpsVcDecayRate1	11h, 02h, 35h, 08h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	56h, 60h, 50h, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 97h, 82h, 18h
	