SonicCD_93_Header:
	smpsHeaderStartSong	06h
	smpsHeaderVoice		SonicCD_93_Voices
	smpsHeaderTempoSFX	01h
	smpsHeaderChanSFX	01h
	smpsHeaderSFXChannel	cFM2, SonicCD_93_FM2, 0F4h, 00h

SonicCD_93_FM2:
	smpsSetvoice	00h
	db	nB3, 07h, smpsNoAttack, nAb3

SonicCD_93_Loop1:
	db	01h
	smpsFMAlterVol	01h
	smpsLoop	00h, 2Fh, SonicCD_93_Loop1
	smpsStop

SonicCD_93_Voices:
;	Voice 00h
;	30h
;	30h, 30h, 30h, 30h,	9Eh, 0D8h, 0DCh, 0DCh,	0Eh, 0Ah, 04h, 05h
;	08h, 08h, 08h, 08h,	0BFh, 0BFh, 0BFh, 0BFh,	14h, 3Ch, 14h, 80h
	smpsVcAlgorithm		00h
	smpsVcFeedback		06h
	smpsVcUnusedBits	00h
	smpsVcDetune		03h, 03h, 03h, 03h
	smpsVcCoarseFreq	00h, 00h, 00h, 00h
	smpsVcRateScale		03h, 03h, 03h, 02h
	smpsVcAttackRate	1Ch, 1Ch, 18h, 1Eh
	smpsVcAmpMod		00h, 00h, 00h, 00h
	smpsVcDecayRate1	05h, 04h, 0Ah, 0Eh
	smpsVcDecayLevel	0Bh, 0Bh, 0Bh, 0Bh
	smpsVcDecayRate2	08h, 08h, 08h, 08h
	smpsVcReleaseRate	0Fh, 0Fh, 0Fh, 0Fh
	smpsVcTotalLevel	80h, 14h, 3Ch, 14h
	