SonicCD_BD_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_BD_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM6, SonicCD_BD_FM6, 07h, 05h

SonicCD_BD_FM6:
	smpsSetvoice	00h

SonicCD_BD_Loop1:
	db	nEb5, 09h
	smpsLoop	00h, 08h, SonicCD_BD_Loop1
	smpsStop

SonicCD_BD_Voices:
;	Voice 00h
;	02h
;	02h, 51h, 20h, 01h,	1Eh, 1Eh, 1Eh, 1Eh,	10h, 0Ah, 14h, 13h
;	01h, 00h, 00h, 00h,	0FFh, 0FFh, 0FFh, 0FFh,	24h, 0Eh, 1Fh, 80h
	smpsVcAlgorithm		02h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 02h, 05h, 00h
	smpsVcCoarseFreq	01h, 00h, 01h, 02h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Eh, 1Eh, 1Eh, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	13h, 14h, 0Ah, 10h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	00h, 00h, 00h, 01h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Fh, 0Eh, 24h
	