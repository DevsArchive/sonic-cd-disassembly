; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Counds
RHY_TRACK_CNT	EQU	1			; Number of rhythm tracks
PCM_TRACK_CNT	EQU	8			; Number of PCM tracks

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
PCMS_STOMP	rs.b	1			; Boss stomp
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

; Track flags
	rsreset
		rs.b	1
PTRK_REST	rs.b	1			; Rest flag
		rs.b	1
		rs.b	1
PTRK_LEGATO	rs.b	1			; Legato flag
		rs.b	1
		rs.b	1
PTRK_PLAY	rs.b	1			; Play flag

; -------------------------------------------------------------------------
; Track variables
; -------------------------------------------------------------------------

	rsreset
ptrkFlags	rs.b	1			; Flags
ptrkChannel	rs.b	1			; Channel ID
ptrkTickMult	rs.b	1			; Tick multiplier
ptrkPanning	rs.b	1			; Panning
ptrkDataPtr	rs.l	1			; Data address
ptrkTranspose	rs.b	1			; Transposition
ptrkVolume	rs.b	1			; Volume
ptrkStackPtr	rs.b	1			; Call stack pointer
ptrkDurCnt	rs.b	1			; Duration counter
ptrkDuration	rs.b	1			; Duration value
ptrkStacCnt	rs.b	1			; Staccato counter
ptrkStaccato	rs.b	1			; Staccato value
ptrkDetune	rs.b	1			; Detune
ptrkFreq	rs.w	1			; Frequency
ptrkSampleBank	rs.b	1			; Sample RAM bank ID
ptrkSampleBlks	rs.b	1			; Sample stream block counter
ptrkPrevSampPos	rs.w	1			; Previous sample playback position
ptrkSampRAMOff	rs.w	1			; Sample RAM offset
ptrkSampleRAM	rs.l	1			; Sample RAM address
ptrkSampleSize	rs.l	1			; Sample size
ptrkSampRemain	rs.l	1			; Sample bytes remaining
ptrkSamplePtr	rs.l	1			; Sample data address
ptrkSampleStart	rs.l	1			; Sample start address
ptrkSampleLoop	rs.l	1			; Sample loop address
ptrkSampStac	rs.b	1			; Sample staccato value
ptrkSampStacCnt	rs.b	1			; Sample staccato counter
ptrkSampleMode	rs.b	1			; Sample mode
		rs.b	$40-__rs
ptrkCallStack	rs.b	0			; Call stack
ptrkRepeatCnts	rs.b	$40			; Repeat counts
ptrkStackBase	rs.b	0			; Call stack base
ptrkSize	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Global driver variables
; -------------------------------------------------------------------------

	rsreset
pdrvTempo	rs.b	1			; Tempo value
pdrvTempoCnt	rs.b	1			; Tempo counter
pdrvOn		rs.b	1			; Channels on/off array
pdrvSFXPrio	rs.b	1			; Saved SFX priority level
pdrvCommFlag	rs.b	1			; Communication flag
pdrvUnkFlag	rs.b	1			; Unknown flag
		rs.b	3
pdrvSoundID	rs.b	1			; Sound ID
pdrvQueue	rs.b	4			; Sound queue slots
pdrvSFXMode	rs.b	1			; SFX mode
pdrvPauseMode	rs.b	1			; Pause mode
pdrvPtrOffset	rs.l	1			; Pointer offset
pdrvFadeSteps	rs.b	1			; Fade out step count
pdrvFadeSpeed	rs.b	1			; Fade out speed
pdrvFadeDelay	rs.b	1			; Fade out delay value
pdrvFadeCnt	rs.b	1			; Fade out delay counter
pdrvUnkFadeVol	rs.b	1			; Unknown fade out volume
		rs.b	$80-__rs
pdrvRhythm	rs.b	ptrkSize		; Rhythm track (unused)
pdrvPCM1	rs.b	ptrkSize		; Music PCM1 track
pdrvPCM2	rs.b	ptrkSize		; Music PCM2 track
pdrvPCM3	rs.b	ptrkSize		; Music PCM3 track
pdrvPCM4	rs.b	ptrkSize		; Music PCM4 track
pdrvPCM5	rs.b	ptrkSize		; Music PCM5 track
pdrvPCM6	rs.b	ptrkSize		; Music PCM6 track
pdrvPCM7	rs.b	ptrkSize		; Music PCM7 track
pdrvPCM8	rs.b	ptrkSize		; Music PCM8 track
pdrvPCMSFX1	rs.b	ptrkSize		; SFX PCM1 track
pdrvPCMSFX2	rs.b	ptrkSize		; SFX PCM2 track
pdrvPCMSFX3	rs.b	ptrkSize		; SFX PCM3 track
pdrvPCMSFX4	rs.b	ptrkSize		; SFX PCM4 track
pdrvPCMSFX5	rs.b	ptrkSize		; SFX PCM5 track
pdrvPCMSFX6	rs.b	ptrkSize		; SFX PCM6 track
pdrvPCMSFX7	rs.b	ptrkSize		; SFX PCM7 track
pdrvPCMSFX8	rs.b	ptrkSize		; SFX PCM8 track
pdrvSize	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Sample data structure
; -------------------------------------------------------------------------

	rsreset
psmpAddr	rs.l	1			; Sample address
psmpSize	rs.l	1			; Sample size
psmpLoop	rs.l	1			; Sample loop offset
psmpStaccato	rs.b	1			; Sample staccato time
psmpMode	rs.b	1			; Sample mode
psmpDest	rs.w	1			; Sample destination address

; -------------------------------------------------------------------------
