StardustSpeedwayPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $04
	smpsHeaderPCM		StardustSpeedwayPast_Rhythm, $00, $FF
	smpsHeaderPCM		StardustSpeedwayPast_PCM1, $D4, $FF
	smpsHeaderPCM		StardustSpeedwayPast_PCM2, $E3, $FF
	smpsHeaderPCM		StardustSpeedwayPast_PCM3, $EE, $9F
	smpsHeaderPCM		StardustSpeedwayPast_PCM4, $EE, $7F
	smpsHeaderPCM		StardustSpeedwayPast_PCM5, $C8, $6F
	smpsHeaderPCM		StardustSpeedwayPast_PCM6, $F8, $BF
	smpsHeaderPCM		StardustSpeedwayPast_PCM8, $F0, $FF
	smpsHeaderPCM		StardustSpeedwayPast_PCM7, $F8, $BF

StardustSpeedwayPast_PCM1:
	smpsAlterPitch	$F4
	smpsSetvoice	sHueHueHue
	dc.b	nBb5, $30, nRst, $08, nBb5, $18, nBb5, $10
	dc.b	nBb5, $30, nRst, $08, nBb5, $18, nBb5, $10
	dc.b	nBb5, $30, nRst, $08, nBb5, $18, nBb5, $10
	dc.b	nBb5, $30, nRst, $08, nBb5, $18, nBb5, $10
	dc.b	nRst, $60, nRst, nRst, nRst, $30, nRst, $18
	smpsAlterPitch	$0C
	smpsAlterPitch	$FC
	smpsSetvoice	sSaxophone
	dc.b	nG5, $04, nA5, nC6, nD6, nE6, nG6

StardustSpeedwayPast_Loop1:
	dc.b	nA6, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nG6, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nE6, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nEb6, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nD6, $08, nC6, $04, nD6, $08, nC6, $04
	smpsAlterVol	$C4
	dc.b	$08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$78
	dc.b	nRst, $24, nG5, $08, nA5, $04, nG5, $08
	dc.b	nA5, $04, nC6, $08, nA5, $04, nG5, $08
	dc.b	nA5, $04
	smpsAlterVol	$C4
	dc.b	$08
	smpsAlterVol	$C4
	dc.b	$04, nRst, $08, nRst, $04
	smpsAlterVol	$78
	smpsAlterPitch	$04
	smpsPan		$F8
	smpsSetvoice	sScratch1
	dc.b	nD5, $0C, $0C
	smpsPan		$8F
	smpsSetvoice	sScratch2
	dc.b	nD5, $18
	smpsPan		$8F
	smpsSetvoice	sScratch1
	dc.b	nFs5, $04, $04, $04, $04, $04, $04
	smpsPan		$F8
	smpsSetvoice	sScratch2
	dc.b	nD5, $14
	smpsSetvoice	sScratch1
	dc.b	nFs5, $04, nD5, $0C, nFs5, $04, nRst, nFs5
	smpsPan		$8F
	smpsSetvoice	sScratch2
	dc.b	nD5, $18
	smpsPan		$FF
	smpsSetvoice	sSaxophone
	smpsAlterPitch	$FC
	smpsLoop	$00, $02, StardustSpeedwayPast_Loop1
	smpsAlterPitch	$04
	smpsAlterNote	$0A
	smpsSetvoice	sVoxClav
	smpsPan		$FA
	smpsAlterPitch	$03

StardustSpeedwayPast_Loop2:
	dc.b	nA4, $08, nA5, $04, nD5, $04, nRst, nE5
	dc.b	nA4, $04, nRst, nG5, nA5, nRst, nG5, nC6
	dc.b	nRst, nG5, nRst, $08, nEb5, $04, nRst, $08
	dc.b	nD5, $04, nC5, nRst, nA4, nD4, $08, nA4
	dc.b	$04, nD5, nRst, $08, nD5, $04, nRst, nA4
	dc.b	nD4, nRst, nD5, nRst, $08, nD4, $04, nFs5
	dc.b	nRst, nA5, nC6, nRst, nD6, nEb6, nD6, nC6
	smpsLoop	$00, $04, StardustSpeedwayPast_Loop2
	smpsAlterNote	$00
	smpsAlterPitch	$FD
	smpsPan		$FF
	smpsAlterPitch	$FA
	smpsAlterNote	$17
	smpsSetvoice	sPiano

StardustSpeedwayPast_Loop3:
	dc.b	nRst, $18, nE6, $0C, nD6, nC6, $14, nB5
	dc.b	$10, nG5, $0C, $0C, nA5, $30, nRst, $24
	dc.b	nRst, $18, nE6, $0C, nF6, nE6, $14, nD6
	dc.b	$10, nC6, $0C, nB5, nA5, $30, nRst, $24
	smpsLoop	$00, $04, StardustSpeedwayPast_Loop3
	smpsAlterPitch	$06
	smpsAlterNote	$00
	smpsAlterPitch	$FC
	smpsSetvoice	sSaxophone
	smpsJump	StardustSpeedwayPast_Loop1

