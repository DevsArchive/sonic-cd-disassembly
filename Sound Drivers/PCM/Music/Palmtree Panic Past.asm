PalmtreePanicPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$08
	smpsHeaderTempo		$01, $04
	smpsHeaderPCM		PalmtreePanicPast_Rhythm, $00, $EF
	smpsHeaderPCM		PalmtreePanicPast_PCM1, $00, $EF
	smpsHeaderPCM		PalmtreePanicPast_PCM2, $E7, $FF
	smpsHeaderPCM		PalmtreePanicPast_PCM3, $D2, $7F
	smpsHeaderPCM		PalmtreePanicPast_PCM4, $C8, $9F
	smpsHeaderPCM		PalmtreePanicPast_PCM5, $DE, $58
	smpsHeaderPCM		PalmtreePanicPast_PCM6, $DE, $60
	smpsHeaderPCM		PalmtreePanicPast_PCM8, $DE, $60

PalmtreePanicPast_PCM1:
	smpsSetvoice	sDrumLoop
	smpsAlterNote	$20

PalmtreePanicPast_Jump1:
	dc.b	nC2, $60
	smpsJump	PalmtreePanicPast_Jump1

PalmtreePanicPast_PCM2:
	smpsSetvoice	sBass

PalmtreePanicPast_Loop1:
	dc.b	nD4, $12, nA4, nA3, nD4, nA4, $0C, nA3
	dc.b	nD4, $12, nA4, nA3, nD4, nA4, $0C, nA3
	dc.b	nC4, $12, nG4, nG3, nC4, nG4, $0C, nG3
	dc.b	nC4, $12, nG4, nG3, nC4, nG4, $0C, nG3
	smpsLoop	$00, $04, PalmtreePanicPast_Loop1
	dc.b	nF4, $18, nC4, nF4, $12, $06, nC4, $0C
	dc.b	nF4, nE4, $18, nB3, nE4, $12, nB3, $06
	dc.b	nE4, $0C, nEb4, nD4, $18, nA3, nD4, $12
	dc.b	nA3, $06, nD4, $0C, nEb4, nE4, $18, nB3
	dc.b	nE4, $12, nB3, $06, nE4, $18, nF4, nC4
	dc.b	nF4, nC4, $0C, nF4, nE4, $18, nB3, nE4
	dc.b	$12, nB3, $06, nE4, $0C, nEb4, nD4, $18
	dc.b	nA3, nD4, nA3, nD4, nA3, nD4, $12, $06
	dc.b	nA3, $0C, nAb3, nG3, $18, nD4, nG4, nD4
	dc.b	$0C, nG3, nG3, $12, $12, nD4, $0C, nG4
	dc.b	$12, nD4, nG3, $0C

PalmtreePanicPast_Loop2:
	dc.b	nC4, $12, nG4, $06, $0C, nG3, nC4, $12
	dc.b	nG4, $06, $06, nG3, nA3, nG3, nE4, $12
	dc.b	nB3, $06, $18, nE4, $12, nB3, $06, $0C
	dc.b	nEb4, nD4, $12, nA4, $06, $0C, nA3, nD4
	dc.b	$12, nA4, $06, $06, nA3, nD4, nA3, nG3
	dc.b	$12, $06, nD4, $12, $06, nG3, $12, nD4
	dc.b	$06, nG4, $0C, nD4, nE4, $12, nB3, $06
	dc.b	$0C, nE3, nE4, $12, nB3, $06, $0C, nBb3
	dc.b	nA3, $12, $06, nE4, $12, $06, nA3, $12
	dc.b	nE4, $06, nG4, nBb4, nCs5, nE5, nD4, $12
	dc.b	$06, nA3, $18, nD4, $12, $06, nA3, $0C
	dc.b	nAb3, nG3, $12, $06, nD4, $12, $06, nF4
	dc.b	nG4, nRst, nF4, nD4, nG3, nD4, nG3
	smpsLoop	$00, $02, PalmtreePanicPast_Loop2
	smpsJump	PalmtreePanicPast_Loop1

