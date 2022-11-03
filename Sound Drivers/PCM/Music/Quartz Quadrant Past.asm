QuartzQuadrantPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $07
	smpsHeaderPCM		QuartzQuadrantPast_Rhythm, $00, $FF
	smpsHeaderPCM		QuartzQuadrantPast_PCM1, $EF, $FF
	smpsHeaderPCM		QuartzQuadrantPast_PCM2, $DC, $BF
	smpsHeaderPCM		QuartzQuadrantPast_PCM3, $C7, $9F
	smpsHeaderPCM		QuartzQuadrantPast_PCM4, $C7, $9F
	smpsHeaderPCM		QuartzQuadrantPast_PCM5, $00, $DF
	smpsHeaderPCM		QuartzQuadrantPast_PCM6, $00, $AF
	smpsHeaderPCM		QuartzQuadrantPast_PCM8, $00, $FF
	smpsHeaderPCM		QuartzQuadrantPast_PCM7, $00, $FF

QuartzQuadrantPast_PCM1:
	smpsAlterNote	$F0
	smpsPan		$F8
	smpsSetvoice	sPianoChord1
	smpsCall	QuartzQuadrantPast_Call1
	smpsSetvoice	sPianoChord2
	smpsCall	QuartzQuadrantPast_Call1
	smpsLoop	$00, $02, QuartzQuadrantPast_PCM1

QuartzQuadrantPast_Loop1:
	smpsAlterNote	$F0
	smpsPan		$F8
	smpsSetvoice	sPianoChord1
	smpsCall	QuartzQuadrantPast_Call1
	smpsSetvoice	sPianoChord2
	smpsCall	QuartzQuadrantPast_Call1
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop1
	smpsAlterNote	$08
	smpsAlterPitch	$D5
	smpsSetvoice	sChoir
	smpsAlterVol	$D0
	dc.b	nB6, $12, nA6, nG6, $18, nE6, $24, nB6
	dc.b	$12, nA6, nG6, $18, nE6, nRst, $09, nF6
	dc.b	$03, nFs6, $12, nE6, $24, nRst, $2A, nRst
	dc.b	$60
	smpsAlterPitch	$2B
	smpsAlterVol	$30
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsAlterVol	$D0
	smpsAlterPitch	$E0
	smpsSetvoice	sToyPiano
	smpsAlterNote	$00

QuartzQuadrantPast_Loop3:
	smpsPan		$FF
	dc.b	nE6, $30

QuartzQuadrantPast_Loop2:
	dc.b	smpsNoAttack, $06
	smpsAlterVol	$F1
	smpsLoop	$00, $08, QuartzQuadrantPast_Loop2
	smpsAlterVol	$78
	dc.b	nRst, $18, nE6, $0C, nG6, nB6, $12, nG6
	dc.b	nE6, $09, nG6, $03, nA6, $18
	smpsPan		$F0
	smpsAlterVol	$E0
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$E0
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$E0
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$F0
	dc.b	nA6
	smpsAlterVol	$20
	smpsAlterVol	$20
	smpsAlterVol	$20
	smpsAlterVol	$40
	smpsLoop	$01, $03, QuartzQuadrantPast_Loop3
	smpsAlterPitch	$20
	smpsAlterVol	$30
	smpsPan		$F8

QuartzQuadrantPast_Loop4:
	smpsSetvoice	sPianoChord1
	smpsCall	QuartzQuadrantPast_Call1
	smpsSetvoice	sPianoChord2
	smpsCall	QuartzQuadrantPast_Call1
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop4
	smpsJump	QuartzQuadrantPast_Loop1

QuartzQuadrantPast_Call1:
	dc.b	nC4, $0F, nRst, $09
	smpsAlterVol	$C0
	smpsPan		$0F
	dc.b	nC4, $0F, nRst, $09
	smpsAlterVol	$C0
	smpsPan		$F0
	dc.b	nC4, $0F, nRst, $09
	smpsAlterVol	$C0
	smpsPan		$8F
	dc.b	nC4, $0F, nRst, $09
	smpsAlterVol	$40
	smpsAlterVol	$40
	smpsPan		$F8
	dc.b	nC4, $06, nRst, $0C, nC4, $06, nRst, $0C
	dc.b	nC4, $06, nRst, $12, nC4, $06, nRst, $0C
	dc.b	nC4, $12
	smpsAlterVol	$40
	smpsReturn

