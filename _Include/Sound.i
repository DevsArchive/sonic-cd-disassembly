; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sound definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; FM driver (Z80)
	if def(MAINCPU)
FMDrvQueue1	EQU	Z80RAM+$1C09		; Sound queue 1
FMDrvQueue2	EQU	Z80RAM+$1C0A		; Sound queue 2
FMDrvQueue3	EQU	Z80RAM+$1C0B		; Sound queue 3
	endif

; PCM driver (Sub CPU)
	if def(SUBCPU)
		include	"Sound Drivers/SMPS-PCM/_Variables.i"
PCMDriver	EQU	PRGRAM+$40000		; PCM driver location
PCMDrvOrigin	EQU	PCMDriver+$10		; PCM driver code origin
PCMDrvRun	EQU	PCMDriver+$10		; Run PCM driver
PCMDrvQueue	EQU	PCMDriver+$18+pdrvQueue	; PCM sound queue
	endif

; -------------------------------------------------------------------------
; IDs
; -------------------------------------------------------------------------

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

; FM
	rsset	$90
FM_SKID		rs.b	1			; Skid
FM_91		rs.b	1
FM_JUMP		rs.b	1			; Jump
FM_HURT		rs.b	1			; Hurt
FM_RINGLOSS	rs.b	1			; Ring loss
FM_RING		rs.b	1			; Ring
FM_DESTROY	rs.b	1			; Destroy
FM_SHIELD	rs.b	1			; Shield
FM_SPRING	rs.b	1			; Spring
FM_99		rs.b	1
FM_KACHING	rs.b	1
FM_9B		rs.b	1
FM_9C		rs.b	1
FM_SIGNPOST	rs.b	1
FM_9E		rs.b	1
FM_9F		rs.b	1
FM_A0		rs.b	1
FM_A1		rs.b	1
FM_A2		rs.b	1
FM_A3		rs.b	1
FM_A4		rs.b	1
FM_A5		rs.b	1
FM_A6		rs.b	1
FM_A7		rs.b	1
FM_RINGL	rs.b	1			; Ring (left channel)
FM_A9		rs.b	1
FM_AA		rs.b	1
FM_AB		rs.b	1
FM_AC		rs.b	1
FM_AD		rs.b	1
FM_CHECKPOINT	rs.b	1			; Checkpoint
FM_AF		rs.b	1
FM_B0		rs.b	1
FM_B1		rs.b	1
FM_B2		rs.b	1
FM_B3		rs.b	1
FM_B4		rs.b	1
FM_B5		rs.b	1
FM_B6		rs.b	1
FM_B7		rs.b	1
FM_B8		rs.b	1
FM_B9		rs.b	1
FM_BA		rs.b	1
FM_BB		rs.b	1
FM_BC		rs.b	1
FM_BD		rs.b	1
FM_BE		rs.b	1
FM_BF		rs.b	1
FM_C0		rs.b	1
FM_C1		rs.b	1
FM_C2		rs.b	1
FM_C3		rs.b	1
FM_C4		rs.b	1
FM_C5		rs.b	1
FM_C6		rs.b	1
FM_C7		rs.b	1
FM_SSWARP	rs.b	1			; Special stage warp
FM_C9		rs.b	1
FM_CA		rs.b	1
FM_CB		rs.b	1
FM_CC		rs.b	1
FM_CD		rs.b	1
FM_CE		rs.b	1
FM_CF		rs.b	1
FM_D0		rs.b	1
FM_D1		rs.b	1
FM_D2		rs.b	1
FM_D3		rs.b	1
FM_D4		rs.b	1
FM_D5		rs.b	1
FM_D6		rs.b	1
FM_D7		rs.b	1
FM_D8		rs.b	1
FM_D9		rs.b	1
FM_DA		rs.b	1
FM_DB		rs.b	1
FM_DC		rs.b	1
FM_DD		rs.b	1
FM_DE		rs.b	1
FM_DF		rs.b	1	

; FM commands
	rsset	$E0
FMC_STOP	rs.b	1			; Stop

; -------------------------------------------------------------------------
