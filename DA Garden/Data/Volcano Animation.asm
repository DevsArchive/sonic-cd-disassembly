; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden volcano animation data
; -------------------------------------------------------------------------

VolcanoAnimStamps:
	dc.w	.Frame0-VolcanoAnimStamps
	dc.w	.Frame1-VolcanoAnimStamps
	dc.w	.Frame2-VolcanoAnimStamps
	dc.w	.Frame3-VolcanoAnimStamps
	dc.w	.Frame4-VolcanoAnimStamps
	dc.w	.Frame5-VolcanoAnimStamps
	dc.w	.Frame0-VolcanoAnimStamps
	dc.w	.Frame7-VolcanoAnimStamps
	dc.w	.Frame8-VolcanoAnimStamps
	dc.w	.Frame9-VolcanoAnimStamps
	dc.w	.Frame10-VolcanoAnimStamps
	dc.w	.Frame11-VolcanoAnimStamps
	
.Frame0:
	dc.w	4, 0
	dc.w	8, $C
.Frame1:
	dc.w	$10, 0
	dc.w	8, $C
.Frame2:
	dc.w	$14, 0
	dc.w	8, $C
.Frame3:
	dc.w	$18, $1C
	dc.w	8, $C
.Frame4:
	dc.w	$20, $24
	dc.w	8, $C
.Frame5:
	dc.w	$28, $2C
	dc.w	8, $C
.Frame7:
	dc.w	4, 0
	dc.w	8, $30
.Frame8:
	dc.w	4, 0
	dc.w	$34, $38
.Frame9:
	dc.w	4, $3C
	dc.w	$40, $44
.Frame10:
	dc.w	$48, $4C
	dc.w	$50, $54
.Frame11:
	dc.w	$58, $5C
	dc.w	$60, $64

; -------------------------------------------------------------------------

VolcanoAnimTimes:
	dc.w	40
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	5
	dc.w	80
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	6

; -------------------------------------------------------------------------
