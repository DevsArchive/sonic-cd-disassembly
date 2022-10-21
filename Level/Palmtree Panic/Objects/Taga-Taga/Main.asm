; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Taga-Taga object
; -------------------------------------------------------------------------

ObjTagaTaga:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTagaTaga_Index(pc,d0.w),d0
	jsr	ObjTagaTaga_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjTagaTaga

; -------------------------------------------------------------------------
ObjTagaTaga_Index:dc.w	ObTagaTaga_Init-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Init2-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Animate-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Jump-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Main-ObjTagaTaga_Index
; -------------------------------------------------------------------------

ObTagaTaga_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$16,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	moveq	#3,d0
	jsr	SetObjectTileID
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	lea	MapSpr_TagaTaga1(pc),a1
	lea	Ani_TagaTaga1(pc),a2
	move.l	#-$3C000,d0
	move.l	#$1000,d1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_TagaTaga2(pc),a1
	lea	Ani_TagaTaga2(pc),a2
	move.l	#-$30000,d0
	move.l	#$1000,d1

.SetInfo:
	move.l	a1,oMap(a0)
	move.l	a2,oVar3C(a0)
	move.l	d0,oVar30(a0)
	move.l	d1,oVar38(a0)
; End of function ObTagaTaga_Init

; -------------------------------------------------------------------------

ObjTagaTaga_Init2:
	addq.b	#2,oRoutine(a0)
	move.w	#$FF,oAnim(a0)
	move.b	#0,oColType(a0)
	move.l	oVar2C(a0),oY(a0)
; End of function ObjTagaTaga_Init2

; -------------------------------------------------------------------------

ObjTagaTaga_Animate:
	movea.l	oVar3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Animate

; -------------------------------------------------------------------------

ObjTagaTaga_Jump:
	addq.b	#2,oRoutine(a0)
	move.w	#$1FF,oAnim(a0)
	move.b	#$2E,oColType(a0)
	move.l	oVar2C(a0),oY(a0)
	move.l	oVar30(a0),oVar34(a0)
	tst.b	oSprFlags(a0)
	bpl.s	ObjTagaTaga_Main
	move.w	#FM_A2,d0
	jsr	PlayFMSound
; End of function ObjTagaTaga_Jump

; -------------------------------------------------------------------------

ObjTagaTaga_Main:
	move.l	oVar34(a0),d0
	add.l	d0,oY(a0)
	move.l	oVar38(a0),d0
	add.l	d0,oVar34(a0)
	move.w	oY(a0),d0
	cmp.w	oVar2C(a0),d0
	ble.s	ObjTagaTaga_DoAnim
	move.b	#2,oRoutine(a0)
	tst.b	oSprFlags(a0)
	bpl.s	ObjTagaTaga_DoAnim
	move.w	#FM_A2,d0
	jsr	PlayFMSound

ObjTagaTaga_DoAnim:
	movea.l	oVar3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Main

; -------------------------------------------------------------------------
Ani_TagaTaga1:
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Animations (Normal).asm"
	even
Ani_TagaTaga2:
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Animations (Damaged).asm"
	even
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
