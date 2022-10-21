; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level events
; -------------------------------------------------------------------------

RunLevelEvents:
	moveq	#0,d0				; Run level events
	move.b	zone,d0
	add.w	d0,d0
	move.w	.Events(pc,d0.w),d0
	jsr	.Events(pc,d0.w)

	cmpi.b	#$2B,objPlayerSlot+oAnim.w	; Is the player giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	move.w	cameraY.w,bottomBound.w		; Set the bottom boundary of the level to wherever the camera is
	move.w	cameraY.w,destBottomBound.w

.NotGivingUp:
	moveq	#4,d1				; Bottom boundary shift speed
	move.w	destBottomBound.w,d0		; Is the bottom boundary shifting?
	sub.w	bottomBound.w,d0
	beq.s	.End				; If not, branch
	bcc.s	.MoveDown			; If it's scrolling down, branch

	neg.w	d1				; Set the speed to go up
	move.w	cameraY.w,d0			; Is the camera past the target bottom boundary?
	cmp.w	destBottomBound.w,d0
	bls.s	.ShiftUp			; If not, branch
	move.w	d0,bottomBound.w		; Set the bottom boundary to be where the camera id
	andi.w	#$FFFE,bottomBound.w

.ShiftUp:
	add.w	d1,bottomBound.w		; Shift the boundary up
	move.b	#1,btmBoundShift.w		; Mark as shifting

.End:
	rts

.MoveDown:
	move.w	cameraY.w,d0			; Is the camera near the bottom boundary?
	addq.w	#8,d0
	cmp.w	bottomBound.w,d0
	bcs.s	.ShiftDown			; If not, branch
	btst	#1,objPlayerSlot+oFlags.w	; Is the player in the air?
	beq.s	.ShiftDown			; If not, branch
	add.w	d1,d1				; If so, quadruple the shift speed
	add.w	d1,d1

.ShiftDown:
	add.w	d1,bottomBound.w		; Shift the boundary down
	move.b	#1,btmBoundShift.w		; Mark as shifting
	rts

; -------------------------------------------------------------------------

.Events:
	dc.w	LevEvents_PPZ-.Events		; PPZ
	dc.w	LevEvents_CCZ-.Events		; CCZ
	dc.w	LevEvents_TTZ-.Events		; TTZ
	dc.w	LevEvents_QQZ-.Events		; QQZ
	dc.w	LevEvents_WWZ-.Events		; WWZ
	dc.w	LevEvents_SSZ-.Events		; SSZ
	dc.w	LevEvents_MMZ-.Events		; MMZ

; -------------------------------------------------------------------------
; Palmtree Panic level events
; -------------------------------------------------------------------------

LevEvents_PPZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_PPZ_Index(pc,d0.w),d0
	jmp	LevEvents_PPZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_PPZ_Index:
	dc.w	LevEvents_PPZ1-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ2-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ3-LevEvents_PPZ_Index

; -------------------------------------------------------------------------

LevEvents_PPZ1:
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	LevEvents_PPZ2			; If not, branch

	cmpi.w	#$1C16,objPlayerSlot+oX.w	; Is the player within the second 3D ramp?
	bcs.s	.Not3DRamp			; If not, branch
	cmpi.w	#$21C6,objPlayerSlot+oX.w
	bcc.s	.Not3DRamp			; If not, branch
	move.w	#$88,camYCenter.w		; If so, change the camera Y center

.Not3DRamp:
	move.w	#$710,destBottomBound.w		; Set bottom boundary before the first 3D ramp

	cmpi.w	#$840,cameraX.w			; Is the camera's X position < $840?
	bcs.s	.End				; If so, branch

	tst.b	updateHUDTime			; Is the level timer running?
	beq.s	.AlreadySet			; If not, branch

	cmpi.w	#$820,leftBound.w		; Has the left boundary been set
	bcc.s	.AlreadySet			; If not, branch
	move.w	#$820,leftBound.w		; Set the left boundary so that the player can't go back to the first 3D ramp
	move.w	#$820,destLeftBound.w

