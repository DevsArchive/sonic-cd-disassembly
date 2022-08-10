WackyWorkbenchPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$08
	smpsHeaderTempo		$01, $05
	smpsHeaderPCM		WackyWorkbenchPast_Rhythm, $00, $6F
	smpsHeaderPCM		WackyWorkbenchPast_PCM1, $05, $9F
	smpsHeaderPCM		WackyWorkbenchPast_PCM2, $00, $AF
	smpsHeaderPCM		WackyWorkbenchPast_PCM3, $00, $9F
	smpsHeaderPCM		WackyWorkbenchPast_PCM4, $05, $7F
	smpsHeaderPCM		WackyWorkbenchPast_PCM5, $0B, $9F
	smpsHeaderPCM		WackyWorkbenchPast_PCM6, $00, $BF
	smpsHeaderPCM		WackyWorkbenchPast_PCM8, $03, $9F

WackyWorkbenchPast_PCM1:
	smpsSetvoice	sPad
	smpsAlterPitch	$03
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$F7
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsLoop	$01, $08, WackyWorkbenchPast_PCM1
	smpsAlterVol	$EC

WackyWorkbenchPast_Loop1:
	smpsSetvoice	sSynth
	dc.b	nRst, $0C, nBb1, nBb1, $18, nC2, $12, nC2
	dc.b	nC2, $0C
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop1
	smpsAlterPitch	$FE

WackyWorkbenchPast_Loop2:
	smpsSetvoice	sSynth
	dc.b	nRst, $0C, nBb1, nBb1, $18, nC2, $12, nC2
	dc.b	nC2, $0C
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop2
	smpsAlterPitch	$02
	smpsAlterVol	$14

WackyWorkbenchPast_Loop3:
	smpsSetvoice	sPad
	smpsAlterPitch	$03
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$F7
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsCall	WackyWorkbenchPast_Call1
	smpsAlterPitch	$02
	smpsLoop	$01, $02, WackyWorkbenchPast_Loop3
	smpsJump	WackyWorkbenchPast_PCM1
	smpsStop	; Unused

WackyWorkbenchPast_Call1:
	smpsPan		$DD
	dc.b	nC2, $18
	smpsAlterVol	$E7
	smpsPan		$7F
	dc.b	nC2, $18
	smpsAlterVol	$E7
	smpsPan		$F7
	dc.b	nC2, $18
	smpsAlterVol	$E7
	smpsPan		$7F
	dc.b	nC2, $18
	smpsAlterVol	$4B
	smpsReturn

WackyWorkbenchPast_PCM2:
	smpsSetvoice	sKick
	dc.b	nC2, $18
	smpsLoop	$00, $08, WackyWorkbenchPast_PCM2

WackyWorkbenchPast_Jump1:
	smpsSetvoice	sKick
	dc.b	nC2, $0C
	smpsSetvoice	sTamborine
	dc.b	nC2, $0C
	smpsJump	WackyWorkbenchPast_Jump1
	smpsStop	; Unused

WackyWorkbenchPast_PCM3:
	smpsAlterPitch	$06

WackyWorkbenchPast_Loop4:
	smpsSetvoice	sBeep
	dc.b	nRst, $0C, nC2, $18, nC2, $12, nBb1, $0C
	dc.b	nBb1, $06, nC2, $0C, nEb2
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop4

WackyWorkbenchPast_Loop5:
	smpsCall	WackyWorkbenchPast_Call2
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop5

WackyWorkbenchPast_Loop6:
	smpsCall	WackyWorkbenchPast_Call3
	smpsLoop	$01, $30, WackyWorkbenchPast_Loop6
	smpsAlterPitch	$FA
	smpsJump	WackyWorkbenchPast_PCM3
	smpsStop	; Unused

WackyWorkbenchPast_Call2:
	smpsSetvoice	sHatClosed
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	smpsReturn

WackyWorkbenchPast_Call3:
	smpsSetvoice	sHatClosed
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	smpsSetvoice	sHatOpen
	dc.b	nA1, $0C
	smpsSetvoice	sHatClosed
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	smpsSetvoice	sHatOpen
	dc.b	nA1, $0C
	smpsSetvoice	sHatClosed
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	smpsSetvoice	sHatOpen
	dc.b	nA1, $0C
	smpsSetvoice	sHatClosed
	dc.b	nC2, $06
	smpsAlterVol	$EC
	dc.b	nC2, $06
	smpsAlterVol	$14
	smpsSetvoice	sHatOpen
	dc.b	nA1, $0C
	smpsReturn

