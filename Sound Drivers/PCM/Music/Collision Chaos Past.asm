CollisionChaosPast_Header:
	smpsHeaderStartSong	$07
	smpsHeaderChan		$09
	smpsHeaderTempo		$01, $05
	smpsHeaderPCM		CollisionChaosPast_Rhythm, $00, $FF
	smpsHeaderPCM		CollisionChaosPast_PCM1, $03, $6F
	smpsHeaderPCM		CollisionChaosPast_PCM2, $16, $5F
	smpsHeaderPCM		CollisionChaosPast_PCM3, $16, $6F
	smpsHeaderPCM		CollisionChaosPast_PCM4, $0A, $6F
	smpsHeaderPCM		CollisionChaosPast_PCM5, $0B, $BF
	smpsHeaderPCM		CollisionChaosPast_PCM6, $0A, $6F
	smpsHeaderPCM		CollisionChaosPast_PCM8, $10, $6F
	smpsHeaderPCM		CollisionChaosPast_PCM7, $0A, $6F

CollisionChaosPast_PCM1:
	smpsSetvoice	sSnare1
	smpsPan		$13
	dc.b	nG1, $03, nG1
	smpsPan		$26
	dc.b	nG1, nG1
	smpsPan		$88
	dc.b	nG1, nG1
	smpsPan		$C8
	dc.b	nG1, nG1
	smpsPan		$F7
	dc.b	nG1, $18
	smpsPan		$26
	dc.b	nG1, $03, nG1, nG1, nG1
	smpsPan		$F7
	dc.b	nG1, $12, nRst, $06
	smpsSetvoice	sKick
	smpsPan		$FF
	dc.b	nCs1, $06, nCs1
	smpsSetvoice	sSnare1
	smpsPan		$7F
	dc.b	nG1, $0C
	smpsPan		$FF
	smpsSetvoice	sKick
	dc.b	nCs1
	smpsSetvoice	sSnare1
	smpsPan		$F7
	dc.b	nG1, $0C
	smpsPan		$FF
	smpsSetvoice	sKick
	dc.b	nCs1
	smpsSetvoice	sSnare1
	smpsPan		$7F
	dc.b	nG1, $0C
	smpsPan		$FF
	smpsSetvoice	sKick
	dc.b	nCs1
	smpsSetvoice	sScratch
	smpsPan		$F3
	dc.b	nCs2, $0C
	smpsPan		$3F
	dc.b	nCs2
	smpsPan		$FF

CollisionChaosPast_Loop1:
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nRst
	smpsSetvoice	sSnare1
	dc.b	nG1, $18
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare1
	dc.b	nG1, $18
	smpsLoop	$00, $07, CollisionChaosPast_Loop1
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare1
	dc.b	nG1, nG1
	smpsSetvoice	sKick
	dc.b	nCs1, $06
	smpsSetvoice	sSnare1
	dc.b	nG1
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsSetvoice	sSnare2
	dc.b	nG1, nG1

CollisionChaosPast_Loop2:
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare2
	dc.b	nG1, $12
	smpsAlterVol	$9C
	dc.b	nG1, $06
	smpsAlterVol	$64
	smpsSetvoice	sKick
	dc.b	nCs1, $06
	smpsSetvoice	sSnare2
	dc.b	nG1, $06
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsSetvoice	sSnare2
	dc.b	nG1, $18
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare2
	dc.b	nG1, $12
	smpsAlterVol	$9C
	dc.b	nG1, $06
	smpsAlterVol	$64
	smpsSetvoice	sKick
	dc.b	nCs1, $06
	smpsSetvoice	sSnare2
	dc.b	nG1, $06
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsSetvoice	sSnare2
	dc.b	nG1, $06, nG1
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsLoop	$00, $03, CollisionChaosPast_Loop2
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare2
	dc.b	nG1, $12
	smpsAlterVol	$B0
	dc.b	nG1, $06
	smpsAlterVol	$50
	smpsSetvoice	sKick
	dc.b	nCs1, $06
	smpsSetvoice	sSnare2
	dc.b	nG1, $06
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsSetvoice	sSnare2
	dc.b	nG1, $18
	smpsSetvoice	sKick
	dc.b	nCs1, $0C, nCs1
	smpsSetvoice	sSnare2
	dc.b	nG1, nG1
	smpsSetvoice	sKick
	dc.b	nCs1, $06
	smpsSetvoice	sSnare2
	dc.b	nG1
	smpsSetvoice	sKick
	dc.b	nCs1, $0C
	smpsSetvoice	sSnare2
	dc.b	nG1, $06, nG1, nG1, nG1
	smpsLoop	$01, $04, CollisionChaosPast_Loop2
	smpsJump	CollisionChaosPast_Loop1

