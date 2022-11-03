MetallicMadnessPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $0B
	smpsHeaderPCM		MetallicMadnessPast_Rhythm, $00, $FF
	smpsHeaderPCM		MetallicMadnessPast_PCM1, $DB, $FF
	smpsHeaderPCM		MetallicMadnessPast_PCM2, $DB, $EF
	smpsHeaderPCM		MetallicMadnessPast_PCM3, $CE, $BF
	smpsHeaderPCM		MetallicMadnessPast_PCM4, $CE, $BF
	smpsHeaderPCM		MetallicMadnessPast_PCM5, $DB, $8F
	smpsHeaderPCM		MetallicMadnessPast_PCM6, $DB, $FF
	smpsHeaderPCM		MetallicMadnessPast_PCM8, $DB, $FF
	smpsHeaderPCM		MetallicMadnessPast_PCM7, $DB, $BF

MetallicMadnessPast_PCM1:
	dc.b	nRst, $60, nRst
	smpsSetvoice	sOrchHit1
	smpsAlterPitch	$FB

MetallicMadnessPast_Loop1:
	dc.b	nE6, $12, nEb6, $12, nD6, $18, nC6, $0C
	dc.b	nA5, $18
	smpsLoop	$00, $02, MetallicMadnessPast_Loop1
	dc.b	nA5, $18
	smpsAlterVol	$B0
	dc.b	nA5
	smpsAlterVol	$B0
	dc.b	nA5
	smpsAlterVol	$D0
	dc.b	nA5
	smpsAlterVol	$50
	smpsAlterVol	$50
	smpsAlterVol	$30
	smpsAlterPitch	$05
	dc.b	nRst, $60, nRst, nRst, $30
	smpsSetvoice	sWoosh
	dc.b	nC4, $30

MetallicMadnessPast_Loop2:
	smpsCall	MetallicMadnessPast_Call1
	smpsLoop	$00, $04, MetallicMadnessPast_Loop2
	smpsSetvoice	sSynth
	smpsAlterVol	$C0
	smpsAlterPitch	$E7
	smpsAlterNote	$00
	dc.b	nA6, $06, nE7, nRst, nC7, nRst, nD7, nE7
	dc.b	nG6, nRst, nEb7, nD7, $0C, nC7, $06, nG6
	dc.b	$0C, nAb6, $06, nA6, nC7, nD7, nA6, nE6
	dc.b	nG6, nA6, nD6, nRst, nC6, nC7, $0C, $06
	dc.b	nA6, nG6, nE6, nEb6, nD6, nC6, nA5, nD6
	dc.b	nEb6, nE6, nG6, nA6, nC7, nD7, nC7, nRst
	dc.b	nA6, nC7, nD7, nRst, nG5, nA5, nG5, nAb5
	dc.b	nC6, $0C, nE6, nF6, nAb6, nC7, nEb7, $06
	dc.b	nE7, nF7, nE7, nD7, nB6, nC7, nD7, nG6
	dc.b	nRst, nA6, nRst, nC7, nD7, nEb7, nC7, nG6
	dc.b	nA6, nC7, nA6, $0C, nE6, $06, nRst, nG6
	dc.b	nA6, nA5, nC7, $0C, $06, $06, nEb6, nD6
	dc.b	nC6, nD6, $0C, $06, nEb6, nD6, nC6, nA5
	dc.b	nG5, nD6, nEb6, nD6, nC6, nA5, nG5, nD6
	dc.b	nEb6, nD6, nC6, nA5, nG5, nA5, $0C, nC6
	dc.b	$06, nD6, $0C, nEb6, $06, nE6, nG6, nAb6
	dc.b	nA6, nC7, nD7
	smpsAlterVol	$40
	smpsAlterPitch	$19
	smpsSetvoice	sOrchHit1
	smpsAlterPitch	$FB

MetallicMadnessPast_Loop3:
	dc.b	nE6, $12, nEb6, $12, nD6, $18, nC6, $0C
	dc.b	nA5, $18
	smpsLoop	$00, $04, MetallicMadnessPast_Loop3
	smpsAlterPitch	$05

MetallicMadnessPast_Loop4:
	smpsCall	MetallicMadnessPast_Call1
	smpsLoop	$00, $04, MetallicMadnessPast_Loop4
	smpsSetvoice	sBass
	smpsAlterVol	$D0
	smpsAlterNote	$25

