; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Game/Time Over object
; -------------------------------------------------------------------------

oGmOverDestX	EQU	oVar2A			; Destination X position

; -------------------------------------------------------------------------

ObjGameOver:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjGameOver_Init-.Index
	dc.w	ObjGameOver_Main-.Index
	
; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjGameOver_Init:
	move.w	#SCMD_FADEPCM,d0		; Fade out PCM
	jsr	SubCPUCmd
	
	addq.b	#2,oRoutine(a0)			; Next routine
	move.w	#96+128,oYScr(a0)		; Set position
	move.w	#0+128,oX(a0)
	move.w	#160+128,oGmOverDestX(a0)	; Set destination X position
	move.w	#$8544,oTile(a0)		; Set base tile ID
	move.l	#MapSpr_GameOver,oMap(a0)	; Set mappings
	
	move.b	#8,powerup			; Load "GAME OVER" art
	bclr	#0,timeOver			; Was there a time over?
	beq.s	.NotTimeOver			; If not, branch
	tst.b	lives				; Are we out of lives?
	beq.s	.GameOver			; If so, branch
	move.l	#MapSpr_TimeOver,oMap(a0)	; Set "TIME OVER" mappings
	addq.b	#2,powerup			; Load "TIME OVER" art
	bra.s	.GameOver

.NotTimeOver:
	tst.b	lives				; Are we out of lives?
	bne.s	.Destroy			; If not, branch

.GameOver:
	bset	#7,powerup			; Load the art
	jsr	FindObjSlot			; Spawn "OVER" text
	beq.s	.SpawnOverText

.Destroy:
	jmp	DeleteObject			; Delete ourselves

.SpawnOverText:
	move.b	#$3B,oID(a1)			; "OVER" text
	move.b	oRoutine(a0),oRoutine(a1)	; Set routine
	move.w	oTile(a0),oTile(a1)		; Set base tile ID
	move.l	oMap(a0),oMap(a1)		; Set mappings
	move.b	#1,oMapFrame(a1)		; Set to "OVER" frame
	move.w	#128+96,oYScr(a1)		; Set position
	move.w	#320+128,oX(a1)
	move.w	#160+128,oGmOverDestX(a1)	; Set destination X position
	
	tst.b	lives				; Are we out of lives?
	bne.s	ObjGameOver_Main		; If not, branch
	move.w	#SCMD_GMOVERMUS,d0		; Play game over music
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

ObjGameOver_Main:
	moveq	#8,d0				; Movement speed
	move.w	oGmOverDestX(a0),d1		; Are we at our destination?
	cmp.w	oX(a0),d1
	beq.s	.Draw				; If so, branch
	bge.s	.AddX				; If we're left of it, branch
	neg.w	d0				; If we're right of it, move left

.AddX:
	add.w	d0,oX(a0)			; Move

.Draw:
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

	include	"Level/_Objects/Game Over/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
