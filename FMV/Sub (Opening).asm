; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sub CPU opening FMV handler
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$30000

	bsr.w	InitPCMWave			; Initialize PCM wave
	bsr.w	Set1MMode			; Set to 1M/1M mode
	bsr.w	WaitMainCPUInit			; Wait for the Main CPU to be initialized
	
	move.b	#$80,PCMCTRL			; Enable PCM sound
	bsr.w	InitPCMRegs			; Initialize PCM registers
	move.b	#%11111100,PCMONOFF		; Unmute PCM1 and PCM2

	move.w	#FID_OPENSTM,d0			; Opening FMV data
	jsr	GetFileName.w
	
	move.w	#FFUNC_FINDFILE,d0		; Find FMV data file
	jsr	FileFunc.w
	bcs.w	.Exit				; If it failed, branch

	move.w	#FFUNC_LOADFMV,d0		; Start loading FMV data
	jsr	FileFunc.w

	bclr	#7,GASUBFLAG&$FFFFFF		; Mark as initialized

; -------------------------------------------------------------------------

.Loop:
	btst	#FMVF_READY,FileVars+feFMV	; Is a packet of data ready?
	beq.w	.CheckStop			; If not, branch
	
	bsr.w	SyncWithPCM			; Sync with PCM
	
	lea	FMVPCMBUF,a0			; Get PCM data
	moveq	#0,d0				; PCM bank ID
	
	move.w	#$80,d1				; Stream to PCM buffer 1
	btst	#FMVF_PBUF,FileVars+feFMV	; Are we streaming to the first PCM buffer?
	beq.s	.StreamPCM			; If so, branch

.PCMBuffer2:
	move.w	#$88,d1				; Stream to PCM buffer 2
	
.StreamPCM:
	lea	PCMREGS,a6			; Set PCM bank ID
	move.b	d1,PCMCTRL-PCMREGS(a6)
	
	; Note: They only copy $FFF bytes instead of $1000 because the last PCM bank
	; holds a loop flag at the very end, and they didn't want to overwrite that.
	; However, their workaround results in 1 byte gaps every $1000 bytes in wave
	; RAM, and also results in the last 8 bytes in a PCM data packet to go
	; unused, causing clicks/skipping.
	; See the note below for why this workaround wasn't even necessary to begin with.
	move.w	#$FFF-1,d3			; Number of bytes per bank
	lea	PCMWAVE,a6			; PCM wave RAM
	
.StreamPCMLoop:
	move.b	(a0)+,(a6)			; Copy PCM data
	addq.l	#2,a6				; Only odd addresses are accessible
	dbf	d3,.StreamPCMLoop		; Loop until bank is finished
	
	addq.w	#1,d0				; Next bank
	addq.w	#1,d1
	cmpi.w	#8-1,d0				; Are we done streaming to this buffer?
	bls.s	.StreamPCM			; If not, branch
	eori.b	#1<<FMVF_PBUF,FileVars+feFMV	; Swap PCM buffers
	
	btst	#FMVF_INIT,FileVars+feFMV	; Has the FMV been marked as playing?
	bne.s	.Playing			; If so, branch
	bset	#FMVF_INIT,FileVars+feFMV	; Mark FMV as playing
	
.Playing:
	bclr	#FMVF_READY,FileVars+feFMV	; Data is retrieved, prepare for streaming more
	
.CheckStop:
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
	move.w	#FFUNC_RESET,d0			; Reset the file engine
	jsr	FileFunc.w
	move.w	#CDCSTOP,d0			; Stop CDC
	jsr	_CDBIOS.w
	move.w	#MSCPAUSEON,d0			; Pause CDDA music
	jsr	_CDBIOS.w

.Exit:
	move.b	#%11111111,PCMONOFF		; Mute all PCM channels
	move.b	#0,PCMCTRL			; Stop PCM sound
	
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
; Initialize PCM wave RAM
; -------------------------------------------------------------------------

InitPCMWave:
	move.b	#%11111111,PCMONOFF		; Mute all PCM channels
	move.b	#$80,PCMCTRL			; Enable PCM sound
	
	moveq	#0,d0				; Bank ID
	move.b	#$80,d1				; Wave bank control
	
.Clear:
	move.b	d1,PCMCTRL			; Set wave bank ID
	move.w	#$1000-1,d2			; Clear entire bank
	lea	PCMWAVE,a6			; PCM wave RAM
	
