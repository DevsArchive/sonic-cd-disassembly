; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Game/Time Over object
; -------------------------------------------------------------------------

ObjGameOver:
	moveq	#0,d0
	move.b	$24(a0),d0
	move.w	ObjGameOver_Index(pc,d0.w),d0
	jmp	ObjGameOver_Index(pc,d0.w)
; End of function ObjGameOver

; -------------------------------------------------------------------------
ObjGameOver_Index:dc.w	ObjGameOver_Init-ObjGameOver_Index
	dc.w	ObjGameOver_Main-ObjGameOver_Index
; -------------------------------------------------------------------------

ObjGameOver_Init:
	move.w	#$82,d0
	jsr	SubCPUCmd
	addq.b	#2,oRoutine(a0)
	move.w	#$E0,oYScr(a0)
	move.w	#$80,oX(a0)
	move.w	#$120,oVar2A(a0)
	move.w	#$8544,oTile(a0)
	move.l	#MapSpr_GameOver1,oMap(a0)
	move.b	#8,lvlLoadShieldArt
	bclr	#0,lvlTimeOver
	beq.s	.NotTimeOver
	tst.b	lifeCount
	beq.s	.GameOver
	move.l	#MapSpr_GameOver2,4(a0)
	addq.b	#2,lvlLoadShieldArt
	bra.s	.GameOver

; -------------------------------------------------------------------------

.NotTimeOver:
	tst.b	lifeCount
	bne.s	.Destroy

.GameOver:
	bset	#7,lvlLoadShieldArt
	jsr	FindObjSlot
	beq.s	.LoadAuxObj

.Destroy:
	jmp	DeleteObject

; -------------------------------------------------------------------------

.LoadAuxObj:
	move.b	#$3B,oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.b	#1,oMapFrame(a1)
	move.w	#$E0,oYScr(a1)
	move.w	#$1C0,oX(a1)
	move.w	#$120,oVar2A(a1)
	tst.b	lifeCount
	bne.s	ObjGameOver_Main
	move.w	#$6E,d0
	jmp	SubCPUCmd
; End of function ObjGameOver_Init

; -------------------------------------------------------------------------

ObjGameOver_Main:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.Display
	bge.s	.MoveToDest
	neg.w	d0

.MoveToDest:
	add.w	d0,oX(a0)

.Display:
	jmp	DrawObject
; End of function ObjGameOver_Main

; -------------------------------------------------------------------------

	include	"Level/_Objects/Game Over/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
