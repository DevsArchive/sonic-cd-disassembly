; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Act 1 Present object art manager
; -------------------------------------------------------------------------

LoadCamPLCFull:
	moveq	#2,d0
	jmp	LoadPLC

LoadCamPLCIncr:

LevelObj_SetBaseTile:
	rts

; -------------------------------------------------------------------------
