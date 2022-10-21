; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present data
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Level data
; -------------------------------------------------------------------------

LevelDataIndex:
	dc.l	$3000000|Art_LevelTiles
	dc.l	$2000000|LevelBlocks
	dc.l	LevelChunks
	dc.b	0
	dc.b	$81

LevelPaletteID:
	dc.b	5
	dc.b	5

; -------------------------------------------------------------------------
; PLC lists
; -------------------------------------------------------------------------

PLCLists:
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Std-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Cam2_Full-PLCLists
	dc.w	PLC_Cam3_Full-PLCLists
	dc.w	PLC_Cam4_Full-PLCLists
	dc.w	PLC_Cam5_Full-PLCLists
	dc.w	PLC_Cam1_Incr-PLCLists
	dc.w	PLC_Cam2_Incr-PLCLists
	dc.w	PLC_Cam3_Incr-PLCLists
	dc.w	PLC_Cam4_Incr-PLCLists
	dc.w	PLC_Cam5_Incr-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Results-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Signpost-PLCLists

PLC_Level:
	dc.w	1
	dc.l	Art_LevelTiles
	dc.w	0
	dc.l	Art_Checkpoint
	dc.w	$D960

PLC_Std:
	dc.w	$D
	dc.l	Art_Spikes
	dc.w	$6400
	dc.l	Art_TunnelDoor
	dc.w	$6500
	dc.l	Art_FloatBlock
	dc.w	$6680
	dc.l	Art_TitleCard
	dc.w	$6C00
	dc.l	Art_TitleCardText
	dc.w	$7A00
	dc.l	Art_DiagonalSpring
	dc.w	$9200
	dc.l	Art_Platform
	dc.w	$97C0
	dc.l	Art_Springs
	dc.w	$A400
	dc.l	Art_HUD
	dc.w	$AD00
	dc.l	Art_MonitorTimePosts
	dc.w	$B500
	dc.l	Art_Explosions
	dc.w	$D000
	dc.l	Art_Points
	dc.w	$D8C0
	dc.l	Art_Flower
	dc.w	$DAE0
	dc.l	Art_Rings
	dc.w	$F5C0

PLC_Cam1_Full:
	dc.w	6
	dc.l	Art_Boulder
	dc.w	$6E80
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_Mosqui
	dc.w	$7400
	dc.l	Art_Anton
	dc.w	$8120
	dc.l	Art_3DPlant
	dc.w	$8480
	dc.l	Art_3DRampBoost
	dc.w	$8820
	dc.l	Art_GoalPost
	dc.w	$9EE0

PLC_Cam2_Full:
	dc.w	5
	dc.l	Art_Boulder
	dc.w	$6E80
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_PataBata
	dc.w	$7600
	dc.l	Art_Anton
	dc.w	$8120
	dc.l	Art_Tamabboh
	dc.w	$8500
	dc.l	Art_GoalPost
	dc.w	$9EE0

PLC_Cam3_Full:
	dc.w	8
	dc.l	Art_Boulder
	dc.w	$6E80
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_SonicHole
	dc.w	$7400
	dc.l	Art_PataBata
	dc.w	$7600
	dc.l	Art_TunnelWaterfall
	dc.w	$7C80
	dc.l	Art_SpinningDisc
	dc.w	$8120
	dc.l	Art_LogShadow
	dc.w	$8300
	dc.l	Art_Tamabboh
	dc.w	$8500
	dc.l	Art_GoalPost
	dc.w	$9EE0

PLC_Cam4_Full:
	dc.w	6
	dc.l	Art_Anton
	dc.w	$6E00
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_Mosqui
	dc.w	$7400
	dc.l	Art_SpinningDisc
	dc.w	$8120
	dc.l	Art_3DPlant
	dc.w	$8480
	dc.l	Art_3DRampBoost
	dc.w	$8820
	dc.l	Art_GoalPost
	dc.w	$9EE0

PLC_Cam5_Full:
	dc.w	4
	dc.l	Art_AmyRose
	dc.w	$6E00
	dc.l	Art_RobotGenWithered
	dc.w	$8120
	dc.l	Art_3DPlant
	dc.w	$8480
	dc.l	Art_3DRampBoost
	dc.w	$8820
	dc.l	Art_GoalPost
	dc.w	$9EE0

PLC_Cam1_Incr:
	dc.w	5
	dc.l	Art_Boulder
	dc.w	$6E80
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_Mosqui
	dc.w	$7400
	dc.l	Art_Anton
	dc.w	$8120
	dc.l	Art_3DPlant
	dc.w	$8480
	dc.l	Art_3DRampBoost
	dc.w	$8820

