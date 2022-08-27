; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Menu object (title screen)
; -------------------------------------------------------------------------

	rsset	oVars
oMenuDelay	rs.b	1			; Delay counter
		rs.b	3
oMenuOption	rs.b	1			; Option ID
oMenuAllowSel	rs.b	1			; Allow selection flag
		rs.b	$16
oMenuCloudsIdx	rs.b	1			; Clouds cheat index
		rs.b	3
oMenuSndTestIdx	rs.b	1			; Sound test cheat index
		rs.b	3
oMenuStgSelIdx	rs.b	1			; Stage select cheat index
		rs.b	3
oMenuBestTmsIdx	rs.b	1			; Best times cheat index

; -------------------------------------------------------------------------

ObjMenu:
	move.l	#MapSpr_Menu,oMap(a0)		; Set mappings
	move.w	#$A000|($D800/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#83,oX(a0)			; Set X position
	move.w	#180,oY(a0)			; Set Y position
	if REGION=USA				; Activate timer
		move.w	#$3FC,timer.w
	else
		move.w	#$1E0,timer.w
	endif

; -------------------------------------------------------------------------

ObjMenu_PressStart:
	addi.b	#$10,oMenuDelay(a0)		; Increment delay counter
	bcc.s	.NoFlash			; If it hasn't overflowed, branch
	eori.b	#1,oMapFrame(a0)		; Flash text

.NoFlash:
	btst	#7,p1CtrlTap.w			; Has the start button been pressed?
	bne.s	.PrepareMenu			; If so, branch

	bsr.w	ObjMenu_CloudsCheat		; Check clouds cheat
	bsr.w	ObjMenu_ChkCloudCtrl		; Check cloud control

	bsr.w	ObjMenu_SoundTestCheat		; Check sound test cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch

	bsr.w	ObjMenu_StageSelCheat		; Check stage select cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch
	
	bsr.w	ObjMenu_BestTimesCheat		; Check best times cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch

	tst.w	timer.w				; Has the timer run out?
	beq.w	ObjMenu_TimeOut			; If so, branch

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenu_PressStart		; Update

; -------------------------------------------------------------------------

.PrepareMenu:
	clr.w	p1CtrlData.w			; Clear controller data
	move.b	#1,oMapFrame(a0)		; Make invisible
	move.w	#$1E0,timer.w			; Reset timer

	lea	menuOptions.w,a2		; Options buffer
	move.b	titleFlags,d1			; Title screen flags

	move.w	#$FF02,(a2)+			; Add stop flag and new game option
	moveq	#1,d0				; Highlight new game option
	btst	#6,d1				; Is there a save file?
	beq.s	.SetSelection			; If not, branch
	moveq	#2,d0				; Highlight continue option
	move.b	#3,(a2)+			; Add continue option

.SetSelection:
	move.b	d0,menuSel.w			; Set menu selection

	btst	#5,d1				; Is time attack enabled?
	beq.s	.NoTimeAttack			; If not, branch
	move.b	#4,(a2)+			; Add time attack option

.NoTimeAttack:
	btst	#4,d1				; Is save management enabled?
	beq.s	.NoRamData			; If not, branch
	move.b	#5,(a2)+			; Add save management option

.NoRamData:
	btst	#3,d1				; Is DA Garden enabled?
	beq.s	.NoDAGarden			; If not, branch
	move.b	#6,(a2)+			; Add DA Garden option

.NoDAGarden:
	btst	#2,d1				; Is Visual Mode enabled?
	beq.s	.NoVisualMode			; If not, branch
	move.b	#7,(a2)+			; Add Visual Mode option

.NoVisualMode:
	move.b	#$FF,(a2)			; Add stop flag

	lea	ObjMenuArrow(pc),a2		; Spawn left menu arrow
	bsr.w	SpawnObject
	move.w	a0,oArrowParent(a1)
	lea	ObjMenuArrow(pc),a2		; Spawn right menu arrow
	bsr.w	SpawnObject
	move.w	a0,oArrowParent(a1)
	move.b	#1,oArrowID(a1)

; -------------------------------------------------------------------------

ObjMenu_MoveRight:
	move.w	#$C000|($D800/$20),oTile(a0)	; Unhighlight text
	clr.b	oMenuAllowSel(a0)		; Disable selection
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$80,oMenuDelay(a0)		; Incremenet delay counter
	bcc.s	ObjMenu_MoveRight		; If it hasn't overflowed, branch

.MoveOut:
	move.w	oX(a0),d0			; Move in
	addi.w	#$20,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	cmpi.w	#$100,oX(a0)			; Is the text fully off screen?
	bcs.s	.MoveOut			; If not, branch
	bsr.w	BookmarkObject			; Set bookmark
	
	lea	menuOptions.w,a2		; Set option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,oMenuOption(a0)
	bsr.w	ObjMenu_SetOption

	move.w	#-$2D,oX(a0)			; Move to left side of screen
	bsr.w	BookmarkObject			; Set bookmark