WackyWorkbenchPast_PCM4:
	smpsAlterNote	$F8

WackyWorkbenchPast_Loop8:
	smpsSetvoice	sHonk
	dc.b	nC2, $06, nBb1, nG1, nC2, nBb1, nG1, nC2
	dc.b	nBb1, nG1, nC2, nBb1, nG1, nC2, $0C, nBb1

WackyWorkbenchPast_Loop7:
	smpsAlterVol	$F6
	smpsPan		$7F
	dc.b	nC2, $0C, nBb1
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nC2, $0C, nBb1
	smpsLoop	$00, $02, WackyWorkbenchPast_Loop7
	smpsAlterVol	$28
	smpsPan		$FF
	smpsLoop	$01, $04, WackyWorkbenchPast_Loop8

WackyWorkbenchPast_Loop9:
	smpsSetvoice	sHonk
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, $0C, nEb2, $12
	smpsAlterVol	$EC
	dc.b	nEb2, $0C
	smpsAlterVol	$14
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, nFs1, nF1, $0C, nEb1, $0C
	dc.b	nC1, $06
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop9

WackyWorkbenchPast_Loop10:
	smpsAlterVol	$14
	dc.b	nG1, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nG1, $0C
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nG1, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nG1, $0C
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nG1, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nG1, $06
	smpsAlterVol	$F9
	smpsPan		$FF
	smpsAlterVol	$2A
	dc.b	nG1, $06, nBb1, nG1, nBb1, $0C, nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nC2, $0C
	smpsAlterVol	$F9
	smpsPan		$FF
	smpsAlterVol	$38
	smpsAlterVol	$EC
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop10

WackyWorkbenchPast_Loop11:
	smpsSetvoice	sHonk
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, $0C, nEb2, $12
	smpsAlterVol	$EC
	dc.b	nEb2, $0C
	smpsAlterVol	$14
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, nFs1, nF1, $0C, nEb1, $0C
	dc.b	nC1, $06
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop11

WackyWorkbenchPast_Loop12:
	smpsCall	WackyWorkbenchPast_Call4
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop12
	smpsAlterPitch	$FE

WackyWorkbenchPast_Loop13:
	smpsCall	WackyWorkbenchPast_Call4
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop13
	smpsAlterPitch	$02

WackyWorkbenchPast_Loop14:
	dc.b	nC1, $0C, nEb1, nF1, nFs1, $06, nC1, $0C
	dc.b	nEb1, nEb1, $06, nF1, $0C, nFs1
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop14
	smpsJump	WackyWorkbenchPast_Loop8
	smpsStop	; Unused

WackyWorkbenchPast_Call4:
	dc.b	nBb1, $06, nC2, nA1, $0C, nG1, $0C
	smpsAlterVol	$F1
	dc.b	nG1, $0C
	smpsAlterVol	$F6
	dc.b	nG1
	smpsAlterVol	$F6
	dc.b	nG1
	smpsAlterVol	$F6
	dc.b	nG1
	smpsAlterVol	$2D
	dc.b	nG1, $06, nG1
	smpsReturn

WackyWorkbenchPast_PCM5:
	smpsSetvoice	sSynthBass
	dc.b	nC1, $0C, nC1, $18, nC1, $0C, nRst, $24
	dc.b	nG0, $06, nBb0
	smpsLoop	$00, $08, WackyWorkbenchPast_PCM5

WackyWorkbenchPast_Loop15:
	smpsSetvoice	sSynthBass
	dc.b	nC1, $0C, nEb1, nF1, nFs1, $06, nC1, $0C
	dc.b	nEb1, nEb1, $06, nF1, $0C, nFs1
	smpsLoop	$00, $18, WackyWorkbenchPast_Loop15

WackyWorkbenchPast_Loop16:
	dc.b	nC1, $0C, nG0, nBb0, nB0, $06, nC1, $0C
	dc.b	nG0, nG0, $06, nBb0, $0C, nB0
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop16
	smpsAlterPitch	$FE