StardustSpeedwayPast_PCM2:
	dc.b	nRst, $60, nRst
	smpsSetvoice	sBass

StardustSpeedwayPast_Loop4:
	dc.b	nA4, $0C, nC5, nRst, $14, nC5, $04, nA4
	dc.b	$0C, nE4, nG4, nC5, nD5, nRst, $18, nC5
	dc.b	$0C, nRst, $08, nD5, $04, nA4, $0C, nC5
	dc.b	nG4
	smpsLoop	$00, $03, StardustSpeedwayPast_Loop4

StardustSpeedwayPast_Loop5:
	dc.b	nA4, $0C, nC5, nRst, $14, nC5, $04, nA4
	dc.b	$0C, nE4, nG4, nC5, nD5, nRst, $18, nC5
	dc.b	$0C, nRst, $08, nD5, $04, nA4, $0C, nC5
	dc.b	nG4
	smpsLoop	$00, $08, StardustSpeedwayPast_Loop5

StardustSpeedwayPast_Loop6:
	dc.b	nF4, $09, nRst, $03, nF4, $09, nRst, $03
	dc.b	nF4, $09, nRst, $03, nF4, $09, nRst, $03
	dc.b	nG4, $09, nRst, $03, nG4, $09, nRst, $03
	dc.b	nG4, $09, nRst, $03, nG4, $09, nRst, $03
	dc.b	nA4, $09, nRst, $03, nA4, $09, nRst, $03
	dc.b	nA4, $08, nE5, $04, nA4, $09, nRst, $03
	dc.b	nG4, $09, nRst, $03, nG4, $09, nRst, $03
	dc.b	nG4, $08, nD5, $04, nG4, $08, nFs4, $04
	smpsLoop	$00, $07, StardustSpeedwayPast_Loop6
	dc.b	nF4, $09, nRst, $03, nF4, $09, nRst, $03
	dc.b	nF4, $09, nRst, $03, nF4, $09, nRst, $03
	dc.b	nG4, $09, nRst, $03, nG4, $09, nRst, $03
	dc.b	nG4, $09, nRst, $03, nG4, $09, nRst, $03
	dc.b	nA4, $09, nRst, $03, nA4, $09, nRst, $03
	dc.b	nA4, $08, nE5, $04, nA4, $09, nRst, $03
	dc.b	nA4, $08, nA4, $04, nB4, $0C, nC5, $0C
	dc.b	nD5, $08, nE5, $04
	smpsJump	StardustSpeedwayPast_Loop5

StardustSpeedwayPast_PCM3:
	smpsAlterNote	$13

StardustSpeedwayPast_Loop7:
	smpsCall	StardustSpeedwayPast_Call1
	smpsLoop	$00, $04, StardustSpeedwayPast_Loop7

StardustSpeedwayPast_Loop8:
	smpsCall	StardustSpeedwayPast_Call1
	smpsLoop	$00, $08, StardustSpeedwayPast_Loop8
	smpsAlterVol	$20
	smpsAlterNote	$F6

StardustSpeedwayPast_Loop9:
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nAb3, $0C, nRst, $0C, nAb3, $0C
	dc.b	nRst, $0C, nBb3, $0C, nRst, $0C, nBb3, $0C
	smpsSetvoice	sOrgan1
	dc.b	nRst, $0C, nBb3, nRst, nBb3
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nBb3, nRst, nBb3
	smpsLoop	$00, $07, StardustSpeedwayPast_Loop9
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nAb3, $0C, nRst, $0C, nAb3, $0C
	dc.b	nRst, $0C, nBb3, $0C, nRst, $0C, nBb3, $0C
	smpsSetvoice	sOrgan1
	dc.b	nRst, $0C, nBb3, nRst, nBb3, nRst, $0C, nBb3
	dc.b	nRst, nBb3
	smpsAlterVol	$E0
	smpsAlterNote	$13
	smpsJump	StardustSpeedwayPast_Loop8

StardustSpeedwayPast_Call1:
	smpsSetvoice	sPianoChord1
	dc.b	nRst, $0C, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $04, nE3, $10
	smpsSetvoice	sPianoChord2
	dc.b	nRst, $0C, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$FF
	dc.b	nRst, $04, nE3, $10
	smpsReturn

StardustSpeedwayPast_PCM4:
	dc.b	nRst, $0C
	smpsAlterNote	$13