PalmtreePanicPast_PCM3:
	smpsAlterVol	$BB
	smpsSetvoice	sFlute
	dc.b	nRst, $4E, nG5, $06, nA5, nG5
	smpsAlterVol	$45

PalmtreePanicPast_Jump2:
	smpsAlterVol	$BB
	smpsAlterPitch	$02
	dc.b	nRst, $0C, nE6, $06, nRst, $12, nD6, $06
	dc.b	nRst, $12, nC6, $06, nRst, $12, nD6, $06
	dc.b	nRst, nC6, nRst, nB5, $0C, nC6, $06, nG5
	dc.b	$3C, nE5, $06, nG5, nE5, smpsNoAttack, $60, nRst
	dc.b	$4E, nG5, $06, nA5, nG5, nE6, nRst, $12
	dc.b	nD6, $06, nRst, $12, nC6, $06, nRst, $12
	dc.b	nD6, $06, nRst, nC6, nRst, nB5, $0C, nC6
	dc.b	$06, nG5, $4E, nRst, $06, nB5, nC6, nG6
	dc.b	$30
	smpsAlterVol	$45
	smpsAlterVol	$80
	smpsSetvoice	sTomDrum
	smpsPan		$F0
	dc.b	nB5, $06
	smpsPan		$FF
	dc.b	nG5
	smpsPan		$0F
	dc.b	nC5
	smpsPan		$FF
	smpsAlterVol	$80
	smpsAlterVol	$BB
	smpsAlterVol	$35
	dc.b	nRst, $06
	smpsSetvoice	sPiano
	dc.b	nRst, $18, nA5, $0C, nC6, nB5, $12, nG5
	dc.b	nG5, $0C, nA5, nC6, nB5, nG5, nA5, $12
	dc.b	$12, nE5, $0C, nG5, $12, nD5, nE5, nG4
	dc.b	$2A, nRst, $60, nRst, $18, nA5, $0C, nC6
	dc.b	nB5, $12, nG5, nG5, $0C, nA5, nC6, nB5
	dc.b	nG5, nG5, $12, nA5, nG5, $0C, $12, nG6
	dc.b	nE6, $36
	smpsAlterPitch	$FE
	smpsAlterVol	$10
	smpsAlterVol	$80
	smpsSetvoice	sTomDrum
	dc.b	nRst, $48, nRst, $06
	smpsPan		$F0
	dc.b	nB5
	smpsPan		$FF
	dc.b	nG5
	smpsPan		$0F
	dc.b	nC5
	smpsPan		$FF
	smpsAlterVol	$80
	smpsSetvoice	sElecPianoHigh
	smpsAlterPitch	$F4
	dc.b	nRst, $0C, nF4, $03, nA4, nC5, nE5, nF5
	dc.b	$06, nA5, nC6, nD6, nE6, nF6, nA6, nC7
	dc.b	nE7, nEb7, nD7, nC7, nA6, $03, nB6, smpsNoAttack
	dc.b	$06, nD7, nG6, $12, $06, nG5, nA5, nB5
	dc.b	nC6, nD6, nE6, nF6, nG6, nA6, nCs7, $03
	dc.b	nD7, smpsNoAttack, $06, nF7, nCs7, $03, nD7, smpsNoAttack
	dc.b	$06, nF7, nRst, nE7, nD7, nC7, nB6, nA6
	dc.b	nG6, nF6, nE6, nD6, $03, nE6, nG6, $06
	dc.b	nG5, nRst, nG5, nG5, $03, nA5, smpsNoAttack, $06
	dc.b	nA5, nG5, nRst, nG4, nA4, nG4, nRst, nB4
	dc.b	nD5, $03, nE5, nG5, nB5, nE6, $06, nF6
	dc.b	nA6, nC7, nE7, $0C, nD7, $06, nC7, nRst
	dc.b	nC7, nD7, nC7, nE7, nF7, nRst, nG7
	smpsAlterPitch	$0C
	dc.b	nA6, $03, nB6
	smpsAlterPitch	$F4
	dc.b	nA7, $06, nG7, nE7, nB6, nG6, nRst, nE7
	dc.b	nD7, $03, nE7, nD7, $06, nB6, nG6, nE6
	dc.b	nB5, nG5, nE5, nF5, nE5, nF5, nA5, nC6
	dc.b	$0C, nA5, $06, nF5, nA5, nC6, nE6, $0C
	dc.b	nC6, $06, nA5, nC6, nE6, nA6, $0C, nE6
	dc.b	$06, nC6, nE6, nF6, nC7, $0C, nD7, $06
	dc.b	nD5, nF5, $03, nA5, nC6, nD6, nEb6, $06
	dc.b	nD6, nC6, nA5, nB5, nG6, nB5, nBb5, nA5
	dc.b	nF6, nA5, nAb5, nG5, nE6, nG5, nFs5, nF5
	dc.b	nD6, nF5, nEb5, nE5, nG4, nG4, $03, nA4
	dc.b	nG4, $06, nB4, nD5, nF5, nG5, nA5, nB5
	dc.b	nD6, nF6, nG6, nA6, nB6, nD7
	smpsAlterPitch	$0C
	dc.b	nRst, $0C
	smpsAlterVol	$BB
	smpsSetvoice	sFlute
	smpsAlterPitch	$02
	dc.b	nG5, $3C, $06, nRst, nA5, nRst, nB5, nRst
	dc.b	nD6, nRst, nC6, nRst, $12, nB5, $06, nRst
	dc.b	$12, nA5, $06, nRst, $12, nG5, $18, nF5
	dc.b	$0C, nE5, nF5, nRst, nE5, nD5, nC5, nB4
	dc.b	nBb4, nB4, nG4, $3C, nRst, $18, nEb5, $06
	dc.b	nE5, nG5, nRst, nG5, nRst, nE5, nRst, nG5
	dc.b	nRst, nA5, nRst, nBb5, smpsNoAttack, $0C, nA5, $06
	dc.b	nRst, $0C, nG5, $06, nRst, $12, nG5, $0C
	dc.b	nF5, nE5, nD5, $06, nRst, $0C, nE5, $06
	dc.b	nRst, $0C, nF5, $06, nRst, $12, nA4, $0C
	dc.b	nC5, nB4, nG4, $48, nE5, $06, nRst, nF5
	dc.b	nRst, nG5, $3C, $06, nRst, nA5, nRst, nB5
	dc.b	nRst, nD6, nRst, nC6, nRst, $12, nB5, $06
	dc.b	nRst, $12, nA5, $06, nRst, $12, nG5, $18
	dc.b	nF5, $0C, nE5, nF5, nRst, nE5, nD5, nC5
	dc.b	nB4, nBb4, nB4, nG4, $3C, nRst, $18, nE5
	dc.b	$0C, nG5, nG5, nE5, nG5, nA5, nBb5, $06
	dc.b	smpsNoAttack, $0C, nA5, $06, nRst, $0C, nG5, $06
	dc.b	nRst, $12, nG5, $0C, nF5, nE5, nD5, $06
	dc.b	smpsNoAttack, $0C, nE5, $06, nRst, $0C, nF5, $06
	dc.b	nRst, $12, nD5, $0C, nF5, nA5, nC6, $18
	dc.b	nB5, nE6, nE6, nC6, $42, nRst, $06, nRst
	dc.b	nRst
	smpsAlterVol	$45
	smpsAlterPitch	$FE
	smpsJump	PalmtreePanicPast_Jump2

