	dc.l	.PressStart

.PressStart:
	dc.b	1, $FF
	dc.l	.PressStart0

.PressStart0:
	dc.b	2, 0, 0, 0, 0
	dc.b	0, $D, 0, 0, 0
	dc.b	0, 9, 0, 8, $20
	dc.b	0, $D, 0, $E, $38
	even
	