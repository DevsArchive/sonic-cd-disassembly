; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

oPlayerStampC	EQU	oVarE			; Collided stamp (center)
oPlayerStampTL	EQU	oVarF			; Collided stamp (top left)
oPlayerStampTR	EQU	oVar10			; Collided stamp (top right)
oPlayerStampBR	EQU	oVar11			; Collided stamp (bottom right)
oPlayerStampBL	EQU	oVar12			; Collided stamp (bottom left)
oPlayerStampOri	EQU	oVar13			; Center collided stamp orientation
oPlayerSpeed	EQU	oVar14			; Speed
oPlayerBumpTime	EQU	oVar16			; Bump/boost timer
oPlayerBumpSpd	EQU	oVar16			; Bump speed
oPlayerTopSpeed	EQU	oVar18			; Top speed
oPlayerSprYVel	EQU	oVar40			; Sprite Y velocity
oPlayerUFOCol	EQU	oVar4F			; UFO collision object ID
oPlayerPitch	EQU	oVar50			; Pitch angle
oPlayerYaw	EQU	oVar54			; Yaw angle
oPlayerTilt	EQU	oVar60			; Tilt
oPlayerTimer	EQU	oVar61			; General timer
oPlayerShoes	EQU	oVar62			; Speed shoes timer

; -------------------------------------------------------------------------

ObjSonic_Index:
	dc.w	ObjSonic_Init-ObjSonic_Index
	dc.w	ObjSonic_Ground-ObjSonic_Index
	dc.w	ObjSonic_Jump-ObjSonic_Index
	dc.w	ObjSonic_Float-ObjSonic_Index
	dc.w	ObjSonic_Bumped-ObjSonic_Index
	dc.w	ObjSonic_Sink-ObjSonic_Index
	dc.w	ObjSonic_Sink2-ObjSonic_Index
	dc.w	ObjSonic_Hurt-ObjSonic_Index
	dc.w	ObjSonic_TimeStone1-ObjSonic_Index
	dc.w	ObjSonic_TimeStone2-ObjSonic_Index
	dc.w	ObjSonic_TimeStone3-ObjSonic_Index
	dc.w	ObjSonic_TimeStone4-ObjSonic_Index
	dc.w	ObjSonic_TimeStone5-ObjSonic_Index
	dc.w	ObjSonic_TimeStone6-ObjSonic_Index
	dc.w	ObjSonic_TimeStone7-ObjSonic_Index
	dc.w	ObjSonic_TimeStone8-ObjSonic_Index
	dc.w	ObjSonic_TimeStone9-ObjSonic_Index
	dc.w	ObjSonic_TimeStone10-ObjSonic_Index
	dc.w	ObjSonic_TimeStone11-ObjSonic_Index
	dc.w	ObjSonic_Boosted-ObjSonic_Index
	dc.w	ObjSonic_Start1-ObjSonic_Index
	dc.w	ObjSonic_Start2-ObjSonic_Index
	dc.w	ObjSonic_Start3-ObjSonic_Index
	dc.w	ObjSonic_Start4-ObjSonic_Index

; -------------------------------------------------------------------------

ObjSonic:
	move.w	ctrlData.w,d0			; Get controller data
	cmp.w	ctrlData.w,d0			; Did it just change?
	bne.s	ObjSonic			; If so, read it again to make sure it's consistent
	move.w	d0,playerCtrlData		; Set player controller data

	moveq	#0,d0				; Get routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	ObjSonic_Index(pc,d0.w),d0

	bsr.w	ObjSonic_HandleSpeed		; Handle speed
	bclr	#5,oFlags(a0)			; Clear bump flag
	bclr	#2,oFlags(a0)			; Enable drawing
	move.w	#$A00,oPlayerTopSpeed(a0)	; Set top speed

	jsr	ObjSonic_Index(pc,d0.w)		; Run routine

	btst	#3,oFlags(a0)			; Is collision and movement disabled?
	bne.s	.CheckRightBound		; If so, branch
	btst	#7,oFlags(a0)			; Are we in the air?
	bne.s	.NoStampCol			; If so, branch
	btst	#6,oFlags(a0)			; Are we floating?
	bne.s	.NoStampCol			; If so, branch
	tst.b	stageInactive			; Is the stage inactive?
	bne.s	.NoStampCol			; If so, branch

	bsr.w	ObjSonic_GetStamps		; Get stamps
	bsr.w	ObjSonic_StampCollide		; Handle stamp collision

.NoStampCol:
	btst	#5,oFlags(a0)			; Are we being bumped?
	bne.s	.CheckLeftBound			; If so, branch
	bsr.w	ObjSonic_Move			; Move

.CheckLeftBound:
	cmpi.w	#$340,oX(a0)			; Are we past the left boundary?
	bcc.s	.CheckRightBound		; If not, branch
	move.w	#$340,oX(a0)			; Prevent going past the boundary

.CheckRightBound:
	cmpi.w	#$1000-$340,oX(a0)		; Are we past the right boundary?
	bcs.s	.CheckTopBound			; If not, branch
	move.w	#$1000-$340,oX(a0)		; Prevent going past the boundary

.CheckTopBound:
	cmpi.w	#$340,oY(a0)			; Are we past the top boundary?
	bcc.s	.CheckBottomBound		; If not, branch
	move.w	#$340,oY(a0)			; Prevent going past the boundary

