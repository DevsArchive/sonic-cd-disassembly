	dc.l	.TimeStone
	dc.l	.Sparkle1
	dc.l	.Sparkle2
	
.TimeStone:
	dc.b	4, 3
	dc.l	.TimeStone0
	dc.l	.TimeStone1
	dc.l	.TimeStone2
	dc.l	.TimeStone3
	
.Sparkle1:
	dc.b	4, 1
	dc.l	.Sparkle1_0
	dc.l	.Sparkle1_1
	dc.l	.Sparkle1_2
	dc.l	.Sparkle1_3
	
.Sparkle2:
	dc.b	4, 1
	dc.l	.Sparkle2_0
	dc.l	.Sparkle2_1
	dc.l	.Sparkle2_2
	dc.l	.Sparkle2_3
	
.TimeStone0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 0, $F8
	even
	
.TimeStone1:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 6, $F8
	even
	
.TimeStone3:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 8, 6, $F8
	even
	
.TimeStone2:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $C, $F8
	even
	
.Sparkle1_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 0, $12, $F4
	dc.b	$F8, 0, 0, $18, $FC
	even
	
.Sparkle1_1:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $10, $18, $FC
	dc.b	$F0, 9, $10, $12, $F4
	even
	
.Sparkle1_2:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $18, $18, $FC
	dc.b	$F0, 9, $18, $12, $F4
	even
	
.Sparkle1_3:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 8, $12, $F4
	dc.b	$F8, 0, 8, $18, $FC
	even
	
.Sparkle2_3:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 0, $19, 0
	dc.b	$F8, 4, 0, $1A, $F8
	even
	
.Sparkle2_2:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 0, $10, $19, 0
	dc.b	$F0, 4, $10, $1A, $F8
	even
	
.Sparkle2_1:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 4, $18, $1A, $F8
	dc.b	$F8, 0, $18, $19, $F8
	even
	
.Sparkle2_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 8, $19, $F8
	dc.b	$F8, 4, 8, $1A, $F8
	even
	