MetallicMadnessPast_Loop5:
	dc.b	nD5, $0C, nC5, nD5, nRst, $06, nD5, nRst
	dc.b	nD5, nC5, $0C, nD5, nRst, $06, nD5, nD5
	dc.b	$0C, nF5, nG5, nAb5, nG5, nF5, nD5, nC5
	dc.b	nA4, $0C, nG4, nA4, nRst, $06, nA4, nRst
	dc.b	nA4, nG4, $0C, nA4, nRst, $06, nA4, nA4
	dc.b	$0C, nC5, nA4, nG4, nA4, $06, nRst, nRst
	dc.b	nA4, nRst, nA4, nC5, $0C
	smpsLoop	$00, $02, MetallicMadnessPast_Loop5
	smpsAlterVol	$30
	smpsAlterNote	$00
	smpsJump	MetallicMadnessPast_PCM1
	smpsStop	; Unused

MetallicMadnessPast_Call1:
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $0C
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord1
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord1
	dc.b	nB5, $06
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nB5, nA5
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord1
	dc.b	nFs5
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nE5, nFs5
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord1
	dc.b	nAb5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord1
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $0C
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $06
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, nFs5
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsReturn

MetallicMadnessPast_PCM2:
	dc.b	nRst, $60, nRst, nRst, nRst
	smpsAlterNote	$15
	smpsSetvoice	sBass

MetallicMadnessPast_Loop6:
	dc.b	nD5, $0C, nF5, nD5, nCs5, $06, nC5, nA4
	dc.b	$0C, nG4, $06, nF4, nG4, $0C, nF4, $06
	dc.b	nC4
	smpsLoop	$00, $20, MetallicMadnessPast_Loop6

MetallicMadnessPast_Loop7:
	dc.b	nD5, $0C, nC5, nD5, nRst, $06, nD5, nRst
	dc.b	nD5, nC5, $0C, nD5, nRst, $06, nF5, nD5
	dc.b	$0C, nF5, nG5, nAb5, nG5, nF5, nD5, nC5
	dc.b	nA4, $0C, nG4, nA4, nRst, $06, nA4, nRst
	dc.b	nA4, nG4, $0C, nA4, nRst, $06, nC5, nA4
	dc.b	$0C, nC5, nA4, nG4, nA4, $06, nRst, nRst
	dc.b	nA4, nRst, nA4, nC5, $0C
	smpsLoop	$00, $02, MetallicMadnessPast_Loop7
	smpsJump	MetallicMadnessPast_PCM2

MetallicMadnessPast_PCM3:
	smpsPan		$0F
	smpsSetvoice	sFantasia
	smpsAlterPitch	$FB

MetallicMadnessPast_Loop8:
	dc.b	nA5, $06, nB5, nC6, nG6, nB6, nC7, nE7
	dc.b	nD7, nB5, nC6, nG6, nB5, nC6, nD6, nE6
	dc.b	nC6, nEb5, nA4, nC5, nEb5, nA5, nEb5, nC5
	dc.b	nA5, nC6, nEb6, nA6, nC7, nEb7, nA6, nC7
	dc.b	nEb7
	smpsLoop	$00, $12, MetallicMadnessPast_Loop8
	smpsAlterPitch	$05
	smpsPan		$FF

MetallicMadnessPast_Loop9:
	smpsSetvoice	sOrchHit2
	smpsPan		$7F
	smpsAlterVol	$E0
	smpsAlterPitch	$0D
	smpsAlterNote	$EC
	dc.b	nD5, $0C, nC5, nD5, $12, nD5, $06, nRst
	dc.b	nD5, nC5, $0C, nD5, $12, nD5, $06
	smpsAlterPitch	$F3
	smpsAlterVol	$20
	smpsAlterNote	$00
	smpsSetvoice	sPad
	smpsPan		$F7
	smpsAlterPitch	$16
	smpsAlterNote	$20
	dc.b	nD5, $0C, nF5, nG5, nAb5, nG5, nF5, nD5
	dc.b	nC5
	smpsAlterNote	$00
	smpsAlterPitch	$EA
	smpsSetvoice	sOrchHit2
	smpsPan		$7F
	smpsAlterVol	$E0
	smpsAlterPitch	$0D
	smpsAlterNote	$EC
	dc.b	nA4, $0C, nG4, nA4, $12, nA4, $06, nRst
	dc.b	nA4, nG4, $0C, nA4, $12, nA4, $06
	smpsAlterNote	$00
	smpsAlterPitch	$F3
	smpsAlterVol	$20
	smpsSetvoice	sPad
	smpsPan		$F7
	smpsAlterPitch	$16
	smpsAlterNote	$20
	dc.b	nA4, $0C, nC5, nA4, nG4, nA4, $06, nRst
	dc.b	nRst, nA4, nRst, nA4, nC5, $0C
	smpsAlterNote	$00
	smpsAlterPitch	$EA
	smpsLoop	$00, $02, MetallicMadnessPast_Loop9
	smpsSetvoice	sFantasia
	smpsPan		$0F
	smpsAlterPitch	$FB
	smpsJump	MetallicMadnessPast_Loop8

