; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS FM sound effect driver
; -------------------------------------------------------------------------

	CPU	68000
	listing	purecode
	
	include	"Sound Drivers/FM/_Compatibility.i"
	include	"Sound Drivers/FM/_Sound IDs.i"
	include	"_smps2asm_inc.i"

	CPU	Z80UNDOC
	dephase
	include	"_Include/Z80.i"
	include	"Sound Drivers/FM/_Variables.i"

; -------------------------------------------------------------------------
; Driver entry point
; -------------------------------------------------------------------------

	org	0

DriverStart:
	di					; Disable interrupts
	di
	im	1				; Interrupt mode 1
	
	jr	InitDriver			; Initialize driver

; -------------------------------------------------------------------------
; Get list from driver info table
; -------------------------------------------------------------------------
; PARAMETERS:
;	c  - Table index
; RETURNS:
;	hl - Pointer to list
; -------------------------------------------------------------------------

	align	8
GetList:
	ld	hl,DriverInfo			; Get pointer to entry
	ld	b,0
	add	hl,bc
	ex	af,af'				; Read pointer
	rst	ReadHLPtr
	ex	af,af'
	ret

; -------------------------------------------------------------------------
; Read pointer from table
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Table index
;	hl - Pointer to table
; -------------------------------------------------------------------------

	align	8
ReadTablePtr:
	ld	c,a				; Get pointer to entry
	ld	b,0
	add	hl,bc
	add	hl,bc

; -------------------------------------------------------------------------
; Read pointer from HL register
; -------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to read
; RETURNS:
;	hl - Read pointer
; -------------------------------------------------------------------------

	align	8
ReadHLPtr:
	ld	a,(hl)				; Read from HL into HL
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret

; -------------------------------------------------------------------------
; Initialize driver
; -------------------------------------------------------------------------

InitDriver:
	ld	sp,stackBase			; Set stack pointer
	
	ld	c,0				; Delay with a 65536x loop

.Delay:
	ld	b,0
	djnz	$
	dec	c
	jr	nz,.Delay
	
	call	StopSound			; Stop all sound

.Loop:
	call	ProcSoundQueue			; Process sound queue
	
	ld	a,(YMADDR0)			; Has timer B run out?
	bit	1,a
	jr	z,.Loop				; If not, wait
	call	ResetTimerB			; Reset timer B
	
	call	UpdateTracks			; Update tracks
	jr	.Loop				; Loop

; -------------------------------------------------------------------------
; Reset timer B
; -------------------------------------------------------------------------

ResetTimerB:
	ld	c,0C8h				; Set timer B frequency
	ld	a,26h
	call	WriteYM1
	
	ld	a,2Fh				; Start timer B up again
	ld	hl,ymReg27
	or	(hl)
	ld	c,a
	ld	a,27h
	call	WriteYM1
	ret

; -------------------------------------------------------------------------
; Update tracks
; -------------------------------------------------------------------------

UpdateTracks:
	call	PlaySoundID			; Check sound ID and play it
	
	ld	ix,fm1Track			; Start on FM1
	ld	b,TRACK_CNT			; Number of tracks

.Update:
	push	bc				; Save counter
	
	bit	FTRK_PLAY,(ix+ftrkFlags)	; Is this track playing?
	call	nz,UpdateTrack			; If so, update it
	
	ld	de,ftrkSize			; Next track
	add	ix,de
	pop	bc				; Loop until all tracks are updated
	djnz	.Update
	ret

; -------------------------------------------------------------------------
; Update track
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

UpdateTrack:
	call	UpdateDuration			; Update note duration
	jr	nz,.Update			; If it hasn't run out, ranch
	
	call	ParseTrackData			; Parse track data
	bit	FTRK_REST,(ix+ftrkFlags)	; Is this track rested?	
	ret	nz				; If so, exit
	
	call	InitVibrato			; Initialize vibrato
	call	UpdatePortamento		; Update portamento
	call	UpdateVibrato			; Update vibrato
	call	UpdateFreq			; Update frequency
	jp	SetKeyOn			; Set key on
	
; ---------------------------------------------------------------------------

.Update:
	bit	FTRK_REST,(ix+ftrkFlags)	; Is this track rested?	
	ret	nz				; If so, exit
	
	ld	a,(ix+ftrkStacCnt)		; Get staccato counter
	or	a
	jr	z,.NoStaccato			; If it's not active, branch
	dec	(ix+ftrkStacCnt)		; Decrement staccato counter
	jp	z,SetKeyOff			; If it has run out, set key off

.NoStaccato:
	call	UpdatePortamento		; Update portamento
	bit	FTRK_VIBEND,(ix+ftrkFlags)	; Has the vibrato envelope ended?
	ret	nz				; If so, branch
	call	UpdateVibrato			; Update vibrato

; -------------------------------------------------------------------------
; Update frequency
; -------------------------------------------------------------------------
; PARAMETERS:
;	hl - Frequency value
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

UpdateFreq:
	bit	FTRK_SNDOFF,(ix+ftrkFlags)	; Is sound disabled?
	ret	nz				; If so, branch
	bit	FTRK_FM3DET,(ix+ftrkFlags)	; Is FM3 detune mode on?
	jp	nz,.CheckFM3			; If so, branch

.NormalFreq:
	ld	a,0A4h				; Write frequency
	ld	c,h
	call	WriteYMTrk
	ld	a,0A0h
	ld	c,l
	call	WriteYMTrk
	ret

; ---------------------------------------------------------------------------

.CheckFM3:
	ld	a,(ix+ftrkChannel)		; Is this FM3?
	cp	2
	jr	nz,.NormalFreq			; If not, branch

	ld	de,fm3DetuneOP1			; Detune value array
	exx
	ld	hl,SpecFM3Regs			; Special FM3 frequency registers
	ld	b,4				; Number of operators