CollisionChaosPast_PCM2:
	smpsSetvoice	sTimpani
	smpsAlterVol	$32
	dc.b	nRst, $54, nAb0, $04
	smpsAlterVol	$0A
	dc.b	$04
	smpsAlterVol	$14
	dc.b	$04, nCs0, $0C
	smpsAlterVol	$EC
	smpsPan		$F6
	dc.b	nCs0, $0C
	smpsAlterVol	$EC
	smpsPan		$6F
	dc.b	nCs0, $0C
	smpsAlterVol	$EC
	smpsPan		$F6
	dc.b	nCs0, $0C
	smpsAlterVol	$EC
	smpsPan		$6F
	dc.b	nCs0, $0C
	smpsAlterVol	$F6
	smpsPan		$F6
	dc.b	nCs0, $0C
	smpsAlterVol	$0A
	dc.b	nRst, nRst

CollisionChaosPast_Jump1:
	smpsPan		$8F
	smpsAlterNote	$FB

CollisionChaosPast_Loop3:
	smpsSetvoice	sSynth1
	dc.b	nC0, $0C, nBb0, nC1, nC0, nBb0, nBb0, $06
	dc.b	nC1, $0C, nC1, $06, nBb0, $0C
	smpsLoop	$00, $10, CollisionChaosPast_Loop3
	smpsAlterPitch	$01
	smpsAlterNote	$0A
	smpsAlterVol	$B0

CollisionChaosPast_Loop4:
	smpsSetvoice	sBlip
	smpsPan		$F0
	dc.b	nEb0, $06
	smpsPan		$FD
	dc.b	nD0
	smpsPan		$DF
	dc.b	nCs0
	smpsPan		$0F
	dc.b	nC0
	smpsLoop	$00, $08, CollisionChaosPast_Loop4
	smpsAlterPitch	$FD
	smpsLoop	$01, $02, CollisionChaosPast_Loop4
	smpsAlterPitch	$06
	smpsLoop	$02, $02, CollisionChaosPast_Loop4

CollisionChaosPast_Loop5:
	smpsSetvoice	sBlip
	smpsAlterVol	$14
	smpsPan		$0F
	dc.b	nC1, $06, nC1
	smpsPan		$8F
	dc.b	nC1, nC1
	smpsPan		$FF
	dc.b	nC1, nC1
	smpsPan		$F8
	dc.b	nC1, nC1
	smpsPan		$F0
	dc.b	nC1, nC1
	smpsPan		$F8
	dc.b	nC1, nC1
	smpsPan		$FF
	dc.b	nC1, nC1
	smpsPan		$8F
	dc.b	nC1, nC1
	smpsAlterVol	$EC
	smpsLoop	$00, $04, CollisionChaosPast_Loop5
	smpsPan		$FF

CollisionChaosPast_Loop6:
	smpsAlterVol	$46
	smpsSetvoice	sSynth2
	smpsAlterPitch	$F4
	smpsPan		$F6
	dc.b	nC1, $0C
	smpsAlterVol	$CE
	dc.b	nC1
	smpsAlterVol	$32
	smpsPan		$6F
	dc.b	nB0, $0C
	smpsAlterVol	$CE
	dc.b	nB0
	smpsAlterVol	$32
	smpsPan		$F6
	dc.b	nBb0, $0C
	smpsAlterVol	$CE
	dc.b	nBb0, $06
	smpsAlterVol	$32
	smpsPan		$6F
	dc.b	nA0, $0C
	smpsAlterVol	$CE
	dc.b	nA0, $06
	smpsAlterVol	$32
	smpsPan		$F6
	dc.b	nAb0, $0C
	smpsPan		$FF
	smpsAlterPitch	$0C
	smpsAlterVol	$BA
	smpsLoop	$00, $04, CollisionChaosPast_Loop6
	smpsAlterPitch	$FF
	smpsAlterNote	$F6
	smpsAlterVol	$50