QuartzQuadrantPast_PCM2:
	dc.b	nRst, $60
	smpsLoop	$00, $04, QuartzQuadrantPast_PCM2
	smpsSetvoice	sBass

QuartzQuadrantPast_Loop5:
	smpsCall	QuartzQuadrantPast_Call2
	smpsLoop	$00, $04, QuartzQuadrantPast_Loop5

QuartzQuadrantPast_Loop6:
	smpsCall	QuartzQuadrantPast_Call2
	smpsLoop	$00, $06, QuartzQuadrantPast_Loop6
	smpsCall	QuartzQuadrantPast_Call3
	smpsLoop	$01, $02, QuartzQuadrantPast_Loop6

QuartzQuadrantPast_Loop7:
	dc.b	nF3, $12, nC4, $0C, nEb4, $03, nF4, nG4
	dc.b	$18, nF4, $12, nC4, nG3, nD4, $0C, nF4
	dc.b	$03, nG4, nA4, $18, nG4, $12, nD4, nA3
	dc.b	nE4, $0C, nG4, $03, nA4, nB4, $18, nG4
	dc.b	$12, nE4, nA3, $06, nRst, $0C, nA3, $06
	dc.b	nRst, $0C, nA3, $06, nRst, $0C, nA3, $06
	dc.b	nC4, nA3, nD4, nA3, nG4, nA3
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop7
	dc.b	nF3, $12, nC4, $0C, nEb4, $03, nF4, nG4
	dc.b	$18, nF4, $12, nC4, nG3, nD4, $0C, nF4
	dc.b	$03, nG4, nA4, $18, nG4, $12, nD4, nA3
	dc.b	nE4, $0C, nG4, $03, nA4, nB4, $18, nG4
	dc.b	$12, nE4, nA3, $06, nRst, $0C, nA3, $06
	dc.b	nRst, $0C, nA3, $06, nRst, nE4, nA4, nD5
	dc.b	nC5, $0C, nB4, $06, nG3, $0C

QuartzQuadrantPast_Loop8:
	smpsCall	QuartzQuadrantPast_Call2
	smpsLoop	$00, $08, QuartzQuadrantPast_Loop8
	smpsJump	QuartzQuadrantPast_Loop6

QuartzQuadrantPast_Call2:
	dc.b	nA3, $12, nE4, $0C, nG4, $03, nA4, nB4
	dc.b	$18, nG4, $12, nE4
	smpsReturn

QuartzQuadrantPast_Call3:
	dc.b	nA3, $12, nE4, $0C, nG4, $03, nA4, nB4
	dc.b	$18, nG4, $12, nE4, nA3, $06, nRst, $0C
	dc.b	nG3, $06, nRst, $0C, nA3, $06, nRst, $12
	dc.b	nF4, $06, nG4, nRst, nG3, nD4, nC4
	smpsReturn

QuartzQuadrantPast_PCM3:
	smpsPan		$3F
	smpsSetvoice	sLogDrum

QuartzQuadrantPast_Loop9:
	smpsCall	QuartzQuadrantPast_Call4
	smpsLoop	$00, $03, QuartzQuadrantPast_Loop9
	smpsCall	QuartzQuadrantPast_Call4

QuartzQuadrantPast_Jump1:
	smpsPan		$3F
	smpsSetvoice	sLogDrum

QuartzQuadrantPast_Loop10:
	smpsCall	QuartzQuadrantPast_Call4
	smpsLoop	$00, $03, QuartzQuadrantPast_Loop10
	smpsCall	QuartzQuadrantPast_Call4
	smpsLoop	$01, $02, QuartzQuadrantPast_Loop10
	smpsAlterVol	$60