PalmtreePanicPast_PCM4:
	smpsAlterPitch	$0C
	smpsSetvoice	sFlute
	dc.b	nRst, $4E, nG5, $06, nA5, nG5

PalmtreePanicPast_Jump3:
	dc.b	nE6, $06, nRst, $12, nD6, $06, nRst, $12
	dc.b	nC6, $06, nRst, $12, nD6, $06, nRst, nC6
	dc.b	nRst, nB5, $0C, nC6, $06, nG5, $3C, nE5
	dc.b	$06, nG5, nE5, smpsNoAttack, $60, nRst, $4E, nG5
	dc.b	$06, nA5, nG5, nE6, nRst, $12, nD6, $06
	dc.b	nRst, $12, nC6, $06, nRst, $12, nD6, $06
	dc.b	nRst, nC6, nRst, nB5, $0C, nC6, $06, nG5
	dc.b	$4E, nRst, $06, nB5, nC6, nG6, $4E
	smpsSetvoice	sPiano
	dc.b	nRst, $18, nA5, $0C, nC6, nB5, $12, nG5
	dc.b	nG5, $0C, nA5, nC6, nB5, nG5, nA5, $12
	dc.b	$12, nE5, $0C, nG5, $12, nD5, nE5, nG4
	dc.b	$2A, nRst, $60, nRst, $18, nA5, $0C, nC6
	dc.b	nB5, $12, nG5, nG5, $0C, nA5, nC6, nB5
	dc.b	nG5, nG5, $12, nA5, nG5, $0C, $12, nG6
	dc.b	nE6, $3C
	smpsAlterPitch	$F4
	smpsSetvoice	sStrings
	smpsAlterPitch	$05
	dc.b	nRst, $24, nG6, $0C, $0C, nF6, nE6, nD6
	dc.b	nD6, $18, $06, nE6, $0C, nC6, $1E, nE6
	dc.b	$18, nD6, $24, nB5, $0C, $0C, nC6, nD6
	dc.b	nE6, nC6, $18, $06, nD6, $0C, nC6, $1E
	dc.b	nE6, $18, nD6, $24, nG6, $0C, $0C, nF6
	dc.b	nE6, nD6, nD6, $18, $06, nE6, $0C, nC6
	dc.b	$1E, nE6, $18, nD6, $24, nB5, $0C, $0C
	dc.b	nC6, nD6, nE6, nD6, $12, nC6, nA5, $3C
	dc.b	smpsNoAttack, $18, nRst, nA5, $12, nB5, nC6, $0C
	dc.b	nA6, $24, nG6, $3C, smpsNoAttack, $48
	smpsAlterPitch	$FB
	smpsAlterPitch	$0C
	smpsSetvoice	sFlute
	dc.b	nE5, $06, nRst, nF5, nRst, nG5, $3C, $06
	dc.b	nRst, nA5, nRst, nB5, nRst, nD6, nRst, nC6
	dc.b	nRst, $12, nB5, $06, nRst, $12, nA5, $06
	dc.b	nRst, $12, nG5, $18, nF5, $0C, nE5, nF5
	dc.b	nRst, nE5, nD5, nC5, nB4, nBb4, nB4, nG4
	dc.b	$3C, nRst, $18, nEb5, $06, nE5, nG5, nRst
	dc.b	nG5, nRst, nE5, nRst, nG5, nRst, nA5, nRst
	dc.b	nBb5, smpsNoAttack, $0C, nA5, $06, nRst, $0C, nG5
	dc.b	$06, nRst, $12, nG5, $0C, nF5, nE5, nD5
	dc.b	$06, smpsNoAttack, $0C, nE5, $06, nRst, $0C, nF5
	dc.b	$06, nRst, $12, nA4, $0C, nC5, nB4, nG4
	dc.b	$48, nE5, $06, nRst, nF5, nRst, nG5, $3C
	dc.b	$06, nRst, nA5, nRst, nB5, nRst, nD6, nRst
	dc.b	nC6, nRst, $12, nB5, $06, nRst, $12, nA5
	dc.b	$06, nRst, $12, nG5, $18, nF5, $0C, nE5
	dc.b	nF5, nRst, nE5, nD5, nC5, nB4, nBb4, nB4
	dc.b	nG4, $3C, nRst, $18, nE5, $0C, nG5, nG5
	dc.b	nE5, nG5, nA5, nBb5, $06, smpsNoAttack, $0C, nA5
	dc.b	$06, nRst, $0C, nG5, $06, nRst, $12, nG5
	dc.b	$0C, nF5, nE5, nD5, $06, smpsNoAttack, $0C, nE5
	dc.b	$06, nRst, $0C, nF5, $06, nRst, $12, nD5
	dc.b	$0C, nF5, nA5, nC6, $18, nB5, nE6, nE6
	dc.b	nC6, $4E, nG5, $06, nA5, nG5
	smpsJump	PalmtreePanicPast_Jump3

