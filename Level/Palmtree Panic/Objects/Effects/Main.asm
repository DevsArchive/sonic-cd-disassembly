; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level effect objects
; -------------------------------------------------------------------------

ObjWaterfall:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjWaterfall_Index(pc,d0.w),d0
	jsr	ObjWaterfall_Index(pc,d0.w)
	lea	Ani_Waterfall,a1
	jsr	AnimateObject
	jmp	DrawObject

; -------------------------------------------------------------------------
ObjWaterfall_Index:
	dc.w	ObjWaterfall_Init-ObjWaterfall_Index
	dc.w	ObjWaterfall_Main-ObjWaterfall_Index
; -------------------------------------------------------------------------

ObjWaterfall_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Waterfall,oMap(a0)
	move.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.w	#$3BA,oTile(a0)
	andi.w	#$FFF0,oY(a0)
	move.w	oY(a0),oVar2A(a0)
	addi.w	#$180,oVar2A(a0)
	rts

; -------------------------------------------------------------------------

ObjWaterfall_Main:
	move.w	oY(a0),d0
	addq.w	#4,d0
	cmp.w	oVar2A(a0),d0
	bcs.s	.NoDel
	jmp	DeleteObject

.NoDel:
	move.w	d0,oY(a0)
	moveq	#2,d3
	bset	#$D,d3
	move.w	oY(a0),d4
	move.w	oX(a0),d5
	subi.w	#$60,d5
	move.w	d4,d6
	andi.w	#$F,d6
	bne.s	.End
	moveq	#$B,d6

.Loop:
	jsr	PlaceBlockAtPos
	addi.w	#$10,d5
	dbf	d6,.Loop

.End:
	rts

; -------------------------------------------------------------------------

ObjEarthquakeSet:
	rts
; End of function ObjWaterfall_Main

; -------------------------------------------------------------------------

ObjEarthquake:
	rts
; End of function ObjEarthquake

; -------------------------------------------------------------------------

Ani_Waterfall:
	include	"Level/Palmtree Panic/Objects/Effects/Data/Animations (Waterfall).asm"
	even
		
MapSpr_Waterfall:
	include	"Level/Palmtree Panic/Objects/Effects/Data/Mappings (Waterfall).asm"
	even

; -------------------------------------------------------------------------