QuartzQuadrantPast_Loop11:
	dc.b	nRst, $0C, nA6, $06, nRst, nA6, nRst, $12
	dc.b	nA6, $06, nRst, nB6, nC7, nRst, nB6, nA6
	dc.b	nRst, nRst, $0C, nB6, $06, nRst, nB6, nRst
	dc.b	$12, nB6, $06, nRst, nC7, nD7, nRst, nC7
	dc.b	nB6, nRst, nRst, $0C, nC7, $06, nRst, nC7
	dc.b	nRst, $12, nC7, $06, nRst, nD7, nE7, nRst
	dc.b	nD7, nC7, nRst, nC7, nRst, $0C, nC7, $06
	dc.b	nRst, $0C, nC7, $06, nRst, $0C, nG6, $06
	dc.b	nA6, nG6, nC7, nA6, nD7, nA6
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop11
	dc.b	nRst, $0C, nA6, $06, nRst, nA6, nRst, $12
	dc.b	nA6, $06, nRst, nB6, nC7, nRst, nB6, nA6
	dc.b	nRst, nRst, $0C, nB6, $06, nRst, nB6, nRst
	dc.b	$12, nB6, $06, nRst, nC7, nD7, nRst, nC7
	dc.b	nB6, nRst, nRst, $0C, nC7, $06, nRst, nC7
	dc.b	nRst, $12, nC7, $06, nRst, nD7, nE7, nRst
	dc.b	nD7, nC7, nRst, nC7, nRst, $0C, nC7, $06
	dc.b	nRst, $0C, nC7, $06, nRst, $36
	smpsAlterVol	$A0
	smpsPan		$FF
	smpsAlterNote	$F0
	smpsAlterVol	$C0
	smpsAlterPitch	$08
	smpsSetvoice	sPianoHigh
	dc.b	nRst, $0C, nC7, $06, nA6, nE6, nA6, nG6
	dc.b	nE6, nEb6, nD6, nC6, nEb6, nE6, nD6, nC6
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	smpsAlterNote	$E0
	dc.b	nA5, nC6, nRst, nC6, nA5, nRst, $3C, nA5
	dc.b	$06, nG5, nC6, nA5, nG5, nE5, nA5, nE5
	dc.b	nD5, nEb5, nD5, nEb5, nD5, nEb5, nD5, nEb5
	dc.b	nD5, nEb5, nD5, nEb5, nE5, nG5, nAb5, nA5
	dc.b	nC6
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	smpsAlterNote	$F0
	dc.b	nD6, nRst, $0C, nC6, $06, nRst, nD6, nRst
	dc.b	nC6, nD6, nRst, nEb6, nE6, nRst, nG6, nRst
	dc.b	nG6, nEb6, nD6, nC6, nD6, nRst, nC6, nA5
	dc.b	nD6, nC6
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	smpsAlterNote	$E0
	dc.b	nA5
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	smpsAlterNote	$F0
	dc.b	nA6, $0C, nG6, $06, nRst, nA6, nEb6, nD6
	dc.b	nC6, nD6, nE6, nRst, nC6, nRst, nD6, nEb6
	dc.b	nE6, nC6
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	smpsAlterNote	$E0
	dc.b	nA5, nG5
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	smpsAlterNote	$F0
	dc.b	nF6, nD6
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	smpsAlterNote	$E0
	dc.b	nB5, nG5, nE5
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	smpsAlterNote	$F0
	dc.b	nA6, nE6, nC6
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	smpsAlterNote	$E0
	dc.b	nA5, nG5
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	smpsAlterNote	$F0
	dc.b	nB6, nG6, nE6, nG6, nB6, nD7, $0C, nC7
	dc.b	$06, nB6, $03, nC7, nB6, $06, nE6, nRst
	dc.b	nG6, $0C, nA6, $06, nRst, nG6, nA6
	smpsAlterVol	$40
	smpsAlterPitch	$F8
	smpsAlterNote	$00
	smpsJump	QuartzQuadrantPast_Jump1