.CheckBottomBound:
	cmpi.w	#$1000-$340,oY(a0)		; Are we past the bottom boundary?
	bcs.s	.SetPosition			; If not, branch
	move.w	#$1000-$340,oY(a0)		; Prevent going past the boundary

.SetPosition:
	lea	gfxVars,a1			; Set positioning for graphics operation
	move.w	oX(a0),gfxCamX(a1)
	move.w	oY(a0),gfxCamY(a1)
	move.w	oZ(a0),gfxCamZ(a1)
	move.w	oPlayerPitch(a0),gfxPitch(a1)
	move.w	oPlayerYaw(a0),gfxYaw(a1)

	cmpi.b	#7,oRoutine(a0)			; Are we hurt?
	beq.s	.Draw				; If so, branch
	cmpi.b	#$13,oRoutine(a0)		; Were we boosted fast?
	beq.s	.Draw				; If so, branch

	bsr.w	ObjSonic_Tilt			; Handle tilting animation
	bsr.w	ObjSonic_Animate		; Animate

.Draw:
	bsr.w	DrawObject			; Draw sprite
	bsr.w	ObjSonic_LoadArt		; Load sprite art

	move.b	#0,oPlayerUFOCol(a0)		; Reset UFO collision
	rts

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjSonic_Init:
	move.w	#$85E0,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Sonic,oMap(a0)		; Mappings
	move.w	#128+128,oSprX(a0)		; Set sprite position
	move.w	#216+128,oSprY(a0)
	moveq	#9,d0				; Set animation
	bsr.w	SetObjAnim
	move.b	#$14,oRoutine(a0)		; Set to starting post
	move.w	#0,oPlayerSpeed(a0)		; Reset speed
	bsr.w	ObjSonic_GetStartPos		; Get start position
	move.w	#$160,oZ(a0)			; Set Z position
	move.w	#$80,oPlayerPitch(a0)		; Set pitch

; -------------------------------------------------------------------------
; Starting pose mode
; -------------------------------------------------------------------------

ObjSonic_Start1:
	rts

; -------------------------------------------------------------------------

ObjSonic_Start2:
	moveq	#$2C,d0				; Set animation
	bsr.w	SetObjAnim
	move.b	#$16,oRoutine(a0)		; Advance routine
	move.b	#5,oPlayerTimer(a0)		; Set timer
	rts

; -------------------------------------------------------------------------

ObjSonic_Start3:
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	moveq	#$A,d0				; Set animation
	bsr.w	SetObjAnim
	move.b	#$17,oRoutine(a0)		; Advance routine

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Start4:
	rts

; -------------------------------------------------------------------------
; Ground mode
; -------------------------------------------------------------------------

ObjSonic_Ground:
	bsr.w	ObjSonic_Rotate			; Handle rotation
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_CheckWin		; Check for winning
	rts

; -------------------------------------------------------------------------
; Jump mode
; -------------------------------------------------------------------------

ObjSonic_Jump:
	move.l	oSprY(a0),d0			; Move sprite
	add.l	oPlayerSprYVel(a0),d0
	move.l	d0,oSprY(a0)
	if REGION<>EUROPE			; Apply gravity
		addi.l	#$A000,oPlayerSprYVel(a0)
	else
		addi.l	#$C000,oPlayerSprYVel(a0)
	endif

	tst.w	jumpTimer			; Are we landing?
	beq.s	.CheckLand			; If so, branch
	if REGION<>EUROPE			; Double the gravity when jumping
		addi.l	#$A000,oPlayerSprYVel(a0)
	else
		addi.l	#$C000,oPlayerSprYVel(a0)
	endif
	subq.w	#1,jumpTimer			; Decrement jump timer

	move.b	playerCtrlHold,d0		; Are A, B, or C beign held?
	andi.b	#$70,d0
	beq.s	.CheckLand			; If not, branch
	if REGION<>EUROPE			; If so, undo gravity doubling
		subi.l	#$A000,oPlayerSprYVel(a0)
	else
		subi.l	#$C000,oPlayerSprYVel(a0)
	endif

.CheckLand:
	cmpi.w	#216+128,oSprY(a0)		; Have we landed?
	bcs.s	.NotLanded			; If not, branch
	move.b	#1,oRoutine(a0)			; Set to ground mode
	move.l	#(216+128)<<16,oSprY(a0)	; Stick to ground
	move.l	#0,oPlayerSprYVel(a0)		; Stop moving
	bclr	#7,oFlags(a0)			; Clear air flag
	move.w	#$160,oZ(a0)			; Reset Z position

.NotLanded:
	bsr.w	ObjSonic_Rotate			; Handle rotation

	move.w	#216+128,d0			; Set Z position
	sub.w	oSprY(a0),d0
	lsl.w	#2,d0
	addi.w	#$160,d0
	move.w	d0,oZ(a0)
	rts

; -------------------------------------------------------------------------
; Float mode
; -------------------------------------------------------------------------

ObjSonic_Float:
	move.l	oSprY(a0),d0			; Move sprite
	add.l	oPlayerSprYVel(a0),d0
	move.l	d0,oSprY(a0)
	if REGION<>EUROPE			; Apply gravity
		addi.l	#$2000,oPlayerSprYVel(a0)
	else
		addi.l	#$2666,oPlayerSprYVel(a0)
	endif

	cmpi.w	#216+128,oSprY(a0)		; Have we landed?
	bcs.s	.NotLanded			; If not, branch
	move.b	#1,oRoutine(a0)			; Set to ground mode
	move.l	#(216+128)<<16,oSprY(a0)	; Stick to ground
	move.l	#0,oPlayerSprYVel(a0)		; Stop moving
	bclr	#6,oFlags(a0)			; Clear float flag
	move.w	#$160,oZ(a0)			; Reset Z position