.ClearLoop:
	move.b	#0,(a6)				; Clear wave RAM
	addq.l	#2,a6				; Only odd addresses are accessible
	dbf	d2,.ClearLoop			; Loop until bank is finished
	
	addq.w	#1,d0				; Next bank
	addq.w	#1,d1
	cmpi.w	#16,d0				; Are all banks cleared out?
	blt.s	.Clear				; If not, branch
	
	; Note: This loop flag is placed at the very end of wave RAM. It's set
	; to loop back to the very start of wave RAM, and is the reason for
	; why the PCM streaming code doesn't copy enough bytes. Setting this flag is
	; actually unnecessary in this context, because the PCM chip wraps back to
	; the very start after it goes past the end anyways.
	move.b	#$FF,PCMWAVE+($FFF*2)		; Set loop flag
	rts
	
; -------------------------------------------------------------------------
; Initialize PCM registers
; -------------------------------------------------------------------------

InitPCMRegs:
	movem.l	d2-d7,-(sp)			; Save registers
	
	lea	PCMREGS,a6			; PCM registers
	lea	.RegValues,a5			; Register values
	
	lea	PCMREGS,a6			; Control and sound PCM1
	move.b	#$C0,PCMCTRL-PCMREGS(a6)
	addq.l	#PCMENV-PCMREGS,a6		; Go to the ENV register
	moveq	#.RegValuesEnd-.RegValues-1,d7	; Number of registers
	
.InitPCM1:
	move.b	(a5)+,(a6)			; Initialize register
	move.b	#4,d4				; Delay between each write
	dbf	d4,*
	addq.l	#2,a6				; Next register
	dbf	d7,.InitPCM1			; Loop until all registers are initialized
	
	lea	PCMREGS,a6			; Control and sound PCM2
	move.b	#$C1,PCMCTRL-PCMREGS(a6)
	addq.l	#PCMENV-PCMREGS,a6		; Go to the ENV register
	moveq	#.RegValuesEnd-.RegValues-1,d7	; Number of registers
	
.InitPCM2:
	; Note: PCM2's registers get filled with garbage data.
	; However, thanks to the register data array being aligned,
	; PCM2's volume gets set to 0, so even when it's being
	; sounded, it doesn't output anything.
	move.b	(a5)+,(a6)			; Initialize register
	move.b	#4,d4				; Delay between each write
	dbf	d4,*
	addq.l	#2,a6				; Next register
	dbf	d7,.InitPCM2			; Loop until all registers are initialized
	
	movem.l	(sp)+,d2-d7			; Restore registers
	rts

; -------------------------------------------------------------------------

.RegValues:
	dc.b	$FF				; Volume
	dc.b	$FF				; Panning
	dc.b	$0C				; Frequency (low)
	dc.b	$08				; Frequency (high)
	dc.b	$00				; Loop address (low)
	dc.b	$00				; Loop address (high)
	dc.b	$80				; Start address (high)
.RegValuesEnd:
	even
	
; -------------------------------------------------------------------------
; Sync with the PCM playback
; -------------------------------------------------------------------------

SyncWithPCM:
	btst	#FMVF_PBUF,FileVars+feFMV	; Are we in PCM buffer 2?
	bne.s	.Buffer2			; If so, branch
	
.Buffer1:
	cmpi.b	#$7F,PCMADDR1H			; Is buffer 1 still being played?
	bhi.s	.End				; If not, branch
	bra.s	.Buffer1			; If so, wait
	
.Buffer2:
	cmpi.b	#$7F,PCMADDR1H			; Is buffer 2 still being played?
	bls.s	.End				; If not, branch
	bra.s	.Buffer2			; If so, wait

.End:
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
; Wait for the Main CPU to be initialized
; -------------------------------------------------------------------------

WaitMainCPUInit:
	btst	#1,GAMAINFLAG&$FFFFFF		; Is the Main CPU ready?
	beq.s	WaitMainCPUInit			; If not, wait
	btst	#1,GAMAINFLAG&$FFFFFF
	beq.s	WaitMainCPUInit			; If not, wait
	btst	#1,GAMAINFLAG&$FFFFFF
	beq.s	WaitMainCPUInit			; If not, wait
	rts
	
; -------------------------------------------------------------------------
