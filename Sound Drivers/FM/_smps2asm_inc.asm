; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================

; ---------------------------------------------------------------------------------------------
; Standard Octave Pitch Equates
	enum smpsPitch10lo=88h,smpsPitch09lo=94h,smpsPitch08lo=0A0h,smpsPitch07lo=0ACh,smpsPitch06lo=0B8h
	enum smpsPitch05lo=0C4h,smpsPitch04lo=0D0h,smpsPitch03lo=0DCh,smpsPitch02lo=0E8h,smpsPitch01lo=0F4h
	enum smpsPitch00=00h,smpsPitch01hi=0Ch,smpsPitch02hi=18h,smpsPitch03hi=24h,smpsPitch04hi=30h
	enum smpsPitch05hi=3Ch,smpsPitch06hi=48h,smpsPitch07hi=54h,smpsPitch08hi=60h,smpsPitch09hi=6Ch
	enum smpsPitch10hi=78h

; ---------------------------------------------------------------------------------------------
; Note Equates
	enum nRst=80h+0,nC0,nCs0,nD0,nEb0,nE0,nF0,nFs0,nG0,nAb0,nA0,nBb0,nB0,nC1,nCs1,nD1
	enum nEb1=nD1+1,nE1,nF1,nFs1,nG1,nAb1,nA1,nBb1,nB1,nC2,nCs2,nD2,nEb2,nE2,nF2,nFs2
	enum nG2=nFs2+1,nAb2,nA2,nBb2,nB2,nC3,nCs3,nD3,nEb3,nE3,nF3,nFs3,nG3,nAb3,nA3,nBb3
	enum nB3=nBb3+1,nC4,nCs4,nD4,nEb4,nE4,nF4,nFs4,nG4,nAb4,nA4,nBb4,nB4,nC5,nCs5,nD5
	enum nEb5=nD5+1,nE5,nF5,nFs5,nG5,nAb5,nA5,nBb5,nB5,nC6,nCs6,nD6,nEb6,nE6,nF6,nFs6
	enum nG6=nFs6+1,nAb6,nA6,nBb6,nB6,nC7,nCs7,nD7,nEb7,nE7,nF7,nFs7,nG7,nAb7,nA7,nBb7

; ---------------------------------------------------------------------------------------------
; Channel IDs for SFX
cFM1				EQU 00h
cFM2				EQU 01h
cFM3				EQU 02h
cFM4				EQU 04h
cFM5				EQU 05h
cFM6				EQU 06h

; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver
SourceDriver set ver
songStart set $
	endm

smpsHeaderStartSongConvert macro ver
SourceDriver set ver
songStart set $
	endm

smpsHeaderVoiceNull macro
	if songStart<>$
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dw	0000h
	endm

; Header - Set up Voice Location
; Common to music and SFX
smpsHeaderVoice macro loc
	if songStart<>$
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dw	loc
	endm

; Header macros for SFX
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	db	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	db	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitch,vol
	db	80h,chanid
	dw	loc
	db	pitch, vol
	endm

; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone set 00h
panRight set 40h
panLeft set 80h
panCentre set 0C0h
panCenter set 0C0h ; silly Americans :U
	db	0E0h,direction+amsfms
	endm

; E1xx - Set pitch slide speed to xx
smpsSlideSpeed macro val
	db	0E1h,val
	endm

; E2xx - Useless
smpsNop macro val
	db	0E2h,val
	endm

; E3xx - Silence track
smpsSilence macro
	db	0E3h
	endm

; E5xxyyyy - Loop end
smpsLoopEnd macro index,loc
	db	0E5h,index
	dw	loc
	endm

; E6xx - Alter Volume
smpsFMAlterVol macro val
	db	0E6h,val
	endm

; E7 - Prevent attack of next note
smpsNoAttack	EQU 0E7h

; E8xx - Set note fill to xx
smpsNoteFill macro val
	db	0E8h,val
	endm

; E9xxyy - Set LFO
smpsSetLFO macro enable,amsfms
	db	0E9h,enable,amsfms
	endm

; EBxxxx - Jump if condition is true	
smpsConditionalJumpCD macro loc
	db	0EBh
	dw	loc
	endm

; EC - Reset ring channel
smpsResetRing macro
	db	0ECh
	endm