.MoveIn:
	move.w	oX(a0),d0			; Move in
	addi.w	#$10,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	tst.w	oX(a0)				; Is the text still off screen?
	bmi.s	.MoveIn				; If so, branch
	cmpi.w	#$53,oX(a0)			; Is the text fully on screen?
	bcs.s	.MoveIn				; If not, branch
	move.w	#$53,oX(a0)			; Stop moving
	
	move.w	#$A000|($D800/$20),oTile(a0)	; Highlight text
	bra.w	ObjMenu_WaitSelection		; Wait for selection

; -------------------------------------------------------------------------

ObjMenu_MoveLeft:
	move.w	#$C000|($D800/$20),oTile(a0)	; Unhighlight text
	clr.b	oMenuAllowSel(a0)		; Disable selection
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$80,oMenuDelay(a0)		; Incremenet delay counter
	bcc.s	ObjMenu_MoveLeft		; If it hasn't overflowed, branch

.MoveOut:
	move.w	oX(a0),d0			; Move in
	subi.w	#$20,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	tst.w	oX(a0)				; Is the text still on screen?
	bpl.s	.MoveOut			; If so, branch
	cmpi.w	#-$35,oX(a0)			; Is the text fully off screen?
	bcc.s	.MoveOut			; If not, branch
	bsr.w	BookmarkObject			; Set bookmark
	
	lea	menuOptions.w,a2		; Set option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,oMenuOption(a0)
	bsr.w	ObjMenu_SetOption

	move.w	#$D3,oX(a0)			; Move to right side of screen
	
.MoveIn:
	bsr.w	BookmarkObject			; Set bookmark
	move.w	oX(a0),d0			; Move in
	subi.w	#$10,d0
	move.w	d0,oX(a0)
	cmpi.w	#$53,oX(a0)			; Is the text fully on screen?
	bcc.s	.MoveIn				; If not, branch
	move.w	#$53,oX(a0)			; Stop moving
	
	move.w	#$A000|($D800/$20),oTile(a0)	; Highlight text
	bra.w	ObjMenu_WaitSelection		; Wait for selection

; -------------------------------------------------------------------------

ObjMenu_WaitSelection:
	move.b	#3,oMenuAllowSel(a0)		; Allow selection
	bsr.w	BookmarkObject			; Set bookmark

.CheckButtons:
	lea	menuOptions.w,a2		; Options buffer
	btst	#2,p1CtrlHold.w			; Has left been pressed?
	bne.s	ObjMenu_SelectLeft		; If so, branch
	btst	#3,p1CtrlHold.w			; Has right been pressed?
	bne.w	ObjMenu_SelectRight		; If so, branch

	move.b	p1CtrlTap.w,d0			; Has any of the face buttons been pressed?
	andi.b	#%11110000,d0
	bne.w	ObjMenu_SelectOption		; If so, branch

	tst.w	timer.w				; Has the timer run out?
	beq.w	ObjMenu_TimeOut			; If so, branch

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.CheckButtons			; Check buttons

; -------------------------------------------------------------------------

ObjMenu_SelectLeft:
	move.w	#$1E0,timer.w			; Reset timer
	
	moveq	#0,d0				; Move selection left
	move.b	menuSel.w,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1				; Should we stop?
	beq.s	.End				; If so, branch
	
	move.b	d0,menuSel.w			; Set selection
	bra.w	ObjMenu_MoveRight		; Move text right

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SelectRight:
	move.w	#$1E0,timer.w			; Reset timer
	
	moveq	#0,d0				; Move selection right
	move.b	menuSel.w,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1				; Should we stop?
	beq.s	.End				; If so, branch
	
	move.b	d0,menuSel.w			; Set selection
	bra.w	ObjMenu_MoveLeft		; Move text left

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SelectOption:
	lea	menuOptions.w,a2		; Get option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	subq.b	#1,d0				; Make it zero based
	bcc.s	.SetExitFlag			; If it hasn't underflowed, branch
	move.b	#1,d0				; If it has, use new game option

.SetExitFlag:
	move.b	d0,exitFlag.w			; Set exit flag

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_TimeOut:
	move.b	#$FF,exitFlag.w			; Go to attract mode

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_CheatActivated:
	move.b	d0,exitFlag.w			; Set exit flag

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_CloudsCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuCloudsIdx(a0),d0
	lea	(a2,d0.w),a2

	btst	#6,p1CtrlHold.w			; Is A being held?
	beq.s	.Failed				; If not, branch

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuCloudsIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuCloudsIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuCloudsIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#-1,d0				; Activated
	move.b	d0,cloudsCtrlFlag.w		; Enable cloud control
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 2, 2, 1
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_ChkCloudCtrl:
	tst.b	cloudsCtrlFlag.w		; Is cloud control enabled?
	beq.s	.End				; If not, branch
	move.b	p2CtrlHold.w,d0			; Get player 2 buttons
	beq.s	.End				; If nothing is being pressed, branch
	move.w	#$1E0,timer.w			; Reset timer

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SoundTestCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuSndTestIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuSndTestIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuSndTestIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuSndTestIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#7,d0				; Exit to sound test
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	2, 2, 2, 4, 8, $40
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_StageSelCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuStgSelIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuStgSelIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuStgSelIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuStgSelIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#8,d0				; Exit to stage select
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 4, 8, $10
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_BestTimesCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuBestTmsIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuBestTmsIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuBestTmsIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuBestTmsIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#9,d0				; Exit to best times screen
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	8, 8, 1, 1, 2, $20
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_PlayRingSound:
	move.b	#FM_RING,fmSndQueue.w		; Play ring sound
	rts

