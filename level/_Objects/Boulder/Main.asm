; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Boulder object
; -------------------------------------------------------------------------

ObjBoulder:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBoulder_Index(pc,d0.w),d0
	jsr	ObjBoulder_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjBoulder

; -------------------------------------------------------------------------
ObjBoulder_Index:dc.w	ObjBoulder_Init-ObjBoulder_Index
	dc.w	ObjBoulder_Main-ObjBoulder_Index
; -------------------------------------------------------------------------

ObjBoulder_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_Boulder,oMap(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#0,oMapFrame(a0)
	moveq	#$B,d0
	jsr	LevelObj_SetBaseTile
; End of function ObjBoulder_Init

; -------------------------------------------------------------------------

ObjBoulder_Main:
	tst.b	oRender(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjBoulder_Main

; -------------------------------------------------------------------------
MapSpr_Boulder:
	include	"Level/_Objects/Boulder/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