.NotLanded:
	bsr.w	ObjSonic_Rotate			; Handle rotation

	move.w	#216+128,d0			; Set Z position
	sub.w	oSprY(a0),d0
	lsl.w	#2,d0
	addi.w	#$160,d0
	move.w	d0,oZ(a0)
	rts

; -------------------------------------------------------------------------
; Bumped mode
; -------------------------------------------------------------------------

ObjSonic_Bumped:
	subq.w	#1,oPlayerBumpTime(a0)		; Decrement bump time
	bne.s	.Move				; If it hasn't run out, branch
	move.b	#1,oRoutine(a0)			; Set to normal ground mode
	move.l	#0,oXVel(a0)			; Stop bump movement
	move.l	#0,oYVel(a0)
	bra.s	.Update

.Move:
	move.l	oXVel(a0),d0			; Apply bump movement
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

.Update:
	bsr.w	ObjSonic_Rotate			; Handle rotation
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_CheckWin		; Check for winning
	rts

; -------------------------------------------------------------------------
; Unused mode that makes Sonic sink down out of the stage
; -------------------------------------------------------------------------

ObjSonic_Sink:
	addq.w	#4,oSprY(a0)			; Move sprite down
	cmpi.w	#320+128,oSprY(a0)		; Has it moved offscreen?
	bcs.s	.End				; If not, branch
	move.b	#6,oRoutine(a0)			; Advance routine

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Sink2:
	rts

; -------------------------------------------------------------------------
; Hurt mode
; -------------------------------------------------------------------------

ObjSonic_Hurt:
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	
	move.b	#1,oRoutine(a0)			; Set to normal ground mode
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------
; Time stone retrieved mode
; -------------------------------------------------------------------------

ObjSonic_TimeStone1:
	cmpi.w	#216+128,oSprY(a0)		; Are we on the ground?
	bcs.s	.Update				; If not, branch
	
	move.b	#60,oPlayerTimer(a0)		; Set timer
	moveq	#$A,d0				; Set animation
	bsr.w	SetObjAnim
	move.b	#9,oRoutine(a0)			; Advance routine
	move.b	#1,stageInactive		; Mark stage as inactive
	move.w	#0,oPlayerSpeed(a0)		; Stop moving
	rts
	
.Update:
	bsr.w	ObjSonic_Rotate			; Handle rotation
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone2:
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch

	move.b	#$E,timeStoneObject+oID		; Spawn time stone and sparkles
	move.b	#$F,sparkleObject1+oID
	move.b	#$10,sparkleObject2+oID

	move.b	#$A,oRoutine(a0)		; Advance routine
	move.b	#6,oPlayerTimer(a0)		; Set timer

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone3:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	
	move.b	#$B,oRoutine(a0)		; Advance routine
	move.b	#4,oPlayerTimer(a0)		; Set timer
	moveq	#$24,d0				; Set animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone4:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	
	move.b	#$C,oRoutine(a0)		; Advance routine
	move.b	#5,oPlayerTimer(a0)		; Set timer
	moveq	#$25,d0				; Set next animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone5:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	
	move.b	#$D,oRoutine(a0)		; Advance routine
	move.b	#4,oPlayerTimer(a0)		; Set timer
	moveq	#$26,d0				; Set next animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone6:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	
	move.b	#$E,oRoutine(a0)		; Advance routine
	move.b	#5,oPlayerTimer(a0)		; Set timer
	moveq	#$27,d0				; Set next animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone7:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch

	move.b	#$F,oRoutine(a0)		; Advance routine
	move.b	#4,oPlayerTimer(a0)		; Set timer
	moveq	#$28,d0				; Set next animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone8:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch

	move.b	#$10,oRoutine(a0)		; Advance routine
	move.b	#5,oPlayerTimer(a0)		; Set timer
	moveq	#$29,d0				; Set next animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone9:
	bset	#2,subScrollFlags		; Rotate left
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	
	subq.b	#1,oPlayerTimer(a0)		; Decrement timer
	bne.s	ObjSonic_TimeStone10		; If it hasn't run out, branch

	move.b	#$11,oRoutine(a0)		; Advance routine
	moveq	#$2A,d0				; Set next animation
	bsr.w	SetObjAnim

; -------------------------------------------------------------------------

ObjSonic_TimeStone10:
	rts

; -------------------------------------------------------------------------

ObjSonic_TimeStone11:
	moveq	#$2B,d0				; Set next animation
	bsr.w	SetObjAnim
	rts

; -------------------------------------------------------------------------
; Boosted mode
; -------------------------------------------------------------------------

ObjSonic_Boosted:
	subq.w	#1,oPlayerBumpTime(a0)		; Decrement boost time
	bne.s	.Move				; If it hasn't run out, branch
	
	move.b	#1,oRoutine(a0)			; Set to normal ground mode
	move.l	#0,oXVel(a0)			; Stop bump movement
	move.l	#0,oYVel(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	bra.s	.Done

.Move:
	move.l	oXVel(a0),d0			; Move
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

.Done:
	bsr.w	ObjSonic_Rotate			; Handle rotation
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	rts