QuartzQuadrantPast_Call4:
	dc.b	nRst, $0C, nC7, $06, nRst, nC7, nRst, $12
	dc.b	nC7, $06, nRst, $0C, nC7, $06, nRst, $0C
	dc.b	nC7, $06, nRst, nRst, $0C, nC7, $06, nRst
	dc.b	nC7, nRst, $12, nC7, $06, nRst, $0C, nC7
	dc.b	$06, nRst, nC7, nRst, nC7
	smpsReturn
	
	; Unused
	dc.b	nRst, $0C, nD7, $06, nRst, nD7, nRst, $12
	dc.b	nD7, $06, nRst, $0C, nD7, $06, nRst, $0C
	dc.b	nD7, $06, nRst, nRst, $0C, nD7, $06, nRst
	dc.b	nD7, nRst, $12, nD7, $06, nRst, $0C, nD7
	dc.b	$06, nRst, nD7, nRst, nD7
	smpsReturn

QuartzQuadrantPast_PCM4:
	smpsPan		$F3
	smpsSetvoice	sLogDrum
	smpsCall	QuartzQuadrantPast_Call5

QuartzQuadrantPast_Jump2:
	smpsPan		$F3
	smpsSetvoice	sLogDrum

QuartzQuadrantPast_Loop12:
	smpsCall	QuartzQuadrantPast_Call5
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop12
	smpsAlterVol	$50

QuartzQuadrantPast_Loop13:
	dc.b	nRst, $0C, nC7, $06, nRst, nC7, nRst, $12
	dc.b	nC7, $06, nRst, nD7, nE7, nRst, nD7, nC7
	dc.b	nRst, nRst, $0C, nD7, $06, nRst, nD7, nRst
	dc.b	$12, nD7, $06, nRst, nE7, nF7, nRst, nE7
	dc.b	nD7, nRst, nRst, $0C, nE7, $06, nRst, nE7
	dc.b	nRst, $12, nE7, $06, nRst, nF7, nG7, nRst
	dc.b	nF7, nE7, nRst, nE7, nRst, $0C, nE7, $06
	dc.b	nRst, $0C, nE7, $06, nRst, $0C, nB6, $06
	dc.b	nC7, nB6, nE7, nC7, nF7, nC7
	smpsLoop	$00, $02, QuartzQuadrantPast_Loop13
	dc.b	nRst, $0C, nC7, $06, nRst, nC7, nRst, $12
	dc.b	nC7, $06, nRst, nD7, nE7, nRst, nD7, nC7
	dc.b	nRst, nRst, $0C, nD7, $06, nRst, nD7, nRst
	dc.b	$12, nD7, $06, nRst, nE7, nF7, nRst, nE7
	dc.b	nD7, nRst, nRst, $0C, nE7, $06, nRst, nE7
	dc.b	nRst, $12, nE7, $06, nRst, nF7, nG7, nRst
	dc.b	nF7, nE7, nRst, nA7, nRst, $0C, nA7, $06
	dc.b	nRst, $0C, nA7, $06, nRst, $36
	smpsAlterVol	$B0
	smpsAlterNote	$F0
	smpsAlterVol	$D0
	smpsAlterVol	$C0
	dc.b	nRst, $07
	smpsPan		$8F
	smpsAlterPitch	$08
	smpsSetvoice	sPianoHigh
	dc.b	nRst, $0C, nC7, $06, nA6, nE6, nA6, nG6
	dc.b	nE6, nEb6, nD6, nC6, nEb6, nE6, nD6, nC6
	smpsAlterNote	$E0
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	dc.b	nA5, nC6, nRst, nC6, nA5, nRst, $3C, nA5
	dc.b	$06, nG5, nC6, nA5, nG5, nE5, nA5, nE5
	dc.b	nD5, nEb5, nD5, nEb5, nD5, nEb5, nD5, nEb5
	dc.b	nD5, nEb5, nD5, nEb5, nE5, nG5, nAb5, nA5
	dc.b	nC6
	smpsAlterNote	$F0
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	dc.b	nD6, nRst, $0C, nC6, $06, nRst, nD6, nRst
	dc.b	nC6, nD6, nRst, nEb6, nE6, nRst, nG6, nRst
	dc.b	nG6, nEb6, nD6, nC6, nD6, nRst, nC6, nA5
	dc.b	nD6, nC6
	smpsAlterNote	$E0
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	dc.b	nA5
	smpsAlterNote	$F0
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	dc.b	nA6, $0C, nG6, $06, nRst, nA6, nEb6, nD6
	dc.b	nC6, nD6, nE6, nRst, nC6, nRst, nD6, nEb6
	dc.b	nE6, nC6
	smpsAlterNote	$E0
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	dc.b	nA5, nG5
	smpsAlterNote	$F0
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	dc.b	nF6, nD6
	smpsAlterNote	$E0
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	dc.b	nB5, nG5, nE5
	smpsAlterNote	$F0
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	dc.b	nA6, nE6, nC6
	smpsAlterNote	$E0
	smpsSetvoice	sPianoLow
	smpsAlterPitch	$0C
	dc.b	nA5, nG5
	smpsAlterNote	$F0
	smpsSetvoice	sPianoHigh
	smpsAlterPitch	$F4
	dc.b	nB6, nG6, nE6, nG6, nB6, nD7, $0C, nC7
	dc.b	$06, nB6, $03, nC7, nB6, $06, nE6, nRst
	dc.b	nG6, $0C, nA6, $06, nRst, nG6, $05
	smpsAlterNote	$00
	smpsAlterPitch	$F8
	smpsAlterVol	$30
	smpsAlterVol	$40
	smpsJump	QuartzQuadrantPast_Jump2