StardustSpeedwayPast_Loop10:
	smpsCall	StardustSpeedwayPast_Call2
	smpsLoop	$00, $04, StardustSpeedwayPast_Loop10

StardustSpeedwayPast_Loop11:
	smpsCall	StardustSpeedwayPast_Call2
	smpsLoop	$00, $08, StardustSpeedwayPast_Loop11
	smpsAlterVol	$20
	smpsAlterNote	$F6

StardustSpeedwayPast_Loop12:
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nAb3, $0C, nRst, $0C, nAb3, $0C
	dc.b	nRst, $0C, nBb3, $0C, nRst, $0C, nBb3, $0C
	smpsSetvoice	sOrgan1
	dc.b	nRst, $0C, nBb3, nRst, nBb3
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nBb3, nRst, nBb3
	smpsLoop	$00, $07, StardustSpeedwayPast_Loop12
	smpsSetvoice	sOrgan2
	dc.b	nRst, $0C, nAb3, $0C, nRst, $0C, nAb3, $0C
	dc.b	nRst, $0C, nBb3, $0C, nRst, $0C, nBb3, $0C
	smpsSetvoice	sOrgan1
	dc.b	nRst, $0C, nBb3, nRst, nBb3, nRst, $0C, nBb3
	dc.b	nRst, nBb3
	smpsAlterNote	$13
	smpsAlterVol	$E0
	smpsJump	StardustSpeedwayPast_Loop11

StardustSpeedwayPast_Call2:
	smpsPan		$F0
	smpsSetvoice	sPianoChord1
	dc.b	nRst, $0C, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $04, nE3, $10
	smpsSetvoice	sPianoChord2
	dc.b	nRst, $0C, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $08, nE3, $08
	smpsAlterVol	$C0
	smpsPan		$FF
	dc.b	$08
	smpsAlterVol	$40
	smpsPan		$F0
	dc.b	nRst, $04, nE3, $10
	smpsReturn

StardustSpeedwayPast_PCM5:
	dc.b	nRst, $18
	smpsSetvoice	sHueHueHue
	dc.b	nBb5, $30, nRst, $08, nBb5, $10, nRst, $08
	dc.b	nBb5, $10, nBb5, $30, nRst, $08, nBb5, $10
	dc.b	nRst, $08, nBb5, $10, nBb5, $30, nRst, $08
	dc.b	nBb5, $10, nRst, $08, nBb5, $10, nBb5, $30
	dc.b	nRst, $08, nBb5, $10, nRst, $08, nBb5, $10
	dc.b	nRst, $60, nRst, nRst, $48
	smpsAlterNote	$F6
	smpsAlterPitch	$FC
	smpsSetvoice	sSaxophone
	dc.b	nRst, $0C, nRst, $30, nRst, $18, nG6, $04
	dc.b	nA6, nC7, nD7, nE7, nG7

StardustSpeedwayPast_Loop13:
	dc.b	nA7, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nG7, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nE7, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nEb7, $08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$C4
	dc.b	$08, nRst, $04
	smpsAlterVol	$78
	dc.b	nD7, $08, nC7, $04, nD7, $08, nC7, $04
	smpsAlterVol	$C4
	dc.b	$08
	smpsAlterVol	$C4
	dc.b	$04
	smpsAlterVol	$78
	dc.b	nRst, $24, nG6, $08, nA6, $04, nG6, $08
	dc.b	nA6, $04, nC7, $08, nA6, $04, nG6, $08
	dc.b	nA6, $04
	smpsAlterVol	$C4
	dc.b	$08
	smpsAlterVol	$C4
	dc.b	$04, nRst, $08, nRst, $34
	smpsAlterVol	$78
	dc.b	nRst, $60
	smpsLoop	$00, $02, StardustSpeedwayPast_Loop13
	smpsAlterPitch	$04
	smpsAlterVol	$05
	smpsAlterNote	$0A
	smpsSetvoice	sVoxClav
	smpsPan		$6F
	smpsAlterPitch	$0F

