; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Shared Backup RAM management variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Backup RAM command IDs
	rsset	1
BRCMD_INIT	rs.b	1			; Initialize Backup RAM interaction
BRCMD_STATUS	rs.b	1			; Get Backup RAM status
BRCMD_SEARCH	rs.b	1			; Search Backup RAM
BRCMD_READ	rs.b	1			; Read from Backup RAM
BRCMD_WRITE	rs.b	1			; Write to Backup RAM
BRCMD_DELETE	rs.b	1			; Delete Backup RAM
BRCMD_FORMAT	rs.b	1			; Format Backup RAM
BRCMD_DIR	rs.b	1			; Get Backup RAM directory
BRCMD_VERIFY	rs.b	1			; Verify Backup RAM
BRCMD_RDSAVE	rs.b	1			; Read save data (Sub CPU)
BRCMD_WRSAVE	rs.b	1			; Write save data (Sub CPU)

; Backup RAM types
BRTYPE_INT	EQU	0			; Internal Backup RAM
BRTYPE_CART	EQU	1			; RAM cartridge

; Backup RAM file
BRFILENAMESZ	EQU	$B			; File name length

; -------------------------------------------------------------------------
; Backup RAM data
; -------------------------------------------------------------------------

	rsreset
; Time attack save data
svTmAtkTimes	rs.l	(7*3*3)+(7*3)		; Time attack times
svTmAtkNames	rs.l	(7*3*3)+(7*3)		; Time attack initials
svTmAtkDefName	rs.l	1			; Time attack default initials
BURAMTIMESZ	rs.b	0			; Time attack save data size

; Main data save data
svZone		rs.b	1			; Zone
svTmAtkUnlock	rs.b	1			; Last unlocked time attack zone
svUnknown	rs.b	1			; Unknown
svGoodFutures	rs.b	1			; Good futures achieved flags
svTitleFlags	rs.b	1			; Title screen flags
		rs.b	3
svSpecStage	rs.b	1			; Special stage ID
svTimeStones	rs.b	1			; Time stones retrieved flags
		rs.b	$14
BURAMMAINSZ	EQU	__rs-BURAMTIMESZ	; Main save data size

BURAMDATASZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Backup RAM function parameters
; -------------------------------------------------------------------------

	rsreset
buramFile	rs.b	BRFILENAMESZ		; File name
buramMisc	rs.b	0			; Misc. parameters start
buramFlag	rs.b	1			; Flag
buramBlkSz	rs.w	1			; Block size
BURAMPARAMSZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Shared Word RAM variables
; -------------------------------------------------------------------------

	rsset	WORDRAM2M+$20
commandID	rs.b	1			; Command ID
cmdStatus	rs.b	1			; Command status
buramD0		rs.w	1			; Backup RAM function returned d0
buramD1		rs.w	1			; Backup RAM function returned d1
buramType	rs.b	1			; Backup RAM type
ramCartFound	rs.b	1			; RAM cart found flag
buramDisabled	rs.b	1			; Backup RAM disabled flag
writeFlag	rs.b	1			; Backup RAM function write flag
blockSize	rs.w	1			; Backup RAM function block size
		rs.b	4
buramParams	rs.b	BURAMPARAMSZ		; Backup RAM function parameters
		rs.b	2
buramData	rs.b	BURAMDATASZ		; Backup RAM data

; -------------------------------------------------------------------------
