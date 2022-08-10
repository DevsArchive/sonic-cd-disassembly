TidalTempestPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$08
	smpsHeaderTempo		$01, $04
	smpsHeaderPCM		TidalTempestPast_Rhythm, $00, $6F
	smpsHeaderPCM		TidalTempestPast_PCM1, $00, $9F
	smpsHeaderPCM		TidalTempestPast_PCM2, $00, $6F
	smpsHeaderPCM		TidalTempestPast_PCM3, $00, $6F
	smpsHeaderPCM		TidalTempestPast_PCM4, $00, $6F
	smpsHeaderPCM		TidalTempestPast_PCM5, $00, $9F
	smpsHeaderPCM		TidalTempestPast_PCM6, $00, $8F
	smpsHeaderPCM		TidalTempestPast_PCM8, $00, $7F

TidalTempestPast_PCM1:
	smpsAlterPitch	$01

TidalTempestPast_Loop1:
	smpsSetvoice	sMarimba
	dc.b	nA1, $0C, nE2, nD2, nE2, nG2, nD2, nE2
	dc.b	nC2, nA1, $0C, nE2, nD2, nE2, nG2, nFs2
	dc.b	nG2, nA2
	smpsAlterPitch	$FE
	dc.b	nA1, $0C, nE2, nD2, nE2, nG2, nD2, nE2
	dc.b	nC2, nA1, $0C, nE2, nD2, nE2, nG2, nFs2
	dc.b	nG2, nA2
	smpsAlterPitch	$02
	smpsLoop	$00, $02, TidalTempestPast_Loop1

TidalTempestPast_Loop2:
	dc.b	nC2, $0C
	smpsAlterVol	$EC
	dc.b	nEb2
	smpsAlterVol	$EC
	dc.b	nD2
	smpsAlterVol	$28
	dc.b	nEb2
	smpsAlterVol	$E2
	dc.b	nF2
	smpsAlterVol	$1E
	dc.b	nEb2, nD2, nEb2, nC2, $0C
	smpsAlterVol	$F1
	dc.b	nEb2
	smpsAlterVol	$F1
	dc.b	nD2
	smpsAlterVol	$F1
	dc.b	nEb2
	smpsAlterVol	$F1
	dc.b	nF2
	smpsAlterVol	$F1
	dc.b	nEb2
	smpsAlterVol	$F1
	dc.b	nD2
	smpsAlterVol	$F1
	dc.b	nEb2
	smpsAlterVol	$69
	smpsLoop	$00, $02, TidalTempestPast_Loop2
	smpsAlterPitch	$03
	smpsLoop	$01, $02, TidalTempestPast_Loop2
	smpsAlterPitch	$FA
	smpsLoop	$02, $02, TidalTempestPast_Loop2
	smpsAlterVol	$D8

TidalTempestPast_Loop3:
	dc.b	nF1, $03, nA1, nC2, nE2
	smpsAlterVol	$CE
	smpsPan		$F7
	dc.b	nF1, nA1, nC2, nE2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nD1, nF1, nA1, nC2
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nD1, nF1, nA1, nC2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nE1, nG1, nB1, nD2
	smpsAlterVol	$CE
	smpsPan		$7F
	smpsPan		$F7
	dc.b	nE1, nG1, nB1, nD2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nBb0, nD1, nF1, nA1
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nBb0, nD1, nF1, nA1
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nF1, nA1, nC2, nE2
	smpsAlterVol	$CE
	smpsPan		$F7
	dc.b	nF1, nA1, nC2, nE2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nD1, nF1, nA1, nC2
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nD1, nF1, nA1, nC2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nE1, nG1, nB1, nD2
	smpsAlterVol	$CE
	smpsPan		$F7
	dc.b	nE1, nG1, nB1, nD2
	smpsAlterVol	$32
	smpsPan		$CD
	dc.b	nC1, nE1, nG1, nB1
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nC1, nE1, nG1, nB1
	smpsAlterVol	$32
	smpsPan		$CD
	smpsLoop	$00, $04, TidalTempestPast_Loop3
	smpsAlterVol	$28
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsJump	TidalTempestPast_Loop1
	smpsStop	; Unused