QuartzQuadrantPast_Call5:
	dc.b	nRst, $0C, nE7, $06, nRst, nE7, nRst, $12
	dc.b	nE7, $06, nRst, $0C, nE7, $06, nRst, $0C
	dc.b	nE7, $06, nRst, nRst, $0C, nE7, $06, nRst
	dc.b	nE7, nRst, $12, nE7, $06, nRst, $0C, nE7
	dc.b	$06, nRst, nE7, nRst, nE7, nRst, $0C, nFs7
	dc.b	$06, nRst, nFs7, nRst, $12, nFs7, $06, nRst
	dc.b	$0C, nFs7, $06, nRst, $0C, nFs7, $06, nRst
	dc.b	nRst, $0C, nFs7, $06, nRst, nFs7, nRst, $12
	dc.b	nFs7, $06, nRst, $0C, nFs7, $06, nRst, nFs7
	dc.b	nRst, nFs7, nRst, $0C, nG7, $06, nRst, nG7
	dc.b	nRst, $12, nG7, $06, nRst, $0C, nG7, $06
	dc.b	nRst, $0C, nG7, $06, nRst, nRst, $0C, nG7
	dc.b	$06, nRst, nG7, nRst, $12, nG7, $06, nRst
	dc.b	$0C, nG7, $06, nRst, nG7, nRst, nG7, nRst
	dc.b	$0C, nA7, $06, nRst, nA7, nRst, $12, nA7
	dc.b	$06, nRst, $0C, nA7, $06, nRst, $0C, nA7
	dc.b	$06, nRst, nRst, $0C, nA7, $06, nRst, nA7
	dc.b	nRst, $12, nA7, $06, nRst, $0C, nA7, $06
	dc.b	nRst, nA7, nRst, nA7
	smpsReturn

QuartzQuadrantPast_PCM5:
	smpsAlterNote	$08
	smpsAlterPitch	$C4
	smpsSetvoice	sChoir
	smpsAlterVol	$D0
	dc.b	nB6, $12, nA6, nG6, $18, nE6, $24, nB6
	dc.b	$12, nA6, nG6, $18, nE6, nRst, $09, nF6
	dc.b	$03, nFs6, $12, nE6, $24, nRst, $2A
	smpsAlterPitch	$3C
	smpsAlterVol	$30
	dc.b	nRst, $60, nRst, nRst, nRst, nRst
	smpsAlterNote	$00