.SetFM3Detune:
	ld	a,(hl)				; Get FM3 operator frequency register
	push	af
	inc	hl
	
	exx					; Get FM3 operator detune value
	ex	de,hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ex	de,hl
	ld	l,(ix+ftrkFreq)			; Add to base frequency value
	ld	h,(ix+ftrkFreq+1)
	add	hl,bc
	
	pop	af				; Write frequency
	push	af
	ld	c,h
	call	WriteYM1
	pop	af
	sub	4
	ld	c,l
	call	WriteYM1
	
	exx					; Loop until all operators are set
	djnz	.SetFM3Detune
	exx
	ret

; -------------------------------------------------------------------------
; Parse track data
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

ParseTrackData:
	ld	e,(ix+ftrkDataPtr)		; Get data pointer
	ld	d,(ix+ftrkDataPtr+1)
	res	FTRK_LEGATO,(ix+ftrkFlags)	; Clear legato flag
	res	FTRK_REST,(ix+ftrkFlags)	; Clear rest flag

ParseNextTrackCmd:
	ld	a,(de)				; Read byte from track data
	inc	de
	cp	0E0h				; Is it a track command?
	jp	nc,TrackCommand			; If so, branch
	
	ex	af,af'				; Set key off
	call	SetKeyOff
	ex	af,af'
	
	bit	FTRK_RAWFREQ,(ix+ftrkFlags)	; Is raw frequency mode set?
	jp	nz,.RawFreqMode			; If so, branch
	
	or	a				; Is the read byte a duration value?
	jp	p,.CalcDuration			; If so, branch
	sub	81h				; Is it a note value?
	jp	p,.GetNote			; If so, branch
	set	FTRK_REST,(ix+ftrkFlags)	; If it's a rest note, set the rest flag
	jr	.ReadDuration			; Read duration

.GetNote:
	add	a,(ix+ftrkTranspose)		; Add transposition to note value
	
	push	de				; Calculate FM frequency block from note octave
	ld	d,8
	ld	e,0Ch
	ex	af,af'
	xor	a

.GetFreqBlock:
	ex	af,af'
	sub	e
	jr	c,.GotFreqBlock
	ex	af,af'
	add	a,d
	jr	.GetFreqBlock

.GotFreqBlock:
	add	a,e				; Get frequency value
	ld	hl,FreqTable
	rst	ReadTablePtr
	ex	af,af'
	or	h
	ld	h,a
	pop	de
	ld	(ix+ftrkFreq),l
	ld	(ix+ftrkFreq+1),h

.ReadDuration:
	bit	FTRK_PORTA,(ix+ftrkFlags)	; Is portamento enabled?
	jr	nz,.SetPortaSpeed		; If so, branch
	
	ld	a,(de)				; Read another byte
	or	a				; Is it a duration?
	jp	p,.GotDuration			; If so, branch
	ld	a,(ix+ftrkDuration)		; If not, use previous duration value
	ld	(ix+ftrkDurCnt),a
	jr	.Finish				; Finish update

.SetPortaSpeed:
	ld	a,(de)				; Read portamento speed
	inc	de
	ld	(ix+ftrkPortaSpeed),a
	jr	.ReadDuration2			; Read duration

; ---------------------------------------------------------------------------

.RawFreqMode:
	ld	h,a				; Get raw frequency value
	ld	a,(de)
	inc	de
	ld	l,a
	or	h
	jr	z,.SetRawFreq			; If it's 0, branch
	
	ld	a,(ix+ftrkTranspose)		; Add transposition value
	ld	b,0
	or	a
	jp	p,.AddRawTranspose
	dec	b

.AddRawTranspose:
	ld	c,a
	add	hl,bc

.SetRawFreq:
	ld	(ix+ftrkFreq),l			; Set frequency
	ld	(ix+ftrkFreq+1),h
	
	bit	FTRK_PORTA,(ix+ftrkFlags)	; Is portamento enabled?
	jr	z,.ReadDuration2		; If not, branch
	ld	a,(de)				; If so, read portamento speed
	inc	de
	ld	(ix+ftrkPortaSpeed),a

.ReadDuration2:
	ld	a,(de)				; Read duration value

.GotDuration:
	inc	de

.CalcDuration:
	call	CalcDuration			; Calculate note duration
	ld	(ix+ftrkDuration),a

.Finish:
	ld	(ix+ftrkDataPtr),e		; Update data pointer
	ld	(ix+ftrkDataPtr+1),d	
	ld	a,(ix+ftrkDuration)		; Reset note duration
	ld	(ix+ftrkDurCnt),a

	bit	FTRK_LEGATO,(ix+ftrkFlags)	; Is legato enabled?
	ret	nz				; If so, branch
	
	xor	a
	ld	(ix+ftrkVibSpeed),a		; Clear vibrato speed counter
	ld	(ix+ftrkVibFreq),a		; Clear vibrato frequency value
	ld	(ix+ftrkEnvCnt),a		; Clear enveloper counter
	ld	a,(ix+ftrkStaccato)		; Reset staccato
	ld	(ix+ftrkStacCnt),a
	ret

; -------------------------------------------------------------------------
; Calculate note duration
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Input duration value
;	ix - Pointer to track variables
; RETURNS:
;	a  - Multiplied duration value
; -------------------------------------------------------------------------

CalcDuration:
	ld	b,(ix+ftrkTickMult)		; Get tick multiplier
	dec	b
	ret	z				; If it's 1, exit

	ld	c,a				; Multiply duration with tick multiplier

.Multiply:
	add	a,c
	djnz	.Multiply
	ret

