; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main CPU global variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Time zones
	rsreset
TIME_PAST		rs.b	1		; Past
TIME_PRESENT		rs.b	1		; Present
TIME_FUTURE		rs.b	1		; Future

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$F00
MAINVARS		rs.b	0		; Main CPU global variables
ipxVSync		rs.b	1		; IPX VSync flag
timeAttackMode		rs.b	1		; Time attack mode flag
savedLevel		rs.w	1		; Saved level
			rs.b	$C
timeAttackTime		rs.l	1		; Time attack time
timeAttackLevel		rs.w	1		; Time attack level
ipxVDPReg1		rs.w	1		; IPX VDP register 1
timeAttackUnlock	rs.b	1		; Last unlocked time attack zone
unkBuRAMVar		rs.b	1		; Unknown Backup RAM variable
goodFutures		rs.b	1		; Good futures achieved flags
			rs.b	1
demoID			rs.b	1		; Demo ID
titleFlags		rs.b	1		; Title screen flags
			rs.b	1
saveDisabled		rs.b	1		; Save disabled flag
timeStones		rs.b	1		; Time stones retrieved flags
curSpecStage		rs.b	1		; Current special stage
palClearFlags		rs.b	1		; Palette clear flags
			rs.b	1
endingID		rs.b	1		; Ending ID
specStageLost		rs.b	1		; Special stage lost flag
			rs.b	$5E0
level			rs.b	0		; Level ID
levelZone		rs.b	1		; Zone ID
levelAct		rs.b	1		; Act ID
lifeCount		rs.b	1		; Life count
			rs.b	9
levelRings		rs.w	1		; Level ring count
levelTime		rs.l	1		; Level time
levelScore		rs.l	1		; Level score
plcLoadFlags		rs.b	1		; PLC load flags
			rs.b	$11
timeZone		rs.b	1		; Time zone
			rs.b	$3B
goodFuture		rs.b	1		; Good future flag
			rs.b	2
projDestroyed		rs.b	1		; Projector destroyed flag
enteredBigRing		rs.b	1		; Entered big ring flag
			rs.b	8
amyCaptured		rs.b	1		; Amy captured flag
			rs.b	8
demoMode		rs.w	1		; Demo mode flag
			rs.b	$C
lastCheckpoint		rs.b	1		; Last checkpoint ID
			rs.b	$A71
MAINVARSSZ		EQU	__rs-MAINVARS	; Size of Main CPU global variables area

WORKRAMFILE		rs.b	$6000		; Work RAM file data

	rsset	WORKRAM+$FF008000
			rs.b	$700A
fmSndQueue1		rs.b	1		; Sound queue 1
fmSndQueue2		rs.b	1		; Sound queue 2
fmSndQueue3		rs.b	1		; Sound queue 3
			rs.b	$AF3

WORKRAMFILESZ		EQU	(__rs&$FFFFFF)-WORKRAMFILE

; -------------------------------------------------------------------------