QuartzQuadrantPast_Jump3:
	smpsSetvoice	sCymbal
	dc.b	nB2, $18
	smpsPan		$8F

QuartzQuadrantPast_Loop14:
	smpsAlterVol	$98
	smpsSetvoice	sCowbell
	dc.b	nB2, $06, $06
	smpsAlterVol	$68
	dc.b	$06, $06
	smpsLoop	$00, $1F, QuartzQuadrantPast_Loop14
	smpsAlterPitch	$C4
	smpsPan		$0F
	smpsAlterVol	$C0
	smpsAlterNote	$08
	smpsSetvoice	sChoir
	smpsAlterVol	$D0
	dc.b	nRst, $09, nB6, $12, nA6, nG6, $18, nE6
	dc.b	$24, nB6, $12, nA6, nG6, $18, nE6, nRst
	dc.b	$09, nF6, $03, nFs6, $12, nE6, $24, nRst
	dc.b	$21, nRst, $60
	smpsAlterVol	$30
	smpsAlterVol	$40
	smpsAlterPitch	$3C
	smpsPan		$8F

QuartzQuadrantPast_Loop15:
	smpsAlterVol	$98
	smpsSetvoice	sCowbell
	dc.b	nB2, $06, $06
	smpsAlterVol	$68
	dc.b	$06, $06
	smpsLoop	$00, $10, QuartzQuadrantPast_Loop15
	smpsAlterVol	$D0
	smpsAlterPitch	$CF
	smpsSetvoice	sToyPiano
	smpsAlterNote	$00
	smpsAlterVol	$9B

QuartzQuadrantPast_Loop17:
	dc.b	nRst, $0F
	smpsPan		$8F
	dc.b	nE6, $30

QuartzQuadrantPast_Loop16:
	dc.b	smpsNoAttack, $06
	smpsAlterVol	$F8
	smpsLoop	$00, $08, QuartzQuadrantPast_Loop16
	smpsAlterVol	$40
	dc.b	nRst, $18, nE6, $0C, nG6, nB6, $12, nG6
	dc.b	nE6, $09, nG6, $03, nA6, $18
	smpsPan		$0F
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$F0
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$FB
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$FB
	dc.b	nA6
	smpsPan		$F0
	smpsAlterVol	$FB
	dc.b	nA6
	smpsPan		$0F
	smpsAlterVol	$FB
	dc.b	nA6, $09
	smpsAlterVol	$10
	smpsAlterVol	$10
	smpsAlterVol	$10
	smpsAlterVol	$14
	smpsLoop	$01, $02, QuartzQuadrantPast_Loop17
	smpsAlterVol	$30
	smpsAlterVol	$30
	smpsPan		$8F
	smpsAlterPitch	$0C
	dc.b	nA5, $30, nC6, $30, nB5, $0C, nRst, $0C
	dc.b	nG5, $0C, nB5, nD6, $12, nB5, nG5, $09
	dc.b	nB5, $03, nC6, $18
	smpsPan		$0F
	smpsAlterVol	$E0
	dc.b	nC6
	smpsPan		$F0
	smpsAlterVol	$E0
	dc.b	nC6
	smpsPan		$0F
	smpsAlterVol	$E0
	dc.b	nC6
	smpsPan		$F0
	smpsAlterVol	$FB
	dc.b	nC6
	smpsPan		$0F
	smpsAlterVol	$FB
	dc.b	nC6
	smpsPan		$F0
	smpsAlterVol	$FB
	dc.b	nC6
	smpsPan		$0F
	smpsAlterVol	$FB
	dc.b	nC6, $18
	smpsAlterVol	$20
	smpsAlterVol	$20
	smpsAlterVol	$20
	smpsAlterVol	$14
	smpsAlterPitch	$F4
	smpsAlterVol	$D0
	smpsAlterPitch	$31
	smpsAlterVol	$65
	smpsPan		$8F