MetallicMadnessPast_PCM4:
	smpsSetvoice	sFantasia
	smpsAlterPitch	$FB
	smpsPan		$F0

MetallicMadnessPast_Loop10:
	dc.b	nA4, $06, nB5, nC6, nG6, nB6, nC7, nE7
	dc.b	nD7, nB5, nC6, nG6, nB5, nC6, nD6, nE6
	dc.b	nC6, nEb5, nA4, nC5, nEb5, nA5, nEb5, nC5
	dc.b	nA5, nC6, nEb6, nA6, nC7, nEb7, nA6, nC7
	dc.b	nEb7
	smpsLoop	$00, $12, MetallicMadnessPast_Loop10
	smpsAlterPitch	$05
	smpsSetvoice	sPiano
	smpsAlterVol	$D0
	smpsAlterPitch	$11

MetallicMadnessPast_Loop11:
	dc.b	nD5, $0C, nC5, nD5, nRst, $06, nD5, nRst
	dc.b	nD5, nC5, $0C, nD5, nRst, $06, nD5, nRst
	dc.b	$60, nA4, $0C, nG4, nA4, nRst, $06, nA4
	dc.b	nRst, nA4, nG4, $0C, nA4, nRst, $06, nA4
	dc.b	nRst, $60
	smpsLoop	$00, $02, MetallicMadnessPast_Loop11
	smpsAlterVol	$30
	smpsAlterPitch	$EF
	smpsJump	MetallicMadnessPast_PCM4

MetallicMadnessPast_PCM5:
	dc.b	nRst, $10

MetallicMadnessPast_Jump1:
	smpsSetvoice	sFantasia
	smpsAlterPitch	$FB
	smpsAlterPitch	$F3
	smpsAlterVol	$A0
	dc.b	nA4, $06, nB5, nC6, nG6, nB6, nC7, nG7
	dc.b	nD7, nB5, nC6, nG6, nB5, nC6, nD6, nE6
	dc.b	nC6, nEb5, nA4, nC5, nEb5, nA5, nEb5, nC5
	dc.b	nA5, nC6, nEb6, nA6, nC7, nEb7, nA6, nC7
	dc.b	nEb7, $02
	smpsAlterPitch	$0D
	smpsAlterPitch	$05
	smpsAlterVol	$60
	smpsSetvoice	sOrchHit1
	smpsAlterPitch	$FB

MetallicMadnessPast_Loop12:
	dc.b	nE6, $12, nEb6, $12, nD6, $18, nC6, $0C
	dc.b	nA5, $18
	smpsLoop	$00, $02, MetallicMadnessPast_Loop12
	dc.b	nA5, $18
	smpsAlterVol	$C0
	dc.b	nA5
	smpsAlterVol	$C0
	dc.b	nA5
	smpsAlterVol	$C0
	dc.b	nA5
	smpsAlterVol	$40
	smpsAlterVol	$40
	smpsAlterVol	$40
	smpsAlterPitch	$05
	dc.b	nRst, $60, nRst, nRst, $30
	smpsSetvoice	sWoosh
	dc.b	nC4, $30

MetallicMadnessPast_Loop13:
	smpsCall	MetallicMadnessPast_Call2
	smpsLoop	$00, $04, MetallicMadnessPast_Loop13
	smpsSetvoice	sSynth
	smpsAlterVol	$E0
	smpsAlterPitch	$E7
	smpsAlterNote	$00
	dc.b	nA6, $06, nE7, nRst, nC7, nRst, nD7, nE7
	dc.b	nG6, nRst, nEb7, nD7, $0C, nC7, $06, nG6
	dc.b	$0C, nAb6, $06, nA6, nC7, nD7, nA6, nE6
	dc.b	nG6, nA6, nD6, nRst, nC6, nC7, $0C, $06
	dc.b	nA6, nG6, nE6, nEb6, nD6, nC6, nA5, nD6
	dc.b	nEb6, nE6, nG6, nA6, nC7, nD7, nC7, nRst
	dc.b	nA6, nC7, nD7, nRst, nG5, nA5, nG5, nAb5
	dc.b	nC6, $0C, nE6, nF6, nAb6, nC7, nEb7, $06
	dc.b	nE7, nF7, nE7, nD7, nB6, nC7, nD7, nG6
	dc.b	nRst, nA6, nRst, nC7, nD7, nEb7, nC7, nG6
	dc.b	nA6, nC7, nA6, $0C, nE6, $06, nRst, nG6
	dc.b	nA6, nA5, nC7, $0C, $06, $06, nEb6, nD6
	dc.b	nC6, nD6, $0C, $06, nEb6, nD6, nC6, nA5
	dc.b	nG5, nD6, nEb6, nD6, nC6, nA5, nG5, nD6
	dc.b	nEb6, nD6, nC6, nA5, nG5, nA5, $0C, nC6
	dc.b	$06, nD6, $0C, nEb6, $06, nE6, nG6, nAb6
	dc.b	nA6, nC7, nD7
	smpsAlterVol	$20
	smpsAlterPitch	$19
	smpsSetvoice	sOrchHit1
	smpsAlterPitch	$FB

