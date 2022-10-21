; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Switch object
; -------------------------------------------------------------------------

oSwitchFlag	EQU	oVar3C
oSwitchPressPrv	EQU	oVar3E
oSwitchPress	EQU	oVar3F

; -------------------------------------------------------------------------

ObjSwitch:
	tst.b	oRoutine(a0)
	bne.s	ObjSwitch_Main

; -------------------------------------------------------------------------

ObjSwitch_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#16,oXRadius(a0)
	move.b	#16,oWidth(a0)
	move.w	#$39A,oTile(a0)
	move.l	#MapSpr_Switch,oMap(a0)
	move.b	#8,oYRadius(a0)

	lea	switchFlags.w,a1
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	lea	(a1,d0.w),a1
	move.w	a1,oSwitchFlag(a0)

; -------------------------------------------------------------------------

ObjSwitch_Main:
	move.b	oSwitchPress(a0),oSwitchPressPrv(a0)

	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	movea.w	oSwitchFlag(a0),a4
	sne	oSwitchPress(a0)
	bne.s	.Pressed

	bclr	#7,(a4)
	bra.s	.CheckPress

.Pressed:
	bset	#7,(a4)
	bset	#6,(a4)

.CheckPress:
	cmpi.w	#$00FF,oSwitchPressPrv(a0)
	bne.s	.CheckUnpress
	tst.b	oSprFlags(a0)
	bpl.s	.PressedFrame
	move.w	#FM_BF,d0
	jsr	PlayFMSound

.PressedFrame:
	bchg	#5,(a4)
	addq.w	#8,oY(a1)
	addq.w	#4,oY(a0)
	addq.b	#1,oMapFrame(a0)
	subq.b	#4,oYRadius(a0)

.CheckUnpress:
	cmpi.w	#$FF00,oSwitchPressPrv(a0)
	bne.s	.Draw
	subq.w	#8,oY(a1)
	subq.w	#4,oY(a0)
	subq.b	#1,oMapFrame(a0)
	addq.b	#4,oYRadius(a0)

.Draw:
	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

MapSpr_Switch:
	include	"Level/Wacky Workbench/Objects/Switch/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
