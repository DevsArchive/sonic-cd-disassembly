; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Special stage global variables
; -------------------------------------------------------------------------

	if def(SUBCPU)
SpecStageData	EQU	PRGRAM+$18000		; Special stage data
	endif
SpecStgDataCopy	EQU	WORDRAM2M+$6D00		; Special stage data copy

specStageIDCmd	EQU	GACOMCMD3		; Stage ID (for Sub CPU command)
timeStonesCmd	EQU	GACOMCMDA		; Time stones retrieved (for Sub CPU command)
specStageFlags	EQU	GACOMCMDB		; Flags
specStageID	EQU	GACOMSTAT3		; Stage ID
specStageRings	EQU	GACOMSTAT4		; Ring count
specStageTimer	EQU	GACOMSTAT6		; Timer
timeStonesSub	EQU	GACOMSTATA		; Time stones retrieved

; -------------------------------------------------------------------------