CollisionChaosPast_Loop7:
	smpsSetvoice	sSynth1
	dc.b	nC0, $0C, nBb0, nC1, nC0, nBb0, nBb0, $06
	dc.b	nC1, $0C, nC1, $06, nBb0, $0C
	smpsLoop	$00, $08, CollisionChaosPast_Loop7
	smpsAlterNote	$05
	smpsJump	CollisionChaosPast_Jump1

CollisionChaosPast_PCM3:
	smpsAlterPitch	$EA
	smpsAlterVol	$46
	smpsAlterNote	$0A
	smpsSetvoice	sSynthKick
	dc.b	nB0, $24, $3C, nB0, $24, $3C
	smpsAlterNote	$F6
	smpsAlterVol	$BA
	smpsAlterPitch	$16

CollisionChaosPast_Jump2:
	smpsAlterPitch	$E9
	smpsAlterNote	$06
	smpsAlterVol	$46

CollisionChaosPast_Loop8:
	smpsPan		$FF
	smpsSetvoice	sSynthKick
	dc.b	nC1, $0C, nBb0, nB0, nC1, nRst, nBb0, nB0
	dc.b	nC1
	smpsLoop	$00, $10, CollisionChaosPast_Loop8

CollisionChaosPast_Loop9:
	dc.b	nEb1, $0C
	smpsLoop	$00, $10, CollisionChaosPast_Loop9

CollisionChaosPast_Loop10:
	dc.b	nC1, $0C
	smpsLoop	$00, $10, CollisionChaosPast_Loop10
	smpsLoop	$01, $02, CollisionChaosPast_Loop9

CollisionChaosPast_Loop11:
	smpsPan		$FF
	smpsSetvoice	sSynthKick
	dc.b	nC1, $0C, nBb0, nB0, nC1, nRst, nBb0, nB0
	dc.b	nC1
	smpsLoop	$00, $10, CollisionChaosPast_Loop11
	smpsAlterVol	$BA
	smpsAlterNote	$FA
	smpsAlterPitch	$17
	smpsJump	CollisionChaosPast_Jump2

CollisionChaosPast_PCM4:
	smpsAlterVol	$1E
	smpsSetvoice	sSynthHit
	dc.b	nRst, $18, nF1, nRst, $0C, nF1, $18, nRst
	dc.b	$0C, nRst, $18, nF1, nRst, $0C, nF1, $18
	dc.b	nRst, $0C
	smpsAlterVol	$E2
	smpsPan		$FA

CollisionChaosPast_Loop12:
	smpsSetvoice	sSynthFlute
	smpsAlterPitch	$05
	dc.b	nG0, $0C, nG1, nF1, nE1, nRst, nC1, nRst
	dc.b	nBb0, nRst, nC1, nRst, nG0, nRst
	smpsAlterVol	$91
	dc.b	nG0, $0C, nRst
	smpsAlterVol	$6F
	dc.b	nG0, $06, nA0, nBb0, $0C, nBb0, nA0, nRst
	dc.b	nBb0, $12, nA0, $06, nRst, $0C, nG0, nRst
	dc.b	$0C
	smpsAlterVol	$91
	dc.b	nG0, $0C
	smpsAlterVol	$6F
	smpsAlterPitch	$FB
	smpsSetvoice	sSynthHit
	smpsAlterVol	$1E
	dc.b	nEb1, $18, nRst, $0C, nEb1, $18, nRst, $0C
	smpsAlterVol	$E2
	smpsSetvoice	sSynthFlute
	smpsAlterPitch	$05
	dc.b	nG0, $0C, nG1, nF1, nE1, nRst, nC1, nRst
	dc.b	nBb0, nRst, nC1, nRst, nG0, nRst
	smpsAlterVol	$91
	dc.b	nG0, $0C, nRst
	smpsAlterVol	$6F
	dc.b	nG0, $06, nA0, nBb0, $0C, nBb0, nA0, nRst
	dc.b	nBb0, $12, nD1, $06, nRst, $0C, nC1, nRst
	dc.b	$0C
	smpsAlterVol	$91
	dc.b	nC1, $0C
	smpsAlterVol	$6F
	smpsAlterPitch	$FB
	smpsSetvoice	sSynthHit
	smpsAlterVol	$1E
	smpsAlterNote	$FA
	dc.b	nF1, $18, nRst, $0C, nF1, $18, nRst, $0C
	smpsAlterVol	$E2
	smpsAlterNote	$06
	smpsLoop	$01, $02, CollisionChaosPast_Loop12
	smpsSetvoice	sSynthFlute
	smpsAlterPitch	$05
	dc.b	nG0, $24, nD1, $3C, nRst, $18, nD1, nD1
	dc.b	$12, nEb1, nF1, $0C, nD1, $24, nB0, $3C
	dc.b	nRst, $60, nG0, $24, nD1, $3C, nRst, $18
	dc.b	nD1, nD1, $12, nEb1, nF1, $0C, nG1, $1E
	dc.b	nFs1, $03, nF1, nE1, $3C, nRst, $60

