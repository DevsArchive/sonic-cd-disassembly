; -------------------------------------------------------------------------------
; Sonic CD Misc. Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------------
; Shared Backup RAM management variables
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------------
; Backup RAM data
; -------------------------------------------------------------------------------

	rsreset
		rs.b	$2A0
		rs.b	$20
BURAM_DATA_LEN	rs.b	0			; Size of structure

; -------------------------------------------------------------------------------
; Backup RAM function parameters
; -------------------------------------------------------------------------------

	rsreset
buramFile	rs.b	$B			; File name
buramMisc	rs.b	0			; Misc. parameters start
buramFlag	rs.b	1			; Flag
buramBlkSz	rs.w	1			; Block size
BURAM_PARAM_LEN	rs.b	0			; Size of structure

; -------------------------------------------------------------------------------
; Shared Word RAM variables
; -------------------------------------------------------------------------------

	rsset	WORDRAM_2M+$20
commandID	rs.b	1			; Command ID
cmdStatus	rs.b	1			; Command status
buramD0		rs.w	1			; Backup RAM function returned d0
buramD1		rs.w	1			; Backup RAM function returned d1
useRAMCart	rs.b	1			; Use RAM cart flag
ramCartFound	rs.b	1			; RAM cart found flag
buramDisabled	rs.b	1			; Backup RAM disabled flag
writeFlag	rs.b	1			; Backup RAM function write flag
blockSize	rs.w	1			; Backup RAM function block size
		rs.b	4
buramParams	rs.b	BURAM_PARAM_LEN		; Backup RAM function parameters
		rs.b	2
buramData	rs.b	BURAM_DATA_LEN		; Backup RAM data

; -------------------------------------------------------------------------------
