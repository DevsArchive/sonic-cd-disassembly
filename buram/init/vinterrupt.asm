; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Backup RAM initialization V-BLANK interrupt
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	tst.b	vsyncFlag.w			; Are we lagging?
	beq.w	.Lag				; If so, branch
	move.b	#0,vsyncFlag.w			; Clear VSync flag

	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-INT occurance flag
	jsr	StopZ80(pc)			; Stop the Z80

	move.w	vintRoutine.w,d0		; Execute routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	.Main-.Routines

; -------------------------------------------------------------------------
; Main V-INT routine
; -------------------------------------------------------------------------

.Main:
	bra.w	.Main2

.Main2:
	bsr.w	StartZ80			; Start the Z80
	tst.w	timer.w				; Is the timer active?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	jsr	ReadController(pc)		; Read controller data

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Lag V-INT routine
; -------------------------------------------------------------------------

.Lag:
	addq.l	#1,lagCounter.w			; Increment lag counter
	move.b	vintRoutine+1.w,lagCounter.w	; Set highest byte to V-INT routine ID
	jsr	ReadController(pc)		; Read controller data

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
