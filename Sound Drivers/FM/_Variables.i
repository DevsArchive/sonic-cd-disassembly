; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS FM sound effect driver variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

TRACK_CNT	EQU	6			; Number of tracks

; Track flags
	phase	0
FTRK_FM3DET:	ds	1			; FM3 detune mode flag
FTRK_LEGATO:	ds	1			; Legato flag
FTRK_SNDOFF:	ds	1			; Sound disable flag
FTRK_RAWFREQ:	ds	1			; Raw frequency mode
FTRK_REST:	ds	1			; Rest flag
FTRK_PORTA:	ds	1			; Portamento flag
FTRK_VIBEND:	ds	1			; Vibrato envelope end flag
FTRK_PLAY:	ds	1			; Play flag
	dephase

; -------------------------------------------------------------------------
; Track variables structure
; -------------------------------------------------------------------------

	phase	0
ftrkFlags:	ds	1			; Flags
ftrkChannel:	ds	1			; Channel ID
ftrkTickMult:	ds	1			; Tick multiplier
ftrkDataPtr:	ds	2			; Data address
ftrkTranspose:	ds	1			; Transposition
ftrkVolume:	ds	1			; Volume
ftrkVibMode:	ds	1			; Vibrato mode
ftrkInstrument:	ds	1			; Instrument ID
ftrkStackPtr:	ds	1			; Call stack pointer
ftrkPanAMSFMS:	ds	1			; Panning/AMS/FMS
ftrkDurCnt:	ds	1			; Duration counter
ftrkDuration:	ds	1			; Duration value
ftrkFreq:	ds	2			; Frequency
		ds	1
ftrkPortaSpeed:	ds	1			; Portamento speed
		ds	6
ftrkEnvCnt:	ds	1			; Envelope counter
ftrkSSGEGMode:	ds	1			; SSG-EG mode
ftrkSSGPtr:	ds	2			; SSG-EG parameter data pointer
ftrkFBAlgo:	ds	1			; FM feedback/algorithm
ftrkTLDataPtr:	ds	2			; FM TL data pointer
ftrkStacCnt:	ds	1			; Staccato counter
ftrkStaccato:	ds	1			; Staccato value
ftrkVibratoPtr:	ds	2			; Vibrato parameter data pointer
ftrkVibFreq:	ds	2			; Vibrato frequency value
ftrkVibDelay:	ds	1			; Vibrato delay counter
ftrkVibSpeed:	ds	1			; Vibrato speed counter
ftrkVibIntens:	ds	1			; Vibrato intensity
ftrkVibDirStep:	ds	1			; Vibrato direction step counter
ftrkRepeatCnts:	ds	2			; Repeat counts
ftrkInsTblPtr:	ds	2			; Instrument table pointer
ftrkStack:	ds	4			; Call stack
ftrkStackBase:	ds	0			; Call stack base
ftrkSize:	ds	0			; Size of structure
	dephase

; -------------------------------------------------------------------------
; Driver variables
; -------------------------------------------------------------------------

	phase	1C00h
Variables:
		ds	9
sndPlay:	ds	1			; Sound play queue
sndQueues:	ds	3			; Sound queue slots
fadeFlag:	ds	1			; Fade flag
		ds	4
ymReg27:	ds	1			; YM register 27
tempoCnt:	ds	1			; Tempo counter
tempo:		ds	1			; Tempo
endFlag:	ds	1			; End flag
commFlag:	ds	1			; Commincation flag
rValue:		ds	1			; R register value
curPriority:	ds	1			; Current sound priority
		ds	1
fm3DetuneOP1:	ds	2			; FM3 OP1 detune value
fm3DetuneOP2:	ds	2			; FM3 OP2 detune value
fm3DetuneOP3:	ds	2			; FM3 OP3 detune value
fm3DetuneOP4:	ds	2			; FM3 OP4 detune value
		ds	10h
channelID:	ds	1			; Channel ID
		ds	6
insTable:	ds	2			; Instrument table
tickMult:	ds	1			; Tick multiplier
		ds	1
ringChannel:	ds	1			; Ring channel
jumpCondition:	ds	1			; Jump condition
		ds	1
fm1Track:	ds	ftrkSize		; FM1 track
fm2Track:	ds	ftrkSize		; FM2 track
fm3Track:	ds	ftrkSize		; FM3 track
fm4Track:	ds	ftrkSize		; FM4 track
fm5Track:	ds	ftrkSize		; FM5 track
fm6Track:	ds	ftrkSize		; FM6 track
VariablesEnd:

		ds	29Dh
stackBase:					; Stack base
	dephase

; -------------------------------------------------------------------------