; -------------------------------------------------------------------------
; Update note duration
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix   - Pointer to track variables
; RETURNS:
;	z/nz - Ran out/Still active
; -------------------------------------------------------------------------

UpdateDuration:
	ld	a,(ix+ftrkDurCnt)		; Decrement note duration
	dec	a
	ld	(ix+ftrkDurCnt),a
	ret

; -------------------------------------------------------------------------
; Initialize vibrato
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

InitVibrato:
	bit	7,(ix+ftrkVibMode)		; Is vibrato enabled?
	ret	z				; If so, exit
	bit	FTRK_LEGATO,(ix+ftrkFlags)	; Is legato set?
	ret	nz				; If so, exit
	
	ld	e,(ix+ftrkVibratoPtr)		; Get vibrato parameters
	ld	d,(ix+ftrkVibratoPtr+1)
	
	push	ix				; Copy parameters
	pop	hl
	ld	b,0
	ld	c,ftrkVibDelay
	add	hl,bc
	ex	de,hl
	ldi
	ldi
	ldi
	ld	a,(hl)				; Direction step counter is divided by 2 (2 directions per cycle)
	srl	a
	ld	(de),a
	
	xor	a				; Clear vibrato frequency value
	ld	(ix+ftrkVibFreq),a
	ld	(ix+ftrkVibFreq+1),a
	ret

; -------------------------------------------------------------------------
; Update vibrato
; -------------------------------------------------------------------------
; PARAMETERS:
;	hl - Input frequency value
;	ix - Pointer to track variables
; RETURNS:
;	hl - Modified frequency value
; -------------------------------------------------------------------------

UpdateVibrato:
	ld	a,(ix+ftrkVibMode)		; Is vibrato enabled?
	or	a
	ret	z				; If not, exit

	dec	(ix+ftrkVibDelay)		; Decrement delay counter
	ret	nz				; If it hasn't run out, exit
	inc	(ix+ftrkVibDelay)		; Cap it

	push	hl				; Get current vibrato frequency value
	ld	l,(ix+ftrkVibFreq)
	ld	h,(ix+ftrkVibFreq+1)
	
	dec	(ix+ftrkVibSpeed)		; Update speed counter
	jr	nz,.UpdateDir
	ld	e,(ix+ftrkVibratoPtr)
	ld	d,(ix+ftrkVibratoPtr+1)
	push	de
	pop	iy
	ld	a,(iy+(ftrkVibSpeed-ftrkVibDelay))
	ld	(ix+ftrkVibSpeed),a
	
	ld	a,(ix+ftrkVibIntens)		; Add intensity value to vibrato frequency value
	ld	c,a
	and	80h
	rlca
	neg
	ld	b,a
	add	hl,bc
	ld	(ix+ftrkVibFreq),l
	ld	(ix+ftrkVibFreq+1),h

.UpdateDir:
	pop	bc				; Add input frequency
	add	hl,bc
	
	dec	(ix+ftrkVibDirStep)		; Update direction step counter
	ret	nz
	ld	a,(iy+(ftrkVibDirStep-ftrkVibDelay))
	ld	(ix+ftrkVibDirStep),a
	
	ld	a,(ix+ftrkVibIntens)		; Flip direction
	neg
	ld	(ix+ftrkVibIntens),a
	ret

; -------------------------------------------------------------------------
; Set key on
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

SetKeyOn:
	ld	a,(ix+ftrkFreq)			; Is a frequency set?
	or	(ix+ftrkFreq+1)
	ret	z				; If not, exit
	ld	a,(ix+ftrkFlags)		; Is either legato set or sound disabled?
	and	(1<<FTRK_LEGATO)|(1<<FTRK_SNDOFF)
	ret	nz				; If so, exit

	ld	a,(ix+ftrkChannel)		; Set key on
	or	0F0h
	ld	c,a
	ld	a,28h
	call	WriteYM1
	ret

; -------------------------------------------------------------------------
; Set key off
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

SetKeyOff:
	ld	a,(ix+ftrkFlags)		; Is either legato set or sound disabled?
	and	(1<<FTRK_LEGATO)|(1<<FTRK_SNDOFF)
	ret	nz				; If so, exit

ForceKeyOff:
	res	FTRK_VIBEND,(ix+ftrkFlags)	; Clear vibrato envelope end flag
	
	ld	c,(ix+ftrkChannel)		; Set key off
	ld	a,28h
	call	WriteYM1
	ret

; -------------------------------------------------------------------------
; Update portamento
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; RETURNS:
;	hl - Frequency value
; -------------------------------------------------------------------------

UpdatePortamento:
	ld	b,0				; Get portamento speed, sign extended
	ld	a,(ix+ftrkPortaSpeed)
	or	a
	jp	p,.GetNewFreq
	dec	b

.GetNewFreq:
	ld	h,(ix+ftrkFreq+1)		; Get frequency
	ld	l,(ix+ftrkFreq)
	ld	c,a				; Add portamento speed
	add	hl,bc
	ex	de,hl
	
	ld	a,7				; Get frequency within block
	and	d
	ld	b,a
	ld	c,e
	
	or	a				; Has it gone past the bottom block boundary?
	ld	hl,283h
	sbc	hl,bc
	jr	c,.CheckTopBound		; If not, branch
	ld	hl,-57Bh			; If so, shift down a block
	add	hl,de
	jr	.UpdateFreq

; ---------------------------------------------------------------------------

.CheckTopBound:
	or	a				; Has it gone past the top block boundary?
	ld	hl,508h
	sbc	hl,bc
	jr	nc,.NoBoundCross		; If not, branch
	ld	hl,57Ch				; If so, shift up a block
	add	hl,de
	ex	de,hl

.NoBoundCross:
	ex	de,hl