PLC_Cam2_Incr:
	dc.w	2
	dc.l	Art_PataBata
	dc.w	$7600
	dc.l	Art_Anton
	dc.w	$8120
	dc.l	Art_Tamabboh
	dc.w	$8500

PLC_Cam3_Incr:
	dc.w	6
	dc.l	Art_Boulder
	dc.w	$6E80
	dc.l	Art_SonicHole
	dc.w	$7400
	dc.l	Art_PataBata
	dc.w	$7600
	dc.l	Art_TunnelWaterfall
	dc.w	$7C80
	dc.l	Art_SpinningDisc
	dc.w	$8120
	dc.l	Art_LogShadow
	dc.w	$8300
	dc.l	Art_Tamabboh
	dc.w	$8500

PLC_Cam4_Incr:
	dc.w	5
	dc.l	Art_Anton
	dc.w	$6E00
	dc.l	Art_Animals
	dc.w	$7100
	dc.l	Art_Mosqui
	dc.w	$7400
	dc.l	Art_SpinningDisc
	dc.w	$8120
	dc.l	Art_3DPlant
	dc.w	$8480
	dc.l	Art_3DRampBoost
	dc.w	$8820

PLC_Cam5_Incr:
	dc.w	1
	dc.l	Art_AmyRose
	dc.w	$6E00
	dc.l	Art_RobotGenWithered
	dc.w	$8120

PLC_Results:
	dc.w	0
	dc.l	Art_Results
	dc.w	$7880

PLC_Signpost:
	dc.w	2
	dc.l	Art_Signpost
	dc.w	$8780
	dc.l	Art_BigRing
	dc.w	$9100
	dc.l	Art_BigRingFlash
	dc.w	$7DE0

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $10000"
; -------------------------------------------------------------------------

	if DEMO=0
		if REGION=USA
		incbin	"Level/Palmtree Panic/Data/Padding/1 (Act 1 Present, U).bin"
		else
		incbin	"Level/Palmtree Panic/Data/Padding/1 (Act 1 Present, JE).bin"
		endif
	else
		if REGION=USA
		incbin	"Level/Palmtree Panic/Data/Padding/1 (Act 1 Present Demo, U).bin"
		else
		incbin	"Level/Palmtree Panic/Data/Padding/1 (Act 1 Present Demo, JE).bin"
		endif
	endif

; -------------------------------------------------------------------------

LevelChunks:
	if DEMO=0
		incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present).bin"
		even
	else
		if REGION=USA
		incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present).bin",0,DemoDataRel
		incbin	"Level/Palmtree Panic/Data/Demo (Act 1 Present, U).bin"
		incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present).bin", &
			DemoDataRel+filesize("Level/Palmtree Panic/Data/Demo (Act 1 Present, U).bin")
		else
		incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present Demo, JE).bin",0,DemoDataRel
		incbin	"Level/Palmtree Panic/Data/Demo (Act 1 Present, JE).bin"
		incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present Demo, JE).bin", &
			DemoDataRel+filesize("Level/Palmtree Panic/Data/Demo (Act 1 Present, JE).bin")
		endif
	endif
MapSpr_Sonic:
	include	"Level/_Objects/Sonic/Data/Mappings.asm"
	even
MapSpr_3DRamp:
	include	"Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Booster).asm"
	even
Art_Sonic:
	incbin	"Level/_Objects/Sonic/Data/Art.bin"
	even
DPLC_Sonic:
	include	"Level/_Objects/Sonic/Data/DPLCs.asm"
	even
Art_Points:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Points).nem"
	even
Art_FlowerCapsule:
	incbin	"Level/_Objects/Level End/Data/Art (Flower Capsule).nem"
	even
Art_BigRing:
	incbin	"Level/_Objects/Level End/Data/Art (Big Ring).nem"
	even
Art_GoalPost:
	incbin	"Level/_Objects/Level End/Data/Art (Goal Post).nem"
	even
Art_Signpost:
	incbin	"Level/_Objects/Level End/Data/Art (Signpost).nem"
	even
Art_Results:
	incbin	"Level/_Objects/Results/Data/Art.nem"
	even
Art_TimeOver:
	incbin	"Level/_Objects/Game Over/Data/Art (Time Over).nem"
	even
Art_GameOver:
	incbin	"Level/_Objects/Game Over/Data/Art (Game Over).nem"
	even
Art_TitleCard:
	incbin	"Level/_Objects/Title Card/Data/Art.nem"
	even