; -------------------------------------------------------------------------
; Get starting position
; -------------------------------------------------------------------------

ObjSonic_GetStartPos:
	moveq	#0,d0				; Set start position and angle
	move.b	specStageID.w,d0
	mulu.w	#6,d0
	move.w	.StartPos(pc,d0.w),oX(a0)
	move.w	.StartPos+2(pc,d0.w),oY(a0)
	move.w	.StartPos+4(pc,d0.w),oPlayerYaw(a0)
	rts

; -------------------------------------------------------------------------

.StartPos:
	incbin	"Special Stage/Data/Stage 1/Start Position.bin"
	incbin	"Special Stage/Data/Stage 2/Start Position.bin"
	incbin	"Special Stage/Data/Stage 3/Start Position.bin"
	incbin	"Special Stage/Data/Stage 4/Start Position.bin"
	incbin	"Special Stage/Data/Stage 5/Start Position.bin"
	incbin	"Special Stage/Data/Stage 6/Start Position.bin"
	incbin	"Special Stage/Data/Stage 7/Start Position.bin"
	incbin	"Special Stage/Data/Stage 8/Start Position.bin"

; -------------------------------------------------------------------------
; Check if the stage is beaten
; -------------------------------------------------------------------------

ObjSonic_CheckWin:
	tst.b	ufoCount.w			; Are there any UFOs left?
	bne.s	.End				; If so, branch

	move.b	#8,sonicObject+oRoutine		; Set to time stone retrieved mode
	lea	timeUFOObject,a6		; Delete time UFO
	bsr.s	.Delete
	lea	timeUFOShadObj,a6

; -------------------------------------------------------------------------

.Delete:
	tst.b	(a6)				; Is the object spawned?
	beq.s	.End				; If not, branch
	bset	#0,oFlags(a6)			; Delete object

.End:
	rts

; -------------------------------------------------------------------------
; Handle stamp collision
; -------------------------------------------------------------------------

ObjSonic_StampCollide:
	bsr.w	ObjSonic_CheckBumper		; Check bumper collision

	tst.b	ufoCount.w			; Are there any UFOs?
	beq.s	.End				; If not, branch

	move.b	oPlayerStampC(a0),d0		; Get stamp we are on
	cmpi.b	#(.TypesEnd-.Types)/2,d0	; Is the type ID too large?
	bcs.s	.Handle				; If not, branch
	moveq	#0,d0				; If so, set to path type

.Handle:
	ext.w	d0				; Run routine
	add.w	d0,d0
	move.w	.Types(pc,d0.w),d0
	jmp	.Types(pc,d0.w)

; -------------------------------------------------------------------------

.Types:
	dc.w	.End-.Types			; Path
	dc.w	.End-.Types			; Bumper
	dc.w	ObjSonic_Fan-.Types		; Fan
	dc.w	ObjSonic_Water-.Types		; Water
	dc.w	ObjSonic_Rough-.Types		; Rough
	dc.w	ObjSonic_Spring-.Types		; Spring
	dc.w	ObjSonic_Hazard-.Types		; Hazard
	dc.w	ObjSonic_BigBooster-.Types	; Big booster
	dc.w	ObjSonic_SmallBooster-.Types	; Small booster
	dc.w	.End-.Types			; Oil
.TypesEnd:

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Fan:
	move.b	#3,oRoutine(a0)			; Set to floating mode
	if REGION<>EUROPE			; Float upwards
		move.l	#-$40000,oPlayerSprYVel(a0)
	else
		move.l	#-$48000,oPlayerSprYVel(a0)
	endif
	bset	#6,oFlags(a0)			; Set floating flag

	move.b	#FM_B8,d0			; Play fan sound
	bsr.w	PlayFMSound

	bsr.w	DeleteSplash			; Delete splash object
	rts

; -------------------------------------------------------------------------

ObjSonic_Water:
	tst.b	timeStopped			; Is time stopped?
	bne.s	.End				; If so, branch

	move.b	#8,splashObject+oID		; Spawn splash object
	btst	#1,specStageFlags.w		; Are we in time attack mode?
	beq.s	.End				; If not, branch
	move.w	#$500,oPlayerTopSpeed(a0)	; If so, slow Sonic down

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Rough:
	if REGION<>EUROPE			; Slow Sonic down
		move.w	#$500,oPlayerTopSpeed(a0)
	else
		move.w	#$600,oPlayerTopSpeed(a0)
	endif
	cmpi.w	#$100,oPlayerSpeed(a0)		; Is Sonic going fast enough?
	bcs.s	.End				; If not, branch

	bsr.w	FindDustObjSlot			; Spawn dust
	bne.s	.PlaySound
	move.b	#7,(a1)

.PlaySound:
	move.b	#FM_D6,d0			; Play dust sound
	bsr.w	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Spring:
	move.b	#2,oRoutine(a0)			; Set to jump mode
	if REGION<>EUROPE			; Jump upwards
		move.l	#-$100000,oPlayerSprYVel(a0)
	else
		move.l	#-$120000,oPlayerSprYVel(a0)
	endif
	bset	#7,oFlags(a0)			; Set jump mode

	move.b	#FM_SPRING,d0			; Play spring sound
	bsr.w	PlayFMSound

	bsr.w	DeleteSplash			; Delete splash object
	rts

; -------------------------------------------------------------------------

