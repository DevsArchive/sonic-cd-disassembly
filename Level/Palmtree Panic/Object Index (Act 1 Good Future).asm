; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Good Future object index
; -------------------------------------------------------------------------

ObjectIndex:
	dc.l	ObjSonic			; 01 - Sonic
	dc.l	ObjSonic			; 02 - Player 2 Sonic
	dc.l	ObjPowerup			; 03 - Power up
	dc.l	ObjWaterfall			; 04 - Unused (broken) waterfall generator
	dc.l	ObjEarthquake			; 05 - Earthquake (scrapped)
	dc.l	ObjTestBadnik			; 06 - Test badnik
	dc.l	ObjTunnelPath			; 07 - Tunnel Path
	dc.l	ObjEarthquakeSet		; 08 - Earthquake setup (scrapped)
	dc.l	ObjSpinningDisc			; 09 - Spinning disc
	dc.l	ObjSpring			; 0A - Spring
	dc.l	ObjTunnelDoorSplash		; 0B - Spin tunnel door water splash
	dc.l	ObjTunnelDoorSplashSet		; 0C - Spin tunnel door water splash setup (scrapped)
	dc.l	ObjTunnelDoor			; 0D - Spin tunnel door
	dc.l	ObjSpinSplash			; 0E - Spin tunnel water splash
	dc.l	ObjMovingSpring			; 0F - Moving spring
	dc.l	ObjRing				; 10 - Ring
	dc.l	ObjLostRing			; 11 - Lost ring
	dc.l	ObjFloatBlock			; 12 - Floating block
	dc.l	ObjNull				; 13 - Blank
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
	dc.l	ObjNull				; 1E - Blank (CCZ flipper)
	dc.l	ObjFlower			; 1F - Flower
	dc.l	ObjCollapsePlatform		; 20 - Collaping platform
	dc.l	ObjPlatform			; 21 - Platform
	dc.l	ObjTamabboh			; 22 - Tamabboh badnik/projectiles
	dc.l	ObjMissile			; 23 - Missile (scrapped)
	dc.l	ObjAnimal			; 24 - Animal
	dc.l	ObjNull				; 25 - Blank
	dc.l	ObjSpikes			; 26 - Spikes
	dc.l	ObjNull				; 27 - Blank
	dc.l	ObjSpringBoard			; 28 - Springboard
	dc.l	ObjNull				; 29 - Blank
	dc.l	ObjNull				; 2A - Blank
	dc.l	ObjCheckpoint			; 2B - Checkpoint
	dc.l	ObjNull				; 2C - Blank
	dc.l	ObjRobotGenerator		; 2D - Robot generator
	dc.l	ObjProjector			; 2E - Metal Sonic holographic projector
	dc.l	ObjNull				; 2F - Blank
	dc.l	ObjNull				; 30 - Blank
	dc.l	ObjSonicHole			; 31 - Sonic hole
	dc.l	ObjScenery			; 32 - Scenery
	dc.l	ObjLogShadow			; 33 - Log shadow
	dc.l	ObjSpinTunnel			; 34 - Spin tunnel tag
	dc.l	ObjTunnelDoorV			; 35 - Vertical spin tunnel door
	dc.l	ObjBreakableWall		; 36 - Breakable wall
	dc.l	ObjNull				; 37 - Blank
	dc.l	ObjNull				; 38 - Blank
	dc.l	ObjNull				; 39 - Blank
	dc.l	ObjResults			; 3A - End of level results
	dc.l	ObjGameOver			; 3B - Game over text
	dc.l	ObjTitleCard			; 3C - Title card
	dc.l	ObjMosqui			; 3D - Mosqui badnik
	dc.l	ObjPataBata			; 3E - Pata-Bata badnik
	dc.l	ObjAnton			; 3F - Anton badnik
	dc.l	ObjTagaTaga			; 40 - Taga-Taga badnik

; -------------------------------------------------------------------------
; Null object
; -------------------------------------------------------------------------

ObjNull:
	move.b	#0,(a0)
	rts

; -------------------------------------------------------------------------
