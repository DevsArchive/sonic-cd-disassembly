; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden palette data
; -------------------------------------------------------------------------

PalCycleTable:
	dc.l	PalCyc_PlanetPresent, PalCyc_BgPresentGF
	dc.l	PalCyc_PlanetGoodFut, PalCyc_BgPresentGF
	dc.l	PalCyc_PlanetBadFut, PalCyc_BgBadFuture

; -------------------------------------------------------------------------

SprPalCycTable:
	dc.w	PalCyc_Sprites0-SprPalCycTable
	dc.w	PalCyc_Sprites1-SprPalCycTable

; -------------------------------------------------------------------------

PalCyc_Sprites0:
	incbin	"DA Garden/Data/Palette.bin", $40, $20
	even

PalCyc_Sprites1:
	incbin	"DA Garden/Data/Palette.bin", $40, $18
	dc.w	$EEE, $EE
	incbin	"DA Garden/Data/Palette.bin", $5C, 4
	even

; -------------------------------------------------------------------------

Pal_SelMenu:
	incbin	"DA Garden/Data/Palette.bin", $60, $20
	even

; -------------------------------------------------------------------------

Pal_DAGarden:
	incbin	"DA Garden/Data/Palette.bin"
Pal_DAGardenEnd:
	even

; -------------------------------------------------------------------------
	
PalCyc_PlanetPresent:
	dc.w	.Pal0-PalCyc_PlanetPresent
	dc.w	.Pal1-PalCyc_PlanetPresent
	dc.w	.Pal2-PalCyc_PlanetPresent
	dc.w	.Pal3-PalCyc_PlanetPresent
	dc.w	.Pal4-PalCyc_PlanetPresent
	dc.w	.Pal5-PalCyc_PlanetPresent
	dc.w	.Pal6-PalCyc_PlanetPresent
	dc.w	.Pal7-PalCyc_PlanetPresent
	dc.w	.Pal8-PalCyc_PlanetPresent
	dc.w	.Pal9-PalCyc_PlanetPresent
	dc.w	.Pal10-PalCyc_PlanetPresent
	dc.w	.Pal11-PalCyc_PlanetPresent
	dc.w	.Pal12-PalCyc_PlanetPresent
	dc.w	.Pal13-PalCyc_PlanetPresent
	dc.w	.Pal14-PalCyc_PlanetPresent
	dc.w	.Pal15-PalCyc_PlanetPresent
	dc.w	.Pal16-PalCyc_PlanetPresent
	dc.w	.Pal15-PalCyc_PlanetPresent
	dc.w	.Pal14-PalCyc_PlanetPresent
	dc.w	.Pal13-PalCyc_PlanetPresent
	dc.w	.Pal12-PalCyc_PlanetPresent
	dc.w	.Pal11-PalCyc_PlanetPresent
	dc.w	.Pal10-PalCyc_PlanetPresent
	dc.w	.Pal9-PalCyc_PlanetPresent
	dc.w	.Pal8-PalCyc_PlanetPresent
	dc.w	.Pal7-PalCyc_PlanetPresent
	dc.w	.Pal6-PalCyc_PlanetPresent
	dc.w	.Pal5-PalCyc_PlanetPresent
	dc.w	.Pal4-PalCyc_PlanetPresent
	dc.w	.Pal3-PalCyc_PlanetPresent
	dc.w	.Pal2-PalCyc_PlanetPresent
	dc.w	.Pal1-PalCyc_PlanetPresent
	
.Pal0:
	dc.w	0, $EE0, $EE, $E02, $68, $AC, $E0, $80, $2E, $28, $EEE, $EAC, $A48, $626, $A2E, $22

.Pal1:
	dc.w	0, $CE0, $EE, $C02, $68, $AC, $E0, $80, $2E, $28, $CEE, $CAC, $848, $426, $82E, $22

.Pal2:
	dc.w	0, $CC0, $CE, $C02, $48, $8C, $C0, $60, $E, 8, $CCE, $C8C, $828, $406, $80E, 2

.Pal3:
	dc.w	0, $CA0, $AE, $C02, $28, $6C, $A0, $40, $E, 8, $CAE, $C6C, $808, $406, $80E, 2

.Pal4:
	dc.w	0, $AA0, $AE, $A02, $28, $6C, $A0, $40, $E, 8, $AAE, $A6C, $608, $206, $60E, 2

