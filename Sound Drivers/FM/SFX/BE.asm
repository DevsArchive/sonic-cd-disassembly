SonicCD_BE_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_BE_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM4, SonicCD_BE_FM4, 03h, 00h

SonicCD_BE_FM4:
	smpsSetvoice	00h
	db	nEb5, 10h
	smpsStop

SonicCD_BE_Voices:
;	Voice 00h
;	02h
;	02h, 03h, 23h, 01h,	1Eh, 1Eh, 1Eh, 1Eh,	10h, 0Ah, 12h, 12h
;	01h, 00h, 00h, 13h,	0FFh, 0FFh, 0FFh, 0FFh,	08h, 0Eh, 1Fh, 80h
	smpsVcAlgorithm		02h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 02h, 00h, 00h
	smpsVcCoarseFreq	01h, 03h, 03h, 02h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Eh, 1Eh, 1Eh, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	12h, 12h, 0Ah, 10h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	13h, 00h, 00h, 01h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 1Fh, 0Eh, 08h
	