.UpdateFreq:
	bit	FTRK_PORTA,(ix+ftrkFlags)	; Is portamento enabled?
	ret	z				; If not, exit
	
	ld	(ix+ftrkFreq+1),h		; Update frequency
	ld	(ix+ftrkFreq),l
	ret

; -------------------------------------------------------------------------
; Get envelope data
; -------------------------------------------------------------------------
; PARAMETERS:
;	c  - Envelope data index
;	hl - Pointer to envelope data
; RETURNS:
;	a  - Read data
; -------------------------------------------------------------------------

GetEnvData:
	ld	b,0
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,(bc)
	ret

; -------------------------------------------------------------------------
; Get pointer to instrument data
; -------------------------------------------------------------------------
; PARAMETERS:
;	b  - Instrument ID
;	ix - Pointer to track variables
; RETURNS:
;	hl - Pointer to instrument data
; -------------------------------------------------------------------------

GetInstrumentPtr:
	ld	l,(ix+ftrkInsTblPtr)		; Get instrument data
	ld	h,(ix+ftrkInsTblPtr+1)
	
	xor	a				; Is the instrument ID 0?
	or	b
	jr	z,.End				; If so, branch

	ld	de,19h				; Jump to correct instrument data

.GetInstrument:
	add	hl,de
	djnz	.GetInstrument

.End:
	ret

; -------------------------------------------------------------------------
; Write YM register data for track
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

WriteYMTrk:
	bit	2,(ix+ftrkChannel)		; Is this 
	jr	nz,WriteYM2Trk

WriteYM1Trk:
	bit	FTRK_SNDOFF,(ix+ftrkFlags)	; Is sound disabled?
	ret	nz				; If so, exit
	add	a,(ix+ftrkChannel)		; Add channel ID to register ID

; -------------------------------------------------------------------------
; Write YM register data (part 1)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; -------------------------------------------------------------------------

WriteYM1:
	ld	(YMADDR0),a			; Write register data
	nop
	ld	a,c
	ld	(YMDATA0),a
	ret
	
; -------------------------------------------------------------------------
; Write YM register data for track (part 2)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

WriteYM2Trk:
	bit	FTRK_SNDOFF,(ix+ftrkFlags)	; Is sound disabled?
	ret	nz				; If so, exit
	add	a,(ix+ftrkChannel)		; Add channel ID to register ID
	sub	4

; -------------------------------------------------------------------------
; Write YM register data (part 2)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; -------------------------------------------------------------------------

WriteYM2:
	ld	(YMADDR1),a			; Write register data
	nop
	ld	a,c
	ld	(YMDATA1),a
	ret

; -------------------------------------------------------------------------
; Update instrument
; -------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to instrument data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

UpdateInstrument:
	ld	de,InstrumentRegs		; Instrument registers
	
	ld	c,(ix+ftrkPanAMSFMS)		; Set panning/AMS/FMS
	ld	a,0B4h
	call	WriteYMTrk

	call	WriteInsReg			; Set feedback/algorithm
	ld	(ix+ftrkFBAlgo),a
	
	ld	b,(InsTLRegs-InstrumentRegs)-1	; Set rest of the registers

.SetRegs:
	call	WriteInsReg
	djnz	.SetRegs

	ld	(ix+ftrkTLDataPtr),l		; Update volume with new TL data
	ld	(ix+ftrkTLDataPtr+1),h
	jp	UpdateVolume

; -------------------------------------------------------------------------
; Write instrument register
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to instrument register ID
;	hl - Pointer to instrument register data
; RETURNS:
;	a  - Written register data
; -------------------------------------------------------------------------

WriteInsReg:
	ld	a,(de)				; Set instrument register data
	inc	de
	ld	c,(hl)
	inc	hl
	call	WriteYMTrk
	ret

; -------------------------------------------------------------------------
; Play a sound from the queue
; -------------------------------------------------------------------------

PlaySoundID:
	ld	a,(sndPlay)			; Get sound pulled from the queue
	bit	7,a				; Is it a sound ID?
	jp	z,StopSound			; If not, stop all sound
	
	cp	FM_END+1			; Is it a sound effect?
	jp	c,PlaySFX			; If so, branch
	
	jp	StopSound			; Stop all sound

; ---------------------------------------------------------------------------
; Initial track data
; ---------------------------------------------------------------------------

TrackInitData:
	db	80h, 0				; FM1
	db	80h, 1				; FM2
	db	80h, 2				; FM3
	db	80h, 4				; FM4
	db	80h, 5				; FM5
	db	80h, 6				; FM6

; -------------------------------------------------------------------------
; Play a sound effect
; -------------------------------------------------------------------------
; PARAMETERS:
;	a - Sound ID
; -------------------------------------------------------------------------

PlaySFX:
	sub	FM_START			; Make ID zero based
	ret	m				; If it's not a valid sound effect ID, exit

	ld	c,DrvInfo_SFXIndex-DriverInfo	; Get sound effect pointer
	rst	GetList
	rst	ReadTablePtr

	push	hl				; Get instrument table pointer
	rst	ReadHLPtr
	ld	(insTable),hl
	xor	a				; Clear end flag
	ld	(endFlag),a
	pop	hl

	push	hl				; Get tick multiplier
	pop	iy
	ld	a,(iy+2)
	ld	(tickMult),a
	ld	de,4				; Skip past header
	add	hl,de
	ld	b,(iy+3)			; Get number of tracks

