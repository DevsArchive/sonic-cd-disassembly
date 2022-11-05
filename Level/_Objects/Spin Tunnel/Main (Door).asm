; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Spin tunnel door object
; -------------------------------------------------------------------------

ObjTunnelDoor:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTunnelDoor_Index(pc,d0.w),d0
	jsr	ObjTunnelDoor_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjTunnelDoor

; -------------------------------------------------------------------------
ObjTunnelDoor_Index:dc.w	ObjTunnelDoor_Init-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Main-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Animate-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Reset-ObjTunnelDoor_Index
; -------------------------------------------------------------------------

ObjTunnelDoor_ChkPlayer:
	tst.w	oYVel(a1)
	bpl.s	.Solid
	bsr.w	ObjTunnelDoor_ChkCollision
	beq.s	.Solid
	move.b	#4,oRoutine(a0)
	tst.b	oSubtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$B,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subq.w	#4,oY(a1)
	move.w	#FM_A4,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.Solid:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	TopSolidObject
; End of function ObjTunnelDoor_ChkPlayer

; -------------------------------------------------------------------------

ObjTunnelDoor_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_TunnelDoor,oMap(a0)
	move.b	#1,oPriority(a0)
	ori.b	#%00000100,oSprFlags(a0)
	move.b	#$2C,oWidth(a0)
	cmpi.b	#2,oSubtype(a0)
	bne.s	.NotNarrow
	move.b	#$18,oWidth(a0)

.NotNarrow:
	move.b	#8,oYRadius(a0)
	moveq	#$C,d0
	jsr	SetObjectTileID
; End of function ObjTunnelDoor_Init

; -------------------------------------------------------------------------

ObjTunnelDoor_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjTunnelDoor_ChkPlayer
	lea	objPlayerSlot2.w,a1
	bra.w	ObjTunnelDoor_ChkPlayer
; End of function ObjTunnelDoor_Main

; -------------------------------------------------------------------------

ObjTunnelDoor_Animate:
	lea	Ani_TunnelDoor,a1
	bra.w	AnimateObject
; End of function ObjTunnelDoor_Animate

; -------------------------------------------------------------------------

ObjTunnelDoor_Reset:
	move.b	#1,oPrevAnim(a0)
	move.b	#0,oMapFrame(a0)
	subq.b	#4,oRoutine(a0)
	rts
; End of function ObjTunnelDoor_Reset

; -------------------------------------------------------------------------

ObjTunnelDoorSplashSet:
	; Scrapped object code

; -------------------------------------------------------------------------

ObjTunnelDoor_ChkCollision:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	moveq	#0,d1
	move.b	oWidth(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollision:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------
; Spin tunnel door splash object
; -------------------------------------------------------------------------

ObjTunnelDoorSplash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTunnelDoorSplash_Index(pc,d0.w),d0
	jmp	ObjTunnelDoorSplash_Index(pc,d0.w)
; End of function ObjTunnelDoorSplash

; -------------------------------------------------------------------------
ObjTunnelDoorSplash_Index:
	dc.w	ObjTunnelDoorSplash_Init-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Main-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Destroy-ObjTunnelDoorSplash_Index
; -------------------------------------------------------------------------

ObjTunnelDoorSplash_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#%00000100,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_TunnelDoorSplash,oMap(a0)
	move.b	oSubtype(a0),oAnim(a0)
	moveq	#$D,d0
	jsr	SetObjectTileID
	move.w	#FM_A2,d0
	cmpi.b	#2,oSubtype(a0)
	bcs.s	.PlaySound
	move.w	#FM_A1,d0

.PlaySound:
	jsr	PlayFMSound
; End of function ObjTunnelDoorSplash_Init

; -------------------------------------------------------------------------

ObjTunnelDoorSplash_Main:
	lea	Ani_TunnelDoorSplash,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjTunnelDoorSplash_Main

; -------------------------------------------------------------------------

ObjTunnelDoorSplash_Destroy:
	jmp	DeleteObject

; -------------------------------------------------------------------------