; -------------------------------------------------------------------------

ObjMenu_SetOption:
	moveq	#0,d0				; Get option
	move.b	oMenuOption(a0),d0
	move.b	d0,oMapFrame(a0)

	move.l	a0,-(sp)			; Load text art
	add.w	d0,d0
	move.w	.Text(pc,d0.w),d0
	lea	.Text(pc,d0.w),a0
	VDPCMD	move.l,$D800,VRAM,WRITE,VDPCTRL
	bsr.w	NemDec
	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------

.Text:
	dc.w	Art_PressStartText-.Text
	dc.w	Art_PressStartText-.Text
	dc.w	Art_NewGameText-.Text
	dc.w	Art_ContinueText-.Text
	dc.w	Art_TimeAttackText-.Text
	dc.w	Art_RamDataText-.Text
	dc.w	Art_DAGardenText-.Text
	dc.w	Art_VisualModeText-.Text

; -------------------------------------------------------------------------
; Menu mappings
; -------------------------------------------------------------------------

MapSpr_Menu:
	include	"Title Screen/Objects/Menu/Data/Mappings (Menu).asm"
	even

; -------------------------------------------------------------------------
; Menu arrow option
; -------------------------------------------------------------------------

	rsset	oVars
oArrowDelay	rs.b	1			; Animation delay counter
oArrowFrame	rs.b	1			; Animation frame
		rs.b	2
oArrowID	rs.b	1			; Text ID
		rs.b	3
oArrowParent	rs.w	1			; Parent object

; -------------------------------------------------------------------------

ObjMenuArrow:
	move.l	#MapSpr_MenuArrow,oMap(a0)	; Set mappings
	move.w	#$A000|($DC00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#181,oY(a0)			; Set Y position
	move.w	#72,oX(a0)			; Set left arrow X position
	tst.b	oArrowID(a0)			; Is this the right arrow?
	beq.s	ObjMenuArrow_Left		; If not, branch
	move.w	#168,oX(a0)			; Set right arrow X position

; -------------------------------------------------------------------------

ObjMenuArrow_Right:
	movea.w	oArrowParent(a0),a1		; Get parent object
	tst.b	oMenuAllowSel(a1)		; Is selection enabled?
	bne.s	.CheckOption			; If so, branch

.Invisible:
	clr.b	oMapFrame(a0)			; Don't display
	clr.w	oArrowDelay(a0)

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Right		; Check display

.CheckOption:
	lea	menuOptions.w,a2		; Get option on the right
	moveq	#0,d0
	move.b	menuSel.w,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0				; Is there no options on the right?
	beq.s	.Invisible			; If so, branch

	moveq	#0,d0				; Display animation frame
	move.b	oArrowFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addi.b	#$10,oArrowDelay(a0)		; Increment animation delay counter
	bcc.s	.Displayed			; If it hasn't overflowed, branch
	addq.b	#1,oArrowFrame(a0)		; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,oArrowFrame(a0)
	bcs.s	.Displayed			; Branch if it doesn't need to wrap
	clr.b	oArrowFrame(a0)			; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Right		; Check display

; -------------------------------------------------------------------------

.Frames:
	dc.b	4, 5, 6
.FramesEnd:
	even

; -------------------------------------------------------------------------

ObjMenuArrow_Left:
	movea.w	oArrowParent(a0),a1		; Get parent object
	tst.b	oMenuAllowSel(a1)		; Is selection enabled?
	bne.s	.CheckOption			; If so, branch

.Invisible:
	clr.b	oMapFrame(a0)			; Don't display
	clr.w	oArrowDelay(a0)

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Left		; Check display

.CheckOption:
	lea	menuOptions.w,a2		; Get option on the left
	moveq	#0,d0
	move.b	menuSel.w,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0				; Is there no options on the right?
	beq.s	.Invisible			; If so, branch

	moveq	#0,d0				; Display animation frame
	move.b	oArrowFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addi.b	#$10,oArrowDelay(a0)		; Increment animation delay counter
	bcc.s	.Displayed			; If it hasn't overflowed, branch
	addq.b	#1,oArrowFrame(a0)		; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,oArrowFrame(a0)
	bcs.s	.Displayed			; Branch if it doesn't need to wrap
	clr.b	oArrowFrame(a0)			; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Left		; Check display

; -------------------------------------------------------------------------

.Frames:
	dc.b	1, 2, 3
.FramesEnd:
	even

; -------------------------------------------------------------------------
; Menu arrow mappings
; -------------------------------------------------------------------------

MapSpr_MenuArrow:
	include	"Title Screen/Objects/Menu/Data/Mappings (Arrow).asm"
	even

; -------------------------------------------------------------------------