.Pal5:
	dc.w	0, $A80, $8C, $A00, 6, $4A, $80, $20, $C, 6, $A8C, $A4A, $606, $204, $60C, 0

.Pal6:
	dc.w	0, $860, $6C, $800, 6, $2A, $60, 0, $C, 6, $86C, $82A, $406, 4, $40C, 0

.Pal7:
	dc.w	0, $640, $4C, $600, 6, $A, $40, 0, $C, 6, $64C, $60A, $206, 4, $20C, 0

.Pal8:
	dc.w	0, $640, $4A, $600, 4, 8, $40, 0, $A, 4, $64A, $608, $204, 2, $20A, 0

.Pal9:
	dc.w	0, $640, $48, $600, 2, 6, $40, 0, 8, 2, $648, $606, $202, 0, $208, 0

.Pal10:
	dc.w	0, $640, $46, $600, 0, 4, $40, 0, 6, 0, $646, $604, $200, 0, $206, 0

.Pal11:
	dc.w	0, $660, $66, $600, 0, $224, $440, $200, $206, 0, $826, $604, $200, 0, $406, 0

.Pal12:
	dc.w	0, $680, $84, $400, $220, $244, $640, $420, $406, 0, $A26, $804, $200, 0, $606, 0

.Pal13:
	dc.w	0, $6A0, $84, $400, $40, $264, $860, $620, $406, $200, $C06, $804, $200, 0, $806, 0

.Pal14:
	dc.w	0, $6C0, $A4, $400, $40, $284, $A60, $820, $606, $200, $E06, $A04, $200, 0, $A06, 0

.Pal15:
	dc.w	0, $6C0, $A4, $400, $40, $284, $C60, $820, $606, $200, $E08, $A04, $400, $200, $C06, 0

.Pal16:
	dc.w	0, $6E0, $A4, $400, $40, $2A4, $E60, $840, $606, $200, $E08, $A04, $400, $200, $C06, 0

; -------------------------------------------------------------------------

PalCyc_PlanetGoodFut:
	dc.w	.Pal0-PalCyc_PlanetGoodFut
	dc.w	.Pal1-PalCyc_PlanetGoodFut
	dc.w	.Pal2-PalCyc_PlanetGoodFut
	dc.w	.Pal3-PalCyc_PlanetGoodFut
	dc.w	.Pal4-PalCyc_PlanetGoodFut
	dc.w	.Pal5-PalCyc_PlanetGoodFut
	dc.w	.Pal6-PalCyc_PlanetGoodFut
	dc.w	.Pal7-PalCyc_PlanetGoodFut
	dc.w	.Pal8-PalCyc_PlanetGoodFut
	dc.w	.Pal9-PalCyc_PlanetGoodFut
	dc.w	.Pal10-PalCyc_PlanetGoodFut
	dc.w	.Pal11-PalCyc_PlanetGoodFut
	dc.w	.Pal12-PalCyc_PlanetGoodFut
	dc.w	.Pal13-PalCyc_PlanetGoodFut
	dc.w	.Pal14-PalCyc_PlanetGoodFut
	dc.w	.Pal15-PalCyc_PlanetGoodFut
	dc.w	.Pal16-PalCyc_PlanetGoodFut
	dc.w	.Pal15-PalCyc_PlanetGoodFut
	dc.w	.Pal14-PalCyc_PlanetGoodFut
	dc.w	.Pal13-PalCyc_PlanetGoodFut
	dc.w	.Pal12-PalCyc_PlanetGoodFut
	dc.w	.Pal11-PalCyc_PlanetGoodFut
	dc.w	.Pal10-PalCyc_PlanetGoodFut
	dc.w	.Pal9-PalCyc_PlanetGoodFut
	dc.w	.Pal8-PalCyc_PlanetGoodFut
	dc.w	.Pal7-PalCyc_PlanetGoodFut
	dc.w	.Pal6-PalCyc_PlanetGoodFut
	dc.w	.Pal5-PalCyc_PlanetGoodFut
	dc.w	.Pal4-PalCyc_PlanetGoodFut
	dc.w	.Pal3-PalCyc_PlanetGoodFut
	dc.w	.Pal2-PalCyc_PlanetGoodFut
	dc.w	.Pal1-PalCyc_PlanetGoodFut
	