Art_Shield:
	incbin	"Level/_Objects/Powerup/Data/Art (Shield).bin"
	even
Art_InvStars:
	incbin	"Level/_Objects/Powerup/Data/Art (Invincibility Stars).bin"
	even
Art_TimeStars:
	incbin	"Level/_Objects/Powerup/Data/Art (Time Warp Stars).bin"
	even
Art_DiagonalSpring:
	incbin	"Level/_Objects/Spring/Data/Art (Diagonal).nem"
	even
Art_Springs:
	incbin	"Level/_Objects/Spring/Data/Art (Normal).nem"
	even
Art_MonitorTimePosts:
	incbin	"Level/_Objects/Monitor and Time Post/Data/Art.nem"
	even
Art_Explosions:
	incbin	"Level/_Objects/Explosion/Data/Art.nem"
	even
Art_Rings:
	incbin	"Level/_Objects/Ring/Data/Art.nem"
	even
Art_LifeIcon:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Life Icon).bin"
	even
Art_HUDNumbers:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Numbers).bin"
	even
Art_HUD:
	incbin	"Level/_Objects/HUD and Points/Data/Art (HUD).nem"
	even
Art_Checkpoint:
	incbin	"Level/_Objects/Checkpoint/Data/Art.Nem"
	even
Art_LogShadowUnused:
	incbin	"Level/Palmtree Panic/Objects/Log Shadow/Data/Art (Withered).nem"
	even
Art_LogShadow:
	incbin	"Level/Palmtree Panic/Objects/Log Shadow/Data/Art.nem"
	even
Ani_Flower:
	include	"Level/Palmtree Panic/Objects/Flower/Data/Animations.asm"
	even
MapSpr_Flower:
	include	"Level/Palmtree Panic/Objects/Flower/Data/Mappings.asm"
	even
Art_Flower:
	incbin	"Level/Palmtree Panic/Objects/Flower/Data/Art.nem"
	even
Art_TitleCardText:
	incbin	"Level/Palmtree Panic/Objects/Title Card/Art.nem"
	even
Art_Platform:
	incbin	"Level/Palmtree Panic/Objects/Platform/Data/Art.nem"
	even
Art_Boulder:
	incbin	"Level/_Objects/Boulder/Data/Art.nem"
	even
Art_FloatBlock:
	incbin	"Level/_Objects/Floating Block/Data/Art.nem"
	even
Art_SpringWheel:
	incbin	"Level/_Objects/Spring/Data/Art (Wheel).nem"
	even
Art_SpinningDisc:
	incbin	"Level/Palmtree Panic/Objects/Spinning Disc/Data/Art.nem"
	even
Art_TunnelWaterfall:
	incbin	"Level/_Objects/Spin Tunnel/Data/Art (Waterfall Splash).nem"
	even
Art_Waterfall:
	incbin	"Level/Palmtree Panic/Objects/Effects/Data/Art (Waterfall).nem"
	even
Art_TunnelDoor:
	incbin	"Level/Palmtree Panic/Objects/Tunnel Door/Data/Art.nem"
	even
Art_TunnelDoorSplash:
	incbin	"Level/_Objects/Spin Tunnel/Data/Art (Door Splash).nem"
	even
Art_Anton:
	incbin	"Level/Palmtree Panic/Objects/Anton/Data/Art.nem"
	even
Art_Mosqui:
	incbin	"Level/Palmtree Panic/Objects/Mosqui/Data/Art.nem"
	even
Art_PataBata:
	incbin	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Art.nem"
	even
Art_TagaTaga:
	incbin	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Art.nem"
	even
Art_Tamabboh:
	incbin	"Level/Palmtree Panic/Objects/Tamabboh/Data/Art.nem"
	even
Art_Springboard:
	incbin	"Level/Palmtree Panic/Objects/Springboard/Data/Art.nem"
	even
Art_Button:
	incbin	"Level/Palmtree Panic/Data/Unused/Art (Button).nem"
	even
Art_Spikes:
	incbin	"Level/_Objects/Spikes/Data/Art.nem"
	even
Art_SwingingPlatform:
	incbin	"Level/Palmtree Panic/Data/Unused/Art (Swinging Platform).nem"
	even
Art_Animals:
	incbin	"Level/Palmtree Panic/Objects/Animal/Data/Art.nem"
	even
Art_SpinningDiscDrill:
	incbin	"Level/Palmtree Panic/Data/Unused/Art (Spinning Disc Drill).nem"
	even
Art_RobotGenWithered:
	incbin	"Level/_Objects/Robot Generator/Data/Art (Withered).nem"
	even