.AlreadySet:
	move.w	#$410,destBottomBound.w		; Set bottom boundary after the first 3D ramp
	cmpi.w	#$E00,cameraX.w			; Is the camera's X position < $E00?
	bcs.s	.End				; If so, branch
	move.w	#$310,destBottomBound.w		; Update the bottom boundary

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_PPZ2:
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_PPZ3:
	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.End				; If so, branch

	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	move.w	#$D70,d0			; Handle end of act 3 boundary
	move.w	#$310,d1
	bsr.w	CheckBossStart

.End:
	rts

; -------------------------------------------------------------------------
; Collision Chaos level events
; -------------------------------------------------------------------------

LevEvents_CCZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_CCZ_Index(pc,d0.w),d0
	jmp	LevEvents_CCZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_CCZ_Index:
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ3-LevEvents_CCZ_Index

; -------------------------------------------------------------------------

LevEvents_CCZ12:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_CCZ3:
	tst.b	bossFlags.w			; Was the boss defeated?
	bne.w	.ChkLock			; If so, branch
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

.ChkLock:
	move.w	#$60,d1				; Handle end of act 3 boundary
	bra.w	SetBossBounds

; -------------------------------------------------------------------------
; Wacky Workbench level events
; -------------------------------------------------------------------------

LevEvents_WWZ:
	btst	#4,bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

.BossActive:
	move.w	#$BA0,d0			; Handle end of act 3 boundary
	move.w	#$1D0,d1
	bsr.w	CheckBossStart
	bne.w	.End				; If the boundary was set, branch

	lea	objPlayerSlot.w,a1		; Check where the player is
	cmpi.w	#$298,oY(a1)			; Are they at the top of the boss arena?
	ble.s	.BoundTop			; If so, branch
	cmpi.w	#$498,oY(a1)			; Are they in the middle of the boss arena?
	ble.s	.BoundMiddle			; If so, branch

.BoundBottom:
	move.w	#$5D0,d0			; Set the bottom boundary at the bottom
	bra.s	.SetBound

.BoundMiddle:
	move.w	#$3D0,d0			; Set the bottom boundary in the middle
	bra.s	.SetBound

.BoundTop:
	move.w	#$1D0,d0			; Set the bottom boundary at the top

.SetBound:
	move.w	d0,d1				; Set target bottom boundary
	move.w	d0,destBottomBound.w

	sub.w	bottomBound.w,d0		; Is the current bottom boundary near the target?
	bge.s	.CheckNearBound
	neg.w	d0

.CheckNearBound:
	cmpi.w	#2,d0
	bgt.s	.End				; If not, branch
	move.w	d1,bottomBound.w		; Update bottom boundary

.End:
	rts

; -------------------------------------------------------------------------
; Quartz Quadrant level events
; -------------------------------------------------------------------------

LevEvents_QQZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_QQZ_Index(pc,d0.w),d0
	jmp	LevEvents_QQZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_QQZ_Index:
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ3-LevEvents_QQZ_Index

; -------------------------------------------------------------------------

LevEvents_QQZ12:
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_QQZ3:
	move.w	#$E10,d0			; Handle end of act 3 boundary
	move.w	#$1F8,d1
	bsr.w	CheckBossStart
	bne.s	.End				; If the boundary was set, branch

	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	if (REGION=USA)|((REGION<>USA)&(DEMO=0)); Set default bottom boundary
		move.w	#$320,destBottomBound.w
	else
		move.w	#$310,destBottomBound.w
	endif
	
.End:
	rts

.BossActive:
	move.w	#$1F8,bottomBound.w		; Set bottom boundary for the boss
	move.w	#$1F8,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Metallic Madness level events
; -------------------------------------------------------------------------

LevEvents_MMZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_MMZ_Index(pc,d0.w),d0
	jmp	LevEvents_MMZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_MMZ_Index:
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ3-LevEvents_MMZ_Index

; -------------------------------------------------------------------------

LevEvents_MMZ12:
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_MMZ3:
	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

.BossActive:
	move.w	#$10C,d0			; Set boundaries for the boss
	move.w	d0,topBound.w
	move.w	d0,destTopBound.w
	move.w	d0,bottomBound.w
	move.w	d0,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Tidal Tempest level events
; -------------------------------------------------------------------------