CollisionChaosPast_Loop13:
	dc.b	nC1, $0C, nG1, nFs1, nF1, nEb1, $12, nC1
	smpsAlterVol	$E2
	dc.b	nC1, $0C
	smpsAlterVol	$1E
	dc.b	nRst, $0C, nG1, nFs1, nF1, nEb1, $06, nC1
	dc.b	nEb1, nF1, nRst, nF1, nEb1, nRst
	smpsLoop	$00, $04, CollisionChaosPast_Loop13

CollisionChaosPast_Loop14:
	dc.b	nRst, $06, nRst, nG0, $0C, nBb0, nG0, nBb0
	dc.b	$06, nG0, nBb0, nC1
	smpsAlterVol	$E2
	dc.b	nC1, $0C
	smpsAlterVol	$E2
	dc.b	nC1, $06
	smpsAlterVol	$3C
	dc.b	nG0, $06, nBb0, $0C, nG0, nBb0, $06, nD1
	dc.b	$0C, nC1, nBb0, nG0, nRst, $12, nRst, $06
	dc.b	nRst, nG0, $0C, nBb0, nG0, nBb0, $06, nG0
	dc.b	nBb0, nC1
	smpsAlterVol	$E2
	dc.b	nC1, $0C
	smpsAlterVol	$E2
	dc.b	nC1, $06
	smpsAlterVol	$3C
	dc.b	nG0, $06, nBb0, $0C, nG0, nBb0, $06, nD1
	dc.b	$0C, nC1, $12, nRst, $24
	smpsLoop	$00, $02, CollisionChaosPast_Loop14
	smpsAlterPitch	$FB
	smpsJump	CollisionChaosPast_Loop12

CollisionChaosPast_PCM7:
	smpsStop

CollisionChaosPast_PCM6:
	smpsSetvoice	sSynthPiano
	dc.b	nEb1, $0C, $0C, $0C, $0C
	smpsAlterVol	$10
	dc.b	nEb1, $0C, $0C, $0C, $0C
	smpsAlterVol	$10
	dc.b	nEb1, $0C, $0C, $0C, $0C
	smpsAlterVol	$10
	dc.b	nEb1, $0C, $0C, $0C, $0C
	smpsAlterVol	$D0