; -------------------------------------------------------------------------
; Collision data
; -------------------------------------------------------------------------

ColAngleMap:
	incbin	"Level/_Data/Collision Angles.bin"
	even
ColHeightMap:
	incbin	"Level/_Data/Collision Height Map.bin"
	even
ColWidthMap:
	incbin	"Level/_Data/Collision Width Map.bin"
	even
LevelCollision:
	incbin	"Level/Palmtree Panic/Data/Collision (Act 1 Present).bin"
	even

; -------------------------------------------------------------------------
; Level layout
; -------------------------------------------------------------------------

LevelLayouts:
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts

.FG:
	incbin	"Level/Palmtree Panic/Data/Foreground (Act 1 Present).bin"
	even
.BG:
	incbin	"Level/Palmtree Panic/Data/Background (Act 1 Present).bin"
	even
.Null:

; -------------------------------------------------------------------------

Art_SonicHole:
	incbin	"Level/Palmtree Panic/Objects/Tunnel Path/Data/Art (Hole).nem"
	even
Art_3DPlant:
	incbin	"Level/Palmtree Panic/Objects/3D Ramp/Data/Art (Plant).nem"
	even
Art_3DRampBoost:
	incbin	"Level/Palmtree Panic/Objects/3D Ramp/Data/Art (Booster).nem"
	even
LevelBlocks:
	incbin	"Level/Palmtree Panic/Data/Blocks (Act 1 Present).nem"
	even
Art_LevelTiles:
	incbin	"Level/Palmtree Panic/Data/Tiles (Act 1 Present).nem"
	even
Ani_Powerup:
	include	"Level/_Objects/Powerup/Data/Animations.asm"
	even
MapSpr_Powerup:
	include	"Level/_Objects/Powerup/Data/Mappings.asm"
	even
Ani_TunnelDoorSplash:
	include	"Level/_Objects/Spin Tunnel/Data/Animations (Door Splash).asm"
	even
MapSpr_TunnelDoorSplash:
	include	"Level/_Objects/Spin Tunnel/Data/Mappings (Door Splash).asm"
	even
Ani_TunnelDoor:
	include	"Level/_Objects/Spin Tunnel/Data/Animations (Door).asm"
	even
MapSpr_TunnelDoor:
	include	"Level/_Objects/Spin Tunnel/Data/Mappings (Door).asm"
	even
Ani_TunnelWaterfall:
	include	"Level/_Objects/Spin Tunnel/Data/Animations (Waterfall Splash).asm"
	even
MapSpr_TunnelWaterfall:
	include	"Level/_Objects/Spin Tunnel/Data/Mappings (Waterfall Splash).asm"
	even
Ani_Explosion:
	include	"Level/_Objects/Explosion/Data/Animations.asm"
	even
MapSpr_Explosion:
	include	"Level/_Objects/Explosion/Data/Mappings.asm"
	even
Ani_Checkpoint:
	include	"Level/_Objects/Checkpoint/Data/Animations.asm"
	even
MapSpr_Checkpoint:
	include	"Level/_Objects/Checkpoint/Data/Mappings.asm"
	even
Ani_BigRing:
	include	"Level/_Objects/Level End/Data/Animations (Big Ring).asm"
	even
MapSpr_BigRing:
	include	"Level/_Objects/Level End/Data/Mappings (Big Ring).asm"
	even
Ani_Signpost:
	include	"Level/_Objects/Level End/Data/Animations (Signpost).asm"
	even
MapSpr_GoalSignpost:
	include	"Level/_Objects/Level End/Data/Mappings (Post).asm"
	even
MapSpr_FlowerCapsule:
;	include	"Level/_Objects/Level End/Data/Mappings (Flower Capsule).asm"
;	even
Ani_FlowerCapsule:
;	include	"Level/_Objects/Level End/Data/Animations (Flower Capsule).asm"
;	even
Art_Projector:
;	incbin	"Level/Palmtree Panic/Objects/Projector/Data/Art.nem"
;	even
Art_AmyRose:
	incbin	"Level/Palmtree Panic/Objects/Amy Rose/Data/Art.nem"
	even
MapSpr_AmyRose:	
	include	"Level/Palmtree Panic/Objects/Amy Rose/Data/Mappings.asm"
	even
Ani_AmyRose:
	include	"Level/Palmtree Panic/Objects/Amy Rose/Data/Animations.asm"
	even

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $40000"
; -------------------------------------------------------------------------

	incbin	"Level/Palmtree Panic/Data/Padding/2 (Act 1 Present).bin"

; -------------------------------------------------------------------------
