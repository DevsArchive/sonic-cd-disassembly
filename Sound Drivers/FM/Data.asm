; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS FM sound effect driver data
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Song index
; -------------------------------------------------------------------------

SongIndex:

; -------------------------------------------------------------------------
; Sound effect index
; -------------------------------------------------------------------------

SFXIndex:
	dw	SFX_90
	dw	SFX_91
	dw	SFX_92
	dw	SFX_93
	dw	SFX_94
	dw	SFX_95
	dw	SFX_96
	dw	SFX_97
	dw	SFX_98
	dw	SFX_99
	dw	SFX_9A
	dw	SFX_9B
	dw	SFX_9C
	dw	SFX_9D
	dw	SFX_9E
	dw	SFX_9F
	dw	SFX_A0
	dw	SFX_A1
	dw	SFX_A2
	dw	SFX_A3
	dw	SFX_A4
	dw	SFX_A5
	dw	SFX_A6
	dw	SFX_A7
	dw	SFX_A8
	dw	SFX_A9
	dw	SFX_AA
	dw	SFX_AB
	dw	SFX_AC
	dw	SFX_AD
	dw	SFX_AE
	dw	SFX_AF
	dw	SFX_B0
	dw	SFX_B1
	dw	SFX_B2
	dw	SFX_B3
	dw	SFX_B4
	dw	SFX_B5
	dw	SFX_B6
	dw	SFX_B7
	dw	SFX_B8
	dw	SFX_B9
	dw	SFX_BA
	dw	SFX_BB
	dw	SFX_BC
	dw	SFX_BD
	dw	SFX_BE
	dw	SFX_BF
	dw	SFX_C0
	dw	SFX_C1
	dw	SFX_C2
	dw	SFX_C3
	dw	SFX_C4
	dw	SFX_C5
	dw	SFX_C6
	dw	SFX_C7
	dw	SFX_C8
	dw	SFX_C9
	dw	SFX_CA
	dw	SFX_CB
	dw	SFX_CC
	dw	SFX_CD
	dw	SFX_CE
	dw	SFX_CF
	dw	SFX_D0
	dw	SFX_D1
	dw	SFX_D2
	dw	SFX_D3
	dw	SFX_D4
	dw	SFX_D5
	dw	SFX_D6
	dw	SFX_D7
	dw	SFX_D8
	dw	SFX_D9
	dw	SFX_DA
	dw	SFX_DB
	dw	SFX_DC
	dw	SFX_DD
	dw	SFX_DE
	dw	SFX_DF

; -------------------------------------------------------------------------
; Sound effect priorities
; -------------------------------------------------------------------------
	
SFXPriorities:
	db	7Ah
	db	7Ah
	db	7Ah
	db	7Dh
	db	7Dh
	db	70h
	db	70h
	db	7Ah
	db	70h
	db	6Dh
	db	7Dh
	db	7Ah
	db	7Ah
	db	70h
	db	7Ah
	db	6Dh
	db	70h
	db	6Dh
	db	70h
	db	70h
	db	6Dh
	db	6Dh
	db	6Dh
	db	70h
	db	70h
	db	7Dh
	db	70h
	db	7Dh
	db	70h
	db	7Dh
	db	7Ah
	db	7Ah
	db	70h
	db	70h
	db	70h
	db	6Dh
	db	70h
	db	70h
	db	7Ah
	db	70h
	db	7Dh
	db	7Dh
	db	6Ah
	db	6Dh
	db	7Dh
	db	6Dh
	db	6Dh
	db	6Dh
	db	70h
	db	70h
	db	70h
	db	7Ah
	db	70h
	db	70h
	db	70h
	db	70h
	db	7Dh
	db	70h
	db	70h
	db	6Dh
	db	6Dh
	db	70h
	db	7Ah
	db	70h
	db	6Dh
	db	6Dh
	db	7Ah
	db	70h
	db	70h
	db	6Dh
	db	6Ah
	db	6Dh
	db	70h
	db	70h
	db	70h
	db	70h
	db	70h
	db	70h
	db	70h

; -------------------------------------------------------------------------

SFX_90:
	binclude "Sound Drivers/FM/SFX/90.bin"
SFX_91:
	binclude "Sound Drivers/FM/SFX/91.bin"
SFX_92:
	binclude "Sound Drivers/FM/SFX/92.bin"
SFX_93:
	binclude "Sound Drivers/FM/SFX/93.bin"
SFX_94:
	binclude "Sound Drivers/FM/SFX/94.bin"
SFX_95:
	binclude "Sound Drivers/FM/SFX/95.bin"
SFX_96:
	binclude "Sound Drivers/FM/SFX/96.bin"
SFX_97:
	binclude "Sound Drivers/FM/SFX/97.bin"
SFX_98:
	binclude "Sound Drivers/FM/SFX/98.bin"
SFX_99:
	binclude "Sound Drivers/FM/SFX/99.bin"
SFX_9A:
	binclude "Sound Drivers/FM/SFX/9A.bin"
SFX_9B:
	binclude "Sound Drivers/FM/SFX/9B.bin"
SFX_9C:
	binclude "Sound Drivers/FM/SFX/9C.bin"
SFX_9D:
	binclude "Sound Drivers/FM/SFX/9D.bin"
SFX_9E:
	binclude "Sound Drivers/FM/SFX/9E.bin"
SFX_9F:
	binclude "Sound Drivers/FM/SFX/9F.bin"
SFX_A0:
	binclude "Sound Drivers/FM/SFX/A0.bin"