MetallicMadnessPast_Loop14:
	dc.b	nE6, $12, nEb6, $12, nD6, $18, nC6, $0C
	dc.b	nA5, $18
	smpsLoop	$00, $04, MetallicMadnessPast_Loop14
	smpsAlterPitch	$05

MetallicMadnessPast_Loop15:
	smpsCall	MetallicMadnessPast_Call2
	smpsLoop	$00, $04, MetallicMadnessPast_Loop15
	smpsAlterVol	$D0
	smpsPan		$8F

MetallicMadnessPast_Loop16:
	smpsSetvoice	sOrchHit2
	smpsPan		$F7
	smpsAlterVol	$F0
	smpsAlterNote	$EC
	dc.b	nD5, $0C, nC5, nD5, $12, nD5, $06, nRst
	dc.b	nD5, nC5, $0C, nD5, $12, nD5, $06
	smpsAlterNote	$00
	smpsAlterVol	$10
	smpsSetvoice	sPad
	smpsPan		$7F
	smpsAlterPitch	$09
	smpsAlterNote	$20
	dc.b	nD5, $0C, nF5, nG5, nAb5, nG5, nF5, nD5
	dc.b	nC5
	smpsAlterNote	$00
	smpsAlterPitch	$F7
	smpsSetvoice	sOrchHit2
	smpsPan		$F7
	smpsAlterVol	$F0
	smpsAlterNote	$EC
	dc.b	nA4, $0C, nG4, nA4, $12, nA4, $06, nRst
	dc.b	nA4, nG4, $0C, nA4, $12, nA4, $06
	smpsAlterNote	$00
	smpsAlterVol	$10
	smpsSetvoice	sPad
	smpsPan		$7F
	smpsAlterPitch	$09
	smpsAlterNote	$20
	dc.b	nA4, $0C, nC5, nA4, nG4, nA4, $06, nRst
	dc.b	nRst, nA4, nRst, nA4, nC5, $0C
	smpsAlterNote	$00
	smpsAlterPitch	$F7
	smpsLoop	$00, $02, MetallicMadnessPast_Loop16
	smpsAlterVol	$30
	smpsPan		$FF
	dc.b	nRst, $04
	smpsJump	MetallicMadnessPast_Jump1

MetallicMadnessPast_Call2:
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $0C
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord1
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord1
	dc.b	nB5, $06
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nB5, nA5
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord1
	dc.b	nFs5
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nE5, nFs5
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord1
	dc.b	nAb5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord1
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $0C
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $06
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, nFs5
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsAlterVol	$E0
	smpsPan		$F8
	smpsSetvoice	sPiano
	dc.b	nFs5, $06
	smpsAlterVol	$20
	smpsPan		$8F
	smpsSetvoice	sPianoChord2
	dc.b	nFs5, $0C
	smpsPan		$FF
	smpsReturn

MetallicMadnessPast_PCM6:
	dc.b	nRst, $60, nRst
	smpsSetvoice	sKick1
	dc.b	nB4, $18, $18, $18, $18, $18, $18, $18
	dc.b	$18

MetallicMadnessPast_Loop17:
	smpsSetvoice	sKick1
	dc.b	nB4, $06
	smpsSetvoice	sSnare1
	smpsAlterVol	$C0
	smpsAlterVol	$C0
	dc.b	nB5, $06
	smpsAlterVol	$40
	dc.b	$06, $06
	smpsAlterVol	$40
	smpsLoop	$00, $07, MetallicMadnessPast_Loop17
	smpsSetvoice	sKick1
	dc.b	nB4, $06
	smpsAlterVol	$C0
	smpsSetvoice	sSnare1
	dc.b	nB5
	smpsAlterVol	$40
	smpsSetvoice	sKick1
	dc.b	nB4
	smpsAlterVol	$C0
	smpsSetvoice	sSnare1
	dc.b	nB5
	smpsAlterVol	$40
	smpsLoop	$01, $10, MetallicMadnessPast_Loop17