CollisionChaosPast_Loop19:
	smpsPan		$AF
	smpsSetvoice	sHiHat2
	dc.b	nF1, $06, nF1, nF1, $0C
	smpsSetvoice	sHiHat1
	smpsPan		$F2
	dc.b	nF1, $0C
	smpsPan		$2F
	dc.b	nF1
	smpsSetvoice	sHiHat2
	dc.b	nF1
	smpsPan		$FA
	dc.b	nF1
	smpsSetvoice	sHiHat1
	smpsPan		$2F
	dc.b	nF1
	smpsSetvoice	sHiHat2
	dc.b	nF1, $06, nF1
	smpsPan		$AF
	smpsLoop	$00, $07, CollisionChaosPast_Loop19
	smpsPan		$AF
	smpsSetvoice	sHiHat2
	dc.b	nF1, $06, nF1, nF1, $0C
	smpsSetvoice	sHiHat1
	smpsPan		$F2
	dc.b	nF1, $0C
	smpsPan		$2F
	dc.b	nF1
	smpsSetvoice	sHiHat2
	dc.b	nF1
	smpsSetvoice	sScratch
	smpsPan		$EE
	dc.b	nF1, $06, nRst
	smpsPan		$2F
	dc.b	nF1, $0C
	smpsPan		$F2
	dc.b	nF1
	smpsJump	CollisionChaosPast_Loop19

CollisionChaosPast_PCM8:
	smpsAlterVol	$14
	smpsAlterPitch	$F0
	smpsAlterNote	$F6
	smpsSetvoice	sSqueak
	smpsPan		$2D
	dc.b	nRst, $54, nF1, $05, nRst, $01
	smpsPan		$D2
	dc.b	nF1, $05, nRst, $01
	smpsPan		$2D
	dc.b	nB0, $18
	smpsAlterVol	$C4
	smpsPan		$D2
	dc.b	nB0
	smpsAlterVol	$C4
	smpsPan		$2D
	dc.b	nB0, $18
	smpsAlterVol	$E2
	smpsPan		$D2
	dc.b	nB0
	smpsAlterVol	$96
	smpsAlterNote	$0A
	smpsAlterVol	$EC
	smpsAlterPitch	$10

CollisionChaosPast_Jump4:
	smpsAlterNote	$F9

CollisionChaosPast_Loop20:
	smpsSetvoice	sSynthBass
	smpsAlterVol	$0A
	smpsPan		$F9
	smpsAlterPitch	$EF
	dc.b	nC1, $0C
	smpsPan		$0F
	smpsAlterVol	$CE
	dc.b	nC1, $0C
	smpsPan		$F6
	smpsAlterVol	$EC
	dc.b	nC1, $0C
	smpsAlterPitch	$11
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsLoop	$00, $02, CollisionChaosPast_Loop20
	dc.b	nRst, $18
	smpsLoop	$01, $10, CollisionChaosPast_Loop20

CollisionChaosPast_Loop22:
	smpsAlterPitch	$03

CollisionChaosPast_Loop21:
	smpsSetvoice	sSynthBass
	smpsAlterVol	$0A
	smpsPan		$F9
	smpsAlterPitch	$EF
	dc.b	nC1, $0C
	smpsPan		$0F
	smpsAlterVol	$CE
	dc.b	nC1, $0C
	smpsPan		$F6
	smpsAlterVol	$EC
	dc.b	nC1, $0C
	smpsAlterPitch	$11
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsLoop	$00, $02, CollisionChaosPast_Loop21
	dc.b	nRst, $18
	smpsLoop	$01, $02, CollisionChaosPast_Loop21
	smpsAlterPitch	$FD
	smpsLoop	$02, $02, CollisionChaosPast_Loop21
	smpsAlterPitch	$03
	smpsLoop	$03, $02, CollisionChaosPast_Loop22

CollisionChaosPast_Loop23:
	smpsSetvoice	sSynthBass
	smpsAlterPitch	$EC
	dc.b	nEb1, $18
	smpsSetvoice	sSnare1
	smpsAlterPitch	$07
	dc.b	nG1, $0A
	smpsAlterPitch	$0D
	smpsSetvoice	sSynthBass
	smpsAlterPitch	$EC
	dc.b	nBb0, $0C, nCs1, nEb1, nRst, $02
	smpsSetvoice	sSnare1
	smpsAlterPitch	$07
	dc.b	nG1, $18
	smpsAlterPitch	$0D
	smpsLoop	$00, $07, CollisionChaosPast_Loop23
	smpsSetvoice	sSynthBass
	smpsAlterPitch	$EC
	dc.b	nEb1, $18
	smpsSetvoice	sSnare1
	smpsAlterPitch	$07
	dc.b	nG1, $18, nG1, $0C, $06, $0C, $06, $06
	dc.b	$06
	smpsAlterPitch	$0D
	smpsAlterNote	$F9

