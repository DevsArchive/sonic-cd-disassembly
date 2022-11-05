; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Act 1 Present object index
; -------------------------------------------------------------------------

ObjectIndex:
	dc.l	ObjSonic			; 01 - Sonic
	dc.l	ObjSonic			; 02 - Player 2 Sonic
	dc.l	ObjPowerup			; 03 - Power up
	dc.l	ObjLauncher			; 04 - Launcher
	dc.l	ObjFreezer			; 05 - Freezer
	dc.l	ObjTestBadnik			; 06 - Test badnik
	dc.l	ObjTunnelPath			; 07 - Tunnel path
	dc.l	ObjGoddessStatue		; 08 - Goddess statue
	dc.l	ObjNull				; 09 - Blank
	dc.l	ObjSpring			; 0A - Spring
	dc.l	ObjTunnelDoorSplash		; 0B - Spin tunnel door water splash
	dc.l	ObjTunnelDoorSplashSet		; 0C - Spin tunnel door water splash setup (scrapped)
	dc.l	ObjTunnelDoor			; 0D - Spin tunnel door
	dc.l	ObjSpinSplash			; 0E - Spin tunnel water splash
	dc.l	ObjMovingSpring			; 0F - Moving spring
	dc.l	ObjRing				; 10 - Ring
	dc.l	ObjLostRing			; 11 - Lost ring
	dc.l	ObjNull				; 12 - Blank
	dc.l	ObjCheckpoint			; 13 - Checkpoint
	dc.l	ObjBigRing			; 14 - Big ring
	dc.l	ObjCapsule			; 15 - Flower capsule
	dc.l	ObjGoalPost			; 16 - Goal post
	dc.l	ObjSignpost			; 17 - Signpost
	dc.l	ObjExplosion			; 18 - Explosion
	dc.l	ObjMonitorTimePost		; 19 - Monitor/Time post
	dc.l	ObjMonitorItem			; 1A - Monitor item
	dc.l	ObjBoulder			; 1B - Boulder
	dc.l	ObjHUDPoints			; 1C - HUD/Points
	dc.l	ObjNull				; 1D - Blank
	dc.l	ObjSpinTunnel			; 1E - Spin tunnel tag
	dc.l	ObjFlower			; 1F - Flower
	dc.l	ObjPiston			; 20 - Piston
	dc.l	ObjElectricBeams		; 21 - Electric beams
	dc.l	ObjPlatform			; 22 - Platform
	dc.l	ObjBouncePlatform		; 23 - Bouncing platform
	dc.l	ObjSwitch			; 24 - Switch
	dc.l	ObjDoor				; 25 - Door
	dc.l	ObjNull				; 26 - Blank
	dc.l	ObjTubeDoor			; 27 - Tube door
	dc.l	ObjSpinPlatform			; 28 - Spinning platform
	dc.l	ObjAnimal			; 29 - Animal
	dc.l	ObjSnakeBlocks			; 2A - Snake blocks
	dc.l	ObjEggmanStatue			; 2B - Eggman statue
	dc.l	ObjSeesaw			; 2C - Seesaw
	dc.l	ObjNull				; 2D - Blank
	dc.l	ObjRobotGenerator		; 2E - Robot generator
	dc.l	ObjProjector			; 2F - Metal Sonic holographic projector
	dc.l	ObjBataPyon			; 30 - Bata-pyon
	dc.l	ObjPohBee			; 31 - Poh-Bee
	dc.l	ObjSemi				; 32 - Semi
	dc.l	ObjMinomusi			; 33 - Minomusi
	dc.l	ObjNull				; 34 - Blank
	dc.l	ObjNull				; 35 - Blank
	dc.l	ObjNull				; 36 - Blank
	dc.l	ObjNull				; 37 - Blank
	dc.l	ObjNull				; 38 - Blank
	dc.l	ObjNull				; 39 - Blank
	dc.l	ObjResults			; 3A - End of level results
	dc.l	ObjGameOver			; 3B - Game over text
	dc.l	ObjTitleCard			; 3C - Title card

; -------------------------------------------------------------------------
; Null object
; -------------------------------------------------------------------------

ObjNull:
	move.b	#0,(a0)
	rts

; -------------------------------------------------------------------------
