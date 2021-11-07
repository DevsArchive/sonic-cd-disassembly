; -------------------------------------------------------------------------------
; Sonic CD Misc. Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------------
; Sound definitions
; -------------------------------------------------------------------------------

; CDDA
	rsset	2
CDDA_WARP	rs.b	1			; Prototype warp
CDDA_R1A	rs.b	1			; Palmtree Panic present
CDDA_R1C	rs.b	1			; Palmtree Panic good future
CDDA_R1D	rs.b	1			; Palmtree Panic bad future
CDDA_R3A	rs.b	1			; Collision Chaos present
CDDA_R3C	rs.b	1			; Collision Chaos good future
CDDA_R3D	rs.b	1			; Collision Chaos bad future
CDDA_R4A	rs.b	1			; Tidal Tempest present
CDDA_R4C	rs.b	1			; Tidal Tempest good future
CDDA_R4D	rs.b	1			; Tidal Tempest bad future
CDDA_R5A	rs.b	1			; Quartz Quadrant present
CDDA_R5C	rs.b	1			; Quartz Quadrant good future
CDDA_R5D	rs.b	1			; Quartz Quadrant bad future
CDDA_R6A	rs.b	1			; Wacky Workbench present
CDDA_R6C	rs.b	1			; Wacky Workbench good future
CDDA_R6D	rs.b	1			; Wacky Workbench bad future
CDDA_R7A	rs.b	1			; Stardust Speedway present
CDDA_R7C	rs.b	1			; Stardust Speedway good future
CDDA_R7D	rs.b	1			; Stardust Speedway bad future
CDDA_R8A	rs.b	1			; Metallic Madness present
CDDA_R8C	rs.b	1			; Metallic Madness good future
CDDA_R8D	rs.b	1			; Metallic Madness bad future
CDDA_BOSS	rs.b	1			; Boss
CDDA_FINAL	rs.b	1			; Final boss
CDDA_TITLE	rs.b	1			; Title screen
CDDA_TMATK	rs.b	1			; Time attack menu
CDDA_LVLEND	rs.b	1			; Level end
CDDA_SHOES	rs.b	1			; Speed shoes
CDDA_INVINC	rs.b	1			; Invincibility
CDDA_GAMEOVER	rs.b	1			; Game over
CDDA_SPECIAL	rs.b	1			; Special stage
CDDA_DAGARDEN	rs.b	1			; D.A. Garden
CDDA_INTRO	rs.b	1			; Opening
CDDA_ENDING	rs.b	1			; Ending

; PCM music
	rsset	$81
PCMM_PAST	rs.b	1			; Past music

; PCM sound effects
	rsset	$B1
PCMS_FUTURE	rs.b	1			; "Future"
PCMS_PAST	rs.b	1			; "Past"
PCMS_ALRIGHT	rs.b	1			; "Alright"
PCMS_GIVEUP	rs.b	1			; "I'm outta here"
PCMS_YES	rs.b	1			; "Yes"
PCMS_YEAH	rs.b	1			; "Yeah"
PCMS_GIGGLE	rs.b	1			; Amy giggle
PCMS_AMYYELP	rs.b	1			; Amy yelp
PCMS_STOMP	rs.b	1			; Boss stomp
PCMS_BUMPER	rs.b	1			; Bumper
PCMS_BREAK	rs.b	1			; Glass breeak

; PCM commands
	rsset	$E0
PCMC_FADEOUT	rs.b	1			; Fade out
PCMC_STOP	rs.b	1			; Stop
PCMC_PAUSE	rs.b	1			; Pause
PCMC_UNPAUSE	rs.b	1			; Unpause
PCMC_MUTE	rs.b	1			; Mute

; -------------------------------------------------------------------------------