.Pal0:
	dc.w	0, $EE0, $EE, $C00, $684, $4CA, $EA, $C0, $6AE, $46C, $EEE, $EEA, $EA6, $E44, $E28, $422

.Pal1:
	dc.w	0, $CE0, $EE, $C00, $664, $4AA, $CA, $A0, $68E, $44C, $ECE, $ECA, $E86, $E24, $E08, $402

.Pal2:
	dc.w	0, $CC0, $EE, $C00, $644, $48A, $AA, $80, $66E, $42C, $EAE, $EAA, $E66, $E04, $E08, $402

.Pal3:
	dc.w	0, $CA0, $EE, $C00, $624, $46A, $8A, $60, $64E, $40C, $E8E, $E8A, $E46, $E04, $E08, $402

.Pal4:
	dc.w	0, $AA0, $EE, $A00, $606, $44A, $6A, $40, $62E, $40A, $E6E, $E6A, $E26, $E04, $E08, $402

.Pal5:
	dc.w	0, $A80, $EE, $600, $406, $22A, $6A, $40, $42E, $20A, $C4E, $C4A, $C06, $C04, $C08, $202

.Pal6:
	dc.w	0, $860, $EE, $400, $206, $2A, $4A, $40, $22C, 8, $A2E, $A2A, $A06, $A04, $A08, 2

.Pal7:
	dc.w	0, $640, $EE, $200, 6, $28, $2A, $40, $2C, 6, $80E, $80A, $806, $804, $A08, 2

.Pal8:
	dc.w	0, $640, $EE, $200, 6, $28, $48, $40, $2A, 6, $60E, $60A, $606, $604, $808, 2

.Pal9:
	dc.w	0, $640, $EE, $200, $22, $26, $46, $40, $28, 4, $60C, $608, $604, $602, $608, 0

.Pal10:
	dc.w	0, $640, $EE, $200, $22, $24, $64, $40, $26, 2, $828, $824, $622, $402, $606, 0

.Pal11:
	dc.w	0, $660, $EE, $200, $22, $24, $64, $40, $26, 2, $846, $842, $620, $402, $404, 0

.Pal12:
	dc.w	0, $680, $EE, $200, $20, $24, $62, $20, $26, 2, $864, $840, $620, $400, $404, 0

.Pal13:
	dc.w	0, $6A0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $402, 0

.Pal14:
	dc.w	0, $6C0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

.Pal15:
	dc.w	0, $6C0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

.Pal16:
	dc.w	0, $6E0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

; -------------------------------------------------------------------------

PalCyc_PlanetBadFut:
	dc.w	.Pal0-PalCyc_PlanetBadFut
	dc.w	.Pal1-PalCyc_PlanetBadFut
	dc.w	.Pal2-PalCyc_PlanetBadFut
	dc.w	.Pal3-PalCyc_PlanetBadFut
	dc.w	.Pal4-PalCyc_PlanetBadFut
	dc.w	.Pal5-PalCyc_PlanetBadFut
	dc.w	.Pal6-PalCyc_PlanetBadFut
	dc.w	.Pal7-PalCyc_PlanetBadFut
	dc.w	.Pal8-PalCyc_PlanetBadFut
	dc.w	.Pal9-PalCyc_PlanetBadFut
	dc.w	.Pal10-PalCyc_PlanetBadFut
	dc.w	.Pal11-PalCyc_PlanetBadFut
	dc.w	.Pal12-PalCyc_PlanetBadFut
	dc.w	.Pal13-PalCyc_PlanetBadFut
	dc.w	.Pal14-PalCyc_PlanetBadFut
	dc.w	.Pal15-PalCyc_PlanetBadFut
	dc.w	.Pal16-PalCyc_PlanetBadFut
	dc.w	.Pal15-PalCyc_PlanetBadFut
	dc.w	.Pal14-PalCyc_PlanetBadFut
	dc.w	.Pal13-PalCyc_PlanetBadFut
	dc.w	.Pal12-PalCyc_PlanetBadFut
	dc.w	.Pal11-PalCyc_PlanetBadFut
	dc.w	.Pal10-PalCyc_PlanetBadFut
	dc.w	.Pal9-PalCyc_PlanetBadFut
	dc.w	.Pal8-PalCyc_PlanetBadFut
	dc.w	.Pal7-PalCyc_PlanetBadFut
	dc.w	.Pal6-PalCyc_PlanetBadFut
	dc.w	.Pal5-PalCyc_PlanetBadFut
	dc.w	.Pal4-PalCyc_PlanetBadFut
	dc.w	.Pal3-PalCyc_PlanetBadFut
	dc.w	.Pal2-PalCyc_PlanetBadFut
	dc.w	.Pal1-PalCyc_PlanetBadFut
	