MetallicMadnessPast_Loop18:
	smpsSetvoice	sKick2
	dc.b	nC5, $06
	smpsSetvoice	sSnare1
	smpsAlterVol	$C0
	dc.b	nB5
	smpsAlterVol	$40
	smpsSetvoice	sKick2
	dc.b	nC5
	smpsAlterVol	$C0
	smpsSetvoice	sSnare1
	dc.b	nB5, nRst, nB5, nB5
	smpsAlterVol	$40
	smpsSetvoice	sKick2
	dc.b	nC5, nC5
	smpsSetvoice	sSnare1
	smpsAlterVol	$C0
	dc.b	nB5
	smpsAlterVol	$40
	smpsSetvoice	sKick2
	dc.b	nC5
	smpsSetvoice	sSnare1
	smpsAlterVol	$C0
	dc.b	nB5, nB5, $03, nB5, nB5, $06, $06, $06
	smpsAlterVol	$40
	smpsLoop	$00, $08, MetallicMadnessPast_Loop18
	smpsJump	MetallicMadnessPast_PCM6

MetallicMadnessPast_PCM8:
	dc.b	nRst, $60, nRst, nRst
	smpsSetvoice	sSnare2
	smpsAlterVol	$B0
	dc.b	nRst, $30, nRst, $0F, nBb5, $03, $03, $03
	smpsAlterVol	$50
	dc.b	nBb5, $06, $06, nRst, nBb5

MetallicMadnessPast_Loop19:
	smpsCall	MetallicMadnessPast_Call3
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call6
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call7
	smpsCall	MetallicMadnessPast_Call3
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call6
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call5
	smpsCall	MetallicMadnessPast_Call8
	smpsLoop	$00, $02, MetallicMadnessPast_Loop19
	smpsSetvoice	sSnare3
	smpsAlterPitch	$F1

MetallicMadnessPast_Loop20:
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call6
	smpsCall	MetallicMadnessPast_Call4
	smpsCall	MetallicMadnessPast_Call9
	smpsLoop	$00, $02, MetallicMadnessPast_Loop20
	smpsAlterPitch	$0F
	smpsJump	MetallicMadnessPast_PCM8

MetallicMadnessPast_Call5:
	dc.b	nRst, $18, nBb5, $06, nRst, $0C, nBb5, $06
	dc.b	nRst, $18, nBb5, $06, nRst, $12
	smpsReturn

MetallicMadnessPast_Call4:
	dc.b	nRst, $18, nBb5, $06, nRst, $0C, nBb5, $06
	dc.b	nRst, $06, nBb5, nRst, $0C, nBb5, $06, nRst
	dc.b	$0C, nBb5, $06
	smpsReturn

MetallicMadnessPast_Call8:
	dc.b	nRst, $06, nBb5, $06, $06, $06, $06, $06
	dc.b	nRst, nBb5, nRst, nBb5, nRst, nBb5, nBb5, nBb5
	dc.b	nBb5, nBb5
	smpsReturn

MetallicMadnessPast_Call3:
	smpsSetvoice	sOrchHitCrash
	dc.b	nFs5, $18
	smpsSetvoice	sSnare2
	dc.b	nBb5, $06, nRst, $0C, nBb5, $06, nRst, $18
	dc.b	nBb5, $06, nRst, $12
	smpsReturn

MetallicMadnessPast_Call7:
	dc.b	nBb5, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, nBb5, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06
	smpsReturn

MetallicMadnessPast_Call6:
	dc.b	nRst, $18, nBb5, $06, nRst, $0C, nBb5, $06
	dc.b	nRst, $06, nBb5, nRst, $0C, nBb5, $06, nRst
	dc.b	$06, nBb5, $06, $06
	smpsReturn

MetallicMadnessPast_Call9:
	dc.b	nRst, $18, nBb5, $06, nRst, $0C, nBb5, $06
	dc.b	nRst, $06, nBb5, nRst, $0C, nBb5, $03, $03
	dc.b	$06, $06, $06
	smpsReturn
	smpsStop	; Unused

MetallicMadnessPast_PCM7:
	smpsStop

MetallicMadnessPast_Rhythm:
	smpsStop
