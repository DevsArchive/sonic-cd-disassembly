; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By RalakiMUS 2021
; -------------------------------------------------------------------------
; System definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Sub CPU commands
; -------------------------------------------------------------------------

	rsset	1
SCMD_R11A	rs.b	1			; Load Palmtree Panic Act 1 present
SCMD_R11B	rs.b	1			; Load Palmtree Panic Act 1 past
SCMD_R11C	rs.b	1			; Load Palmtree Panic Act 1 good future
SCMD_R11D	rs.b	1			; Load Palmtree Panic Act 1 bad future
SCMD_MDINIT	rs.b	1			; Load Mega Drive initialization
SCMD_STAGESEL	rs.b	1			; Load stage select
SCMD_R12A	rs.b	1			; Load Palmtree Panic Act 2 present
SCMD_R12B	rs.b	1			; Load Palmtree Panic Act 2 past
SCMD_R12C	rs.b	1			; Load Palmtree Panic Act 2 good future
SCMD_R12D	rs.b	1			; Load Palmtree Panic Act 2 bad future
SCMD_TITLE	rs.b	1			; Load title screen
SCMD_WARP	rs.b	1			; Load warp sequence
SCMD_TIMEATK	rs.b	1			; Load time attack menu
SCMD_FADECDA	rs.b	1			; Fade out CDDA MUSic
SCMD_R1AMUS	rs.b	1			; Play Palmtree Panic present MUSic
SCMD_R1CMUS	rs.b	1			; Play Palmtree Panic good future MUSic
SCMD_R1DMUS	rs.b	1			; Play Palmtree Panic bad future MUSic
SCMD_R3AMUS	rs.b	1			; Play Collision Chaos present MUSic
SCMD_R3CMUS	rs.b	1			; Play Collision Chaos good future MUSic
SCMD_R3DMUS	rs.b	1			; Play Collision Chaos bad future MUSic
SCMD_R4AMUS	rs.b	1			; Play Tidal Tempest present MUSic
SCMD_R4CMUS	rs.b	1			; Play Tidal Tempest good future MUSic
SCMD_R4DMUS	rs.b	1			; Play Tidal Tempest bad future MUSic
SCMD_R5AMUS	rs.b	1			; Play Quartz Quadrant present MUSic
SCMD_R5CMUS	rs.b	1			; Play Quartz Quadrant good future MUSic
SCMD_R5DMUS	rs.b	1			; Play Quartz Quadrant bad future MUSic
SCMD_R6AMUS	rs.b	1			; Play Wacky Workbench present MUSic
SCMD_R6CMUS	rs.b	1			; Play Wacky Workbench good future MUSic
SCMD_R6DMUS	rs.b	1			; Play Wacky Workbench bad future MUSic
SCMD_R7AMUS	rs.b	1			; Play Stardust Speedway present MUSic
SCMD_R7CMUS	rs.b	1			; Play Stardust Speedway good future MUSic
SCMD_R7DMUS	rs.b	1			; Play Stardust Speedway bad future MUSic
SCMD_R8AMUS	rs.b	1			; Play Metallic Madness present MUSic
SCMD_R8CMUS	rs.b	1			; Play Metallic Madness good future MUSic
SCMD_IPX	rs.b	1			; Load main program
SCMD_R43CDEMO	rs.b	1			; Load Tidal Tempest Act 3 good future demo
SCMD_R82ADEMO	rs.b	1			; Load Metallic Madness Act 2 present demo
SCMD_SNDTEST	rs.b	1			; Load sound test
		rs.b	1			; Invalid
