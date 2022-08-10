SonicCD_D5_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_D5_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h	; BUG: Should be 1
	smpsHeaderSFXChannel	cFM6, SonicCD_D5_FM6, 00h, 09h

SonicCD_D5_FM6:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 19h, 0FFh
	db	nB1, 20h
	smpsModOff
	db	smpsNoAttack, nAb2, 30h, smpsNoAttack, 30h
	smpsStop

SonicCD_D5_Voices:
;	Voice 00h
;	28h
;	03h, 0Bh, 11h, 03h,	1Fh, 19h, 1Fh, 1Fh,	02h, 01h, 02h, 0Eh
;	01h, 01h, 01h, 01h,	1Fh, 1Fh, 1Fh, 1Fh,	15h, 26h, 1Ch, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		05h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 01h, 00h, 00h
	smpsVcCoarseFreq	03h, 01h, 0Bh, 03h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 19h, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Eh, 02h, 01h, 02h
	smpsVcDecayLevel	01h, 01h, 01h, 01h
	smpsVcDecayRate2	01h, 01h, 01h, 01h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Ch, 26h, 15h
	