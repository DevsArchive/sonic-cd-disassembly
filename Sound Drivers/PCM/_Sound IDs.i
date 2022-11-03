; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM sound IDs
; -------------------------------------------------------------------------

; PCM music
	rsset	$81
PCMM_START	rs.b	0			; Starting ID
PCMM_PAST	rs.b	1			; Past music
		rs.b	$E
PCMM_END	EQU	__rs-1			; Ending ID

; PCM sound effects
	rsset	$B0
PCMS_START	rs.b	0			; Starting ID
PCMS_MUSLOOP	rs.b	1			; Music loop (unused)
PCMS_FUTURE	rs.b	1			; "Future"
PCMS_PAST	rs.b	1			; "Past"
PCMS_ALRIGHT	rs.b	1			; "Alright"
PCMS_GIVEUP	rs.b	1			; "I'm outta here"
PCMS_YES	rs.b	1			; "Yes"
PCMS_YEAH	rs.b	1			; "Yeah"
PCMS_GIGGLE	rs.b	1			; Amy giggle
PCMS_AMYYELP	rs.b	1			; Amy yelp
PCMS_STOMP	rs.b	1			; Mech stomp
PCMS_BUMPER	rs.b	1			; Bumper
PCMS_BREAK	rs.b	1			; Glass break
		rs.b	4
PCMS_END	EQU	__rs-1			; Ending ID

; PCM commands
	rsset	$E0
PCMC_START	rs.b	0			; Starting ID
PCMC_FADEOUT	rs.b	1			; Fade out
PCMC_STOP	rs.b	1			; Stop
PCMC_PAUSE	rs.b	1			; Pause
PCMC_UNPAUSE	rs.b	1			; Unpause
PCMC_MUTE	rs.b	1			; Mute
PCMC_END	EQU	__rs-1			; Ending ID

; -------------------------------------------------------------------------