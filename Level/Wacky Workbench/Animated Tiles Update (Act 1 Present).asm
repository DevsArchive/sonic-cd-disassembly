; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Present animated tiles update
; -------------------------------------------------------------------------

UpdateAnimTiles:
	jsr	LoadShieldArt

	lea	aniArtTimers.w,a2
	lea	aniArtFrames.w,a4

	lea	AniArt_ElectricSparks,a1
	move.w	#$100/4-1,d6
	bsr.w	AnimateTilesSimple
	bne.s	.AniSparkOrb
	LVLDMA	aniArtBuffer,$4440,$100,VRAM
	
.AniSparkOrb:
	lea	AniArt_ElecSparkOrb,a1
	move.w	#$80/4-1,d6
	bsr.w	AnimateTilesSimple
	bne.s	.AniSiren
	LVLDMA	aniArtBuffer,$43C0,$80,VRAM
	
.AniSiren:
	lea	AniArt_Siren,a1
	move.w	#$80/4-1,d6
	bsr.w	AnimateTilesScript
	bne.s	.End
	LVLDMA	aniArtBuffer,$4340,$80,VRAM
	
.End:
	rts

; -------------------------------------------------------------------------

	include	"Level/Animate Tiles (Scripted).asm"

; -------------------------------------------------------------------------

AniArt_Siren:
	dc.b	4, 0
	dc.b	4, 0
	dc.b	9, 1
	dc.b	4, 2
	dc.b	$F, 3
	dc.l	Art_Siren
	dc.l	Art_Siren+$80
	dc.l	Art_Siren+$100
	dc.l	Art_Siren+$180

; -------------------------------------------------------------------------

	include	"Level/Animate Tiles (Simple).asm"

; -------------------------------------------------------------------------

AniArt_ElectricSparks:
	dc.b	4, 3
	dc.l	Art_ElectricSparks
	dc.l	Art_ElectricSparks+$100
	dc.l	Art_ElectricSparks+$200

AniArt_ElecSparkOrb:
	dc.b	3, 2
	dc.l	Art_ElecSparkOrb
	dc.l	Art_ElecSparkOrb+$80

; -------------------------------------------------------------------------
