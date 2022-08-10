SonicCD_A2_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_A2_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_A2_FM3, 10h, 08h
	smpsHeaderSFXChannel	cFM4, SonicCD_A2_FM4, 00h, 00h

SonicCD_A2_FM3:
	smpsSetvoice	00h
	smpsModSet	03h, 01h, 20h, 04h
	db	nC0, 06h

SonicCD_A2_Loop1:
	db	nC0, 0Eh
	smpsFMAlterVol	0Eh
	smpsLoop	00h, 04h, SonicCD_A2_Loop1
	smpsStop

SonicCD_A2_FM4:
	smpsSetvoice	01h
	db	nCs3, 06h, 14h
	smpsStop

SonicCD_A2_Voices:
;	Voice 00h
;	0F9h
;	21h, 30h, 10h, 32h,	1Ch, 1Fh, 1Fh, 10h,	05h, 18h, 09h, 02h
;	0Bh, 1Fh, 10h, 05h,	1Fh, 2Fh, 4Fh, 2Fh,	0Ch, 06h, 04h, 80h
	smpsVcAlgorithm		01h
	smpsVcFeedback		07h
	smpsVcUnusedBits	03h
	smpsVcDetune		03h, 01h, 03h, 02h
	smpsVcCoarseFreq	02h, 00h, 00h, 01h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	10h, 1Fh, 1Fh, 1Ch
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	02h, 09h, 18h, 05h
	smpsVcDecayLevel	02h, 04h, 02h, 01h
	smpsVcDecayRate2	05h, 10h, 1Fh, 0Bh
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 06h, 0Ch
	
;	Voice 01h
;	00h
;	00h, 03h, 02h, 00h,	0D9h, 0DFh, 1Fh, 1Fh,	12h, 11h, 14h, 0Fh
;	0Ah, 00h, 0Ah, 0Dh,	0FFh, 0FFh, 0FFh, 0FFh,	22h, 07h, 27h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		00h, 00h, 00h, 00h
	smpsVcCoarseFreq	00h, 02h, 03h, 00h
	smpsVcRateScale		00h, 00h, 03h, 03h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 19h
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Fh, 14h, 11h, 12h
	smpsVcDecayLevel	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcDecayRate2	0Dh, 0Ah, 00h, 0Ah
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 27h, 07h, 22h
	