CollisionChaosPast_Loop24:
	smpsSetvoice	sSynthBass
	smpsAlterVol	$0A
	smpsPan		$F9
	smpsAlterPitch	$EF
	dc.b	nC1, $0C
	smpsPan		$0F
	smpsAlterVol	$CE
	dc.b	nC1, $0C
	smpsPan		$F6
	smpsAlterVol	$EC
	dc.b	nC1, $0C
	smpsAlterPitch	$11
	smpsPan		$FF
	smpsAlterVol	$3C
	smpsLoop	$00, $02, CollisionChaosPast_Loop24
	dc.b	nRst, $18
	smpsLoop	$01, $08, CollisionChaosPast_Loop24
	smpsAlterNote	$07
	smpsJump	CollisionChaosPast_Jump4

CollisionChaosPast_PCM5:
	smpsSetvoice	sStrings
	smpsAlterVol	$90
	dc.b	nC1, $0C, $0C, $0C, $0C
	smpsAlterVol	$20
	dc.b	nC1, $0C, $0C, $0C, $0C
	smpsAlterVol	$20
	dc.b	nC1, $0C, $0C, $0C, $0C
	smpsAlterVol	$30
	dc.b	nC1, $0C, $0C, $0C, $0C

CollisionChaosPast_Jump3:
	smpsAlterNote	$05

CollisionChaosPast_Loop15:
	smpsSetvoice	sSynth2
	dc.b	nRst, $18
	smpsCall	CollisionChaosPast_Call1
	smpsLoop	$00, $03, CollisionChaosPast_Loop15
	dc.b	nRst, $60
	smpsLoop	$01, $04, CollisionChaosPast_Loop15

CollisionChaosPast_Loop16:
	smpsAlterPitch	$05
	smpsAlterVol	$1E
	smpsSetvoice	sRattle
	dc.b	nC1, $18
	smpsSetvoice	sJamesBrownHit
	smpsCall	CollisionChaosPast_Call1
	dc.b	nRst, $18
	smpsSetvoice	sJamesBrownHit
	smpsCall	CollisionChaosPast_Call1
	smpsSetvoice	sRattle
	dc.b	nC1, $18
	smpsAlterPitch	$FD
	smpsSetvoice	sJamesBrownHit
	smpsCall	CollisionChaosPast_Call1
	dc.b	nRst, $18
	smpsSetvoice	sJamesBrownHit
	smpsCall	CollisionChaosPast_Call1
	smpsAlterPitch	$FE
	smpsAlterVol	$E2
	smpsLoop	$00, $02, CollisionChaosPast_Loop16

CollisionChaosPast_Loop17:
	smpsAlterPitch	$07
	smpsAlterVol	$1E
	smpsPan		$7F
	dc.b	nC1, $18
	smpsPan		$F7
	dc.b	nB0
	smpsPan		$7F
	dc.b	nBb0, $12
	smpsPan		$F7
	dc.b	nAb0
	smpsPan		$7F
	dc.b	nG0, $0C
	smpsPan		$FF
	smpsAlterPitch	$F9
	smpsAlterVol	$E2
	smpsLoop	$00, $08, CollisionChaosPast_Loop17
	smpsAlterNote	$FB

CollisionChaosPast_Loop18:
	smpsSetvoice	sSynth2
	dc.b	nRst, $18
	smpsCall	CollisionChaosPast_Call1
	smpsLoop	$00, $08, CollisionChaosPast_Loop18
	smpsJump	CollisionChaosPast_Jump3
	even

CollisionChaosPast_Call1:
	smpsPan		$FF
	dc.b	nC1, $0C
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nC1
	smpsAlterVol	$CE
	smpsPan		$F7
	dc.b	nC1
	smpsAlterVol	$64
	smpsPan		$FF
	dc.b	nC1
	smpsAlterVol	$CE
	smpsPan		$7F
	dc.b	nC1
	smpsAlterVol	$CE
	smpsPan		$F7
	dc.b	nC1
	smpsAlterVol	$64
	smpsReturn

CollisionChaosPast_Rhythm:
	smpsStop