LevEvents_TTZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_TTZ_Index(pc,d0.w),d0
	jmp	LevEvents_TTZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_TTZ_Index:
	dc.w	LevEvents_TTZ1-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ2-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ3-LevEvents_TTZ_Index

; -------------------------------------------------------------------------

LevEvents_TTZ1:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_TTZ2:
	cmpi.b	#$2B,objPlayerSlot+oAnim.w	; Is the player giving up from boredom?
	beq.s	.NoWrap				; If so, branch
	cmpi.b	#6,objPlayerSlot+oRoutine.w	; Is the player dead?
	bcc.s	.NoWrap				; If so, branch

	move.w	#$800,bottomBound.w		; Set bottom boundary for wrapping section
	move.w	#$800,destBottomBound.w
	cmpi.w	#$200,cameraX.w			; Is the camera's X position < $200?
	bcs.s	.End				; If so, branch

.NoWrap:
	move.w	#$710,bottomBound.w		; Set bottom boundary after the wrapping section
	move.w	#$710,destBottomBound.w

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_TTZ3:
	move.w	#$AF8,d0			; Handle end of act 3 boundary
	move.w	#$4C0,d1
	bsr.w	CheckBossStart
	bne.s	.End				; If the boundary was set, branch

	tst.b	bossFlags.w			; Has the boss fight been started?
	bne.s	.BossActive			; If so, branch

.End:
	rts

.BossActive:
	move.w	#$4F0,bottomBound.w		; Set bottom boundary for the boss fight
	move.w	#$4F0,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Stardust Speedway level events
; -------------------------------------------------------------------------

LevEvents_SSZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_SSZ_Index(pc,d0.w),d0
	jmp	LevEvents_SSZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_SSZ_Index:
	dc.w	LevEvents_SSZ1-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ2-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ3-LevEvents_SSZ_Index

; -------------------------------------------------------------------------

LevEvents_SSZ1:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_SSZ2:
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_SSZ3:
	lea	objPlayerSlot.w,a1		; Have we reached Metal Sonic?
	cmpi.w	#$930,oX(a1)
	bge.s	.FoundMetalSonic		; If so, branch
	move.w	#$210,destBottomBound.w		; If not, set default bottom boundary
	rts

.FoundMetalSonic:
	cmpi.w	#$DC0,oX(a1)			; Has the race started?
	blt.s	.RaceStarted			; If so, branch
	move.w	#$210,destBottomBound.w		; If not, set default bottom boundary
	rts

.RaceStarted:
	move.w	#$120,d0			; Set bottom boundary for the race
	move.w	d0,d1
	move.w	d0,destBottomBound.w

	sub.w	bottomBound.w,d1		; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.End				; If not, branch
	move.w	d0,bottomBound.w		; Update bottom boundary

.End:
	rts

; -------------------------------------------------------------------------
; Check if the boss arena boundaries should be set
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - X position in which boundaries are set
;	d1.w - Bottom boundary value
; -------------------------------------------------------------------------

CheckBossStart:
	cmp.w	objPlayerSlot+oX.w,d0		; Has the player reached the point where boundaries should be set?
	ble.s	SetBossBounds		; If so, branch

	moveq	#0,d0				; Mark boundaries as not set
	rts

; -------------------------------------------------------------------------

SetBossBounds:
	move.w	d1,destBottomBound.w		; Set bottom boundary

	sub.w	bottomBound.w,d1		; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.NoYLock			; If not, branch
	move.w	destBottomBound.w,bottomBound.w	; Update bottom boundary

.NoYLock:
	move.w	objPlayerSlot+oX.w,d0		; Get player's position
	subi.w	#320/2,d0
	cmp.w	leftBound.w,d0			; Has the left boundary already been set?
	blt.s	.BoundsSet			; If so, branch
	cmp.w	rightBound.w,d0			; Have we reached the right boundary?
	ble.s	.NoBoundSet			; If not, branch
	move.w	rightBound.w,d0			; Set to bound at the right boundary

.NoBoundSet:
	move.w	d0,leftBound.w			; Update the left boundary
	move.w	d0,destLeftBound.w

.BoundsSet:
	moveq	#1,d0				; Mark boundaries as set
	rts

; -------------------------------------------------------------------------