TidalTempestPast_PCM2:
	smpsAlterPitch	$05

TidalTempestPast_Jump1:
	smpsAlterNote	$0E
	smpsSetvoice	sPiano1
	smpsPan		$FF
	dc.b	nB1, $0C
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$37
	smpsPan		$FF
	dc.b	nA1
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$1E
	smpsPan		$FF
	dc.b	nB1
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$EC
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$32
	smpsPan		$FF
	dc.b	nC2
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$EC
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$32
	smpsPan		$FF
	dc.b	nD2
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nD2
	smpsAlterVol	$1E
	smpsPan		$FF
	dc.b	nA1
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$FE
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FD
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$FD
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$FA
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nA1
	smpsAlterVol	$50
	smpsPan		$FF
	dc.b	nAb1, $04
	smpsAlterVol	$08
	dc.b	nA1
	smpsAlterVol	$08
	dc.b	nBb1
	smpsPan		$FF
	dc.b	nB1, $0C
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$37
	smpsPan		$FF
	dc.b	nA1
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nA1
	smpsAlterVol	$1E
	smpsPan		$FF
	dc.b	nB1
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nB1
	smpsAlterVol	$EC
	smpsPan		$F7
	dc.b	nB1
	smpsAlterVol	$32
	smpsPan		$FF
	dc.b	nC2
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$EC
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$32
	smpsPan		$FF
	dc.b	nD2
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nD2
	smpsAlterVol	$1E
	smpsPan		$FF
	dc.b	nE2
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$FE
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FD
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$FD
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$FB
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$FA
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$F9
	smpsPan		$F7
	dc.b	nE2
	smpsAlterVol	$F9
	smpsPan		$7F
	dc.b	nE2
	smpsAlterVol	$67
	smpsAlterNote	$08
	smpsSetvoice	sPiano2
	smpsAlterVol	$B0

TidalTempestPast_Loop4:
	dc.b	nD2, $06, nEb2
	smpsAlterVol	$0A
	smpsLoop	$00, $08, TidalTempestPast_Loop4

TidalTempestPast_Loop5:
	dc.b	nD2, $06, nEb2
	smpsAlterVol	$F6
	smpsLoop	$00, $08, TidalTempestPast_Loop5
	smpsLoop	$01, $02, TidalTempestPast_Loop4
	smpsAlterPitch	$03
	smpsLoop	$02, $02, TidalTempestPast_Loop4
	smpsAlterPitch	$FA
	smpsLoop	$03, $02, TidalTempestPast_Loop4
	smpsPan		$FF
	smpsAlterVol	$50
	smpsAlterNote	$F8
	smpsAlterPitch	$FC
	smpsAlterNote	$0E

TidalTempestPast_Loop6:
	dc.b	nRst, $0C, nE2, nD2, nC2, nB1, nA1, nBb1
	dc.b	nD2, nRst, $0C, nE2, nD2, nC2, nD2, nG2
	dc.b	nE2
	smpsAlterVol	$C4
	dc.b	nE2
	smpsAlterVol	$3C
	dc.b	nRst, $0C, nE2, nD2, nC2, nB1, nA1, nBb1
	dc.b	nD2, nRst, $0C, nE2, nD2, nC2, nD2, nG2
	dc.b	nA2
	smpsAlterVol	$C4
	dc.b	nA2
	smpsAlterVol	$3C
	smpsLoop	$00, $02, TidalTempestPast_Loop6
	smpsAlterNote	$F2
	smpsAlterPitch	$04
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsJump	TidalTempestPast_Jump1
	smpsStop	; Unused

TidalTempestPast_PCM3:
	smpsAlterPitch	$05

TidalTempestPast_Loop7:
	smpsSetvoice	sMarimbaChord
	dc.b	nRst, $18, nC2, nRst, $0C, nC2, $24, nRst
	dc.b	$18, nC2, nRst, $0C, nC2, $24
	smpsAlterPitch	$FE
	dc.b	nRst, $18, nC2, nRst, $0C, nC2, $24, nRst
	dc.b	$18, nC2, nRst, $0C, nC2, $24
	smpsAlterPitch	$02
	smpsLoop	$00, $02, TidalTempestPast_Loop7