SCMD_R31A	rs.b	1			; Load Collision Chaos Act 1 present
SCMD_R31B	rs.b	1			; Load Collision Chaos Act 1 past
SCMD_R31C	rs.b	1			; Load Collision Chaos Act 1 good future
SCMD_R31D	rs.b	1			; Load Collision Chaos Act 1 bad future
SCMD_R32A	rs.b	1			; Load Collision Chaos Act 2 present 
SCMD_R32B	rs.b	1			; Load Collision Chaos Act 2 past 
SCMD_R32C	rs.b	1			; Load Collision Chaos Act 2 good future 
SCMD_R32D	rs.b	1			; Load Collision Chaos Act 2 bad future 
SCMD_R33C	rs.b	1			; Load Collision Chaos Act 3 good future 
SCMD_R33D	rs.b	1			; Load Collision Chaos Act 3 bad future 
SCMD_R13C	rs.b	1			; Load Palmtree Panic Act 3 good future
SCMD_R13D	rs.b	1			; Load Palmtree Panic Act 3 bad future 
SCMD_R41A	rs.b	1			; Load Tidal Tempest Act 1 present
SCMD_R41B	rs.b	1			; Load Tidal Tempest Act 1 past
SCMD_R41C	rs.b	1			; Load Tidal Tempest Act 1 good future
SCMD_R41D	rs.b	1			; Load Tidal Tempest Act 1 bad future
SCMD_R42A	rs.b	1			; Load Tidal Tempest Act 2 present 
SCMD_R42B	rs.b	1			; Load Tidal Tempest Act 2 past 
SCMD_R42C	rs.b	1			; Load Tidal Tempest Act 2 good future 
SCMD_R42D	rs.b	1			; Load Tidal Tempest Act 2 bad future 
SCMD_R43C	rs.b	1			; Load Tidal Tempest Act 3 good future 
SCMD_R43D	rs.b	1			; Load Tidal Tempest Act 3 bad future 
SCMD_R51A	rs.b	1			; Load Quartz Quadrant Act 1 present
SCMD_R51B	rs.b	1			; Load Quartz Quadrant Act 1 past
SCMD_R51C	rs.b	1			; Load Quartz Quadrant Act 1 good future
SCMD_R51D	rs.b	1			; Load Quartz Quadrant Act 1 bad future
SCMD_R52A	rs.b	1			; Load Quartz Quadrant Act 2 present 
SCMD_R52B	rs.b	1			; Load Quartz Quadrant Act 2 past 
SCMD_R52C	rs.b	1			; Load Quartz Quadrant Act 2 good future 
SCMD_R52D	rs.b	1			; Load Quartz Quadrant Act 2 bad future 
SCMD_R53C	rs.b	1			; Load Quartz Quadrant Act 3 good future 
SCMD_R53D	rs.b	1			; Load Quartz Quadrant Act 3 bad future 
SCMD_R61A	rs.b	1			; Load Wacky Workbench Act 1 present
SCMD_R61B	rs.b	1			; Load Wacky Workbench Act 1 past
SCMD_R61C	rs.b	1			; Load Wacky Workbench Act 1 good future
SCMD_R61D	rs.b	1			; Load Wacky Workbench Act 1 bad future
SCMD_R62A	rs.b	1			; Load Wacky Workbench Act 2 present 
SCMD_R62B	rs.b	1			; Load Wacky Workbench Act 2 past 
SCMD_R62C	rs.b	1			; Load Wacky Workbench Act 2 good future 
SCMD_R62D	rs.b	1			; Load Wacky Workbench Act 2 bad future 
SCMD_R63C	rs.b	1			; Load Wacky Workbench Act 3 good future 
SCMD_R63D	rs.b	1			; Load Wacky Workbench Act 3 bad future 
SCMD_R71A	rs.b	1			; Load Stardust Speedway Act 1 present
SCMD_R71B	rs.b	1			; Load Stardust Speedway Act 1 past
SCMD_R71C	rs.b	1			; Load Stardust Speedway Act 1 good future
SCMD_R71D	rs.b	1			; Load Stardust Speedway Act 1 bad future
SCMD_R72A	rs.b	1			; Load Stardust Speedway Act 2 present 
SCMD_R72B	rs.b	1			; Load Stardust Speedway Act 2 past 
SCMD_R72C	rs.b	1			; Load Stardust Speedway Act 2 good future 
SCMD_R72D	rs.b	1			; Load Stardust Speedway Act 2 bad future 
SCMD_R73C	rs.b	1			; Load Stardust Speedway Act 3 good future 
SCMD_R73D	rs.b	1			; Load Stardust Speedway Act 3 bad future 
SCMD_R81A	rs.b	1			; Load Metallic Madness Act 1 present
SCMD_R81B	rs.b	1			; Load Metallic Madness Act 1 past
SCMD_R81C	rs.b	1			; Load Metallic Madness Act 1 good future
SCMD_R81D	rs.b	1			; Load Metallic Madness Act 1 bad future
SCMD_R82A	rs.b	1			; Load Metallic Madness Act 2 present 
SCMD_R82B	rs.b	1			; Load Metallic Madness Act 2 past 
SCMD_R82C	rs.b	1			; Load Metallic Madness Act 2 good future 
SCMD_R82D	rs.b	1			; Load Metallic Madness Act 2 bad future 
SCMD_R83C	rs.b	1			; Load Metallic Madness Act 3 good future 
SCMD_R83D	rs.b	1			; Load Metallic Madness Act 3 bad future 
SCMD_R8DMUS	rs.b	1			; Play Metallic Madness bad future MUSic
SCMD_BOSSMUS	rs.b	1			; Play boss MUSic
SCMD_FINALMUS	rs.b	1			; Play final boss MUSic
SCMD_TITLEMUS	rs.b	1			; Play title screen MUSic
SCMD_TMATKMUS	rs.b	1			; Play time attack menu MUSic
SCMD_LVLENDMUS	rs.b	1			; Play level end MUSic
SCMD_SHOESMUS	rs.b	1			; Play speed shoes MUSic
SCMD_INVINCMUS	rs.b	1			; Play invincibility MUSic
SCMD_GMOVERMUS	rs.b	1			; Play game over MUSic
SCMD_SPECMUS	rs.b	1			; Play special stage MUSic
SCMD_DAGRDNMUS	rs.b	1			; Play D.A. Garden MUSic
SCMD_PROTOWARP	rs.b	1			; Play prototype warp sound
SCMD_INTROMUS	rs.b	1			; Play opening MUSic
SCMD_ENDINGMUS	rs.b	1			; Play ending MUSic
SCMD_STOPCDA	rs.b	1			; Stop CDDA MUSic
SCMD_SPECSTAGE	rs.b	1			; Load special stage
SCMD_FUTURESFX	rs.b	1			; Play "Future" voice clip
SCMD_PASTSFX	rs.b	1			; Play "Past" voice clip
SCMD_ALRIGHTSFX	rs.b	1			; Play "Alright" voice clip
SCMD_GIVEUPSFX	rs.b	1			; Play "I'm outta here" voice clip
SCMD_YESSFX	rs.b	1			; Play "Yes" voice clip
SCMD_YEAHSFX	rs.b	1			; Play "Yeah" voice clip
SCMD_GIGGLESFX	rs.b	1			; Play Amy giggle voice clip
SCMD_YELPSFX	rs.b	1			; Play Amy yelp voice clip
SCMD_STOMPSFX	rs.b	1			; Play boss stomp sound
SCMD_BUMPERSFX	rs.b	1			; Play bumper sound
SCMD_PASTMUS	rs.b	1			; Play past MUSic
SCMD_DAGARDEN	rs.b	1			; Load D.A. Garden
SCMD_FADEPCM	rs.b	1			; Fade out PCM
SCMD_STOPPCM	rs.b	1			; Stop PCM
SCMD_R11ADEMO	rs.b	1			; Load Palmtree Panic Act 1 present demo
SCMD_VISMODE	rs.b	1			; Load Visual Mode menu
SCMD_INITSS2	rs.b	1			; Reset special stage flags
SCMD_READSAVE	rs.b	1			; Read save data
SCMD_WRITESAVE	rs.b	1			; Write save data
SCMD_BURAMINIT	rs.b	1			; Load Backup RAM initialization
SCMD_INITSS	rs.b	1			; Reset special stage flags
SCMD_RDTEMPSAVE	rs.b	1			; Read temporary save data
SCMD_WRTEMPSAVE	rs.b	1			; Write temporary save data
SCMD_THANKYOU	rs.b	1			; Load "Thank You" screen
SCMD_BURAMMGR	rs.b	1			; Load Backup RAM manager
SCMD_RESETVOL	rs.b	1			; Reset CDDA music volume
SCMD_PAUSEPCM	rs.b	1			; Pause PCM
SCMD_UNPAUSEPCM	rs.b	1			; Unpause PCM
SCMD_BREAKSFX	rs.b	1			; Play glass break sound
SCMD_BADEND	rs.b	1			; Load bad ending FMV
SCMD_GOODEND	rs.b	1			; Load good ending FMV
SCMD_R1AMUST	rs.b	1			; Play Palmtree Panic present music (sound test)
SCMD_R1CMUST	rs.b	1			; Play Palmtree Panic good future music (sound test)
SCMD_R1DMUST	rs.b	1			; Play Palmtree Panic bad future music (sound test)
SCMD_R3AMUST	rs.b	1			; Play Collision Chaos present music (sound test)
SCMD_R3CMUST	rs.b	1			; Play Collision Chaos good future music (sound test
SCMD_R3DMUST	rs.b	1			; Play Collision Chaos bad future music (sound test)
SCMD_R4AMUST	rs.b	1			; Play Tidal Tempest present music (sound test)
SCMD_R4CMUST	rs.b	1			; Play Tidal Tempest good future music (sound test)
SCMD_R4DMUST	rs.b	1			; Play Tidal Tempest bad future music (sound test)
SCMD_R5AMUST	rs.b	1			; Play Quartz Quadrant present music (sound test)
SCMD_R5CMUST	rs.b	1			; Play Quartz Quadrant good future music (sound test
SCMD_R5DMUST	rs.b	1			; Play Quartz Quadrant bad future music (sound test)
SCMD_R6AMUST	rs.b	1			; Play Wacky Workbench present music (sound test)
SCMD_R6CMUST	rs.b	1			; Play Wacky Workbench good future music (sound test
SCMD_R6DMUST	rs.b	1			; Play Wacky Workbench bad future music (sound test)
SCMD_R7AMUST	rs.b	1			; Play Stardust Speedway present music (sound test)
SCMD_R7CMUST	rs.b	1			; Play Stardust Speedway good future music (sound te
SCMD_R7DMUST	rs.b	1			; Play Stardust Speedway bad future music (sound tes
SCMD_R8AMUST	rs.b	1			; Play Metallic Madness present music (sound test)
SCMD_R8CMUST	rs.b	1			; Play Metallic Madness good future music (sound tes
SCMD_R8DMUST	rs.b	1			; Play Metallic Madness bad future music (sound test
SCMD_BOSSMUST	rs.b	1			; Play boss music (sound test)
SCMD_FINALMUST	rs.b	1			; Play final boss music (sound test)
SCMD_TITLEMUST	rs.b	1			; Play title screen music (sound test)
SCMD_TMATKMUST	rs.b	1			; Play time attack music (sound test)
SCMD_LVLENDMUST	rs.b	1			; Play level end music (sound test)
SCMD_SHOESMUST	rs.b	1			; Play speed shoes music (sound test)
SCMD_INVINCMUST	rs.b	1			; Play invincibility music (sound test)
SCMD_GMOVERMUST	rs.b	1			; Play game over music (sound test)
SCMD_SPECMUST	rs.b	1			; Play special stage music (sound test)
SCMD_DAGRDNMUST	rs.b	1			; Play D.A. Garden music (sound test)
SCMD_PROTOWARPT	rs.b	1			; Play prototype warp sound (sound test)
SCMD_INTROMUST	rs.b	1			; Play opening music (sound test)
SCMD_ENDINGMUST	rs.b	1			; Play ending music (sound test)
SCMD_FUTURESFXT	rs.b	1			; Play "Future" voice clip (sound test)
SCMD_PASTSFXT	rs.b	1			; Play "Past" voice clip (sound test)
SCMD_ALRGHTSFXT	rs.b	1			; Play "Alright" voice clip (sound test)
SCMD_GIVEUPSFXT	rs.b	1			; Play "I'm outta here" voice clip (sound test)
SCMD_YESSFXT	rs.b	1			; Play "Yes" voice clip (sound test)
SCMD_YEAHSFXT	rs.b	1			; Play "Yeah" voice clip (sound test)
SCMD_GIGGLESFXT	rs.b	1			; Play Amy giggle voice clip (sound test)
SCMD_YELPSFXT	rs.b	1			; Play Amy yelp voice clip (sound test)
SCMD_STOMPSFXT	rs.b	1			; Play boss stomp sound (sound test)
SCMD_BUMPERSFXT	rs.b	1			; Play bumper sound (sound test)
SCMD_R1BMUST	rs.b	1			; Play Palmtree Panic past music (sound test)
SCMD_R3BMUST	rs.b	1			; Play Collision Chaos past music (sound test)
SCMD_R4BMUST	rs.b	1			; Play Tidal Tempest past music (sound test)
SCMD_R5BMUST	rs.b	1			; Play Quartz Quadrant past music (sound test)
SCMD_R6BMUST	rs.b	1			; Play Palmtree Panic past music (sound test)
SCMD_R7BMUST	rs.b	1			; Play Palmtree Panic past music (sound test)
SCMD_R8BMUST	rs.b	1			; Play Palmtree Panic past music (sound test)
SCMD_FUNISINF	rs.b	1			; Load "Fun is infinite" screen
SCMD_STAFFCREDS	rs.b	1			; Load staff credits
SCMD_MCSONIC	rs.b	1			; Load M.C. Sonic screen
SCMD_TAILS	rs.b	1			; Load Tails screen
SCMD_BATMAN	rs.b	1			; Load Batman Sonic screen
SCMD_CUTESONIC	rs.b	1			; Load cute Sonic screen
SCMD_STAFFTIMES	rs.b	1			; Load best staff times screen
SCMD_DUMMY1	rs.b	1			; Load dummy file (unused)
SCMD_DUMMY2	rs.b	1			; Load dummy file (unused)
SCMD_DUMMY3	rs.b	1			; Load dummy file (unused)
SCMD_DUMMY4	rs.b	1			; Load dummy file (unused)
SCMD_DUMMY5	rs.b	1			; Load dummy file (unused)
SCMD_PENCILTEST	rs.b	1			; Load pencil test FMV
SCMD_PAUSECDA	rs.b	1			; Pause CDDA MUSic
SCMD_UNPAUSECDA	rs.b	1			; Unpause CDDA MUSic
SCMD_OPENING	rs.b	1			; Load opening FMV
SCMD_COMINSOON	rs.b	1			; Load "Comin' Soon" screen

; -------------------------------------------------------------------------

	if def(SUBCPU)

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; System program
SPVariables	EQU	$7000			; Variables
SaveDataTemp	EQU	$7400			; Temporary save data buffer
SPIRQ2		EQU	$7700			; IRQ2 handler
LoadFile	EQU	$7800			; Load file
GetFileName	EQU	$7840			; Get file name
FileEngineFunc	EQU	$7880			; File engine function handler
FileEngineVars	EQU	$8C00			; File engine variables

; System program extension
SPX		EQU	$B800			; SPX start location
SPXFileTable	EQU	SPX			; SPX file table
SPXStart	EQU	SPX+$800		; SPX code start
Stack		EQU	$10000			; Stack base

; FMV
FMVPCMBUF	EQU	PRGRAM+$40000		; PCM data buffer
FMVGFXBUF	EQU	WORDRAM1M		; Graphics data buffer

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; File engine functions
	rsreset
FFUNC_INIT	rs.b	1			; Initialize
FFUNC_OPER	rs.b	1			; Perform operation
FFUNC_STATUS	rs.b	1			; Get status
FFUNC_GETFILES	rs.b	1			; Get files
FFUNC_LOADFILE	rs.b	1			; Load file
FFUNC_FINDFILE	rs.b	1			; Find file
FFUNC_LOADFMV	rs.b	1			; Load FMV
FFUNC_RESET	rs.b	1			; Reset
FFUNC_LOADFMVM	rs.b	1			; Load FMV (mute)

; File engine operation modes
	rsreset
FMODE_NONE	rs.b	1			; No function
FMODE_GETFILES	rs.b	1			; Get files
FMODE_LOADFILE	rs.b	1			; Load file
FMODE_LOADFMV	rs.b	1			; Load FMV
FMODE_LOADFMVM	rs.b	1			; Load FMV (mute)

; File engine statuses
FSTAT_OK	EQU	100			; OK
FSTAT_GETFAIL	EQU	-1			; File get failed
FSTAT_NOTFOUND	EQU	-2			; File not found
FSTAT_LOADFAIL	EQU	-3			; File load failed
FSTAT_READFAIL	EQU	-100			; Failed
FSTAT_FMVFAIL	EQU	-111			; FMV load failed

; FMV data types
FMVT_PCM	EQU	0			; PCM data type
FMVT_GFX	EQU	1			; Graphics data type

; FMV flags
FMVF_INIT	EQU	3			; Initialized flag
FMVF_BANK	EQU	4			; PCM bank ID
FMVF_READY	EQU	5			; Ready flag
FMVF_SECT	EQU	7			; Reading data section 1 flag

; File data
FILENAMESZ	EQU	12			; File name length

; -------------------------------------------------------------------------
; SP variables
; -------------------------------------------------------------------------

	rsset	SPVariables
curPCMDriver	rs.l	1			; Current PCM driver
ssFlags		rs.b	1			; Special stage flags
pcmDrvFlags	rs.b	1			; PCM driver flags
		rs.b	$400-__rs
SPVARSSZ	rs.b	1			; Size of structure

; -------------------------------------------------------------------------
; File engine variables structure
; -------------------------------------------------------------------------

	rsreset
feOperMark	rs.l	1			; Operation bookmark
feSector	rs.l	1			; Sector to read from
feSectorCnt	rs.l	1			; Number of sectors to read
feReturnAddr	rs.l	1			; Return address for CD read functions
feReadBuffer	rs.l	1			; Read buffer address
feReadTime	rs.b	0			; Time of read sector
feReadMin	rs.b	1			; Read sector minute
feReadSec	rs.b	1			; Read sector second
feReadFrame	rs.b	1			; Read sector frame
		rs.b	1
feDirSectors	rs.b	0			; Directory size in sectors
feFileSize	rs.l	1			; File size buffer
feOperMode	rs.w	1			; Operation mode
feStatus	rs.w	1			; Status code
feFileCount	rs.w	1			; File count
feWaitTime	rs.w	1			; Wait timer
feRetries	rs.w	1			; Retry counter
feSectorsRead	rs.w	1			; Number of sectors read
feCDC		rs.b	1			; CDC mode
feSectorFrame	rs.b	1			; Sector frame
feFileName	rs.b	FILENAMESZ		; File name buffer
		rs.b	$100-__rs
feFileList	rs.b	$2000			; File list
feDirReadBuf	rs.b	$900			; Directory read buffer
feFMVSectFrame	rs.w	1			; FMV sector frame
feFMVDataType	rs.b	1			; FMV read data type
feFMVFlags	rs.b	1			; FMV flags
feFMVFailCount	rs.b	1			; FMV fail counter
FILEVARSSZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; File entry structure
; -------------------------------------------------------------------------

	rsreset
fileName	rs.b	FILENAMESZ		; File name
		rs.b	$17-__rs
fileFlags	rs.b	1			; File flags
fileSector	rs.l	1			; File sector
fileLength	rs.l	1			; File size
FILEENTRYSZ	rs.b	0			; Size of structure
	endif

; -------------------------------------------------------------------------
