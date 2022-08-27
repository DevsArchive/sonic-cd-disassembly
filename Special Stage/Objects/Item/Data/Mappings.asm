	dc.l	.Rings
	dc.l	.SpeedShoes
	dc.l	.Time
	dc.l	.Hand
	dc.l	.LostRing

.Rings:
	dc.b	1, $FF
	dc.l	.Ring0

.SpeedShoes:
	dc.b	1, $FF
	dc.l	.SpeedShoes0

.Time:
	dc.b	1, $FF
	dc.l	.Time0

.Hand:
	dc.b	1, $FF
	dc.l	.Hand0

.LostRing:
	dc.b	4, 4
	dc.l	.LostRing0
	dc.l	.LostRing1
	dc.l	.LostRing2
	dc.l	.LostRing3

.Ring0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, 0, $F8
	even

.SpeedShoes0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, 4, $F8
	even

.Time0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, 8, $F8
	even

.Hand0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 8, $C, $F8
	even

.LostRing0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $10, $F8
	even

.LostRing1:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $16, $F8
	even

.LostRing2:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 2, 0, $1C, $FC
	even

.LostRing3:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 8, $16, $F8
	even
	