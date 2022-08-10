SonicCD_AF_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_AF_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	02h
	smpsHeaderSFXChannel	cFM3, SonicCD_AF_FM3, 0Ch, 00h
	smpsHeaderSFXChannel	cFM4, SonicCD_AF_FM4, 00h, 13h

SonicCD_AF_FM3:
	smpsSetvoice	01h
	db	nRst, 01h, nA2, 08h
	smpsSetvoice	00h
	db	smpsNoAttack, nAb3, 26h
	smpsStop

SonicCD_AF_FM4:
	smpsSetvoice	02h
	smpsModSet	06h, 01h, 03h, 0FFh
	db	nRst, 0Ah

SonicCD_AF_Loop1:
	db	nFs5, 06h
	smpsLoop	00h, 05h, SonicCD_AF_Loop1
	db	nFs5, 17h
	smpsStop

SonicCD_AF_Voices:
;	Voice 00h
;	30h
;	30h, 5Ch, 34h, 30h,	9Eh, 0A8h, 0ACh, 0DCh,	0Eh, 0Ah, 04h, 05h
;	08h, 08h, 08h, 08h,	0BFh, 0BFh, 0BFh, 0BFh,	24h, 1Ch, 04h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 05h, 03h
	smpsVcCoarseFreq	00h, 04h, 0Ch, 00h
	smpsVcRateScale		03h, 02h, 02h, 02h
	smpsVcAttackRate	1Ch, 2Ch, 28h, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	05h, 04h, 0Ah, 0Eh
	smpsVcDecayLevel	0Bh, 0Bh, 0Bh, 0Bh
	smpsVcDecayRate2	08h, 08h, 08h, 08h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 1Ch, 24h
	
;	Voice 01h
;	30h
;	30h, 5Ch, 34h, 30h,	9Eh, 0A8h, 0ACh, 0DCh,	0Eh, 0Ah, 04h, 05h
;	08h, 08h, 08h, 08h,	0BFh, 0BFh, 0BFh, 0BFh,	24h, 2Ch, 04h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 05h, 03h
	smpsVcCoarseFreq	00h, 04h, 0Ch, 00h
	smpsVcRateScale		03h, 02h, 02h, 02h
	smpsVcAttackRate	1Ch, 2Ch, 28h, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	05h, 04h, 0Ah, 0Eh
	smpsVcDecayLevel	0Bh, 0Bh, 0Bh, 0Bh
	smpsVcDecayRate2	08h, 08h, 08h, 08h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 04h, 2Ch, 24h
	
;	Voice 02h
;	04h
;	37h, 72h, 77h, 49h,	1Fh, 1Fh, 1Fh, 1Fh,	07h, 0Ah, 07h, 0Dh
;	00h, 0Bh, 00h, 0Bh,	1Fh, 0Fh, 1Fh, 0Fh,	13h, 81h, 13h, 88h
	smpsVcAlgorithm		04h
	smpsVcFeedback		00h
	smpsVcUnusedBits	00h
	smpsVcDetune		04h, 07h, 07h, 03h
	smpsVcCoarseFreq	09h, 07h, 02h, 07h
	smpsVcRateScale		00h, 00h, 00h, 00h
	smpsVcAttackRate	1Fh, 1Fh, 1Fh, 1Fh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	0Dh, 07h, 0Ah, 07h
	smpsVcDecayLevel	00h, 01h, 00h, 01h
	smpsVcDecayRate2	0Bh, 00h, 0Bh, 00h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	88h, 13h, 81h, 13h
	