PalmtreePanicPast_PCM5:
	smpsSetvoice	sElecPianoLow
	dc.b	nD4, $0C, $0C, nRst, nD4, $06, nRst, nD4
	dc.b	nRst, nD4, nRst, nD4, nRst, $12, nD4, $0C
	dc.b	nRst, nD4, $06, nRst, nD4, nRst, $12, nD4
	dc.b	$06, nRst, nD4, nRst, $0C, nD4, $06, nC4
	dc.b	$0C, nRst, nC4, $06, nRst, nC4, nRst, nC4
	dc.b	nRst, nC4, nRst, nC4, nRst, $12, nC4, $0C
	dc.b	nRst, nC4, $06, nRst, nC4, nRst, nC4, nRst
	dc.b	$12, nC4, $06, nRst, nC4, $0C
	smpsLoop	$00, $04, PalmtreePanicPast_PCM5
	smpsSetvoice	sElecPianoHigh
	smpsAlterVol	$E0
	smpsAlterPitch	$E8
	dc.b	nRst, $0A, nRst, $0C, nF4, $03, nA4, nC5
	dc.b	nE5, nF5, $06, nA5, nC6, nD6, nE6, nF6
	dc.b	nA6, nC7, nE7, nEb7, nD7, nC7, nA6, $03
	dc.b	nB6, smpsNoAttack, $06, nD7, nG6, $12, $06, nG5
	dc.b	nA5, nB5, nC6, nD6, nE6, nF6, nG6, nA6
	dc.b	nCs7, $03, nD7, smpsNoAttack, $06, nF7, nCs7, $03
	dc.b	nD7, smpsNoAttack, $06, nF7, nRst, nE7, nD7, nC7
	dc.b	nB6, nA6, nG6, nF6, nE6, nD6, $03, nE6
	dc.b	nG6, $06, nG5, nRst, nG5, nG5, $03, nA5
	dc.b	smpsNoAttack, $06, nA5, nG5, nRst, nG4, nA4, nG4
	dc.b	nRst, nB4, nD5, $03, nE5, nG5, nB5, nE6
	dc.b	$06, nF6, nA6, nC7, nE7, $0C, nD7, $06
	dc.b	nC7, nRst, nC7, nD7, nC7, nE7, nF7, nRst
	dc.b	nG7
	smpsAlterPitch	$0C
	dc.b	nA6, $03, nB6
	smpsAlterPitch	$F4
	dc.b	nA7, $06, nG7, nE7, nB6, nG6, nRst, nE7
	dc.b	nD7, $03, nE7, nD7, $06, nB6, nG6, nE6
	dc.b	nB5, nG5, nE5, nF5, nE5, nF5, nA5, nC6
	dc.b	$0C, nA5, $06, nF5, nA5, nC6, nE6, $0C
	dc.b	nC6, $06, nA5, nC6, nE6, nA6, $0C, nE6
	dc.b	$06, nC6, nE6, nF6, nC7, $0C, nD7, $06
	dc.b	nD5, nF5, $03, nA5, nC6, nD6, nEb6, $06
	dc.b	nD6, nC6, nA5, nB5, nG6, nB5, nBb5, nA5
	dc.b	nF6, nA5, nAb5, nG5, nE6, nG5, nFs5, nF5
	dc.b	nD6, nF5, nEb5, nE5, nG4, nG4, $03, nA4
	dc.b	nG4, $06, nB4, nD5, nF5, nG5, nA5, nB5
	dc.b	nD6, nF6, nG6, nA6, nB6, $02
	smpsAlterPitch	$18
	smpsAlterVol	$20
	smpsAlterPitch	$EA
	smpsAlterVol	$50
	smpsSetvoice	sPiano
	dc.b	nG6, $3C, $0C, nA6, nB6, nD7, nC7, nRst
	dc.b	nB6, nRst, nA6, nRst, nG6, nRst, nF6, nE6
	dc.b	nF6, $18, nE6, $0C, nD6, nC6, nB5, nBb5
	dc.b	nB5, nG5, $3C, nRst, $18, nEb6, $06, nE6
	dc.b	nG6, $0C, $0C, nE6, nG6, nA6, nBb6, $12
	dc.b	nA6, nG6, $18, $0C, nF6, nE6, nD6, nRst
	dc.b	$06, nE6, $0C, nRst, $06, nF6, $0C, nRst
	dc.b	nA5, nC6, nB5, nG5, $48, nE6, $0C, nF6
	dc.b	nG6, $3C, $0C, nA6, nB6, nD7, nC7, nRst
	dc.b	nB6, $18, nA6, nG6, $0C, nRst, nF6, nE6
	dc.b	nF6, $18, nE6, $0C, nD6, nC6, nB5, nBb5
	dc.b	nB5, nG5, $3C, nRst, $18, nE6, $0C, nG6
	dc.b	nG6, nE6, nG6, nA6, nBb6, $12, nA6, nG6
	dc.b	$18, $0C, nF6, nE6, nD6, $12, nE6, nF6
	dc.b	$18, nD6, $0C, nF6, nA6, nC7, $18, nB6
	dc.b	nE7, nE7
	smpsAlterPitch	$16
	smpsAlterVol	$B0
	smpsJump	PalmtreePanicPast_PCM5