StardustSpeedwayPast_Loop14:
	dc.b	nA4, $08, nA5, $04, nD5, $04, nRst, nE5
	dc.b	nA4, $04, nRst, nG5, nA5, nRst, nG5, nC6
	dc.b	nRst, nG5, nRst, $08, nEb5, $04, nRst, $08
	dc.b	nD5, $04, nC5, nRst, nA4, nD4, $08, nA4
	dc.b	$04, nD5, nRst, $08, nD5, $04, nRst, nA4
	dc.b	nD4, nRst, nD5, nRst, $08, nD4, $04, nFs5
	dc.b	nRst, nA5, nC6, nRst, nD6, nEb6, nD6, nC6
	smpsLoop	$00, $04, StardustSpeedwayPast_Loop14
	smpsAlterPitch	$F1
	smpsAlterVol	$FB
	smpsPan		$FF
	smpsAlterNote	$00
	smpsAlterPitch	$06
	smpsAlterNote	$17
	smpsAlterVol	$15
	smpsSetvoice	sPiano
	dc.b	nRst, $18, nE6, $0C, nD6, nC6, $14, nB5
	dc.b	$10, nG5, $0C, $0C, nA5, $30, nRst, $24
	dc.b	nRst, $18, nE6, $0C, nF6, nE6, $14, nD6
	dc.b	$10, nC6, $0C, nB5, nA5, $30, nRst, $24
	dc.b	nRst, $18, nE6, $0C, nD6, nC6, $14, nB5
	dc.b	$10, nG5, $0C, $0C, nA5, $30, nRst, $24
	dc.b	nRst, $18, nE6, $0C, nF6, nE6, $14, nD6
	dc.b	$10, nC6, $0C, nB5, nA5, $30, nRst, $18
	smpsAlterVol	$EB
	smpsAlterPitch	$FA
	smpsAlterVol	$7F

StardustSpeedwayPast_Loop15:
	smpsSetvoice	sPadChord1
	dc.b	nE6, $30, nFs6, $30
	smpsSetvoice	sPadChord2
	dc.b	nFs6, $30
	smpsSetvoice	sPadChord1
	dc.b	nFs6, $30
	smpsLoop	$00, $03, StardustSpeedwayPast_Loop15
	smpsSetvoice	sPadChord1
	dc.b	nE6, $30, nFs6, $30
	smpsSetvoice	sPadChord2
	dc.b	nFs6, $30, nRst, $30
	smpsAlterVol	$81
	smpsAlterNote	$F6
	smpsAlterPitch	$FC
	smpsSetvoice	sSaxophone
	dc.b	nRst, $0C
	smpsJump	StardustSpeedwayPast_Loop13

StardustSpeedwayPast_PCM6:
	smpsSetvoice	sHatClosed
	smpsPan		$F8
	smpsAlterVol	$9C
	dc.b	nC3, $04
	smpsAlterVol	$32
	dc.b	$04
	smpsAlterVol	$32
	dc.b	$04
	smpsSetvoice	sHatOpen
	smpsPan		$8F
	dc.b	nCs3, $0C
	smpsSetvoice	sHatClosed
	smpsPan		$F8
	dc.b	nC3, $08, $04
	smpsSetvoice	sHatOpen
	smpsPan		$8F
	dc.b	nCs3, $0C
	smpsSetvoice	sHatClosed
	smpsPan		$F8
	dc.b	nC3, $08, $04
	smpsPan		$8F
	smpsSetvoice	sHatOpen
	dc.b	nCs3, $0C
	smpsPan		$F8
	smpsSetvoice	sHatClosed
	dc.b	nC3, $08, $04
	smpsPan		$8F
	smpsSetvoice	sHatOpen
	dc.b	nCs3, $0C
	smpsJump	StardustSpeedwayPast_PCM6

StardustSpeedwayPast_PCM8:
	dc.b	nRst, $60, nRst, nRst
	smpsSetvoice	sTom
	smpsPan		$0F
	dc.b	nEb4, $04, nRst, $04, nEb4, $04, $04, $04
	dc.b	$04
	smpsPan		$8F
	dc.b	nBb3, $04, nRst, $04, nBb3, $04, $04, $04
	dc.b	$04
	smpsPan		$F8
	dc.b	nEb3, $04, $04, $04, $04, $04, $04
	smpsPan		$F0
	dc.b	nAb2, $04, $04, $04, $04, $04, $04
	smpsPan		$FF

StardustSpeedwayPast_Jump1:
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $14, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08, $0C, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $14, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $08
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3
	smpsSetvoice	sKick
	dc.b	nF3, $04, $08
	smpsSetvoice	sSnare
	dc.b	nC3, $04, $04, $04
	smpsPan		$F8
	smpsSetvoice	sTom
	dc.b	nBb3, $04, nBb3
	smpsPan		$8F
	dc.b	nRst, nEb3
	smpsPan		$FF
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $14, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08, $0C, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $14, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $04
	smpsSetvoice	sKick
	dc.b	nF3, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $14, $0C
	smpsSetvoice	sKick
	dc.b	nF3, $04, $0C
	smpsSetvoice	sSnare
	dc.b	nC3, $08
	smpsSetvoice	sKick
	dc.b	nF3, $04
	smpsSetvoice	sSnare
	dc.b	nC3, nC3, nC3
	smpsJump	StardustSpeedwayPast_Jump1

StardustSpeedwayPast_PCM7:
	smpsStop

StardustSpeedwayPast_Rhythm:
	smpsStop