SFX_A1:
	binclude "Sound Drivers/FM/SFX/A1.bin"
SFX_A2:
	binclude "Sound Drivers/FM/SFX/A2.bin"
SFX_A3:
	binclude "Sound Drivers/FM/SFX/A3.bin"
SFX_A4:
	binclude "Sound Drivers/FM/SFX/A4.bin"
SFX_A5:
	binclude "Sound Drivers/FM/SFX/A5.bin"
SFX_A6:
	binclude "Sound Drivers/FM/SFX/A6.bin"
SFX_A7:
	binclude "Sound Drivers/FM/SFX/A7.bin"
SFX_A8:
	binclude "Sound Drivers/FM/SFX/A8.bin"
SFX_A9:
	binclude "Sound Drivers/FM/SFX/A9.bin"
SFX_AA:
	binclude "Sound Drivers/FM/SFX/AA.bin"
SFX_AB:
	binclude "Sound Drivers/FM/SFX/AB.bin"
SFX_AC:
	binclude "Sound Drivers/FM/SFX/AC.bin"
SFX_AD:
	binclude "Sound Drivers/FM/SFX/AD.bin"
SFX_AE:
	binclude "Sound Drivers/FM/SFX/AE.bin"
SFX_AF:
	binclude "Sound Drivers/FM/SFX/AF.bin"
SFX_B0:
	binclude "Sound Drivers/FM/SFX/B0.bin"
SFX_B1:
	binclude "Sound Drivers/FM/SFX/B1.bin"
SFX_B2:
	binclude "Sound Drivers/FM/SFX/B2.bin"
SFX_B3:
	binclude "Sound Drivers/FM/SFX/B3.bin"
SFX_B4:
	binclude "Sound Drivers/FM/SFX/B4.bin"
SFX_B5:
	binclude "Sound Drivers/FM/SFX/B5.bin"
SFX_B6:
	binclude "Sound Drivers/FM/SFX/B6.bin"
SFX_B7:
	binclude "Sound Drivers/FM/SFX/B7.bin"
SFX_B8:
	binclude "Sound Drivers/FM/SFX/B8.bin"
SFX_B9:
	binclude "Sound Drivers/FM/SFX/B9.bin"
SFX_BA:
	binclude "Sound Drivers/FM/SFX/BA.bin"
SFX_BB:
	binclude "Sound Drivers/FM/SFX/BB.bin"
SFX_BC:
	binclude "Sound Drivers/FM/SFX/BC.bin"
SFX_BD:
	binclude "Sound Drivers/FM/SFX/BD.bin"
SFX_BE:
	binclude "Sound Drivers/FM/SFX/BE.bin"
SFX_BF:
	binclude "Sound Drivers/FM/SFX/BF.bin"
SFX_C0:
	binclude "Sound Drivers/FM/SFX/C0.bin"
SFX_C1:
	binclude "Sound Drivers/FM/SFX/C1.bin"
SFX_C2:
	binclude "Sound Drivers/FM/SFX/C2.bin"
SFX_C3:
	binclude "Sound Drivers/FM/SFX/C3.bin"
SFX_C4:
	binclude "Sound Drivers/FM/SFX/C4.bin"
SFX_C5:
	binclude "Sound Drivers/FM/SFX/C5.bin"
SFX_C6:
	binclude "Sound Drivers/FM/SFX/C6.bin"
SFX_C7:
	binclude "Sound Drivers/FM/SFX/C7.bin"
SFX_C8:
	binclude "Sound Drivers/FM/SFX/C8.bin"
SFX_C9:
	binclude "Sound Drivers/FM/SFX/C9.bin"
SFX_CA:
	binclude "Sound Drivers/FM/SFX/CA.bin"
SFX_CB:
	binclude "Sound Drivers/FM/SFX/CB.bin"
SFX_CC:
	binclude "Sound Drivers/FM/SFX/CC.bin"
SFX_CD:
	binclude "Sound Drivers/FM/SFX/CD.bin"
SFX_CE:
	binclude "Sound Drivers/FM/SFX/CE.bin"
SFX_CF:
	binclude "Sound Drivers/FM/SFX/CF.bin"
SFX_D0:
	binclude "Sound Drivers/FM/SFX/D0.bin"
SFX_D1:
	binclude "Sound Drivers/FM/SFX/D1.bin"
SFX_D2:
	binclude "Sound Drivers/FM/SFX/D2.bin"
SFX_D3:
	binclude "Sound Drivers/FM/SFX/D3.bin"
SFX_D4:
	binclude "Sound Drivers/FM/SFX/D4.bin"
SFX_D5:
	binclude "Sound Drivers/FM/SFX/D5.bin"
SFX_D6:
	binclude "Sound Drivers/FM/SFX/D6.bin"
SFX_D7:
	binclude "Sound Drivers/FM/SFX/D7.bin"
SFX_D8:
	binclude "Sound Drivers/FM/SFX/D8.bin"
SFX_D9:
	binclude "Sound Drivers/FM/SFX/D9.bin"
SFX_DA:
	binclude "Sound Drivers/FM/SFX/DA.bin"
SFX_DB:
	binclude "Sound Drivers/FM/SFX/DB.bin"
SFX_DC:
	binclude "Sound Drivers/FM/SFX/DC.bin"
SFX_DD:
	binclude "Sound Drivers/FM/SFX/DD.bin"
SFX_DE:
	binclude "Sound Drivers/FM/SFX/DE.bin"
SFX_DF:
	binclude "Sound Drivers/FM/SFX/DF.bin"

; -------------------------------------------------------------------------
