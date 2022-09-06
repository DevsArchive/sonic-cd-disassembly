	dc.l	.Sparkle
	
.Sparkle:
	dc.b	4, 1
	dc.l	.Sparkle0
	dc.l	.Sparkle1
	dc.l	.Sparkle2
	dc.l	.Sparkle3
	dc.l	.Sparkle4
	
.Sparkle0:
	dc.b	3
	dc.b	$E0, 5, 0, $46, $F0
	dc.b	$E0, 5, 8, $46, 0
	dc.b	$F0, 5, $10, $46, $F0
	dc.b	$F0, 5, $18, $46, 0
	even
	
.Sparkle1:
	dc.b	3
	dc.b	$E0, 5, 0, $4A, $F0
	dc.b	$E0, 5, 8, $4A, 0
	dc.b	$F0, 5, $10, $4A, $F0
	dc.b	$F0, 5, $18, $4A, 0
	even
	
.Sparkle2:
	dc.b	3
	dc.b	$D0, $A, 0, $4E, $E8
	dc.b	$D0, $A, 8, $4E, 0
	dc.b	$E8, $A, $10, $4E, $E8
	dc.b	$E8, $A, $18, $4E, 0
	even
	
.Sparkle3:
	dc.b	3
	dc.b	$E0, 5, 0, $57, $F0
	dc.b	$E0, 5, 0, $5B, 0
	dc.b	$F0, 5, $18, $5B, $F0
	dc.b	$F0, 5, $18, $57, 0
	even
	
.Sparkle4:
	dc.b	1
	dc.b	$E8, 6, 0, $5F, $F0
	dc.b	$E8, 6, 8, $5F, 0
	even
	