TidalTempestPast_Loop8:
	dc.b	nRst, $18, nAb1, nRst, $0C, nAb1, $24
	smpsLoop	$00, $04, TidalTempestPast_Loop8
	smpsAlterPitch	$03

TidalTempestPast_Loop9:
	dc.b	nRst, $18, nAb1, nRst, $0C, nAb1, $24
	smpsLoop	$00, $04, TidalTempestPast_Loop9
	smpsAlterPitch	$FD
	smpsLoop	$01, $02, TidalTempestPast_Loop8
	smpsSetvoice	sPiano2
	smpsAlterNote	$0F
	smpsAlterPitch	$FC
	smpsPan		$3F
	smpsAlterVol	$C4
	dc.b	nRst, $03, nRst, $0C, nE2, nD2, nC2, nB1
	dc.b	nA1, nBb1, nD2, nRst, nE2, nD2, nC2, nD2
	dc.b	nG2, nE2
	smpsAlterVol	$C4
	dc.b	nE2
	smpsAlterVol	$3C
	dc.b	nRst, nE2, nD2, nC2, nB1, nA1, nBb1, nD2
	dc.b	nRst, nE2, nD2, nC2, nD2, nG2, nA2
	smpsAlterVol	$C4
	dc.b	nA2
	smpsAlterVol	$3C
	dc.b	nRst, $0C, nE2, nD2, nC2, nB1, nA1, nBb1
	dc.b	nD2, nRst, nE2, nD2, nC2, nD2, nG2, nE2
	smpsAlterVol	$C4
	dc.b	nE2
	smpsAlterVol	$3C
	dc.b	nRst, nE2, nD2, nC2, nB1, nA1, nBb1, nD2
	dc.b	nRst, nE2, nD2, nC2, nD2, nG2, nA2, $15
	smpsAlterPitch	$04
	smpsAlterVol	$3C
	smpsAlterNote	$F1
	smpsPan		$FF
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsJump	TidalTempestPast_Loop7
	smpsStop	; Unused

TidalTempestPast_PCM4:
	smpsAlterPitch	$08

TidalTempestPast_Loop10:
	smpsSetvoice	sBass
	dc.b	nA1, $0C, nRst, nRst, nA1, nRst, nRst, nE1
	dc.b	nG1, nA1, $0C, nRst, nRst, nA1, nRst, nRst
	dc.b	nA1, nAb1, nG1, $0C, nRst, nRst, nG1, nRst
	dc.b	nRst, nD1, nF1, nG1, $0C, nRst, nRst, nG1
	dc.b	nRst, nD1, nG1, nAb1
	smpsLoop	$00, $02, TidalTempestPast_Loop10

TidalTempestPast_Loop11:
	dc.b	nF1, $0C, nRst, nRst, nF1, nRst, nRst, nF1
	dc.b	nF1, nF1, $0C, nRst, nRst, nF1, nRst, nRst
	dc.b	nF1, nF1, nF1, $0C, nRst, nRst, nF1, nRst
	dc.b	nRst, nF1, nF1, nF1, $0C, nRst, nRst, nF1
	dc.b	nC2, nBb1, nG1, nF1
	smpsAlterPitch	$03
	smpsLoop	$00, $02, TidalTempestPast_Loop11
	smpsAlterPitch	$FA
	smpsLoop	$01, $02, TidalTempestPast_Loop11
	dc.b	nF1, $18, nD1, nE1, nBb1, nF1, nD1, nE1
	dc.b	nA1, nF1, $18, nD1, nE1, nBb1, nF1, nD1
	dc.b	nE1, nA1, nF1, $18, nD1, nE1, nBb1, nF1
	dc.b	nD1, nE1, nA1, nF1, $18, nD1, nE1, nBb1
	dc.b	nF1, nD1, nE1, nA1, nRst, $60, nRst, nRst
	dc.b	nRst
	smpsJump	TidalTempestPast_Loop10
	smpsStop	; Unused

TidalTempestPast_PCM5:
	smpsAlterPitch	$05

