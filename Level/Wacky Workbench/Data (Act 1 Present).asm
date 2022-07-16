; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Act 1 Present data
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
	dc.b	4
	dc.b	4

; -------------------------------------------------------------------------
; PLC lists
; -------------------------------------------------------------------------

PLCLists:
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Std-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Results-PLCLists
	dc.w	PLC_Std2-PLCLists
	dc.w	PLC_Signpost-PLCLists

PLC_Level:
	dc.w	1
	dc.l	Art_LevelTiles
	dc.w	0
	dc.l	Art_Checkpoint
	dc.w	$D960

PLC_Std:
	dc.w	$E
	dc.l	Art_TitleCard
	dc.w	$6C00
	dc.l	Art_TitleCardText
	dc.w	$7A00
	dc.l	Art_BataPyon
	dc.w	$8700
	dc.l	Art_PohBee
	dc.w	$8AE0
	dc.l	Art_Minomusi
	dc.w	$9100
	dc.l	Art_Semi
	dc.w	$9500
	dc.l	Art_MinomusiBomb
	dc.w	$9900
	dc.l	Art_Animals
	dc.w	$9A00
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

PLC_Std2:
	dc.w	$D
	dc.l	Art_GoalPost
	dc.w	$4580
	dc.l	Art_IceBlock
	dc.w	$5C20
	dc.l	Art_Freezer
	dc.w	$6200
	dc.l	Art_Piston
	dc.w	$6800
	dc.l	Art_ElecOrbPresent
	dc.w	$6B00
	dc.l	Art_PlatformPresent
	dc.w	$6D40
	dc.l	Art_Switch
	dc.w	$7340
	dc.l	Art_Door
	dc.w	$7400
	dc.l	Art_SnakeBlock
	dc.w	$7500
	dc.l	Art_Seesaw
	dc.w	$7700
	dc.l	Art_BouncePlatform
	dc.w	$7D00
	dc.l	Art_Launcher
	dc.w	$8000
	dc.l	Art_TubeDoor
	dc.w	$8200
	dc.l	Art_RobotGenWithered
	dc.w	$9D00

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

	if REGION=USA
	incbin	"Level/Wacky Workbench/Data/Padding/1 (Act 1 Present, U).bin"
	else
	incbin	"Level/Wacky Workbench/Data/Padding/1 (Act 1 Present, JE).bin"
	endif

; -------------------------------------------------------------------------

LevelChunks:
	incbin	"Level/Wacky Workbench/Data/Chunks (Act 1 Present).bin"

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $20000"
; -------------------------------------------------------------------------

	incbin	"Level/Wacky Workbench/Data/Padding/2 (Act 1 Present).bin"

; -------------------------------------------------------------------------

Art_Sonic:
	incbin	"Level/Wacky Workbench/Objects/Sonic/Data/Art.bin"
	even
MapSpr_Sonic:
	include	"Level/Wacky Workbench/Objects/Sonic/Data/Mappings.asm"
	even
DPLC_Sonic:
	include	"Level/Wacky Workbench/Objects/Sonic/Data/DPLCs.asm"
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
Ani_Flower:
	include	"Level/Wacky Workbench/Objects/Flower/Data/Animations.asm"
	even
MapSpr_Flower:
	include	"Level/Wacky Workbench/Objects/Flower/Data/Mappings.asm"
	even
Art_Flower:
	incbin	"Level/Wacky Workbench/Objects/Flower/Data/Art.nem"
	even
Art_TitleCardText:
	incbin	"Level/Wacky Workbench/Objects/Title Card/Art.nem"
	even
Art_ElecSparkOrb:
	incbin	"Level/Wacky Workbench/Data/Animated Tiles (Electric Spark Orb).bin"
	even
Art_ElectricSparks:
	incbin	"Level/Wacky Workbench/Data/Animated Tiles (Electric Sparks).bin"
	even
Art_Siren:
	incbin	"Level/Wacky Workbench/Data/Animated Tiles (Siren).bin"
	even
Art_Launcher:
	incbin	"Level/Wacky Workbench/Objects/Launcher/Data/Art.nem"
	even
Art_Freezer:
	incbin	"Level/Wacky Workbench/Objects/Freezer/Data/Art (Freezer).nem"
	even
Art_IceBlock:
	incbin	"Level/Wacky Workbench/Objects/Freezer/Data/Art (Ice Block).nem"
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
	incbin	"Level/Wacky Workbench/Data/Collision (Act 1 Present).bin"
	even

; -------------------------------------------------------------------------
; Level layout
; -------------------------------------------------------------------------

LevelLayouts:
	dc.w	.FG-LevelLayouts,    .BG-LevelLayouts,    .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts,   .Null3-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts,   .Null3-LevelLayouts, .Null3-LevelLayouts
	dc.w	.Null4-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts
	dc.w	.FG-LevelLayouts,    .BG-LevelLayouts,    .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts,   .Null3-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts,   .Null3-LevelLayouts, .Null3-LevelLayouts
	dc.w	.Null4-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts
	dc.w	.FG-LevelLayouts,    .BG-LevelLayouts,    .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts,   .Null3-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts,   .Null3-LevelLayouts, .Null3-LevelLayouts
	dc.w	.Null4-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts

.FG:
	incbin	"Level/Wacky Workbench/Data/Foreground (Act 1 Present).bin"
	even
.BG:
	incbin	"Level/Wacky Workbench/Data/Background (Act 1 Present).bin"
	even
.Null:
	dc.b	0, 0, 0, 0
.FG2:
	incbin	"Level/_Data/Unused/Unknown Layout 1.bin"
	even
.Null2:
	dc.b	0, 0, 0, 0
.FG3:
	incbin	"Level/_Data/Unused/Unknown Layout 2.bin"
	even
.Null3:
	dc.b	0, 0, 0, 0
.Null4:
	dc.b	0, 0, 0, 0

; -------------------------------------------------------------------------

LevelBlocks:
	incbin	"Level/Wacky Workbench/Data/Blocks (Act 1 Present).nem"
	even
Art_LevelTiles:
	incbin	"Level/Wacky Workbench/Data/Tiles (Act 1 Present).nem"
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

	incbin	"Level/_Data/Unused/Unknown Data.bin"
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
Ani_FlowerCapsule:
	include	"Level/_Objects/Level End/Data/Animations (Flower Capsule).asm"
	even
MapSpr_FlowerCapsule:
	include	"Level/_Objects/Level End/Data/Mappings (Flower Capsule).asm"
	even
Art_Piston:
	incbin	"Level/Wacky Workbench/Objects/Piston/Data/Art.nem"
	even
Art_PlatformPresent:
	incbin	"Level/Wacky Workbench/Objects/Platform/Data/Art (Normal, Present).nem"
	even
Art_PlatformPast:
	incbin	"Level/Wacky Workbench/Objects/Platform/Data/Art (Normal, Past).nem"
	even
Art_PlatformFuture:
	incbin	"Level/Wacky Workbench/Objects/Platform/Data/Art (Normal, Future).nem"
	even
Art_BouncePlatform:
	incbin	"Level/Wacky Workbench/Objects/Platform/Data/Art (Bounce).nem"
	even
Art_Switch:
	incbin	"Level/Wacky Workbench/Objects/Switch/Data/Art.nem"
	even
Art_Door:
	incbin	"Level/Wacky Workbench/Objects/Door/Data/Art.nem"
	even
Art_BossDoor:
	incbin	"Level/Wacky Workbench/Objects/Boss/Data/Art (Door).nem"
	even
Art_Crusher:
	incbin	"Level/Wacky Workbench/Objects/Crusher/Data/Art (Normal).nem"
	even
Art_CrusherGoodFuture:
	incbin	"Level/Wacky Workbench/Objects/Crusher/Data/Art (Good Future).nem"
	even
Art_TubeDoor:
	incbin	"Level/Wacky Workbench/Objects/Tube Door/Data/Art.nem"
	even
Art_ElecOrbPresent:
	incbin	"Level/Wacky Workbench/Objects/Electric Beams/Data/Art (Orb, Present).nem"
	even
Art_ElecOrbPast:
	incbin	"Level/Wacky Workbench/Objects/Electric Beams/Data/Art (Orb, Past).nem"
	even
Art_ElecOrbGoodFuture:
	incbin	"Level/Wacky Workbench/Objects/Electric Beams/Data/Art (Orb, Good Future).nem"
	even
Art_ElecOrbBadFuture:
	incbin	"Level/Wacky Workbench/Objects/Electric Beams/Data/Art (Orb, Bad Future).nem"
	even
Art_BataPyon:
	incbin	"Level/Wacky Workbench/Objects/Bata-pyon/Data/Art.nem"
	even
Art_PohBee:
	incbin	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Art.nem"
	even
Art_Minomusi:
	incbin	"Level/Wacky Workbench/Objects/Minomusi/Data/Art.nem"
	even
Art_MinomusiBomb:
	incbin	"Level/Wacky Workbench/Objects/Minomusi/Data/Art (Bomb).nem"
	even
Art_SnakeBlock:
	incbin	"Level/Wacky Workbench/Objects/Snake Blocks/Data/Art.nem"
	even
Art_Semi:
	incbin	"Level/Wacky Workbench/Objects/Semi/Data/Art.nem"
	even
Art_Seesaw:
	incbin	"Level/Wacky Workbench/Objects/Seesaw/Data/Art.nem"
	even
Art_EggmanStatue:
	incbin	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Art.nem"
	even
Art_SpikeBall:
	incbin	"Level/Wacky Workbench/Objects/Spike Ball/Data/Art.nem"
	even
Art_Animals:
	incbin	"Level/Wacky Workbench/Objects/Animal/Data/Art.nem"
	even
Art_ProjAnimals:
	incbin	"Level/Wacky Workbench/Objects/Projector/Data/Art (Animals).nem"
	even
Art_RobotGenWithered:
	incbin	"Level/_Objects/Robot Generator/Data/Art (Withered).nem"
	even
Art_RobotGenerator:
	incbin	"Level/_Objects/Robot Generator/Data/Art.nem"
	even
Art_Projector:
	incbin	"Level/Wacky Workbench/Objects/Projector/Data/Art.nem"
	even

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $40000"
; -------------------------------------------------------------------------

	incbin	"Level/Wacky Workbench/Data/Padding/3 (Act 1 Present).bin"

; -------------------------------------------------------------------------
