SonicCD_BA_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_BA_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM6, SonicCD_BA_FM6, 0FEh, 00h
	smpsHeaderSFXChannel	cFM5, SonicCD_BA_FM6, 00h, 00h

SonicCD_BA_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 0EDh, 0FFh
	db	nE0, 0Ah
	smpsModOff
	db	nD0, 20h
	smpsStop

SonicCD_BA_Voices:
;	Voice 00h
;	28h
;	03h, 0Ah, 11h, 03h,	1Fh, 19h, 1Fh, 1Fh,	02h, 01h, 02h, 0Eh
;	01h, 01h, 01h, 8Eh,	1Fh, 1Fh, 1Fh, 1Fh,	25h, 26h, 1Ch, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		05h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 01h, 00h, 00h
	smpsVcCoarseFreq	03h, 01h, 0Ah, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 19h, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 02h, 01h, 02h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	8Eh, 01h, 01h, 01h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Ch, 26h, 25h
	