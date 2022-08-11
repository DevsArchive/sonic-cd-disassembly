; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; FM sound IDs
; -------------------------------------------------------------------------

; SFX
	rsset	$90
FM_START	rs.w	0			; Starting ID
FM_SKID		rs.b	1			; Skid
FM_91		rs.b	1
FM_JUMP		rs.b	1			; Jump
FM_HURT		rs.b	1			; Hurt
FM_RINGLOSS	rs.b	1			; Ring loss
FM_RING		rs.b	1			; Ring
FM_DESTROY	rs.b	1			; Destroy
FM_SHIELD	rs.b	1			; Shield
FM_SPRING	rs.b	1			; Spring
FM_99		rs.b	1
FM_KACHING	rs.b	1
FM_9B		rs.b	1
FM_9C		rs.b	1
FM_SIGNPOST	rs.b	1
FM_9E		rs.b	1
FM_9F		rs.b	1
FM_A0		rs.b	1
FM_A1		rs.b	1
FM_A2		rs.b	1
FM_A3		rs.b	1
FM_A4		rs.b	1
FM_A5		rs.b	1
FM_A6		rs.b	1
FM_A7		rs.b	1
FM_RINGL	rs.b	1			; Ring (left channel)
FM_A9		rs.b	1
FM_AA		rs.b	1
FM_AB		rs.b	1
FM_AC		rs.b	1
FM_AD		rs.b	1
FM_CHECKPOINT	rs.b	1			; Checkpoint
FM_AF		rs.b	1
FM_B0		rs.b	1
FM_B1		rs.b	1
FM_B2		rs.b	1
FM_B3		rs.b	1
FM_B4		rs.b	1
FM_B5		rs.b	1
FM_B6		rs.b	1
FM_B7		rs.b	1
FM_B8		rs.b	1
FM_B9		rs.b	1
FM_BA		rs.b	1
FM_BB		rs.b	1
FM_BC		rs.b	1
FM_BD		rs.b	1
FM_BE		rs.b	1
FM_BF		rs.b	1
FM_C0		rs.b	1
FM_C1		rs.b	1
FM_C2		rs.b	1
FM_C3		rs.b	1
FM_C4		rs.b	1
FM_C5		rs.b	1
FM_C6		rs.b	1
FM_C7		rs.b	1
FM_SSWARP	rs.b	1			; Special stage warp
FM_C9		rs.b	1
FM_CA		rs.b	1
FM_CB		rs.b	1
FM_CC		rs.b	1
FM_CD		rs.b	1
FM_CE		rs.b	1
FM_CF		rs.b	1
FM_D0		rs.b	1
FM_D1		rs.b	1
FM_D2		rs.b	1
FM_D3		rs.b	1
FM_D4		rs.b	1
FM_D5		rs.b	1
FM_D6		rs.b	1
FM_D7		rs.b	1
FM_D8		rs.b	1
FM_D9		rs.b	1
FM_DA		rs.b	1
FM_DB		rs.b	1
FM_DC		rs.b	1
FM_DD		rs.b	1
FM_DE		rs.b	1
FM_DF		rs.b	0
FM_END		rs.b	0			; Ending ID

; Commands
	rsset	$E0
FMC_STOP	rs.b	1			; Stop

; -------------------------------------------------------------------------
