.Map:
	dc.w	.PPZ-.Map
	dc.w	.PPZG-.Map
	dc.w	.PPZB-.Map
	dc.w	.CCZ-.Map
	dc.w	.CCZG-.Map
	dc.w	.CCZB-.Map
	dc.w	.TTZ-.Map
	dc.w	.TTZG-.Map
	dc.w	.TTZB-.Map
	dc.w	.QQZ-.Map
	dc.w	.QQZG-.Map
	dc.w	.QQZB-.Map
	dc.w	.WWZ-.Map
	dc.w	.WWZG-.Map
	dc.w	.WWZB-.Map
	dc.w	.SSZ-.Map
	dc.w	.SSZG-.Map
	dc.w	.SSZB-.Map
	dc.w	.MMZ-.Map
	dc.w	.MMZG-.Map
	dc.w	.MMZB-.Map
	dc.w	.Final-.Map
	dc.w	.LittlePlanet-.Map
	dc.w	.GameOver-.Map
	dc.w	.ZoneClear-.Map
	dc.w	.Boss-.Map
	dc.w	.Invincible-.Map
	dc.w	.SpeedUp-.Map
	dc.w	.Title-.Map
	dc.w	.SpecStg-.Map
	dc.w	.Opening-.Map
	dc.w	.Ending-.Map
	
.Boss:
	dc.w	1
	dc.w	1, .Boss0-.Boss
	
.Boss0:
	dc.w	2-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	0, 4, -$20, 0, 0, 0
	
.CCZ:
	dc.w	1
	dc.w	1, .CCZ0-.CCZ
	
.CCZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$400, $C, -$60, 0, 0, 0
	
.CCZB:
	dc.w	1
	dc.w	1, .CCZB0-.CCZB
	
.CCZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$400, $10, -$80, 0, 0, 0
	
.CCZG:
	dc.w	1
	dc.w	1, .CCZG0-.CCZG
	
.CCZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$400, $10, -$80, 0, 0, 0
	
.Final:
	dc.w	1
	dc.w	1, .Final0-.Final
	
.Final0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$400, 8, -$40, 0, 0, 0
	
.GameOver:
	dc.w	1
	dc.w	1, .GameOver0-.GameOver
	
.GameOver0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	0, 8, -$40, 0, 0, 0
	
.Invincible:
	dc.w	1
	dc.w	1, .Invincible0-.Invincible
	
.Invincible0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$400, 8, -$40, 0, 0, 0
	
.LittlePlanet:
	dc.w	1
	dc.w	1, .LittlePlanet0-.LittlePlanet
	
.LittlePlanet0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	
.MMZ:
	dc.w	1
	dc.w	1, .MMZ0-.MMZ
	
.MMZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$800, $C, -$60, 0, 0, 0
	
.MMZB:
	dc.w	1
	dc.w	1, .MMZB0-.MMZB
	
.MMZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$C00, $10, -$80, 0, 0, 0
	
.MMZG:
	dc.w	1
	dc.w	1, .MMZG0-.MMZG
	
.MMZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$C00, $10, -$80, 0, 0, 0
	
.PPZ:
	dc.w	1
	dc.w	1, .PPZ0-.PPZ
	
.PPZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	0, $C, -$60, 0, 0, 0
	
.PPZB:
	dc.w	1
	dc.w	1, .PPZB0-.PPZB
	
.PPZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	0, $10, -$80, 0, 0, 0
	
.PPZG:
	dc.w	1
	dc.w	1, .PPZG0-.PPZG
	
.PPZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	0, $10, -$80, 0, 0, 0
	
.QQZ:
	dc.w	1
	dc.w	1, .QQZ0-.QQZ
	
.QQZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$400, $C, -$60, 0, 0, 0
	
.QQZB:
	dc.w	1
	dc.w	1, .QQZB0-.QQZB
	
.QQZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$400, $10, -$80, 0, 0, 0
	
.QQZG:
	dc.w	1
	dc.w	1, .QQZG0-.QQZG
	
.QQZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$400, $10, -$80, 0, 0, 0
	
.SpecStg:
	dc.w	1
	dc.w	1, .SpecStg0-.SpecStg
	
.SpecStg0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	
.SpeedUp:
	dc.w	1
	dc.w	1, .SpeedUp0-.SpeedUp
	
.SpeedUp0:
	dc.w	2-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	
.SSZ:
	dc.w	1
	dc.w	1, .SSZ0-.SSZ
	
.SSZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	
.SSZB:
	dc.w	1
	dc.w	1, .SSZB0-.SSZB
	
.SSZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$C00, $10, -$80, 0, 0, 0
	
.SSZG:
	dc.w	1
	dc.w	1, .SSZG0-.SSZG
	
.SSZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$C00, $10, -$80, 0, 0, 0
	
.Title:
	dc.w	1
	dc.w	1, .Title0-.Title
	
.Title0:
	dc.w	2-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	0, 4, -$20, 0, 0, 0
	
.TTZ:
	dc.w	1
	dc.w	1, .TTZ0-.TTZ
	
.TTZ0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	
.TTZB:
	dc.w	1
	dc.w	1, .TTZB0-.TTZB
	
.TTZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	0, $10, -$80, 0, 0, 0
	
.TTZG:
	dc.w	1
	dc.w	1, .TTZG0-.TTZG
	
.TTZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	0, $10, -$80, 0, 0, 0
	
.WWZ:
	dc.w	1
	dc.w	1, .WWZ0-.WWZ
	
.WWZ0:
	dc.w	4-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$400, $C, -$60, 0, 0, 0
	
.WWZB:
	dc.w	1
	dc.w	1, .WWZB0-.WWZB
	
.WWZB0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$800, $10, -$80, 0, 0, 0
	
.WWZG:
	dc.w	1
	dc.w	1, .WWZG0-.WWZG
	
.WWZG0:
	dc.w	5-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	$C00, 8, -$40, 0, 0, 0
	dc.w	$C00, $C, -$60, 0, 0, 0
	dc.w	$800, $10, -$80, 0, 0, 0
	
.ZoneClear:
	dc.w	1
	dc.w	1, .ZoneClear0-.ZoneClear
	
.ZoneClear0:
	dc.w	3-1
	dc.w	$C00, 0, 0, 0, 0, 0
	dc.w	$C00, 4, -$20, 0, 0, 0
	dc.w	0, 8, -$40, 0, 0, 0
	
.Opening:
	dc.w	1
	dc.w	1, .Opening0-.Opening
	
.Opening0:
	if REGION<>USA
		dc.w	6-1
		dc.w	$C00, 0, 0, 0, 0, 0
		dc.w	$C00, 4, -$20, 0, 0, 0
		dc.w	$C00, 8, -$40, 0, 0, 0
		dc.w	$C00, $C, -$60, 0, 0, 0
		dc.w	$C00, $10, -$80, 0, 0, 0
		dc.w	$400, $14, -$A0, 0, 0, 0
	else
		dc.w	2-1
		dc.w	$C00, 0, 0, 0, 0, 0
		dc.w	$400, 4, -$20, 0, 0, 0
	endif
	
.Ending:
	dc.w	1
	dc.w	1, .Ending0-.Ending
	
.Ending0:
	if REGION<>USA
		dc.w	8-1
		dc.w	$C00, 0, 0, 0, 0, 0
		dc.w	$C00, 4, -$20, 0, 0, 0
		dc.w	$C00, 8, -$40, 0, 0, 0
		dc.w	$C00, $C, -$60, 0, 0, 0
		dc.w	$C00, $10, -$80, 0, 0, 0
		dc.w	$C00, $14, -$A0, 0, 0, 0
		dc.w	$C00, $18, -$C0, 0, 0, 0
		dc.w	0, $1C, -$E0, 0, 0, 0
	else
		dc.w	2-1
		dc.w	$C00, 0, 0, 0, 0, 0
		dc.w	$400, 4, -$20, 0, 0, 0
	endif
	