PalmtreePanicPast_PCM6:
	smpsPan		$FA
	smpsSetvoice	sElecPianoLow

PalmtreePanicPast_Loop3:
	dc.b	nRst, $06, nA4, nRst, $0C, nA4, $06, $06
	dc.b	nRst, nA4, nRst, nA4, nRst, nA4, nRst, nA4
	dc.b	nRst, $0C, $0C, nA4, $06, $06, nRst, nA4
	dc.b	nRst, nA4, $0C, $06, nRst, nA4, nRst, nA4
	dc.b	nRst, $0C, $0C, nG4, $06, $06, nRst, nG4
	dc.b	nRst, nG4, nRst, nG4, nRst, nG4, nRst, nG4
	dc.b	$0C, nRst, $06, $0C, nG4, $06, $06, nRst
	dc.b	nG4, nRst, nG4, nRst, $12, nG4, $06, nRst
	dc.b	nG4, nRst, nG4
	smpsLoop	$00, $04, PalmtreePanicPast_Loop3
	dc.b	nRst, $0C, nA4, $06, nRst, $0C, nA4, nRst
	dc.b	$06, nA4, nRst, $0C, nA4, nRst, $06, nA4
	dc.b	nRst, nRst, $0C, nG4, $06, nB4, nRst, $0C
	dc.b	nG4, nRst, $06, nG4, $0C, nRst, $06, nG4
	dc.b	nRst, nB4, $0C, nRst, nF4, $06, nRst, $18
	dc.b	nF4, $06, nRst, $0C, nF4, nRst, $06, nA4
	dc.b	$0C, nRst, $06, $0C, nG4, $06, nRst, $0C
	dc.b	nB4, $06, nRst, nB4, nRst, nG4, $0C, nRst
	dc.b	$06, nG4, nRst, nG4, nB4, nRst, $0C, nA4
	dc.b	$06, nRst, $0C, nA4, nRst, $06, nA4, nRst
	dc.b	$0C, nA4, nRst, $06, nA4, nRst, nRst, $0C
	dc.b	nG4, $06, nB4, nRst, $0C, nG4, nRst, $06
	dc.b	nG4, $0C, nRst, $06, nG4, nRst, nB4, $0C
	dc.b	nRst, $06, nA4, nD4, nA4, nD4, nA4, nA4
	dc.b	nD4, nD4, nA4, nD4, nA4, nA4, nD4, nD4
	dc.b	nA4, nRst, nA4, nD4, nA4, nD4, nA4, nA4
	dc.b	nD4, nD4, nA4, nD4, nA4, nA4, nD4, nD4
	dc.b	nA4, nG4, nD4, nF4, nD4, nG4, nG4, nD4
	dc.b	nG4, nF4, nG4, nD4, nG4, nD4, nG4, nF4
	dc.b	nD4, nRst, nD4, nF4, nD4, nG4, nG4, nD4
	dc.b	nG4, nF4, nG4, nD4, nG4, nD4, nG4, nF4
	dc.b	nD4

