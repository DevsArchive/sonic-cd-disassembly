; -------------------------------------------------------------------------------
; Sonic CD Misc. Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------------
; System definitions
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------------

; Addresses
SPVariables	EQU	$7000			; Variables
BuRAMBuffer	EQU	$7400			; BuRAM buffer
SPIRQ2		EQU	$7700			; IRQ2 handler
LoadFile	EQU	$7800			; Load file
GetFileName	EQU	$7840			; Get file name
FileEngineFunc	EQU	$7880			; File engine function handler
FileEngineVars	EQU	$8C00			; File engine variables
SPX		EQU	$B800			; SPX start location
SPXFileTable	EQU	SPX			; SPX file table
SPXStart	EQU	SPX+$800		; SPX code start
Stack		EQU	$10000			; Stack base
PCMDriver	EQU	PRG_RAM+$40000		; PCM driver location
PCMDrv_Run	EQU	PCMDriver+$10		; Run PCM driver
PCMDrv_Queue	EQU	PCMDriver+$22		; PCM sound queue

; File engine functions
FFUNC_INIT	EQU	0			; Initialize
FFUNC_OPER	EQU	1			; Perform operation
FFUNC_STATUS	EQU	2			; Get status
FFUNC_GETFILES	EQU	3			; Get files
FFUNC_LOADFILE	EQU	4			; Load file
FFUNC_FINDFILE	EQU	5			; Find file
FFUNC_LOADFMV	EQU	6			; Load FMV
FFUNC_RESET	EQU	7			; Reset
FFUNC_LOADFMVM	EQU	8			; Load FMV (mute)

; File engine operation modes
FMODE_NONE	EQU	0			; No function
FMODE_GETFILES	EQU	1			; Get files
FMODE_LOADFILE	EQU	2			; Load file
FMODE_LOADFMV	EQU	3			; Load FMV
FMODE_LOADFMVM	EQU	4			; Load FMV (mute)

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

; FMV addreses
FMV_PCM_BUF	EQU	PRG_RAM+$40000		; PCM data buffer
FMV_GFX_BUF	EQU	WORDRAM_1M		; Graphics data buffer

; File data
FILENAME_LEN	EQU	12			; File name length

; Backup RAM
BURAM_BUF_LEN	EQU	$2C0			; Backup RAM buffer length

; -------------------------------------------------------------------------------
; SP variables
; -------------------------------------------------------------------------------

	rsset	SPVariables
curPCMDriver	rs.l	1			; Current PCM driver
ssFlags		rs.b	1			; Special stage flags
pcmDrvFlags	rs.b	1			; PCM driver flags
		rs.b	$400-__rs
SP_VARS_LEN	rs.b	1			; Size of structure

; -------------------------------------------------------------------------------
; File engine variables structure
; -------------------------------------------------------------------------------

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
feFileName	rs.b	FILENAME_LEN		; File name buffer
		rs.b	$100-__rs
feFileList	rs.b	$2000			; File list
feDirReadBuf	rs.b	$900			; Directory read buffer
feFMVSectFrame	rs.w	1			; FMV sector frame
feFMVDataType	rs.b	1			; FMV read data type
feFMVFlags	rs.b	1			; FMV flags
feFMVFailCount	rs.b	1			; FMV fail counter
FILE_VARS_LEN	rs.b	0			; Size of structure

; -------------------------------------------------------------------------------
; File entry structure
; -------------------------------------------------------------------------------

	rsreset
fileName	rs.b	FILENAME_LEN		; File name
		rs.b	$17-__rs
fileFlags	rs.b	1			; File flags
fileSector	rs.l	1			; File sector
fileLength	rs.l	1			; File size
FILE_ENTRY_LEN	rs.b	0			; Size of structure

; -------------------------------------------------------------------------------
