; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Initial program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/System.i"
	include	"_Include/MMD.i"

; -------------------------------------------------------------------------
; Security block
; -------------------------------------------------------------------------

	org	WORKRAM

	if REGION=JAPAN
		incbin	"CD Initial Program/Security/Japan.bin"
	elseif REGION=USA
		incbin	"CD Initial Program/Security/USA.bin"
	else
		incbin	"CD Initial Program/Security/Europe.bin"
	endif

; -------------------------------------------------------------------------
; Program
; -------------------------------------------------------------------------

	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	move.w	#_LEVEL4,GAUSERHINT		; Set H-INT address
	move.l	#HInterrupt,_LEVEL4+2.w

.SendWordRAM:
	bset	#1,GAMEMMODE			; Send Word RAM access to the Sub CPU
	beq.s	.SendWordRAM

	lea	GACOMCMDS,a0			; Clear communication commands
	moveq	#0,d0
	move.b	d0,GAMAINFLAG-GACOMCMDS(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	LoadIPX(pc),a0			; Copy main program loader
	lea	WORKRAM+$1000,a1
	move.w	#LoadIPXEnd-LoadIPX-1,d7

.CopyIPXLoader:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyIPXLoader

	jmp	WORKRAM+$1000			; Go to main program loader

; -------------------------------------------------------------------------
; IPX loader
; -------------------------------------------------------------------------

LoadIPX:
	obj	WORKRAM+$1000

	moveq	#SCMD_IPX,d0			; Load IPX file
	jsr	SubCPUCmd

	movea.l	WORDRAM2M+mmdEntry,a0		; Get entry address
	
	move.l	WORDRAM2M+mmdOrigin,d0		; Get origin address
	beq.s	.GetHInt			; If it's not set, branch
	
	movea.l	d0,a2				; Copy file to origin address
	lea	WORDRAM2M+mmdFile,a1
	move.w	WORDRAM2M+mmdSize,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHInt:
	move.l	WORDRAM2M+mmdHInt,d0		; Get H-INT address
	beq.s	.GetVInt			; If it's not set, branch
	move.l	d0,_LEVEL4+2.w			; Set H-INT address

.GetVInt:
	move.l	WORDRAM2M+mmdVInt,d0		; Get V-INT address
	beq.s	.SendWordRAM			; If it's blank, branch
	move.l	d0,_LEVEL6+2.w			; Set V-INT address

.SendWordRAM:
	bset	#1,GAMEMMODE			; Send Word RAM access to the Sub CPU
	beq.s	.SendWordRAM

	jmp	(a0)				; Go to main program

	objend
LoadIPXEnd:

; -------------------------------------------------------------------------
; Send Sub CPU command
; -------------------------------------------------------------------------

SubCPUCmd:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitAck:
	tst.w	GACOMSTAT0			; Has the Sub CPU received the command?
	beq.s	.WaitAck			; If not, wait
	
	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitDone:
	tst.w	GACOMSTAT0			; Is the Sub CPU done processing the command?
	bne.s	.WaitDone			; If not, wait
	rts

; -------------------------------------------------------------------------
; V-INT
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Trigger Sub CPU IRQ2

HInterrupt:
	rte

; -------------------------------------------------------------------------