.InitTracks:
	push	bc				; Save track counter
	
	push	hl				; Get track variables pointer
	inc	hl
	ld	c,(hl)
	call	GetSFXTrackPtr
	push	ix
	pop	de
	pop	hl

	ldi					; Copy flags
	ld	a,(de)				; Get channel ID
	cp	2				; Is it FM3?
	call	z,DisableSpecFM3		; If so, disable special FM3 mode
	ldi					; Copy channel ID
	ld	a,(tickMult)			; Set tick multiplier
	ld	(de),a
	inc	de
	ldi					; Copy track data pointer
	ldi
	ldi					; Copy transposition value
	ldi					; Copy volume value

	call	FinishTrackInit			; Finish track initialization

	push	hl				; Set instrument table pointer
	ld	hl,(insTable)
	ld	(ix+ftrkInsTblPtr),l
	ld	(ix+ftrkInsTblPtr+1),h
	call	SetKeyOff			; Set key off
	call	DisableSSGEG			; Disable SSG-EG
	pop	hl
	
	pop	bc				; Loop until all tracks are initialized
	djnz	.InitTracks

ResetSoundQueue:
	ld	a,80h				; Clear sound play queue
	ld	(sndPlay),a
	ret

; -------------------------------------------------------------------------
; Get sound effect track variables pointer
; -------------------------------------------------------------------------
; PARAMETERS:
;	c  - Channel ID
; RETURNS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

GetSFXTrackPtr:
	ld	a,c				; Get channel ID
	bit	2,a				; Is it a YM part 2 channel?
	jr	z,.GetPtr			; If not, branch
	dec	a				; Make ID linear

.GetPtr:
	ld	(channelID),a			; Get track variables pointer
	push	af
	ld	hl,SFXTrackPtrs
	rst	ReadTablePtr
	push	hl
	pop	ix
	pop	af
	ret

; -------------------------------------------------------------------------
; Finish track initialization
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track variables after volume
; RETURNS:
;	de - Advanced track variables pointer
; -------------------------------------------------------------------------

FinishTrackInit:
	ex	af,af'
	xor	a				; Reset vibrato mode
	ld	(de),a
	inc	de
	ld	(de),a				; Reset instrument ID
	inc	de
	ex	af,af'

	ex	de,hl				; Set call stack pointer
	ld	(hl),ftrkStackBase
	inc	hl
	ld	(hl),0C0h			; Set panning/AMS/FMS
	inc	hl
	ld	(hl),1				; Set duration counter to 1

	ld	b,ftrkSize-ftrkDuration		; Clear rest of the track

.ClearTrack:
	inc	hl
	ld	(hl),0
	djnz	.ClearTrack

	inc	hl
	ex	de,hl
	ret

; ---------------------------------------------------------------------------
; Sound effect track variables pointers
; ---------------------------------------------------------------------------

SFXTrackPtrs:
	dw	fm1Track			; FM1
	dw	fm2Track			; FM2
	dw	fm3Track			; FM3
	dw	fm4Track			; FM4
	dw	fm5Track			; FM5
	dw	fm6Track			; FM6

; -------------------------------------------------------------------------
; Stop all sound
; -------------------------------------------------------------------------

StopSound:
	ld	hl,sndPlay			; Clear driver variables
	ld	de,sndPlay+1
	ld	bc,(VariablesEnd-sndPlay)-1
	ld	(hl),0
	ldir

	; BUG: SilenceTrack and DisableSSGEG expect ix to be a pointer
	; to a track's variables. TrackInitData also doesn't get properly used.
	; As a result, this function does not work properly.
	ld	ix,TrackInitData		; Initial track data
	ld	b,TRACK_CNT			; Number of tracks

.StopTracks:
	push	bc				; Save track counter
	call	SilenceTrack			; Silence track
	call	DisableSSGEG			; Disable SSG-EG

	inc	ix				; Next track
	inc	ix
	pop	bc
	djnz	.StopTracks			; Loop until all tracks are stopped
	
	ld	b,7				; Reset fading
	xor	a
	ld	(fadeFlag),a

; -------------------------------------------------------------------------
; Disable special FM3 mode
; -------------------------------------------------------------------------

DisableSpecFM3:
	ld	a,0Fh				; Disable special FM3 mode
	ld	(ymReg27),a
	ld	c,a
	ld	a,27h
	call	WriteYM1
	
	jp	ResetSoundQueue			; Reset sound queue

; -------------------------------------------------------------------------
; Disable SSG-EG
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

DisableSSGEG:
	ld	a,90h				; Disable SSG-EG
	ld	c,0
	jp	WriteYM4OP

; -------------------------------------------------------------------------
; Process sound queue
; -------------------------------------------------------------------------

ProcSoundQueue:
	ld	a,r				; Store value of the R register
	ld	(rValue),a

	ld	de,sndQueues			; Process sound queue 1
	call	.ProcSlot
	call	.ProcSlot			; Process sound queue 2
	; Fall through to process sound queue 3

; -------------------------------------------------------------------------

.ProcSlot:
	ld	a,(de)				; Read from queue
	bit	7,a				; Is a sound ID written in it?
	ret	z				; If not, exit
	sub	FM_START			; Is it a valid sound effect ID?
	ret	c				; If not, exit
	
	ld	c,DrvInfo_SFXPrios-DriverInfo	; Get sound priority
	rst	GetList
	ld	c,a
	ld	b,0
	add	hl,bc

	ld	a,(curPriority)			; Get current sound priority
	cp	(hl)				; Is this sound's priority greater?
	jr	z,.SetSound			; If so, branch
	jr	nc,.ClearSlot			; If not, branch

.SetSound:
	ld	a,(de)				; Override sound play queue
	ld	(sndPlay),a
	ld	a,(hl)				; Set new priority
	and	7Fh
	ld	(curPriority),a

.ClearSlot:
	xor	a				; Clear queue slot
	ld	(de),a
	inc	de				; Next queue slot
	ret

; -------------------------------------------------------------------------
; Silence track
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

