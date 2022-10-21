; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level collision check functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Calculate the amount of room in front of the player
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_CalcRoomInFront:
	move.l	oX(a0),d3
	move.l	oY(a0),d2
	move.w	oXVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	add.l	d1,d3
	move.w	oYVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	add.l	d1,d2
	swap	d2
	swap	d3
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	move.b	d0,d1
	addi.b	#$20,d0
	bpl.s	.HighAngle
	move.b	d1,d0
	bpl.s	.SkipSub
	subq.b	#1,d0

.SkipSub:
	addi.b	#$20,d0
	bra.s	.GotQuadrant

; -------------------------------------------------------------------------

.HighAngle:
	move.b	d1,d0
	bpl.s	.SkipAdd
	addq.b	#1,d0

.SkipAdd:
	addi.b	#$1F,d0

.GotQuadrant:
	andi.b	#$C0,d0
	beq.w	Player_GetFloorDist_Part2
	cmpi.b	#$80,d0
	beq.w	Player_GetCeilDist_Part2
	andi.b	#$38,d1
	bne.s	.CheckWalls
	addq.w	#8,d2

.CheckWalls:
	cmpi.b	#$40,d0
	beq.w	Player_GetLWallDist_Part2
	bra.w	Player_GetRWallDist_Part2
; End of function Player_CalcRoomInFront

; -------------------------------------------------------------------------

Player_CalcRoomOverHead:
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	addi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Player_CheckLCeil
	cmpi.b	#$80,d0
	beq.w	Player_CheckCeiling
	cmpi.b	#$C0,d0
	beq.w	Player_CheckRCeil

Player_CheckFloor:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.w	(sp)+,d0
	move.b	#0,d2

Player_ChooseAngle:
	move.b	secondaryAngle.w,d3
	cmp.w	d0,d1
	ble.s	.NoExchange
	move.b	primaryAngle.w,d3
	exg	d0,d1

.NoExchange:
	btst	#0,d3
	beq.s	.End
	move.b	d2,d3

.End:
	rts
; End of function Player_CalcRoomOverHead

; -------------------------------------------------------------------------

Player_GetFloorDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetFloorDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetFloorDist_Part2:
	addi.w	#$A,d2
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	#0,d2

Player_GetPriAngle:
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	d2,d3

.End:
	rts
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetFloorDist:
	move.w	oX(a0),d3

ObjGetFloorDist2:
	move.w	oY(a0),d2
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#0,d3

.End:
	rts
; End of function ObjGetFloorDist

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Player_CalcRoomOverHead

Player_CheckRCeil:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	(sp)+,d0
	move.b	#$C0,d2
	bra.w	Player_ChooseAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomOverHead
; -------------------------------------------------------------------------

Player_GetRWallDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetRWallDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetRWallDist_Part2:
	addi.w	#$A,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	#$C0,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetRWallDist:
	add.w	oX(a0),d3
	move.w	oY(a0),d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$C0,d3

.End:
	rts
; End of function ObjGetRWallDist

; -------------------------------------------------------------------------

Player_CheckCeiling:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.w	(sp)+,d0
	move.b	#$80,d2
	bra.w	Player_ChooseAngle
; End of function Player_CheckCeiling

; -------------------------------------------------------------------------

Player_GetCeilDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetCeilDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetCeilDist_Part2:
	subi.w	#$A,d2
	eori.w	#$F,d2
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	#$80,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetCeilDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$80,d3

.End:
	rts
; End of function ObjGetCeilDist

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Player_CalcRoomOverHead

Player_CheckLCeil:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	secondaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	(sp)+,d0
	move.b	#$40,d2
	bra.w	Player_ChooseAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomOverHead
; -------------------------------------------------------------------------

Player_GetLWallDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetLWallDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetLWallDist_Part2:
	subi.w	#$A,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	#$40,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetLWallDist:
	add.w	oX(a0),d3
	move.w	oY(a0),d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$40,d3

.End:
	rts
; End of function ObjGetLWallDist

; -------------------------------------------------------------------------