PalmtreePanicPast_Loop4:
	dc.b	nRst, $0C, nG4, $06, nRst, $0C, nG4, $06
	dc.b	nRst, nG4, nRst, nG4, nRst, nG4, nRst, nG4
	dc.b	nRst, nB4, nRst, $0C, nG4, $06, nD5, nRst
	dc.b	nE5, nRst, nG4, nRst, nE5, nRst, nB4, nRst
	dc.b	nE5, nG4, nRst, nRst, $0C, nA4, $06, nD5
	dc.b	nRst, nA4, nRst, $0C, nA4, nRst, $06, nA4
	dc.b	$0C, nRst, $06, nA4, nF5, nRst, $0C, nF4
	dc.b	$06, nB4, nRst, nG4, nRst, nF4, nRst, nG3
	dc.b	nRst, nG3, nRst, $0C, nG3, $06, nRst, nRst
	dc.b	nB4, nRst, nD5, nRst, nG4, nRst, nB4, nRst
	dc.b	nD5, nRst, nB4, nRst, $0C, nB4, $06, nRst
	dc.b	nBb4, $0C, nRst, $06, nBb4, nRst, $0C, nBb4
	dc.b	nRst, $06, nCs5, $0C, nRst, $06, nCs5, nRst
	dc.b	nBb4, nRst, nRst, nC5, nRst, nC5, $0C, nRst
	dc.b	$06, nC5, nRst, $0C, nA4, nRst, $06, nF4
	dc.b	nRst, nFs4, nRst, nRst, nF4, nRst, nB4, nRst
	dc.b	nB4, nRst, $0C, nF4, nRst, $06, nG4, $0C
	dc.b	nRst, $06, nF4, $0C
	smpsLoop	$00, $02, PalmtreePanicPast_Loop4
	smpsJump	PalmtreePanicPast_Loop3