TidalTempestPast_Jump2:
	smpsSetvoice	sBongoLow
	smpsPan		$8F
	dc.b	nC2, $18
	smpsSetvoice	sBongoHigh
	smpsPan		$F8
	dc.b	$0C, $18
	smpsSetvoice	sBongoLow
	smpsPan		$8F
	dc.b	nC2, $0C
	smpsSetvoice	sBongoHigh
	smpsPan		$F8
	dc.b	$18
	smpsJump	TidalTempestPast_Jump2
	smpsStop	; Unused

TidalTempestPast_PCM6:
	smpsSetvoice	sSynthKick
	dc.b	nC2, $18
	smpsSetvoice	sShaker
	smpsAlterVol	$14
	dc.b	nBb2, $0C
	smpsAlterVol	$EC
	smpsSetvoice	sSynthKick
	dc.b	nC2, $18, $0C
	smpsSetvoice	sShaker
	smpsAlterVol	$14
	dc.b	nBb2, $0C, nBb2
	smpsAlterVol	$EC
	smpsSetvoice	sSynthKick
	dc.b	nC2, $18
	smpsSetvoice	sShaker
	smpsAlterVol	$14
	dc.b	nBb2, $0C
	smpsAlterVol	$EC
	smpsSetvoice	sSynthKick
	dc.b	nC2, $18, $0C
	smpsSetvoice	sSnare
	smpsAlterVol	$1E
	dc.b	nBb2, $18
	smpsAlterVol	$E2
	smpsJump	TidalTempestPast_PCM6
	smpsStop	; Unused

TidalTempestPast_PCM8:
	smpsPan		$AF
	smpsAlterPitch	$06

TidalTempestPast_Loop12:
	smpsAlterNote	$08
	smpsSetvoice	sPiano3
	smpsAlterVol	$EC
	dc.b	nRst, $18, nB1, $0C, nC2, nD2, nC2, nB1
	smpsAlterVol	$D8
	dc.b	nB1
	smpsAlterVol	$28
	dc.b	nRst, $18, nB1, $0C, nC2, nD2, nE2, nB1
	smpsAlterVol	$D8
	dc.b	nB1
	smpsAlterVol	$28
	smpsAlterVol	$14
	smpsAlterPitch	$FE
	smpsLoop	$00, $02, TidalTempestPast_Loop12
	smpsAlterPitch	$04
	smpsLoop	$01, $02, TidalTempestPast_Loop12
	smpsAlterPitch	$FA
	smpsAlterNote	$F8
	smpsPan		$FF
	smpsAlterPitch	$01

TidalTempestPast_Loop13:
	smpsSetvoice	sHarp
	smpsPan		$FF
	dc.b	nC2, $0C
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$28
	smpsPan		$FF
	dc.b	nD2, $0C
	smpsAlterVol	$E2
	smpsPan		$7F
	dc.b	nD2
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nD2
	smpsAlterVol	$28
	smpsPan		$FF
	dc.b	nEb2
	smpsAlterVol	$E7
	smpsPan		$F7
	dc.b	nEb2
	smpsAlterVol	$19
	smpsPan		$FF
	dc.b	nC2, $0C
	smpsAlterVol	$F1
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$F1
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$F1
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$F1
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$F6
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$F6
	smpsPan		$F7
	dc.b	nC2
	smpsAlterVol	$F6
	smpsPan		$7F
	dc.b	nC2
	smpsAlterVol	$5A
	smpsLoop	$00, $02, TidalTempestPast_Loop13
	smpsAlterPitch	$03
	smpsLoop	$01, $02, TidalTempestPast_Loop13
	smpsAlterPitch	$FA
	smpsLoop	$02, $02, TidalTempestPast_Loop13
	smpsAlterPitch	$FF

TidalTempestPast_Loop14:
	smpsSetvoice	sTamborine
	dc.b	nD2, $0C, nE2
	smpsLoop	$00, $20, TidalTempestPast_Loop14
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsJump	TidalTempestPast_PCM8
	smpsStop	; Unused

TidalTempestPast_Rhythm:
	smpsStop