; EDxxyy - FM command (track)
smpsFMCommand macro reg,val
	db	0EDh,reg,val
	endm

; EExxyy - FM command (part 1)
smpsFMICommand macro reg,val
	db	0EEh,reg,val
	endm

; EFxx - Set Voice of FM channel to xx
smpsSetvoice macro voice
	db	0EFh,voice
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro wait,speed,change,step
	db	0F0h,wait,speed,change,step
	endm

; F1 - Turn off Modulation
smpsModOff macro
	db	0F1h
	endm

; F2 - End of channel
smpsStop macro
	db	0F2h
	endm

; F3 - Swap ring channels
smpsRingSwap macro
	db	0F3h
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	db	0F6h
	dw	loc
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	db	0F7h,index,loops
	dw	loc
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	db	0F8h
	dw	loc
	endm

; F9 - Return
smpsReturn macro val
	db	0F9h
	endm

; FAxx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	db	0FAh,val
	endm

; FBxx - Add xx to channel pitch
smpsAlterPitch macro val
	db	0FBh,val
	endm

; FCxx - Enable pitch slide
smpsPitchSlide macro enable
	dc.b	0FCh,enable
	endm

; FDxx - Enable alternate frequency mode
smpsAlternateSMPS macro flag
	db	0FDh,flag
	endm

; FEwwxxyyzz - Enable FM3 special mode
smpsFM3SpecialMode macro ind1,ind2,ind3,ind4
	db	0FEh,ind1,ind2,ind3,ind4
	endm

; FF01xx - Set music tempo modifier to xx
smpsSetTempoMod macro mod
	db	0FFh,01h,mod
	endm

; FF02xx - Play sound xx
smpsPlaySound macro index
	db	0FFh,02h,index
	endm

; FF04xxxxyy - Copy data
smpsCopyData macro data,len
	fatal "Coord. Flag to copy data should not be used."
	db	0FFh,04h
	dw	data
	db	len
	endm

; FF06wwxxyyzz - Enable SSG-EG
smpsSSGEG macro op1,op2,op3,op4
	db	0FF,06h,op1,op3,op2,op4
	endm

; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set val
	endm

smpsVcUnusedBits macro val
vcUnusedBits set val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set op1
vcDT2 set op2
vcDT3 set op3
vcDT4 set op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set op1
vcCF2 set op2
vcCF3 set op3
vcCF4 set op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set op1
vcRS2 set op2
vcRS3 set op3
vcRS4 set op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set op1
vcAR2 set op2
vcAR3 set op3
vcAR4 set op4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro op1,op2,op3,op4
vcAM1 set op1
vcAM2 set op2
vcAM3 set op3
vcAM4 set op4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set op1
vcD1R2 set op2
vcD1R3 set op3
vcD1R4 set op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set op1
vcD2R2 set op2
vcD2R3 set op3
vcD2R4 set op4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set op1
vcDL2 set op2
vcDL3 set op3
vcDL4 set op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set op1
vcRR2 set op2
vcRR3 set op3
vcRR4 set op4
	endm

; Voices - Total Level
smpsVcTotalLevel macro op1,op2,op3,op4
vcTL1 set op1
vcTL2 set op2
vcTL3 set op3
vcTL4 set op4
	db	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
	db	(vcDT4<<4)+vcCF4 ,(vcDT3<<4)+vcCF3 ,(vcDT2<<4)+vcCF2 ,(vcDT1<<4)+vcCF1
	db	(vcRS4<<6)+vcAR4 ,(vcRS3<<6)+vcAR3 ,(vcRS2<<6)+vcAR2 ,(vcRS1<<6)+vcAR1
	db	(vcAM4<<7)+vcD1R4,(vcAM3<<7)+vcD1R3,(vcAM2<<7)+vcD1R2,(vcAM1<<7)+vcD1R1
	db	vcD2R4           ,vcD2R3           ,vcD2R2           ,vcD2R1
	db	(vcDL4<<4)+vcRR4 ,(vcDL3<<4)+vcRR3 ,(vcDL2<<4)+vcRR2 ,(vcDL1<<4)+vcRR1
	db	vcTL4            ,vcTL3            ,vcTL2            ,vcTL1
	endm

