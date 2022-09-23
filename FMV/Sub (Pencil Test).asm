; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sub CPU pencil test FMV handler
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$30000

	bsr.w	Set1MMode			; Set to 1M/1M mode
	bsr.w	SyncWithMainCPU			; Sync with Main CPU
	
	move.w	#FID_PENCILSTM,d0		; Opening FMV data
	jsr	GetFileName.w
	
	move.w	#FFUNC_FINDFILE,d0		; Find FMV data file
	jsr	FileFunc.w
	bcs.w	.Exit				; If it failed, branch

	move.w	#FFUNC_LOADFMVM,d0		; Start loading FMV data
	jsr	FileFunc.w

	bclr	#7,GASUBFLAG&$FFFFFF		; Mark as initialized

; -------------------------------------------------------------------------

.Loop:
	btst	#2,GAMAINFLAG&$FFFFFF		; Is the FMV being stopped?
	beq.s	.CheckStatus			; If not, branch
	btst	#2,GAMAINFLAG&$FFFFFF
	beq.s	.CheckStatus			; If not, branch
	btst	#2,GAMAINFLAG&$FFFFFF
	bne.w	.Stop				; If so, branch

.CheckStatus:
	move.w	#FFUNC_STATUS,d0		; Check FMV status
	jsr	FileFunc.w
	bcs.w	.Loop				; If the FMV is not over, loop
	bra.w	.Exit				; Exit the FMV

; -------------------------------------------------------------------------

.Stop:
	move.w	#CDCSTOP,d0			; Stop CDC
	jsr	_CDBIOS.w
	move.w	#FFUNC_RESET,d0			; Reset the file engine
	jsr	FileFunc.w
	move.w	#MSCPAUSEON,d0			; Pause CDDA music
	jsr	_CDBIOS.w

.Exit:
	bset	#1,GASUBFLAG&$FFFFFF		; Tell the Main CPU we are done
	
.WaitMainCPU:
	btst	#4,GAMAINFLAG&$FFFFFF		; Has the Main CPU responded?
	beq.s	.WaitMainCPU			; If not, wait
	btst	#4,GAMAINFLAG&$FFFFFF
	beq.s	.WaitMainCPU			; If not, wait
	btst	#4,GAMAINFLAG&$FFFFFF
	beq.s	.WaitMainCPU			; If not, wait
	
	bclr	#1,GASUBFLAG&$FFFFFF		; Communication is done
	clr.b	GASUBFLAG&$FFFFFF
	rts	

; -------------------------------------------------------------------------
; Set to 1M/1M mode
; -------------------------------------------------------------------------

Set1MMode:
	bset	#2,GAMEMMODE&$FFFFFF		; Set 1M/1M mode
	
.Wait:
	btst	#2,GAMEMMODE&$FFFFFF		; Is 1M/1M mode set yet?
	beq.s	.Wait				; If not, wait
	
	move.b	#0,GASUBFLAG&$FFFFFF		; Mark as initializing
	bset	#7,GASUBFLAG&$FFFFFF
	rts

; -------------------------------------------------------------------------
; Sync with the Main CPU
; -------------------------------------------------------------------------

SyncWithMainCPU:
	btst	#1,GAMAINFLAG&$FFFFFF		; Is the Main CPU ready?
	bne.s	.End				; If so, branch
	btst	#1,GAMAINFLAG&$FFFFFF		; Is the Main CPU ready?
	bne.s	.End				; If so, branch
	btst	#1,GAMAINFLAG&$FFFFFF		; Is the Main CPU ready?
	bne.s	.End				; If so, branch

.CheckStop:
	btst	#2,GAMAINFLAG&$FFFFFF		; Is the FMV being stopped?
	beq.s	SyncWithMainCPU			; If not, branch
	btst	#2,GAMAINFLAG&$FFFFFF
	beq.s	SyncWithMainCPU			; If not, branch
	btst	#2,GAMAINFLAG&$FFFFFF
	beq.s	SyncWithMainCPU			; If not, branch

.End:
	rts
	
; -------------------------------------------------------------------------
; Copy of the system program's IRQ2 handler
; -------------------------------------------------------------------------

SPIRQ2Copy:
	movem.l	d0-a6,-(sp)			; Save registers
	move.w	#FFUNC_OPER,d0			; Perform engine operation
	jsr	FileFunc.w
	movem.l	(sp)+,d0-a6			; Restore registers
	rts
	
; -------------------------------------------------------------------------
