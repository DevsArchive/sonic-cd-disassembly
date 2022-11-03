; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Counts
RHY_TRACK_CNT	EQU	1			; Number of rhythm tracks
PCM_TRACK_CNT	EQU	8			; Number of PCM tracks

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
; Track variables structure
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
; Global driver variables structure
; -------------------------------------------------------------------------

	rsreset
pdrvTempo	rs.b	1			; Tempo value
pdrvTempoCnt	rs.b	1			; Tempo counter
pdrvOn		rs.b	1			; Channels on/off array
pdrvSFXPrio	rs.b	1			; Saved SFX priority level
pdrvCommFlag	rs.b	1			; Communication flag
pdrvCDDALoop	rs.b	1			; CDDA music loop flag
pdrvUnkCounter	rs.b	1			; Unknown counter
		rs.b	2
pdrvSndPlay	rs.b	1			; Sound play queue
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