SilenceTrack:
	call	SetInstrumentMaxRel		; Maximize release rate
	ld	a,40h				; Silence channel
	ld	c,7Fh
	call	WriteYM4OP

	ld	c,(ix+ftrkChannel)		; Set key off
	jp	ForceKeyOff

; -------------------------------------------------------------------------
; Maximize release rate
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

SetInstrumentMaxRel:
	ld	a,80h				; Set max release rate
	ld	c,0FFh

; -------------------------------------------------------------------------
; Write a value to all 4 operators for a register
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Base register ID
;	c  - Register data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

WriteYM4OP:
	ld	b,4				; Number of operators

.Write:
	push	af				; Write operator register data
	call	WriteYMTrk
	pop	af
	add	a,4				; Next operator
	djnz	.Write				; Loop until operator registers are set
	ret

; ---------------------------------------------------------------------------
; Instrument registers
; ---------------------------------------------------------------------------

InstrumentRegs:
	db	0B0h				; Feedback/Algorithm
	db	30h, 38h, 34h, 3Ch		; Detune/Multiply
	db	50h, 58h, 54h, 5Ch		; Rate scale/Attack rate
	db	60h, 68h, 64h, 6Ch		; AMS enable/Decay rate
	db	70h, 78h, 74h, 7Ch		; Sustain rate
	db	80h, 88h, 84h, 8Ch		; Sustain level/Release rate
InsTLRegs:
	db	40h, 48h, 44h, 4Ch		; Total level
InsSSGEGRegs:
	db	90h, 98h, 94h, 9Ch		; SSG-EG

; ---------------------------------------------------------------------------
; Special FM3 frequency registers
; ---------------------------------------------------------------------------

SpecFM3Regs:
	db	0ADh, 0AEh, 0ACh, 0A6h		; FM3 frequency
	
; ---------------------------------------------------------------------------
; Frequency table
; ---------------------------------------------------------------------------
	
FreqTable:
	;	C     C#/Db D     D#/Eb E     F     F#/Gb G     G#/Ab A     A#/Bb B
	dw	284h, 2ABh, 2D3h, 2FEh, 32Dh, 35Ch, 38Fh, 3C5h, 3FFh, 43Ch, 47Ch, 4C0h

; -------------------------------------------------------------------------
; Process track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Track command ID
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrackCommand:
	ld	hl,.Done			; Set return address
	push	hl

	sub	0E0h				; Process track command
	ld	hl,.Commands
	rst	ReadTablePtr
	ld	a,(de)
	jp	(hl)

.Done:
	inc	de				; Parse next track command
	jp	ParseNextTrackCmd

; ---------------------------------------------------------------------------

.Commands:
	dw	TrkCmd_Panning			; Set panning
	dw	TrkCmd_PortaSpeed		; Set detune
	dw	TrkCmd_CommFlag			; Set communication flag
	dw	TrkCmd_Silence			; Silence track
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_RepeatEnd		; End repeat
	dw	TrkCmd_Volume			; Add volume
	dw	TrkCmd_Legato			; Set legato
	dw	TrkCmd_Staccato			; Set staccato
	dw	TrkCmd_LFO			; Set LFO
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_CondJump			; Conditional jump
	dw	TrkCmd_ResetRingChn		; Reset ring channel
	dw	TrkCmd_YMWrite			; Write YM register data for track
	dw	TrkCmd_YM1Write			; Write YM register data (part 1)
	dw	TrkCmd_Instrument		; Set instrument
	dw	TrkCmd_Vibrato			; Set vibrato
	dw	TrkCmd_VibDisable		; Disable vibrato
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_SwapRingChn		; Swap ring channel
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_Jump			; Jump
	dw	TrkCmd_Repeat			; Repeat
	dw	TrkCmd_Call			; Call
	dw	TrkCmd_Return			; Return
	dw	TrkCmd_TrackTickMult		; Set track tick multiplier
	dw	TrkCmd_Transpose		; Transpose
	dw	TrkCmd_Portamento		; Set portamento
	dw	TrkCmd_RawFreqMode		; Set raw frequency mode
	dw	TrkCmd_FM3Detune		; Set FM3 detune mode
	dw	.FFxx				; FFxx
	
.CommandsFFxx:
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_Tempo			; Set tempo
	dw	TrkCmd_PlaySound		; Play sound
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_CopyData			; Copy data
	dw	TrkCmd_Stop			; Stop
	dw	TrkCmd_SSGEG			; Set SSG-EG

; -------------------------------------------------------------------------
; Process FFxx track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

.FFxx:
	ld	hl,.CommandsFFxx		; Process track command
	rst	ReadTablePtr
	inc	de
	ld	a,(de)
	jp	(hl)

; -------------------------------------------------------------------------
; Tempo track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Tempo value
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Tempo:
	ld	hl,tempo			; Set tempo
	ld	(hl),a
	dec	hl
	ld	(hl),a
	ret

; -------------------------------------------------------------------------
; Sound play track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Sound ID
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_PlaySound:
	ld	hl,sndPlay			; Play sound
	ld	(hl),a
	ret

; -------------------------------------------------------------------------
; Data copy track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_CopyData:
	ex	de,hl				; Get destination address
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	ld	c,(hl)				; Get count
	ld	b,0
	inc	hl
	ex	de,hl

	ldir					; Copy data
	dec	de
	ret

; -------------------------------------------------------------------------
; Conditional jump track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_CondJump:
	ld	a,(jumpCondition)		; Get jump condition
	or	a				; Should we jump?
	jp	z,TrkCmd_Jump			; If so, branch
	inc	de				; If not, skip
	ret

; -------------------------------------------------------------------------
; Ring channel reset track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_ResetRingChn:
	ld	a,80h				; Reset ring channel
	ld	(ringChannel),a
	ret

