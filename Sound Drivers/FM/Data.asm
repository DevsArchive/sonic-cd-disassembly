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

	CPU	68000
	padding	off
	
SFX_90:
	include	"Sound Drivers/FM/SFX/90.asm"
SFX_91:
	include	"Sound Drivers/FM/SFX/91.asm"
SFX_92:
	include	"Sound Drivers/FM/SFX/92.asm"
SFX_93:
	include	"Sound Drivers/FM/SFX/93.asm"
SFX_94:
	include	"Sound Drivers/FM/SFX/94.asm"
SFX_95:
	include	"Sound Drivers/FM/SFX/95.asm"
SFX_96:
	include	"Sound Drivers/FM/SFX/96.asm"
SFX_97:
	include	"Sound Drivers/FM/SFX/97.asm"
SFX_98:
	include	"Sound Drivers/FM/SFX/98.asm"
SFX_99:
	include	"Sound Drivers/FM/SFX/99.asm"
SFX_9A:
	include	"Sound Drivers/FM/SFX/9A.asm"
SFX_9B:
	include	"Sound Drivers/FM/SFX/9B.asm"
SFX_9C:
	include	"Sound Drivers/FM/SFX/9C.asm"
SFX_9D:
	include	"Sound Drivers/FM/SFX/9D.asm"
SFX_9E:
	include	"Sound Drivers/FM/SFX/9E.asm"
SFX_9F:
	include	"Sound Drivers/FM/SFX/9F.asm"
SFX_A0:
	include	"Sound Drivers/FM/SFX/A0.asm"
SFX_A1:
	include	"Sound Drivers/FM/SFX/A1.asm"
SFX_A2:
	include	"Sound Drivers/FM/SFX/A2.asm"
SFX_A3:
	include	"Sound Drivers/FM/SFX/A3.asm"
SFX_A4:
	include	"Sound Drivers/FM/SFX/A4.asm"
SFX_A5:
	include	"Sound Drivers/FM/SFX/A5.asm"
SFX_A6:
	include	"Sound Drivers/FM/SFX/A6.asm"
SFX_A7:
	include	"Sound Drivers/FM/SFX/A7.asm"
SFX_A8:
	include	"Sound Drivers/FM/SFX/A8.asm"
SFX_A9:
	include	"Sound Drivers/FM/SFX/A9.asm"
SFX_AA:
	include	"Sound Drivers/FM/SFX/AA.asm"
SFX_AB:
	include	"Sound Drivers/FM/SFX/AB.asm"
SFX_AC:
	include	"Sound Drivers/FM/SFX/AC.asm"
SFX_AD:
	include	"Sound Drivers/FM/SFX/AD.asm"
SFX_AE:
	include	"Sound Drivers/FM/SFX/AE.asm"
SFX_AF:
	include	"Sound Drivers/FM/SFX/AF.asm"
SFX_B0:
	include	"Sound Drivers/FM/SFX/B0.asm"
SFX_B1:
	include	"Sound Drivers/FM/SFX/B1.asm"
SFX_B2:
	include	"Sound Drivers/FM/SFX/B2.asm"
SFX_B3:
	include	"Sound Drivers/FM/SFX/B3.asm"
SFX_B4:
	include	"Sound Drivers/FM/SFX/B4.asm"
SFX_B5:
	include	"Sound Drivers/FM/SFX/B5.asm"
SFX_B6:
	include	"Sound Drivers/FM/SFX/B6.asm"
SFX_B7:
	include	"Sound Drivers/FM/SFX/B7.asm"
SFX_B8:
	include	"Sound Drivers/FM/SFX/B8.asm"
SFX_B9:
	include	"Sound Drivers/FM/SFX/B9.asm"
SFX_BA:
	include	"Sound Drivers/FM/SFX/BA.asm"
SFX_BB:
	include	"Sound Drivers/FM/SFX/BB.asm"
SFX_BC:
	include	"Sound Drivers/FM/SFX/BC.asm"
SFX_BD:
	include	"Sound Drivers/FM/SFX/BD.asm"
SFX_BE:
	include	"Sound Drivers/FM/SFX/BE.asm"
SFX_BF:
	include	"Sound Drivers/FM/SFX/BF.asm"
SFX_C0:
	include	"Sound Drivers/FM/SFX/C0.asm"
SFX_C1:
	include	"Sound Drivers/FM/SFX/C1.asm"
SFX_C2:
	include	"Sound Drivers/FM/SFX/C2.asm"
SFX_C3:
	include	"Sound Drivers/FM/SFX/C3.asm"
SFX_C4:
	include	"Sound Drivers/FM/SFX/C4.asm"
SFX_C5:
	include	"Sound Drivers/FM/SFX/C5.asm"
SFX_C6:
	include	"Sound Drivers/FM/SFX/C6.asm"
SFX_C7:
	include	"Sound Drivers/FM/SFX/C7.asm"
SFX_C8:
	include	"Sound Drivers/FM/SFX/C8.asm"
SFX_C9:
	include	"Sound Drivers/FM/SFX/C9.asm"
SFX_CA:
	include	"Sound Drivers/FM/SFX/CA.asm"
SFX_CB:
	include	"Sound Drivers/FM/SFX/CB.asm"
SFX_CC:
	include	"Sound Drivers/FM/SFX/CC.asm"
SFX_CD:
	include	"Sound Drivers/FM/SFX/CD.asm"
SFX_CE:
	include	"Sound Drivers/FM/SFX/CE.asm"
SFX_CF:
	include	"Sound Drivers/FM/SFX/CF.asm"
SFX_D0:
	include	"Sound Drivers/FM/SFX/D0.asm"
SFX_D1:
	include	"Sound Drivers/FM/SFX/D1.asm"
SFX_D2:
	include	"Sound Drivers/FM/SFX/D2.asm"
SFX_D3:
	include	"Sound Drivers/FM/SFX/D3.asm"
SFX_D4:
	include	"Sound Drivers/FM/SFX/D4.asm"
SFX_D5:
	include	"Sound Drivers/FM/SFX/D5.asm"
SFX_D6:
	include	"Sound Drivers/FM/SFX/D6.asm"
SFX_D7:
	include	"Sound Drivers/FM/SFX/D7.asm"
SFX_D8:
	include	"Sound Drivers/FM/SFX/D8.asm"
SFX_D9:
	include	"Sound Drivers/FM/SFX/D9.asm"
SFX_DA:
	include	"Sound Drivers/FM/SFX/DA.asm"
SFX_DB:
	include	"Sound Drivers/FM/SFX/DB.asm"
SFX_DC:
	include	"Sound Drivers/FM/SFX/DC.asm"
SFX_DD:
	include	"Sound Drivers/FM/SFX/DD.asm"
SFX_DE:
	include	"Sound Drivers/FM/SFX/DE.asm"
SFX_DF:
	include	"Sound Drivers/FM/SFX/DF.asm"

; -------------------------------------------------------------------------
