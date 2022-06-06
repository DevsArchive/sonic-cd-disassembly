; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Floating block object
; -------------------------------------------------------------------------

ObjFloatBlock:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjFloatBlock_Index(pc,d0.w),d0
	jsr	ObjFloatBlock_Index(pc,d0.w)
	move.w	oX(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts
; End of function ObjFloatBlock

; -------------------------------------------------------------------------
ObjFloatBlock_Index:
	dc.w	ObjFloatBlock_Init-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Main-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Fall-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Appear-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Visible-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Vanish-ObjFloatBlock_Index
	dc.w	ObjFloatBlock_Reset-ObjFloatBlock_Index
; -------------------------------------------------------------------------

ObjFloatBlock_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.l	#MapSpr_FloatBlock,oMap(a0)
	moveq	#5,d0
	jsr	LevelObj_SetBaseTile
	move.b	#1,oPriority(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$C,oYRadius(a0)
	move.b	#5,oMapFrame(a0)
; End of function ObjFloatBlock_Init

; -------------------------------------------------------------------------

ObjFloatBlock_Main:
	bsr.w	ObjFloatBlock_SolidObj
	tst.b	timeZone
	beq.s	.Display
	cmpi.b	#2,timeZone
	bne.s	.Appear
	btst	#3,oStatus(a0)
	bne.s	.StartFall
	bra.s	.Display

; -------------------------------------------------------------------------

.Appear:
	move.b	#0,oMapFrame(a0)
	btst	#3,oStatus(a0)
	beq.s	.Display
	move.b	#6,oRoutine(a0)
	move.b	#1,oAnim(a0)

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.StartFall:
	addq.b	#2,oRoutine(a0)
; End of function ObjFloatBlock_Main

; -------------------------------------------------------------------------

ObjFloatBlock_Fall:
	bsr.w	ObjFloatBlock_SolidObj
	addq.w	#2,oY(a0)
	move.w	cameraY.w,d0
	addi.w	#$E0,d0
	cmp.w	oY(a0),d0
	bcc.s	.Display
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Display:
	jmp	DrawObject
; End of function ObjFloatBlock_Fall

; -------------------------------------------------------------------------

ObjFloatBlock_Appear:
	bsr.w	ObjFloatBlock_SolidObj
	btst	#3,oStatus(a0)
	bne.s	.Animate
	move.b	#2,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.Animate:
	lea	Ani_FloatBlock,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjFloatBlock_Appear

; -------------------------------------------------------------------------

ObjFloatBlock_Visible:
	move.b	#0,oAnim(a0)
	bsr.w	ObjFloatBlock_SolidObj
	btst	#3,oStatus(a0)
	bne.s	.Animate
	addq.b	#2,oRoutine(a0)
	move.b	#2,oAnim(a0)
	rts

; -------------------------------------------------------------------------

.Animate:
	lea	Ani_FloatBlock,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjFloatBlock_Visible

; -------------------------------------------------------------------------

ObjFloatBlock_Vanish:
	bsr.w	ObjFloatBlock_SolidObj
	lea	Ani_FloatBlock,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjFloatBlock_Vanish

; -------------------------------------------------------------------------

ObjFloatBlock_Reset:
	move.b	#2,oRoutine(a0)
	rts
; End of function ObjFloatBlock_Reset

; -------------------------------------------------------------------------

ObjFloatBlock_SolidObj:
	lea	objPlayerSlot.w,a1
	bsr.w	*+4
; End of function ObjFloatBlock_SolidObj

; -------------------------------------------------------------------------

ObjFloatBlock_SolidObj2:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject1
; End of function ObjFloatBlock_SolidObj2

; -------------------------------------------------------------------------

Ani_FloatBlock:
	include	"Level/_Objects/Floating Block/Data/Animations.asm"
	even
MapSpr_FloatBlock:
	include	"Level/_Objects/Floating Block/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
