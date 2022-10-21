; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sub CPU functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Fade out music
; -------------------------------------------------------------------------

FadeOutMusic:
	move.w	#SCMD_FADECDA,d0		; Fade out CD music

; -------------------------------------------------------------------------
; Send a command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
	cmpi.w	#SCMD_BOSSMUS,d0		; Is this the command to play the boss music?
	bne.s	.NotBossMusic			; If not, branch
	move.b	#1,bossMusic			; Mark boss music as being played

.NotBossMusic:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait
	rts
	
; -------------------------------------------------------------------------

	dc.w	0

; -------------------------------------------------------------------------
