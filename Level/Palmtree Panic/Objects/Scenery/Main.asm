; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Scenery object
; -------------------------------------------------------------------------

ObjScenery:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjScenery_Index(pc,d0.w),d0
	jsr	ObjScenery_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjScenery

; -------------------------------------------------------------------------
ObjScenery_Index:
	dc.w	ObjScenery_Init-ObjScenery_Index
	dc.w	ObjScenery_Main-ObjScenery_Index
; -------------------------------------------------------------------------

ObjScenery_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.l	#MapSpr_Scenery,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oYRadius(a0)
	bsr.w	ObjScenery_SetBaseTile
; End of function ObjScenery_Init

; -------------------------------------------------------------------------

ObjScenery_Main:
	rts
; End of function ObjScenery_Main

; -------------------------------------------------------------------------

ObjScenery_SetBaseTile:
	moveq	#0,d0
	move.b	timeZone,d0
	andi.b	#$7F,d0
	cmpi.b	#2,d0
	bne.s	.NotFuture
	moveq	#1,d0
	add.b	goodFuture,d0

.NotFuture:
	add.w	d0,d0
	add.b	act,d0
	add.w	d0,d0
	move.w	ObjScenery_BaseTileList(pc,d0.w),oTile(a0)
	ori.w	#$4000,oTile(a0)
	rts
; End of function ObjScenery_SetBaseTile

; -------------------------------------------------------------------------
ObjScenery_BaseTileList:
	dc.w	$3DB, $46E
	dc.w	$438, $39F
	dc.w	$438, $38F
MapSpr_Scenery:
	include	"Level/Palmtree Panic/Objects/Scenery/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