ObjSonic_Hazard:
	cmpi.b	#4,oRoutine(a0)			; Are we being bumped around?
	beq.w	.End				; If so, branch
	cmpi.b	#7,oRoutine(a0)			; Are we already hurt?
	beq.w	.End				; If so, branch

	move.b	#46,oPlayerTimer(a0)		; Set hurt timer
	move.b	#7,oRoutine(a0)			; Set to hurt mode
	moveq	#$D,d0				; Set animation
	bsr.w	SetObjAnim

	move.w	specStageRings.w,d0		; Halve ring count
	move.w	d0,d1
	lsr.w	#1,d0
	move.w	d0,specStageRings.w
	sub.w	d0,d1

	tst.w	d1				; Should we drop 0 rings?
	beq.s	.End				; If so, branch
	cmpi.w	#1,d1				; Should we drop 1 rings?
	beq.s	.Lose1Ring			; If so, branch
	cmpi.w	#2,d1				; Should we drop 2 rings?
	beq.s	.Lose2Rings			; If so, branch
	cmpi.w	#3,d1				; Should we drop 3 rings?
	beq.s	.Lose3Rings			; If so, branch
	cmpi.w	#4,d1				; Should we drop 4 rings?
	beq.s	.Lose4Rings			; If so, branch
	cmpi.w	#5,d1				; Should we drop 5 rings?
	beq.s	.Lose5Rings			; If so, branch
	cmpi.w	#6,d1				; Should we drop 6 rings?
	beq.s	.Lose6Rings			; If so, branch
	
.Lose7Rings:
	move.b	#$D,ringObject1+oID		; Drop ring #7

.Lose6Rings:
	move.b	#$D,ringObject2+oID		; Drop ring #6

.Lose5Rings:
	move.b	#$D,ringObject3+oID		; Drop ring #5

.Lose4Rings:
	move.b	#$D,ringObject4+oID		; Drop ring #4

.Lose3Rings:
	move.b	#$D,ringObject5+oID		; Drop ring #3

.Lose2Rings:
	move.b	#$D,ringObject6+oID		; Drop ring #2

.Lose1Ring:
	move.b	#$D,ringObject7+oID		; Drop ring #1

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_BigBooster:
	move.b	#FM_CE,d0			; Play boost sound
	bsr.w	PlayFMSound
	moveq	#$E,d0				; Set animation
	bsr.w	SetObjAnim

	moveq	#0,d0				; Boost towards direction
	move.b	oPlayerStampOri(a0),d0
	andi.w	#$E,d0
	move.w	.Orientations(pc,d0.w),d0
	jmp	.Orientations(pc,d0.w)

; -------------------------------------------------------------------------

.Orientations:
	dc.w	.Up-.Orientations
	dc.w	.Left-.Orientations
	dc.w	.Down-.Orientations
	dc.w	.Right-.Orientations
	dc.w	.Up-.Orientations
	dc.w	.Right-.Orientations
	dc.w	.Down-.Orientations
	dc.w	.Left-.Orientations

; -------------------------------------------------------------------------

.Up:
	moveq	#0,d0				; Boost up
	move.w	#-$18,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Left:
	move.w	#-$18,d0			; Boost left
	moveq	#0,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Down:
	moveq	#0,d0				; Boost down
	moveq	#$18,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Right:
	moveq	#$18,d0				; Boost right
	moveq	#0,d1

; -------------------------------------------------------------------------

.Boost:
	move.w	d0,oXVel(a0)			; Set speed
	move.w	d1,oYVel(a0)
	move.w	#$14,oPlayerBumpTime(a0)	; Set boost time
	move.b	#$13,oRoutine(a0)		; Set boost mode
	rts

; -------------------------------------------------------------------------

ObjSonic_SmallBooster:
	move.b	#FM_C3,d0			; Play boost sound
	bsr.w	PlayFMSound

	moveq	#0,d0				; Boost towards direction
	move.b	oPlayerStampOri(a0),d0
	andi.w	#$E,d0
	move.w	.Orientations(pc,d0.w),d0
	jmp	.Orientations(pc,d0.w)

; -------------------------------------------------------------------------

.Orientations:
	dc.w	.Up-.Orientations
	dc.w	.Left-.Orientations
	dc.w	.Down-.Orientations
	dc.w	.Right-.Orientations
	dc.w	.Up-.Orientations
	dc.w	.Right-.Orientations
	dc.w	.Down-.Orientations
	dc.w	.Left-.Orientations

; -------------------------------------------------------------------------

.Up:
	moveq	#0,d0				; Boost up
	move.w	#-$10,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Left:
	move.w	#-$10,d0			; Boost left
	moveq	#0,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Down:
	moveq	#0,d0				; Boost down
	moveq	#$10,d1
	bra.s	.Boost

; -------------------------------------------------------------------------

.Right:
	moveq	#$10,d0				; Boost right
	moveq	#0,d1

; -------------------------------------------------------------------------

.Boost:
	move.w	d0,oXVel(a0)			; Set speed
	move.w	d1,oYVel(a0)
	move.w	#8,oPlayerBumpTime(a0)		; Set boost time
	move.b	#4,oRoutine(a0)			; Set boost mode
	rts

; -------------------------------------------------------------------------

ObjSonic_CheckBumper:
	moveq	#0,d1				; Get bump speed
	move.w	oPlayerSpeed(a0),d1
	lsl.l	#8,d1
	addi.l	#$20000,d1
	move.l	d1,d2				; Get bump speed in opposite direction
	neg.l	d2
	moveq	#0,d3				; No speed

	moveq	#0,d0				; Reset flags
	cmpi.b	#1,oPlayerStampTL(a0)		; Is the top left stamp being touched a bumper?
	bne.s	.CheckTopRight			; If not, branch
	bset	#0,d0				; Set top left flag

