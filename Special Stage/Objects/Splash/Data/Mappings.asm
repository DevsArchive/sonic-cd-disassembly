	dc.l	.Large
	dc.l	.Small
	
.Large:
	dc.b	7, 1
	dc.l	.Splash0
	dc.l	.Splash1
	dc.l	.Splash2
	dc.l	.Splash3
	dc.l	.Splash4
	dc.l	.Splash5
	dc.l	.Splash6
	
.Small:
	dc.b	3, 0
	dc.l	.Splash0
	dc.l	.Splash1
	dc.l	.Splash2
	
.Splash0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 4, 0, 0, $F8
	dc.b	$F8, $C, 0, 2, $F0
	even

.Splash1:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 0, 0, 6, $F8
	dc.b	$E8, $E, 0, 7, $F0
	even

.Splash2:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E0, $F, 0, $13, $F0
	even

.Splash3:
	dc.b	2, 0, 0, 0, 0
	dc.b	$D0, 4, 0, $23, $F8
	dc.b	$D8, 8, 0, $25, $F0
	dc.b	$E0, $F, 0, $28, $F0
	even

.Splash4:
	dc.b	3, 0, 0, 0, 0
	dc.b	$C0, 8, 0, $38, $F8
	dc.b	$C8, 8, 0, $3B, $F0
	dc.b	$D0, $F, 0, $3E, $F0
	dc.b	$F0, $D, 0, $4E, $F0
	even

.Splash5:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 4, 0, $56, $F8
	even

.Splash6:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 4, 0, $58, $F0
	dc.b	$F8, 4, 8, $58, 0
	even