PalmtreePanicPast_Rhythm:
	smpsStop

PalmtreePanicPast_PCM8:
	smpsPan		$AF
	smpsSetvoice	sElecPianoLow

PalmtreePanicPast_Loop5:
	dc.b	nRst, $06, nD5, nRst, $0C, nF5, $06, nCs5
	dc.b	nRst, nF5, nRst, nC5, nRst, nF5, nRst, nCs5
	dc.b	nF5, $0C, nRst, nD5, $06, nF5, nRst, nCs5
	dc.b	nRst, nF5, $0C, nC5, $06, nRst, nF5, nRst
	dc.b	nCs5, nF5, nRst, nRst, $0C, nC5, $06, nE5
	dc.b	nRst, nB4, nRst, nE5, nRst, nA4, nRst, nE5
	dc.b	nRst, nB4, $0C, nE5, $06, nRst, $0C, nE5
	dc.b	$06, $06, nRst, nE5, nRst, $12, nB4, $06
	dc.b	nC5, nRst, $0C, nE5, $06, nRst, $0C
	smpsLoop	$00, $04, PalmtreePanicPast_Loop5
	dc.b	nF4, $06, $06, nC5, nF4, nRst, nC5, $0C
	dc.b	nF4, $06, nC5, nF4, nF4, nC5, $0C, nF4
	dc.b	$06, nC5, nF4, nE4, nG4, nB4, nE5, nRst
	dc.b	nE4, nB4, $0C, nE4, $06, nB4, $0C, nE4
	dc.b	$06, nB4, nE4, nD5, $0C, nD4, nA4, $06
	dc.b	nD4, nRst, nD4, nRst, nA4, nRst, nD4, nA4
	dc.b	$0C, nD4, $06, nC5, $0C, nD4, $06, nE4
	dc.b	$0C, nB4, $06, nE4, nRst, nD5, nE4, nE5
	dc.b	nRst, nB4, $0C, nE4, $06, nB4, nRst, nB4
	dc.b	nE5, nF4, nF4, nC5, nF4, nRst, nC5, $0C
	dc.b	nF4, $06, nC5, nF4, nF4, nC5, $0C, nF4
	dc.b	$06, nC5, nF4, nE4, nG4, nB4, nE5, nRst
	dc.b	nE4, nB4, $0C, nE4, $06, nB4, $0C, nE4
	dc.b	$06, nB4, nE4, nD5, $0C, nRst, nA4, nRst
	dc.b	$06, nC5, $0C, nRst, $06, nA4, $0C, nRst
	dc.b	$06, nC5, $0C, nRst, $06, nA4, $0C, nRst
	dc.b	nA4, nRst, $06, nC5, $0C, nRst, $06, nA4
	dc.b	$0C, nRst, $06, nC5, $0C, nRst, $06, nA4
	dc.b	$0C, nRst, nB4, nRst, $06, nE5, $0C, nRst
	dc.b	$06, nB4, $0C, nRst, $06, nE5, $0C, nRst
	dc.b	$06, nB4, $0C, nRst, nB4, nRst, $06, nE5
	dc.b	$0C, nRst, $06, nB4, $0C, nRst, $06, nE5
	dc.b	$0C, nRst, $06, nB4, $0C