QuartzQuadrantPast_Loop18:
	smpsAlterVol	$98
	smpsSetvoice	sCowbell
	dc.b	nB2, $06, $06
	smpsAlterVol	$68
	dc.b	$06, $06
	smpsLoop	$00, $20, QuartzQuadrantPast_Loop18
	smpsJump	QuartzQuadrantPast_Jump3

QuartzQuadrantPast_PCM6:
	smpsPan		$9F
	smpsAlterVol	$B0
	smpsSetvoice	sCabasa
	dc.b	nB2, $06, $06
	smpsPan		$FD
	smpsAlterVol	$50
	dc.b	$06, $06
	smpsLoop	$00, $20, QuartzQuadrantPast_PCM6

QuartzQuadrantPast_Loop19:
	smpsPan		$9F
	smpsAlterVol	$B0
	smpsSetvoice	sCabasa
	dc.b	nB2, $06, $06
	smpsPan		$FD
	smpsAlterVol	$50
	dc.b	$06, $06
	smpsLoop	$00, $6C, QuartzQuadrantPast_Loop19
	dc.b	nRst, $60

QuartzQuadrantPast_Loop20:
	smpsPan		$9F
	smpsAlterVol	$B0
	smpsSetvoice	sCabasa
	dc.b	nB2, $06, $06
	smpsPan		$FD
	smpsAlterVol	$50
	dc.b	$06, $06
	smpsLoop	$00, $20, QuartzQuadrantPast_Loop20
	smpsJump	QuartzQuadrantPast_Loop19

QuartzQuadrantPast_PCM8:
	smpsAlterNote	$08
	smpsPan		$0F
	smpsAlterVol	$B0
	smpsAlterPitch	$C4
	smpsSetvoice	sChoir
	smpsAlterVol	$D0
	dc.b	nRst, $09, nB6, $12, nA6, nG6, $18, nE6
	dc.b	$24, nB6, $12, nA6, nG6, $18, nE6, nRst
	dc.b	$09, nF6, $03, nFs6, $12, nE6, $24, nRst
	dc.b	$21
	smpsAlterVol	$30
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsAlterPitch	$3C
	smpsAlterVol	$50
	smpsPan		$FF
	smpsAlterNote	$00
	smpsSetvoice	sSnare
	dc.b	nBb2, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06

QuartzQuadrantPast_Loop21:
	smpsCall	QuartzQuadrantPast_Call6
	smpsLoop	$00, $03, QuartzQuadrantPast_Loop21
	smpsCall	QuartzQuadrantPast_Call7
	smpsLoop	$01, $02, QuartzQuadrantPast_Loop21
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call8
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call7
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call9
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call6
	smpsCall	QuartzQuadrantPast_Call7
	smpsJump	QuartzQuadrantPast_Loop21

QuartzQuadrantPast_Call6:
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1, $06
	smpsSetvoice	sSnare
	dc.b	nBb2, $06
	smpsSetvoice	sKick
	dc.b	nG1, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $12, $06
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $06
	smpsSetvoice	sSnare
	dc.b	nBb2, $03, $03, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1, $06
	smpsSetvoice	sSnare
	dc.b	nBb2, $06
	smpsSetvoice	sKick
	dc.b	nG1, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $12, $06
	smpsReturn

QuartzQuadrantPast_Call7:
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $12, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2, $03, $03, $06, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2, $0C, $06
	smpsReturn

QuartzQuadrantPast_Call8:
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $12, $06
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $06
	smpsSetvoice	sSnare
	dc.b	nBb2, $03, $03, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sSnare
	dc.b	nBb2, $0C, $06
	smpsReturn

QuartzQuadrantPast_Call9:
	smpsSetvoice	sKick
	dc.b	nG1, $0C, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $06, $0C, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1, $0C
	smpsSetvoice	sSnare
	dc.b	nBb2, $12, $06, $06
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sKick
	dc.b	nG1
	smpsSetvoice	sSnare
	dc.b	nBb2, $3C
	smpsReturn

QuartzQuadrantPast_PCM7:
	smpsStop

QuartzQuadrantPast_Rhythm:
	smpsStop