.CheckTopRight:
	cmpi.b	#1,oPlayerStampTR(a0)		; Is the top right stamp being touched a bumper?
	bne.s	.CheckBottomRight		; If not, branch
	bset	#1,d0				; Set top right flag

.CheckBottomRight:
	cmpi.b	#1,oPlayerStampBR(a0)		; Is the bottom right stamp being touched a bumper?
	bne.s	.CheckBottomLeft		; If not, branch
	bset	#2,d0				; Set bottom right flag

.CheckBottomLeft:
	cmpi.b	#1,oPlayerStampBL(a0)		; Is the bottom left stamp being touched a bumper?
	bne.s	.Handle				; If not, branch
	bset	#3,d0				; Set bottom left flag

.Handle:
	add.w	d0,d0				; Run routine
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	.End-.Index
	dc.w	.DownRight-.Index
	dc.w	.DownLeft-.Index
	dc.w	.Down-.Index
	dc.w	.UpLeft-.Index
	dc.w	.UpRight-.Index
	dc.w	.Left-.Index
	dc.w	.DownLeft-.Index
	dc.w	.UpRight-.Index
	dc.w	.Right-.Index
	dc.w	.UpLeft-.Index
	dc.w	.DownRight-.Index
	dc.w	.Up-.Index
	dc.w	.UpRight-.Index
	dc.w	.UpLeft-.Index
	dc.w	.UpLeft-.Index

; -------------------------------------------------------------------------

.DownRight:
	move.l	d1,oXVel(a0)			; Bump down right
	move.l	d1,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.DownLeft:
	move.l	d2,oXVel(a0)			; Bump down left
	move.l	d1,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.Down:
	move.l	d3,oXVel(a0)			; Bump down
	move.l	d1,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.UpLeft:
	move.l	d2,oXVel(a0)			; Bump up left
	move.l	d2,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.UpRight:
	move.l	d1,oXVel(a0)			; Bump up right
	move.l	d2,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.Left:
	move.l	d2,oXVel(a0)			; Bump left
	move.l	d3,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.Right:
	move.l	d1,oXVel(a0)			; Bump right
	move.l	d3,oYVel(a0)
	bra.s	.Bump

; -------------------------------------------------------------------------

.Up:
	move.l	d3,oXVel(a0)			; Bump up
	move.l	d2,oYVel(a0)

; -------------------------------------------------------------------------

.Bump:
	move.w	#$10,oPlayerBumpTime(a0)	; Set bump time
	move.b	#4,oRoutine(a0)			; Set bump mode
	bset	#5,oFlags(a0)			; Set bump flag

	move.b	#FM_B5,d0			; Play bumper sound
	bsr.w	PlayFMSound
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim

.End:
	rts

; -------------------------------------------------------------------------
; Find dust object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Not found/found
;	a1.l  - Found slot
; -------------------------------------------------------------------------

FindDustObjSlot:
	lea	dustObjects,a1			; Dust object slots
	moveq	#DUSTOBJCOUNT-1,d7		; Number of slots

.Find:
	tst.w	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, branch
	adda.w	#oSize,a1			; Next slot
	dbf	d7,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Check for jumping
; -------------------------------------------------------------------------

ObjSonic_CheckJump:
	tst.b	stageInactive			; Is the stage inactive?
	bne.s	.End				; If so, branch
	move.b	playerCtrlTap,d0		; Was A, B, or C pressed?
	andi.b	#$70,d0
	beq.s	.End				; If not, branch

	move.b	#2,oRoutine(a0)			; Set to jump mode
	if REGION<>EUROPE			; Jump upwards
		move.l	#-$80000,oPlayerSprYVel(a0)
	else
		move.l	#-$90000,oPlayerSprYVel(a0)
	endif

	move.w	#20,jumpTimer			; Set jump timer
	bset	#7,oFlags(a0)			; Set jump flag
	move.w	#0,oPlayerBumpTime(a0)		; Stop bumping
	
	move.b	#FM_JUMP,d0			; Play jump sound
	bsr.w	PlayFMSound
	bsr.w	DeleteSplash			; Delete splash object

.End:
	rts

; -------------------------------------------------------------------------
; Handle rotation
; -------------------------------------------------------------------------

ObjSonic_Rotate:
	tst.b	stageInactive			; Is the stage inactive?
	bne.s	.End				; If so, branch

	if REGION<>EUROPE			; Rotation speed
		move.l	#$60000,d0
	else
		move.l	#$73333,d0
	endif

	btst	#3,playerCtrlHold		; Is right being held?
	beq.s	.CheckLeft			; If not, branch
	sub.l	d0,oPlayerYaw(a0)		; Rotate right
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#3,subScrollFlags

.CheckLeft:
	btst	#2,playerCtrlHold		; Is left being held?
	beq.s	.End				; If not, branch
	add.l	d0,oPlayerYaw(a0)		; Rotate left
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#2,subScrollFlags

.End:
	rts

; -------------------------------------------------------------------------
; Handle rotation (slow)
; -------------------------------------------------------------------------