.Pal0:
	dc.w	0, $4AA, $288, $244, $426, $44A, $62C, $606, $A86, $662, $8AA, $686, $446, $424, $46A, $220

.Pal1:
	dc.w	0, $2AA, $88, $44, $226, $24A, $42C, $406, $886, $462, $6AA, $486, $246, $224, $26A, $20

.Pal2:
	dc.w	0, $28A, $268, $24, $206, $22A, $40C, $406, $866, $442, $68A, $466, $226, $204, $24A, 0

.Pal3:
	dc.w	0, $8A, $68, $24, 6, $2A, $20C, $206, $666, $242, $48A, $266, $26, 4, $4A, 0

.Pal4:
	dc.w	0, $8A, $66, $204, 6, $2A, $20C, $206, $646, $222, $46A, $246, 6, 4, $4A, 0

.Pal5:
	dc.w	0, $88, $64, $204, 6, $26, $C, 6, $626, $22, $44A, $226, 6, 4, $4A, 0

.Pal6:
	dc.w	0, $88, $64, $202, 4, $24, $A, 6, $426, $22, $448, $206, 4, 2, $4A, 0

.Pal7:
	dc.w	0, $88, $64, $202, 2, $22, 8, 4, $424, $22, $428, $204, 2, 0, $4A, 0

.Pal8:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $424, $22, $408, $204, 2, 0, $4A, 0

.Pal9:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $404, $22, $406, $204, 2, 0, $4A, 0

.Pal10:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $402, $22, $404, $204, 2, 0, $4A, 0

.Pal11:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $204, 2, 0, $4A, 0

.Pal12:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $202, 2, 0, $4A, 0

.Pal13:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $202, 2, 0, $4A, 0

.Pal14:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

.Pal15:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

.Pal16:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

; -------------------------------------------------------------------------

PalCyc_BgPresentGF:
	dc.w	.Pal0-PalCyc_BgPresentGF
	dc.w	.Pal1-PalCyc_BgPresentGF
	dc.w	.Pal2-PalCyc_BgPresentGF
	dc.w	.Pal3-PalCyc_BgPresentGF
	dc.w	.Pal4-PalCyc_BgPresentGF
	dc.w	.Pal5-PalCyc_BgPresentGF
	dc.w	.Pal6-PalCyc_BgPresentGF
	dc.w	.Pal7-PalCyc_BgPresentGF
	dc.w	.Pal8-PalCyc_BgPresentGF
	dc.w	.Pal9-PalCyc_BgPresentGF
	dc.w	.Pal10-PalCyc_BgPresentGF
	dc.w	.Pal11-PalCyc_BgPresentGF
	dc.w	.Pal12-PalCyc_BgPresentGF
	dc.w	.Pal13-PalCyc_BgPresentGF
	dc.w	.Pal14-PalCyc_BgPresentGF
	dc.w	.Pal15-PalCyc_BgPresentGF
	dc.w	.Pal16-PalCyc_BgPresentGF
	dc.w	.Pal15-PalCyc_BgPresentGF
	dc.w	.Pal14-PalCyc_BgPresentGF
	dc.w	.Pal13-PalCyc_BgPresentGF
	dc.w	.Pal12-PalCyc_BgPresentGF
	dc.w	.Pal11-PalCyc_BgPresentGF
	dc.w	.Pal10-PalCyc_BgPresentGF
	dc.w	.Pal9-PalCyc_BgPresentGF
	dc.w	.Pal8-PalCyc_BgPresentGF
	dc.w	.Pal7-PalCyc_BgPresentGF
	dc.w	.Pal6-PalCyc_BgPresentGF
	dc.w	.Pal5-PalCyc_BgPresentGF
	dc.w	.Pal4-PalCyc_BgPresentGF
	dc.w	.Pal3-PalCyc_BgPresentGF
	dc.w	.Pal2-PalCyc_BgPresentGF
	dc.w	.Pal1-PalCyc_BgPresentGF
	