PalmtreePanicPast_Loop6:
	dc.b	nC4, $0C, nC5, $06, nE5, nRst, nB4, nC4
	dc.b	nE5, nRst, nA4, nC4, nE5, nRst, nB4, nC4
	dc.b	nE5, nE4, $0C, nB4, $06, nG5, nE4, nG5
	dc.b	nE4, nB4, nRst, nG5, nE4, nG5, nE4, nG5
	dc.b	nB4, nE4, nD4, $0C, nC5, $06, nF5, nD4
	dc.b	nD5, nD4, nRst, nE5, $0C, nD4, $06, nC5
	dc.b	$0C, nD4, $06, nD5, nA5, nG4, nRst, nG4
	dc.b	nE5, nG4, nB4, nG4, nA4, nB4, nG5, nB4
	dc.b	nBb4, nA4, nF5, nA4, nAb4, nE4, nD5, nRst
	dc.b	nG5, nE4, nB4, nRst, nD5, nE4, nG5, nRst
	dc.b	nD5, nE4, nE4, nE5, nE4, nF5, $0C, nA4
	dc.b	$06, nE5, nRst, nA4, nF5, $0C, nA4, $06
	dc.b	nG5, $0C, nA4, $06, nF5, nA4, nE5, nRst
	dc.b	nD4, nG5, nRst, nF5, $0C, nD4, $06, nG5
	dc.b	nD4, nD4, nF5, $0C, nD4, $06, nA4, nD4
	dc.b	nBb4, nRst, nG4, nB4, nRst, nE5, nG4, nE5
	dc.b	nF4, nG4, nB4, $0C, nG4, $06, nE5, $0C
	dc.b	nG4, $06, nB4, $0C
	smpsLoop	$00, $02, PalmtreePanicPast_Loop6
	smpsJump	PalmtreePanicPast_Loop5