ObjSonic_RotateSlow:
	if REGION<>EUROPE			; Rotation speed
		move.l	#$40000,d0
	else
		move.l	#$4CCCC,d0
	endif

	btst	#3,playerCtrlHold		; Is right being held?
	beq.s	.CheckLeft			; If not, branch
	sub.l	d0,oPlayerYaw(a0)		; Rotate right
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#3,subScrollFlags

.CheckLeft:
	btst	#2,playerCtrlHold		; Is left being held?
	beq.s	.End				; If not, branch
	add.l	d0,oPlayerYaw(a0)		; Rotate left
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#2,subScrollFlags

.End:
	rts

; -------------------------------------------------------------------------
; Handle speed
; -------------------------------------------------------------------------

ObjSonic_HandleSpeed:
	tst.b	stageInactive			; Is the stage inactive?
	bne.s	.End				; If so, branch

	move.b	playerCtrlHold,d1		; Is only down being held?
	andi.b	#$F,d1
	cmpi.b	#2,d1
	beq.s	.Decelerate			; If so, branch

	tst.w	oPlayerShoes(a0)		; Is the speed shoes timer active?
	beq.s	.NoSpeedShoes			; If not, branch
	subq.w	#1,oPlayerShoes(a0)		; Decrement speed shoes timer
	if REGION<>EUROPE			; Set speed shoes top speed
		move.w	#$E00,d7
	else
		move.w	#$10CC,d7
	endif
	bra.s	.Accelerate

.NoSpeedShoes:
	cmpi.b	#7,oRoutine(a0)			; Are we hurt?
	bne.s	.NotHurt			; If not, branch
	if REGION<>EUROPE			; If so, set hurt top speed
		move.w	#$200,d7
	else
		move.w	#$266,d7
	endif
	bra.s	.Accelerate

.NotHurt:
	move.w	oPlayerTopSpeed(a0),d7		; Get top speed

.Accelerate:
	if REGION<>EUROPE			; Accelerate
		addi.w	#$20,oPlayerSpeed(a0)
	else
		addi.w	#$26,oPlayerSpeed(a0)
	endif
	cmp.w	oPlayerSpeed(a0),d7		; Are we at the top speed?
	bcc.s	.End				; If not, branch
	move.w	d7,oPlayerSpeed(a0)		; If so, cap at top speed
	rts

.Decelerate:
	if REGION<>EUROPE			; Decelerate
		subi.w	#$40,oPlayerSpeed(a0)
	else
		subi.w	#$4C,oPlayerSpeed(a0)
	endif
	cmpi.w	#$200,oPlayerSpeed(a0)
	bge.s	.End
	move.w	#$200,oPlayerSpeed(a0)

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic
; -------------------------------------------------------------------------

ObjSonic_Move:
	move.w	oPlayerYaw(a0),d0		; Get cosine of yaw angle
	addi.w	#$180,d0
	andi.w	#$1FF,d0
	move.w	d0,d3
	bsr.w	GetCosine
	if REGION<>EUROPE			; Multiply by speed
		muls.w	oPlayerSpeed(a0),d3
	else
		move.w	oPlayerSpeed(a0),d5
		muls.w	#60,d5
		divs.w	#50,d5
		muls.w	d5,d3
	endif
	add.l	d3,oX(a0)			; Add to X position
	andi.l	#$FFFFFFF,oX(a0)

	move.w	d0,d3				; Get sine of yaw angle
	bsr.w	GetSine
	if REGION<>EUROPE			; Multiply by speed
		muls.w	oPlayerSpeed(a0),d3
	else
		muls.w	d5,d3
	endif
	add.l	d3,oY(a0)			; Add to Y position
	andi.l	#$FFFFFFF,oY(a0)
	rts

; -------------------------------------------------------------------------
; Bump up (unused)
; -------------------------------------------------------------------------

ObjSonic_BumpUp:
	move.w	oPlayerYaw(a0),d0		; Bump up
	addi.w	#$80,d0
	andi.w	#$1FF,d0
	bra.s	ObjSonic_BumpMove

; -------------------------------------------------------------------------
; Bump right (unused)
; -------------------------------------------------------------------------

ObjSonic_BumpRight:
	move.w	oPlayerYaw(a0),d0		; Bump right
	addi.w	#0,d0
	andi.w	#$1FF,d0
	bra.s	ObjSonic_BumpMove

; -------------------------------------------------------------------------
; Bump left (unused)
; -------------------------------------------------------------------------

ObjSonic_BumpLeft:
	move.w	oPlayerYaw(a0),d0		; Bump left
	addi.w	#$100,d0
	andi.w	#$1FF,d0