WackyWorkbenchPast_Loop17:
	dc.b	nC1, $0C, nG0, nBb0, nB0, $06, nC1, $0C
	dc.b	nG0, nG0, $06, nBb0, $0C, nB0
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop17
	smpsAlterPitch	$02

WackyWorkbenchPast_Loop18:
	dc.b	nC1, $0C, nEb1, nF1, nFs1, $06, nC1, $0C
	dc.b	nEb1, nEb1, $06, nF1, $0C, nFs1
	smpsLoop	$00, $08, WackyWorkbenchPast_Loop18
	smpsJump	WackyWorkbenchPast_PCM5
	smpsStop	; Unused

WackyWorkbenchPast_PCM6:
	smpsCall	WackyWorkbenchPast_Call5

WackyWorkbenchPast_Loop19:
	smpsCall	WackyWorkbenchPast_Call6
	smpsLoop	$00, $06, WackyWorkbenchPast_Loop19
	smpsCall	WackyWorkbenchPast_Call7
	smpsCall	WackyWorkbenchPast_Call5

WackyWorkbenchPast_Loop20:
	smpsCall	WackyWorkbenchPast_Call6
	smpsLoop	$00, $06, WackyWorkbenchPast_Loop20
	smpsCall	WackyWorkbenchPast_Call8
	smpsLoop	$01, $03, WackyWorkbenchPast_PCM6
	smpsCall	WackyWorkbenchPast_Call5

WackyWorkbenchPast_Loop21:
	smpsCall	WackyWorkbenchPast_Call6
	smpsLoop	$00, $06, WackyWorkbenchPast_Loop21
	smpsCall	WackyWorkbenchPast_Call7
	smpsJump	WackyWorkbenchPast_PCM6
	smpsStop	; Unused

WackyWorkbenchPast_Call5:
	smpsSetvoice	sCrashCymbal
	smpsAlterVol	$28
	smpsPan		$7F
	dc.b	nF2, $18
	smpsAlterVol	$D8
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $06, nFs2, $0C, nFs2, $06
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsReturn

WackyWorkbenchPast_Call6:
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $0C, nFs2, $0C
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $06, nFs2, $0C, nFs2, $06
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsReturn

WackyWorkbenchPast_Call7:
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $0C, nFs2, $0C
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $06, nFs2, $0C
	smpsSetvoice	sTom
	smpsPan		$5B
	dc.b	nA2, $02, nA2, nA2
	smpsPan		$DD
	dc.b	nD2, $06, nD2
	smpsPan		$B5
	dc.b	nA1, $0C
	smpsPan		$FF
	smpsReturn

WackyWorkbenchPast_Call8:
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $0C, nFs2, $0C
	smpsSetvoice	sSnare
	smpsPan		$FF
	dc.b	nE2, $18
	smpsSetvoice	sClap
	smpsPan		$7F
	dc.b	nRst, $06, nFs2, $0C
	smpsSetvoice	sTom
	smpsPan		$5B
	dc.b	nA2, $06
	smpsPan		$DD
	dc.b	nD2, $0C
	smpsPan		$B5
	dc.b	nA1, $06, nA1
	smpsPan		$FF
	smpsReturn

WackyWorkbenchPast_PCM8:
	dc.b	nRst, $60, nRst, nRst, nRst, nRst, nRst, nRst
	dc.b	nRst

WackyWorkbenchPast_Loop23:
	smpsAlterPitch	$05
	smpsAlterNote	$F3
	smpsSetvoice	sPiano
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, $0C, nEb2, $0C, nRst, $06
	smpsAlterVol	$EC
	dc.b	nEb2, $0C
	smpsAlterVol	$14
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, nFs1, nF1, $0C, nEb1, $0C
	dc.b	nC1, $06
	smpsAlterNote	$0D
	smpsAlterPitch	$FB

WackyWorkbenchPast_Loop22:
	smpsSetvoice	sFlute
	smpsAlterVol	$E2
	dc.b	nBb1, $06, nC2, nEb2, nC2, nFs2, $0C, nC2
	dc.b	$06, nF2, $0C, nC2, $06, nEb2, $0C, nC2
	dc.b	nRst
	smpsAlterVol	$1E
	smpsLoop	$00, $02, WackyWorkbenchPast_Loop22
	smpsLoop	$01, $02, WackyWorkbenchPast_Loop23