.Pal0:
	dc.w	0, $E86, $EA8, $ECA, $ECC, $E64, $E64, $E64, $E64, $ECC, $ECC, $ECC, $ECC, $E64, $FFFF, $FFFF

.Pal1:
	dc.w	0, $E66, $E88, $EAA, $EAC, $E44, $E44, $E44, $E44, $EAE, $EAC, $EAC, $EAC, $E44, $FFF, $FFF

.Pal2:
	dc.w	0, $E46, $E68, $E8A, $E8C, $E24, $E24, $E24, $E24, $E8C, $E8C, $E8C, $E8C, $E24, $FFF, $FFF

.Pal3:
	dc.w	0, $E26, $E48, $E6A, $E6C, $E04, $E04, $E04, $E04, $E6C, $E6C, $E6C, $E6C, $E04, $FFF, $FFF

.Pal4:
	dc.w	0, $C26, $C48, $C6A, $C6C, $C04, $C04, $C04, $EA0, $C6C, $C6C, $C6C, $EA0, $C04, $FFF, $FFF

.Pal5:
	dc.w	0, $C06, $C48, $C4A, $C4C, $C04, $C04, $C04, $EA0, $C4C, $C4C, $C4C, $EA0, $C04, $FFF, $FFF

.Pal6:
	dc.w	0, $A06, $A08, $A0A, $A0C, $A04, $A04, $A04, $EA0, $A2C, $A2C, $A2C, $EA0, $A04, $FFF, $FFF

.Pal7:
	dc.w	0, $806, $808, $80A, $80C, $804, $804, $E40, $EA0, $80C, $80C, $E60, $EA0, $804, $FFF, $FFF

.Pal8:
	dc.w	0, $804, $806, $808, $80A, $802, $802, $E40, $EA0, $80A, $80A, $E60, $EA0, $802, $FFF, $FFF

.Pal9:
	dc.w	0, $802, $804, $806, $808, $800, $800, $E40, $EA0, $808, $808, $E60, $EA0, $800, $FFF, $FFF

.Pal10:
	dc.w	0, $800, $802, $804, $806, $800, $E40, $EA0, $EEE, $806, $E60, $EA0, $EEE, $800, $FFF, $FFF

.Pal11:
	dc.w	0, $800, $800, $802, $804, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $800, $FFF, $FFF

.Pal12:
	dc.w	0, $800, $800, $800, $802, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $800, $FFF, $FFF

.Pal13:
	dc.w	0, $600, $600, $600, $600, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $600, $FFF, $FFF

.Pal14:
	dc.w	0, $400, $400, $400, $400, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $400, $FFF, $FFF

.Pal15:
	dc.w	0, $200, $200, $200, $200, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $200, $FFF, $FFF

.Pal16:
	dc.w	0, 0, 0, 0, 0, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, 0, $FFF, $FFF

; -------------------------------------------------------------------------

PalCyc_BgBadFuture:
	dc.w	.Pal0-PalCyc_BgBadFuture
	dc.w	.Pal1-PalCyc_BgBadFuture
	dc.w	.Pal2-PalCyc_BgBadFuture
	dc.w	.Pal3-PalCyc_BgBadFuture
	dc.w	.Pal4-PalCyc_BgBadFuture
	dc.w	.Pal5-PalCyc_BgBadFuture
	dc.w	.Pal6-PalCyc_BgBadFuture
	dc.w	.Pal7-PalCyc_BgBadFuture
	dc.w	.Pal8-PalCyc_BgBadFuture
	dc.w	.Pal9-PalCyc_BgBadFuture
	dc.w	.Pal10-PalCyc_BgBadFuture
	dc.w	.Pal11-PalCyc_BgBadFuture
	dc.w	.Pal12-PalCyc_BgBadFuture
	dc.w	.Pal13-PalCyc_BgBadFuture
	dc.w	.Pal14-PalCyc_BgBadFuture
	dc.w	.Pal15-PalCyc_BgBadFuture
	dc.w	.Pal16-PalCyc_BgBadFuture
	dc.w	.Pal15-PalCyc_BgBadFuture
	dc.w	.Pal14-PalCyc_BgBadFuture
	dc.w	.Pal13-PalCyc_BgBadFuture
	dc.w	.Pal12-PalCyc_BgBadFuture
	dc.w	.Pal11-PalCyc_BgBadFuture
	dc.w	.Pal10-PalCyc_BgBadFuture
	dc.w	.Pal9-PalCyc_BgBadFuture
	dc.w	.Pal8-PalCyc_BgBadFuture
	dc.w	.Pal7-PalCyc_BgBadFuture
	dc.w	.Pal6-PalCyc_BgBadFuture
	dc.w	.Pal5-PalCyc_BgBadFuture
	dc.w	.Pal4-PalCyc_BgBadFuture
	dc.w	.Pal3-PalCyc_BgBadFuture
	dc.w	.Pal2-PalCyc_BgBadFuture
	dc.w	.Pal1-PalCyc_BgBadFuture
	
