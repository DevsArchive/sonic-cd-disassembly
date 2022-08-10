SonicCD_B9_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_B9_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_B9_FM3, 18h, 00h
	smpsHeaderSFXChannel	cFM4, SonicCD_B9_FM3, 10h, 03h

SonicCD_B9_FM3:
	smpsSetvoice	00h
	smpsModSet	01h, 01h, 31h, 0FFh
	db	nEb5, 06h, nRst, 02h, nEb5, 14h
	smpsStop

SonicCD_B9_Voices:
;	Voice 00h
;	3Bh
;	3Ch, 39h, 30h, 31h,	0DFh, 1Fh, 1Fh, 0DFh,	04h, 05h, 04h, 01h
;	04h, 04h, 04h, 02h,	0FFh, 0Fh, 1Fh, 0AFh,	0Dh, 20h, 0Ch, 80h
	smpsVcAlgorithm		03h
	smpsVcFeedback		07h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	01h, 00h, 09h, 0Ch
	smpsVcRateScale		03h, 00h, 00h, 03h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	01h, 04h, 05h, 04h
	smpsVcDecayLevel	0Ah, 01h, 00h, 0Fh
	smpsVcDecayRate2	02h, 04h, 04h, 04h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 0Ch, 20h, 0Dh
	