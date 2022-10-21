; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Launcher object
; -------------------------------------------------------------------------

oLaunchParent	EQU	oVar2A
oLaunchX	EQU	oVar2E

; -------------------------------------------------------------------------

ObjLauncher:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjLauncher_Init-.Index
	dc.w	ObjLauncher_Main-.Index
	dc.w	ObjLauncher_Launch-.Index
	dc.w	ObjLauncher_Revert-.Index
	dc.w	ObjLauncher_SolidSide-.Index

; -------------------------------------------------------------------------

ObjLauncher_Init:
	ori.b	#4,oSprFlags(a0)
	move.w	#$400,oTile(a0)
	move.l	#MapSpr_Launcher,oMap(a0)
	move.w	oX(a0),oLaunchX(a0)
	move.b	#28,oXRadius(a0)
	move.b	#28,oWidth(a0)
	move.b	#4,oYRadius(a0)
	addq.b	#2,oRoutine(a0)
	
	jsr	FindNextObjSlot
	move.b	#4,oID(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	#$400,oTile(a1)
	move.l	#MapSpr_Launcher,oMap(a1)
	move.b	#4,oXRadius(a1)
	move.b	#12,oYRadius(a1)
	move.b	#1,oMapFrame(a1)
	move.l	a0,oLaunchParent(a1)
	move.b	#8,oRoutine(a1)

; -------------------------------------------------------------------------

ObjLauncher_Main:
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	beq.s	.End
	bset	#0,oPlayerCtrl(a1)
	move.w	oX(a0),oX(a1)
	bclr	#0,oFlags(a1)
	move.b	#$3A,oAnim(a1)
	addq.b	#2,oRoutine(a0)
	move.w	#$C00,oXVel(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjLauncher_Launch:
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	oX(a0),d1
	add.l	d0,d1
	move.l	d1,oX(a0)
	
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	
	move.w	p1CtrlData.w,d0
	andi.b	#$70,d0
	beq.s	.NoJump
	
	bclr	#0,oPlayerCtrl(a1)
	move.w	#-$680,oYVel(a1)
	move.w	oXVel(a0),oXVel(a1)
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oFlags(a1)
	bclr	#5,oFlags(a1)
	move.b	#2,oAnim(a1)
	move.w	#FM_JUMP,d0
	jsr	PlayFMSound
	
.NoJump:
	move.w	oLaunchX(a0),d0
	addi.w	#912,d0
	cmp.w	oX(a0),d0
	bcc.s	.End
	move.w	d0,oX(a0)
	
	addq.b	#2,oRoutine(a0)
	btst	#3,oFlags(a0)
	beq.s	.End
	bclr	#0,oPlayerCtrl(a1)
	move.w	oXVel(a0),oXVel(a1)
	move.b	#0,oAnim(a1)
	bset	#1,oFlags(a1)
	bclr	#3,oFlags(a1)

.End:
	rts

; -------------------------------------------------------------------------

ObjLauncher_Revert:
	subq.w	#4,oX(a0)
	move.w	oLaunchX(a0),d0
	cmp.w	oX(a0),d0
	bcs.s	.End
	move.w	oLaunchX(a0),oX(a0)
	move.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjLauncher_SolidSide:
	movea.l	oLaunchParent(a0),a1
	cmpi.b	#4,oRoutine(a1)
	bcc.s	.End
	move.w	oX(a1),oX(a0)
	subi.w	#24,oX(a0)
	move.w	oY(a1),oY(a0)
	subi.w	#16,oY(a0)
	
	lea	objPlayerSlot.w,a1
	jmp	SolidObject
	
.End:
	rts

; -------------------------------------------------------------------------

MapSpr_Launcher:
	include	"Level/Wacky Workbench/Objects/Launcher/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