; -------------------------------------------------------------------------
; SSG-EG track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_SSGEG:
	ld	(ix+ftrkSSGEGMode),80h		; Enable SSG-EG
	ld	(ix+ftrkSSGPtr),e		; Set parameters pointer
	ld	(ix+ftrkSSGPtr+1),d

	ld	hl,InsSSGEGRegs			; Set SSG-EG register data
	ld	b,4

.SetRegs:
	ld	a,(de)
	inc	de
	ld	c,a
	ld	a,(hl)
	inc	hl
	call	WriteYMTrk
	djnz	.SetRegs
	dec	de
	ret

; -------------------------------------------------------------------------
; Portamento speed track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Portamento speed
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_PortaSpeed:
	ld	(ix+ftrkPortaSpeed),a		; Set portamento speed
	ret

; -------------------------------------------------------------------------
; Communication flag track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Communication flag
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_CommFlag:
	ld	(commFlag),a
	ret

; -------------------------------------------------------------------------
; Silence track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Silence:
	call	SilenceTrack			; Silence track
	jp	TrkCmd_Stop			; Stop track

; -------------------------------------------------------------------------
; Staccato track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Staccato duration
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Staccato:
	call	CalcDuration			; Set staccato time
	ld	(ix+ftrkStacCnt),a
	ld	(ix+ftrkStaccato),a
	ret

; -------------------------------------------------------------------------
; Track YM register data write track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_YMWrite:
	call	GetYMWriteData			; Get register data
	call	WriteYMTrk			; Write it
	ret

; -------------------------------------------------------------------------
; YM register data write (part 1) track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_YM1Write:
	call	GetYMWriteData			; Get register data
	call	WriteYM1			; Write it
	ret


; -------------------------------------------------------------------------
; Get YM register data to write
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
; RETURNS:
;	a  - Register ID
;	c  - Register data
;	de - Advanced track data pointer
; -------------------------------------------------------------------------

GetYMWriteData:
	ex	de,hl
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	ex	de,hl
	ret

; -------------------------------------------------------------------------
; Vibrato track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Vibrato:
	ld	(ix+ftrkVibratoPtr),e		; Set parameters pointer
	ld	(ix+ftrkVibratoPtr+1),d
	ld	(ix+ftrkVibMode),80h		; Enable vibrato
	inc	de
	inc	de
	inc	de
	ret

; -------------------------------------------------------------------------
; Vibrato disable track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_VibDisable:
	res	7,(ix+ftrkVibMode)		; Disable vibrato
	dec	de
	ret

; -------------------------------------------------------------------------
; Legato track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Legato:
	set	FTRK_LEGATO,(ix+ftrkFlags)	; Set legato
	dec	de
	ret

; -------------------------------------------------------------------------
; FM3 detune mode track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_FM3Detune:
	ld	a,(ix+ftrkChannel)		; Is this FM3?
	cp	2
	jr	nz,.NotFM3			; If not, branch

	set	FTRK_FM3DET,(ix+ftrkFlags)	; Set FM3 detune mode

	exx					; Set operator detune values
	ld	de,fm3DetuneOP1
	ld	b,4

.SetDetune:
	push	bc
	exx
	ld	a,(de)
	inc	de
	exx
	ld	hl,.DetuneVals
	add	a,a
	ld	c,a
	ld	b,0
	add	hl,bc
	ldi
	ldi
	pop	bc
	djnz	.SetDetune
	exx

	dec	de				; Enable FM3 special mode
	ld	a,4Fh
	ld	(ymReg27),a
	ld	c,a
	ld	a,27h
	call	WriteYM1
	ret

.NotFM3:
	inc	de				; If this is not FM3, skip this command
	inc	de
	inc	de
	ret

; ---------------------------------------------------------------------------

.DetuneVals:
	dw	0
	dw	132h
	dw	18Eh
	dw	1E4h
	dw	234h
	dw	27Eh
	dw	2C2h
	dw	2F0h

; -------------------------------------------------------------------------
; Instrument track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Instrument:
	call	SetInstrumentMaxRel		; Maximize release rate

	ld	a,(de)				; Set new instrument
	ld	(ix+ftrkInstrument),a
	push	de
	ld	b,a
	call	GetInstrumentPtr
	call	UpdateInstrument
	pop	de
	ret

; -------------------------------------------------------------------------
; Panning track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Panning:
	ld	c,3Fh				; Set panning

; -------------------------------------------------------------------------
; Update panning/AMS/FMS
; -------------------------------------------------------------------------
; PARAMETERS:
;	c  - Bits to mask out from old register data
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

UpdatePanAMSFMS:
	ld	a,(ix+ftrkPanAMSFMS)		; Mask out bits
	and	c
	ex	de,hl
	or	(hl)				; Combine new bits from track data

	ld	(ix+ftrkPanAMSFMS),a		; Write new register data
	ld	c,a
	ld	a,0B4h
	call	WriteYMTrk
	ex	de,hl
	ret

; -------------------------------------------------------------------------
; LFO track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - LFO value
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_LFO:
	ld	c,a				; Set new LFO value
	ld	a,22h
	call	WriteYM1

	inc	de				; Set new AMS/FMS
	ld	c,0C0h
	jr	UpdatePanAMSFMS

; -------------------------------------------------------------------------
; Volume track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Volume add value
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Volume:
	add	a,(ix+ftrkVolume)		; Add volume
	ld	(ix+ftrkVolume),a

; -------------------------------------------------------------------------
; Update volume
; -------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

UpdateVolume:
	exx					; Get TL register data
	ld	de,InsTLRegs
	ld	l,(ix+ftrkTLDataPtr)
	ld	h,(ix+ftrkTLDataPtr+1)
	ld	b,4