; -------------------------------------------------------------------------
; Handle bump movement (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Bump angle
; -------------------------------------------------------------------------

ObjSonic_BumpMove:
	move.w	d0,d3				; Get cosine of angle
	bsr.w	GetCosine
	if REGION<>EUROPE			; Multiply by speed
		muls.w	oPlayerBumpSpd(a0),d3
	else
		move.w	oPlayerBumpSpd(a0),d5
		muls.w	#60,d5
		divs.w	#50,d5
		muls.w	d5,d3
	endif
	add.l	d3,oX(a0)			; Add to X position
	andi.l	#$FFFFFFF,oX(a0)

	move.w	d0,d3				; Get sine of angle
	bsr.w	GetSine
	if REGION<>EUROPE			; Multiply by speed
		muls.w	oPlayerBumpSpd(a0),d3
	else
		muls.w	d5,d3
	endif
	add.l	d3,oY(a0)			; Add to Y position
	andi.l	#$FFFFFFF,oY(a0)
	rts

; -------------------------------------------------------------------------
; Handle tilting
; -------------------------------------------------------------------------

ObjSonic_Tilt:
	btst	#2,playerCtrlHold		; Is left being held?
	beq.s	.CheckRight			; If not, branch
	subq.b	#1,oPlayerTilt(a0)		; Tilt left
	bpl.s	.EndLeft			; If we haven't tilted all the way, branch
	move.b	#0,oPlayerTilt(a0)		; Cap tilting

.EndLeft:
	rts


.CheckRight:
	btst	#3,playerCtrlHold		; Is right being held?
	beq.s	.Untilt				; If not, branch
	addq.b	#1,oPlayerTilt(a0)		; Tilt right
	cmpi.b	#$A,oPlayerTilt(a0)		; Have we tilted all the way?
	bcs.s	.EndRight			; If not, branch
	move.b	#9,oPlayerTilt(a0)		; Cap tilting

.EndRight:
	rts

.Untilt:
	; BUG: This function is bugged. It intends to gradually untilt Sonic's sprite,
	; but with the way the branches are set up, it makes it instant instead
	cmpi.b	#5,oPlayerTilt(a0)		; Are we tilting left?
	bcs.s	.UntiltLeft			; If so, branch

.UntiltRight:
	subq.b	#1,oPlayerTilt(a0)		; Untilt from the right
	cmpi.b	#5,oPlayerTilt(a0)		; Are we in the center?
	bcc.s	.UntiltLeft			; If not, branch
	move.b	#5,oPlayerTilt(a0)		; Cap at center
	rts

.UntiltLeft:
	addq.b	#1,oPlayerTilt(a0)		; Untilt from the left
	cmpi.b	#5,oPlayerTilt(a0)		; Are we in the center?
	bls.s	.UntiltLeft			; If not, branch
	move.b	#5,oPlayerTilt(a0)		; Cap at center
	rts

; -------------------------------------------------------------------------
; Animate Sonic's sprite
; -------------------------------------------------------------------------

ObjSonic_Animate:
	tst.b	stageInactive			; Is the stage inactive?
	bne.w	.End				; If so, branch
	
	moveq	#6,d0				; Jumping animation
	btst	#7,oFlags(a0)			; Are we jumping?
	bne.s	.OtherAnim			; If so, branch

	moveq	#$B,d0				; Floating animation
	btst	#6,oFlags(a0)			; Are we floating?
	bne.s	.OtherAnim			; If so, branch

	moveq	#$A,d0				; Standing animation
	move.w	oPlayerSpeed(a0),d1		; Are we moving?
	beq.s	.OtherAnim			; If not, branch

	move.b	oPlayerTilt(a0),d2		; Get tilt offset
	add.w	d2,d2
	andi.w	#$1C,d2

	move.b	.WalkAnims+3(pc,d2.w),d0	; Get slowest animation
	cmpi.w	#$300,d1			; Is our speed slow enough?
	bcs.s	.GroundMoveAnim			; If so, branch

	move.b	.WalkAnims+2(pc,d2.w),d0	; Get faster animation
	cmpi.w	#$540,d1			; Is our speed slow enough?
	bcs.s	.GroundMoveAnim			; If so, branch

	move.b	.WalkAnims+1(pc,d2.w),d0	; Get even faster animation
	cmpi.w	#$780,d1			; Is our speed slow enough?
	bcs.s	.GroundMoveAnim			; If so, branch

	move.b	.WalkAnims(pc,d2.w),d0		; Get fastest animation
	cmpi.w	#$B00,d1			; Is our speed slow enough?
	bcs.s	.GroundMoveAnim			; If so, branch

	move.b	#1,d0				; Set to sprinting animation
	bra.s	.CheckAnimReset

.OtherAnim:
	bclr	#4,oFlags(a0)			; Clear ground animation set flag

.CheckAnimReset:
	cmp.b	oAnim(a0),d0			; Is the animation different?
	beq.s	.End				; If not, branch
	bsr.w	SetObjAnim			; Set animation and reset animation
	rts
	
.GroundMoveAnim:
	bset	#4,oFlags(a0)			; Is a ground animation already set?
	beq.s	.CheckAnimReset			; If not, branch
	cmp.b	oAnim(a0),d0			; Is the animation different?
	beq.s	.End				; If not, branch
	bsr.w	ChgObjAnim			; Change animation

.End:
	rts

; -------------------------------------------------------------------------

.WalkAnims:
	dc.b	$04, $19, $1A, $1B		; Furthest left
	dc.b	$03, $16, $17, $18		; Slightly left
	dc.b	$00, $10, $11, $12		; Center
	dc.b	$02, $13, $14, $15		; Slightly right
	dc.b	$05, $1C, $1D, $1E		; Furthest right

; -------------------------------------------------------------------------
; Load Sonic art
; -------------------------------------------------------------------------

ObjSonic_LoadArt:
	moveq	#0,d0				; Use sprite flag as art index
	move.b	oSpriteFlag(a0),d0
	lea	SonicArt,a1			; Get pointer to art
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a1,d0.w),a1

	lea	subSonicArtBuf,a2		; Load art
	move.w	#$300/32-1,d7

.Copy:
	rept	32/4
		move.l	(a1)+,(a2)+
	endr
	dbf	d7,.Copy
	rts

; -------------------------------------------------------------------------