WackyWorkbenchPast_Loop24:
	smpsSetvoice	sSynthBell
	smpsAlterVol	$C4
	smpsPan		$8F
	dc.b	nF2, $06, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$DF
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$FD
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$F8
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$FD
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2, nF2, nEb2
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop24

WackyWorkbenchPast_Loop26:
	smpsAlterPitch	$05
	smpsAlterNote	$F3
	smpsSetvoice	sPiano
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, $0C, nEb2, $0C, nRst, $06
	smpsAlterVol	$EC
	dc.b	nEb2, $0C
	smpsAlterVol	$14
	dc.b	nRst, $0C, nC2, nC2
	smpsAlterVol	$EC
	dc.b	nC2
	smpsAlterVol	$14
	dc.b	nBb1, $06, nC2, nFs1, nF1, $0C, nEb1, $0C
	dc.b	nC1, $06
	smpsAlterNote	$0D
	smpsAlterPitch	$FB

WackyWorkbenchPast_Loop25:
	smpsSetvoice	sFlute
	smpsAlterVol	$E2
	dc.b	nBb1, $06, nC2, nEb2, nC2, nFs2, $0C, nC2
	dc.b	$06, nF2, $0C, nC2, $06, nEb2, $0C, nC2
	dc.b	nRst
	smpsAlterVol	$1E
	smpsLoop	$00, $02, WackyWorkbenchPast_Loop25
	smpsLoop	$01, $02, WackyWorkbenchPast_Loop26
	smpsAlterPitch	$04
	smpsAlterVol	$1E

WackyWorkbenchPast_Loop27:
	smpsSetvoice	sBeep
	dc.b	nD1, $18, nD1, $0C, nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$28
	dc.b	nRst, $0C, nD1
	smpsAlterVol	$F6
	dc.b	nD1
	smpsAlterVol	$F6
	dc.b	nD1
	smpsAlterVol	$14
	dc.b	nE2
	smpsAlterVol	$F6
	dc.b	nE2
	smpsAlterVol	$0A
	dc.b	nD2
	smpsAlterVol	$F6
	dc.b	nD2
	smpsAlterVol	$0A
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop27
	smpsAlterPitch	$FE

WackyWorkbenchPast_Loop28:
	smpsSetvoice	sBeep
	dc.b	nD1, $18, nD1, $0C, nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$F6
	dc.b	nE1
	smpsAlterVol	$28
	dc.b	nRst, $0C, nD1
	smpsAlterVol	$F6
	dc.b	nD1
	smpsAlterVol	$F6
	dc.b	nD1
	smpsAlterVol	$14
	dc.b	nE2
	smpsAlterVol	$F6
	dc.b	nE2
	smpsAlterVol	$0A
	dc.b	nD2
	smpsAlterVol	$F6
	dc.b	nD2
	smpsAlterVol	$0A
	smpsLoop	$00, $04, WackyWorkbenchPast_Loop28
	smpsAlterPitch	$FE
	smpsAlterVol	$E2

WackyWorkbenchPast_Loop29:
	smpsSetvoice	sSynthBell
	smpsAlterVol	$C4
	smpsPan		$8F
	dc.b	nF2, $06, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$DF
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$FD
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$F8
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$FD
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2, nF2, nEb2
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsLoop	$00, $03, WackyWorkbenchPast_Loop29
	smpsSetvoice	sSynthBell
	smpsAlterVol	$C4
	smpsPan		$8F
	dc.b	nF2, $06, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$DF
	dc.b	nF2, nEb2, nC2, nBb1, nC2, nEb2
	smpsPan		$FD
	dc.b	nF2, nEb2, nC2, nBb1
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsSetvoice	sFlute
	smpsAlterVol	$E2
	dc.b	nC2, $0C, nEb2, nF2, nFs2, $06, nC2, $0C
	dc.b	nEb2, nEb2, $06, nF2, $0C, nFs2
	smpsAlterVol	$1E
	smpsJump	WackyWorkbenchPast_PCM8
	smpsStop	; Unused

WackyWorkbenchPast_Rhythm:
	smpsStop