.SetRegs:
	ld	a,(hl)				; Get register
	or	a				; Is this a slot operator?
	jp	p,.SetTL			; If not, branch
	add	a,(ix+ftrkVolume)		; If so, add volume to it

.SetTL:
	and	7Fh				; Write new TL data
	ld	c,a
	ld	a,(de)
	call	WriteYMTrk
	
	inc	de				; Next operator
	inc	hl
	djnz	.SetRegs			; Loop until all registers are set
	exx
	ret

; -------------------------------------------------------------------------
; Transpose track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Transposition
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Transpose:
	add	a,(ix+ftrkTranspose)		; Transpose
	ld	(ix+ftrkTranspose),a
	ret

; -------------------------------------------------------------------------
; Track tick multiplier track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Tick multiplier
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_TrackTickMult:
	ld	(ix+ftrkTickMult),a		; Set new tick multiplier
	ret

; -------------------------------------------------------------------------
; Jump track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Jump:
	ex	de,hl				; Jump to new data address
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de
	ret

; -------------------------------------------------------------------------
; Portamento track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Enable flag
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Portamento:
	cp	1				; Is portamento being enabled?
	jr	nz,.Disable			; If not, branch
	set	FTRK_PORTA,(ix+ftrkFlags)	; Enable portamento
	ret

.Disable:
	res	FTRK_LEGATO,(ix+ftrkFlags)	; Clear legato flag
	res	FTRK_PORTA,(ix+ftrkFlags)	; Disable portamento
	xor	a				; Clear portamento speed
	ld	(ix+ftrkPortaSpeed),a
	ret

; -------------------------------------------------------------------------
; Raw frequency mode command
; -------------------------------------------------------------------------

TrkCmd_RawFreqMode:
	cp	1				; Is raw frequency mode being enabled?
	jr	nz,.Disable			; If not, branch
	set	FTRK_RAWFREQ,(ix+ftrkFlags)	; Enable raw frequency mode
	ret

.Disable:
	res	FTRK_RAWFREQ,(ix+ftrkFlags)	; Disable raw frequency mode
	ret

; -------------------------------------------------------------------------
; Stop track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Stop:
	res	FTRK_PLAY,(ix+ftrkFlags)	; Stop playing track
	ld	a,1Fh				; Set end flag
	ld	(endFlag),a
	ld	c,(ix+ftrkChannel)		; Set key off
	call	ForceKeyOff
	xor	a				; Clear sound priority
	ld	(curPriority),a

	pop	hl				; Skip immediately to next track
	pop	hl
	ret

; -------------------------------------------------------------------------
; Ring channel swap track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_SwapRingChn:
	ld	a,(ringChannel)			; Get current ring channel
	or	a				; Is it left?
	jr	z,.SetRight			; If so, branch

.SetLeft:
	xor	a				; Switch to left channel
	ld	(ringChannel),a
	ld	a,FM_RINGL			; Play left channel ring SFX
	ld	(sndQueues),a
	dec	de
	ret

.SetRight:
	ld	a,80h				; Switch to right channel
	ld	(ringChannel),a
	dec	de
	ret

; -------------------------------------------------------------------------
; Call track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	a  - Low byte of call address
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Call:
	ld	c,a				; Get call address
	inc	de
	ld	a,(de)
	ld	b,a

	push	bc				; Push return address to call stack
	push	ix
	pop	hl
	dec	(ix+ftrkStackPtr)
	ld	c,(ix+ftrkStackPtr)
	dec	(ix+ftrkStackPtr)
	ld	b,0
	add	hl,bc
	ld	(hl),d
	dec	hl
	ld	(hl),e

	pop	de				; Jump to call address
	dec	de
	ret

; -------------------------------------------------------------------------
; Return track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Return:
	push	ix				; Pop return address from call stack
	pop	hl
	ld	c,(ix+ftrkStackPtr)
	ld	b,0
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	(ix+ftrkStackPtr)
	inc	(ix+ftrkStackPtr)
	ret

; -------------------------------------------------------------------------
; Repeat track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_Repeat:
	inc	de				; Get repeat index
	add	a,ftrkRepeatCnts
	ld	c,a
	ld	b,0
	push	ix
	pop	hl
	add	hl,bc

	ld	a,(hl)				; Is the repeat count already set?
	or	a
	jr	nz,.CheckRepeat			; If so, branch
	ld	a,(de)				; Set repeat count
	ld	(hl),a

.CheckRepeat:
	inc	de				; Decrement repeat count
	dec	(hl)
	jp	nz,TrkCmd_Jump			; If it hasn't run out, branch
	inc	de				; If it has, skip past repeat address
	ret

; -------------------------------------------------------------------------
; Repeat end track command
; -------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; -------------------------------------------------------------------------

TrkCmd_RepeatEnd:
	inc	de				; Get repeat index
	add	a,ftrkRepeatCnts
	ld	c,a
	ld	b,0
	push	ix
	pop	hl
	add	hl,bc

	ld	a,(hl)				; Decrement repeat count
	dec	a
	jp	z,.Jump				; If it's running out, branch
	inc	de				; If not, just continue as normal
	ret

.Jump:
	xor	a				; Clear repeat count
	ld	(hl),a
	jp	TrkCmd_Jump			; Jump

; -------------------------------------------------------------------------
; Driver info
; -------------------------------------------------------------------------

DriverInfo:
DrvInfo_SFXPrios:
	dw	SFXPriorities			; Sound effect priority table
	dw	0
	dw	SongIndex			; Song index
DrvInfo_SFXIndex:
	dw	SFXIndex			; SFX index
	dw	0
	dw	0
	dw	FM_START			; First SFX ID
	dw	0
	dw	Variables			; Variables
	dw	0

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

	include	"Sound Drivers/FM/Data.asm"

; -------------------------------------------------------------------------
