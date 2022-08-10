; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================

; ---------------------------------------------------------------------------------------------
; Note Equates
	rsset	$80
nRst		rs.b	1
nC0		rs.b	1
nCs0		rs.b	1
nD0		rs.b	1
nEb0		rs.b	1
nE0		rs.b	1
nF0		rs.b	1
nFs0		rs.b	1
nG0		rs.b	1
nAb0		rs.b	1
nA0		rs.b	1
nBb0		rs.b	1
nB0		rs.b	1
nC1		rs.b	1
nCs1		rs.b	1
nD1		rs.b	1
nEb1		rs.b	1
nE1		rs.b	1
nF1		rs.b	1
nFs1		rs.b	1
nG1		rs.b	1
nAb1		rs.b	1
nA1		rs.b	1
nBb1		rs.b	1
nB1		rs.b	1
nC2		rs.b	1
nCs2		rs.b	1
nD2		rs.b	1
nEb2		rs.b	1
nE2		rs.b	1
nF2		rs.b	1
nFs2		rs.b	1
nG2		rs.b	1
nAb2		rs.b	1
nA2		rs.b	1
nBb2		rs.b	1
nB2		rs.b	1
nC3		rs.b	1
nCs3		rs.b	1
nD3		rs.b	1
nEb3		rs.b	1
nE3		rs.b	1
nF3		rs.b	1
nFs3		rs.b	1
nG3		rs.b	1
nAb3		rs.b	1
nA3		rs.b	1
nBb3		rs.b	1
nB3		rs.b	1
nC4		rs.b	1
nCs4		rs.b	1
nD4		rs.b	1
nEb4		rs.b	1
nE4		rs.b	1
nF4		rs.b	1
nFs4		rs.b	1
nG4		rs.b	1
nAb4		rs.b	1
nA4		rs.b	1
nBb4		rs.b	1
nB4		rs.b	1
nC5		rs.b	1
nCs5		rs.b	1
nD5		rs.b	1
nEb5		rs.b	1
nE5		rs.b	1
nF5		rs.b	1
nFs5		rs.b	1
nG5		rs.b	1
nAb5		rs.b	1
nA5		rs.b	1
nBb5		rs.b	1
nB5		rs.b	1
nC6		rs.b	1
nCs6		rs.b	1
nD6		rs.b	1
nEb6		rs.b	1
nE6		rs.b	1
nF6		rs.b	1
nFs6		rs.b	1
nG6		rs.b	1
nAb6		rs.b	1
nA6		rs.b	1
nBb6		rs.b	1
nB6		rs.b	1
nC7		rs.b	1
nCs7		rs.b	1
nD7		rs.b	1
nEb7		rs.b	1
nE7		rs.b	1
nF7		rs.b	1
nFs7		rs.b	1
nG7		rs.b	1
nAb7		rs.b	1
nA7		rs.b	1
nBb7		rs.b	1

; ---------------------------------------------------------------------------------------------
; Channel IDs
cPCM1				EQU $00
cPCM2				EQU $01
cPCM3				EQU $02
cPCM4				EQU $03
cPCM5				EQU $04
cPCM6				EQU $05
cPCM7				EQU $06
cPCM8				EQU $07

; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver
SourceDriver set ver
songStart set *
	dc.w	$0000
	endm

smpsHeaderStartSongConvert macro ver
SourceDriver set ver
songStart set *
	dc.w	$0000
	endm

; Header macros for music (not for SFX)
; Header - Set up Channel Usage
smpsHeaderChan macro pcm
	dc.b	pcm,0
	endm

; Header - Set up Tempo
smpsHeaderTempo macro div,mod
	dc.b	div,mod
	endm

; Header - Set up PCM Channel
smpsHeaderPCM macro loc,pitch,vol
	dc.w	loc-songStart
	dc.b	pitch,vol
	endm

; Header macros for SFX
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitc,vol
	dc.b	$80,chanid
	dc.w	loc-songStart
	dc.b	pitc, vol
	endm

; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning
smpsPan macro pan
	dc.b	$E0,pan
	endm

; E1xx - Set channel detune to val
smpsAlterNote macro val
	dc.b	$E1,val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$E2,val
	endm

; E3xx - Start CDDA loop
smpsCDDALoop macro val
	dc.b	$E3
	endm

; E6xx - Alter Volume
smpsAlterVol macro val
	dc.b	$E6,val
	endm

; E7 - Prevent attack of next note
smpsNoAttack	EQU $E7

; E8xx - Set note fill to xx
smpsNoteFill macro val
	dc.b	$E8,val
	endm

; EAxx - Set music tempo modifier to xx
smpsSetTempoMod macro mod
	dc.b	$EA,mod
	endm

; EBxx - Play sound xx
smpsPlaySound macro index
	dc.b	$EB,index
	endm

; EFxx - Set Voice of channel to xx
smpsSetvoice macro voice
	dc.b	$EF,voice
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	loc-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7,index,loops
	dc.w	loc-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	loc-*-1
	endm

; F9 - Return
smpsReturn macro val
	dc.b	$F9
	endm

; FAxx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$FA,val
	endm

; FBxx - Add xx to channel pitch
smpsAlterPitch macro val
	dc.b	$FB,val
	endm

; FCxx - Set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$FC,val
	endm

; FExxyy - Unknown
smpsUnkFE macro val1, val2
	dc.b	$FE,val1,val2
	endm