.Pal0:
	dc.w	0, $AC, $8A, $68, $46, $8A, $8A, $8A, $8A, $46, $46, $46, $46, $8A, $FFF, $FFF

.Pal1:
	dc.w	0, $8C, $6A, $48, $28, $6A, $6A, $6A, $6A, $26, $26, $26, $26, $6A, $FFF, $FFF

.Pal2:
	dc.w	0, $6C, $4A, $28, 6, $4A, $4A, $4A, $4A, 6, 6, 6, 6, $4A, $FFF, $FFF

.Pal3:
	dc.w	0, $4C, $2A, 8, 6, $2A, $2A, $2A, $2A, 6, 6, 6, 6, $2A, $FFF, $FFF

.Pal4:
	dc.w	0, $2C, $A, 8, 6, $A, $A, $A, $A, 6, 6, 6, 6, $A, $FFF, $FFF

.Pal5:
	dc.w	0, $C, $A, 8, 6, $A, $A, $A, $A, 6, 6, 6, 6, $A, $FFF, $FFF

.Pal6:
	dc.w	0, $A, 8, 6, 4, 8, 8, 8, 8, 4, 4, 4, 4, 8, $FFF, $FFF

.Pal7:
	dc.w	0, 8, 6, 4, 2, 6, 6, 6, 6, 2, 2, 2, 2, 6, $FFF, $FFF

.Pal8:
	dc.w	0, 6, 4, 2, 0, 4, 4, 4, 4, 0, 0, 0, 0, 4, $FFF, $FFF

.Pal9:
	dc.w	0, 6, 4, 2, 0, 4, 4, 4, $C, 0, 0, 0, 0, 4, $FFF, $FFF

.Pal10:
	dc.w	0, 6, 4, 2, 0, 4, 4, 8, $E, 0, 0, 0, $C, 4, $FFF, $FFF

.Pal11:
	dc.w	0, 6, 4, 2, 0, 4, 4, 8, $E, 0, 0, 4, $C, 2, $FFF, $FFF

.Pal12:
	dc.w	0, 4, 2, 0, 0, 4, 6, $A, $6E, 0, 4, 6, $2E, 0, $FFF, $FFF

.Pal13:
	dc.w	0, 2, 2, 0, 0, 4, 6, $A, $E, 4, 6, $A, $8E, 0, $FFF, $FFF

.Pal14:
	dc.w	0, 2, 0, 0, 0, 4, 6, $E, $AE, 4, 6, $E, $AE, 0, $FFF, $FFF

.Pal15:
	dc.w	0, 2, 0, 0, 0, 4, 6, $E, $EE, 4, 6, $E, $EE, 0, $FFF, $FFF

.Pal16:
	dc.w	0, 2, 0, 0, 0, 6, 8, $4E, $EE, 6, 8, $4E, $EE, 0, $FFF, $FFF

; -------------------------------------------------------------------------

PalCycleTimes:
	dc.w	780
	dc.w	4
	dc.w	6
	dc.w	8
	dc.w	120
	dc.w	6
	dc.w	8
	dc.w	130
	dc.w	6
	dc.w	8
	dc.w	140
	dc.w	6
	dc.w	8
	dc.w	150
	dc.w	6
	dc.w	8
	dc.w	780
	dc.w	4
	dc.w	6
	dc.w	8
	dc.w	120
	dc.w	6
	dc.w	8
	dc.w	130
	dc.w	6
	dc.w	8
	dc.w	140
	dc.w	6
	dc.w	8
	dc.w	150
	dc.w	6
	dc.w	8

; -------------------------------------------------------------------------
