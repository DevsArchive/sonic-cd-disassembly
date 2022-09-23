; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main CPU definitions
; -------------------------------------------------------------------------

MAINCPU		EQU	1

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; Cartridge
CARTRIDGE	EQU	$400000			; Cartridge start
CARTRIDGEE	EQU	$800000			; Cartridge end
CARTRIDGES	EQU	CARTRIDGEE-CARTRIDGES	; Cartridge size
CARTID		EQU	CARTRIDGE+$000001	; RAM cartridge ID
CARTDATA	EQU	CARTRIDGE+$200001	; RAM cartridge data
CARTDATAE	EQU	CARTRIDGE+$300000	; RAM cartridge data end
CARTDATAS	EQU	(CARTDATAE-CARTDATA)/2+1; RAM cartridge data size
CARTWREN	EQU	CARTRIDGE+$3FFFFF	; RAM cartridge write enable
CARTSPECID	EQU	CARTRIDGE+$000010	; Special RAM cartridge ID
CARTSPECPRG	EQU	CARTRIDGE+$000020	; Special RAM cartridge handler

; Expansion
EXPANSION	EQU	$000000			; Expansion memory start
EXPANSIONE	EQU	$400000			; Expansion memory end
EXPANDS		EQU	EXPANSIONE-EXPANSION	; Expansion memory size

; Z80
Z80RAM		EQU	$A00000			; Z80 RAM start
Z80RAME		EQU	$A02000			; Z80 RAM end
Z80RAMS		EQU	Z80RAME-Z80RAM		; Z80 RAM size
Z80BUS		EQU	$A11100			; Z80 bus request
Z80RESET	EQU	$A11200			; Z80 reset

; Work RAM
WORKRAM		EQU	$FF0000			; Work RAM start
WORKRAME	EQU	$1000000		; Work RAM end
WORKRAMS	EQU	WORKRAME-WORKRAM	; Work RAM size

; Sound
YMADDR0		EQU	$A04000			; YM2612 address port 0
YMDATA0		EQU	$A04001			; YM2612 data port 0
YMADDR1		EQU	$A04002			; YM2612 address port 1
YMDATA1		EQU	$A04003			; YM2612 data port 1
PSGCTRL		EQU	$C00011			; PSG control port

; VDP
VDPDATA		EQU	$C00000			; VDP data port
VDPCTRL		EQU	$C00004			; VDP control port
VDPHVCNT	EQU	$C00008			; VDP H/V counter
VDPDEBUG	EQU	$C0001C			; VDP debug register

; I/O
VERSION		EQU	$A10001			; Hardware version
IODATA1		EQU	$A10003			; I/O port 1 data port
IODATA2		EQU	$A10005			; I/O port 2 data port
IODATA3		EQU	$A10007			; I/O port 3 data port
IOCTRL1		EQU	$A10009			; I/O port 1 control port
IOCTRL2		EQU	$A1000B			; I/O port 2 control port
IOCTRL3		EQU	$A1000D			; I/O port 3 control port

; TMSS
TMSSSEGA	EQU	$A14000			; TMSS "SEGA" register
TMSSMODE	EQU	$A14100			; TMSS bus mode

; Mega CD BIOS ROM
CDBIOS		EQU	EXPANSION+$000000	; MCD BIOS ROM start
CDBIOSE		EQU	EXPANSION+$020000	; MCD BIOS ROM end
CDBIOSS		EQU	CDBIOSE-CDBIOS		; MCD BIOS ROM size

; Mega CD PRG-RAM
PRGRAM		EQU	EXPANSION+$020000	; MCD PRG-RAM bank start
PRGRAME		EQU	EXPANSION+$040000	; MCD PRG-RAM bank end
PRGRAMS		EQU	PRGRAME-PRGRAM		; MCD PRG-RAM bank size
SUBPRGRAM	EQU	$000000			; MCD Sub CPU address for PRG-RAM

; Mega CD Word RAM
WORDRAM1M	EQU	EXPANSION+$200000	; MCD Word RAM start (1M/1M)
WORDRAM1ME	EQU	EXPANSION+$220000	; MCD Word RAM end (1M/1M)
WORDRAM1MS	EQU	WORDRAM1ME-WORDRAM1M	; MCD Word RAM size (1M/1M)
WORDRAM2M	EQU	EXPANSION+$200000	; MCD Word RAM start (2M)
WORDRAM2ME	EQU	EXPANSION+$240000	; MCD Word RAM end (2M)
WORDRAM2MS	EQU	WORDRAM2ME-WORDRAM2M	; MCD Word RAM size (2M)
WORDRAMIMG	EQU	EXPANSION+$220000	; MCD VRAM image of Word RAM start (1M/1M)
WORDRAMIMGE	EQU	EXPANSION+$240000	; MCD VRAM image of Word RAM end (1M/1M)
WORDRAMIMGS	EQU	WORDRAMIMGE-WORDRAMIMGS	; MCD VRAM image of Word RAM size (1M/1M)
SUBWORDRAM2M	EQU	$080000			; MCD Sub CPU address for Word RAM (2M)
SUBWORDRAM1M	EQU	$0C0000			; MCD Sub CPU address for Word RAM (1M/1M)

; Mega CD gate array
GATEARRAY	EQU	$A12000			; Gate array
GAIRQ2		EQU	GATEARRAY+$0000		; IRQ2 send
GARESET		EQU	GATEARRAY+$0001		; Reset
GAPROTECT	EQU	GATEARRAY+$0002		; Write protection
GAMEMMODE	EQU	GATEARRAY+$0003		; Memory mode
GACDCMODE	EQU	GATEARRAY+$0004		; CDC mode/Device destination
GAUSERHINT	EQU	GATEARRAY+$0006		; User H-INT address
GACDCHOST	EQU	GATEARRAY+$0008		; 16-bit CDC data to host
GASTOPWATCH	EQU	GATEARRAY+$000C		; Stopwatch
GACOMFLAGS	EQU	GATEARRAY+$000E		; Communication flags
GAMAINFLAG	EQU	GATEARRAY+$000E		; Main CPU communication flag
GASUBFLAG	EQU	GATEARRAY+$000F		; Sub CPU communication flag
GACOMCMDS	EQU	GATEARRAY+$0010		; Communication commands
GACOMCMD0	EQU	GATEARRAY+$0010		; Communication command 0
GACOMCMD1	EQU	GATEARRAY+$0011		; Communication command 0
GACOMCMD2	EQU	GATEARRAY+$0012		; Communication command 1
GACOMCMD3	EQU	GATEARRAY+$0013		; Communication command 1
GACOMCMD4	EQU	GATEARRAY+$0014		; Communication command 2
GACOMCMD5	EQU	GATEARRAY+$0015		; Communication command 2
GACOMCMD6	EQU	GATEARRAY+$0016		; Communication command 3
GACOMCMD7	EQU	GATEARRAY+$0017		; Communication command 3
GACOMCMD8	EQU	GATEARRAY+$0018		; Communication command 4
GACOMCMD9	EQU	GATEARRAY+$0019		; Communication command 4
GACOMCMDA	EQU	GATEARRAY+$001A		; Communication command 5
GACOMCMDB	EQU	GATEARRAY+$001B		; Communication command 5
GACOMCMDC	EQU	GATEARRAY+$001C		; Communication command 6
GACOMCMDD	EQU	GATEARRAY+$001D		; Communication command 6
GACOMCMDE	EQU	GATEARRAY+$001E		; Communication command 7
GACOMCMDF	EQU	GATEARRAY+$001F		; Communication command 7
GACOMSTATS	EQU	GATEARRAY+$0020		; Communication statuses
GACOMSTAT0	EQU	GATEARRAY+$0020		; Communication status 0
GACOMSTAT1	EQU	GATEARRAY+$0021		; Communication status 0
GACOMSTAT2	EQU	GATEARRAY+$0022		; Communication status 1
GACOMSTAT3	EQU	GATEARRAY+$0023		; Communication status 1
GACOMSTAT4	EQU	GATEARRAY+$0024		; Communication status 2
GACOMSTAT5	EQU	GATEARRAY+$0025		; Communication status 2
GACOMSTAT6	EQU	GATEARRAY+$0026		; Communication status 3
GACOMSTAT7	EQU	GATEARRAY+$0027		; Communication status 3
GACOMSTAT8	EQU	GATEARRAY+$0028		; Communication status 4
GACOMSTAT9	EQU	GATEARRAY+$0029		; Communication status 4
GACOMSTATA	EQU	GATEARRAY+$002A		; Communication status 5
GACOMSTATB	EQU	GATEARRAY+$002B		; Communication status 5
GACOMSTATC	EQU	GATEARRAY+$002C		; Communication status 6
GACOMSTATD	EQU	GATEARRAY+$002D		; Communication status 6
GACOMSTATE	EQU	GATEARRAY+$002E		; Communication status 7
GACOMSTATF	EQU	GATEARRAY+$002F		; Communication status 7

; BIOS functions
BIOS_SetVDPRegs	EQU	CDBIOS+$2B0		; Set up VDP registers
BIOS_DMA68k	EQU	CDBIOS+$2D4		; DMA 68000 data to VDP memory

; CD Work RAM assignments
_EXCPT		EQU	$FFFFFD00		; Exception
_LEVEL6		EQU	$FFFFFD06		; V-INT
_LEVEL4		EQU	$FFFFFD0C		; H-INT
_LEVEL2		EQU	$FFFFFD12		; EXT-INT
_TRAP00		EQU	$FFFFFD18		; TRAP #00
_TRAP01		EQU	$FFFFFD1E		; TRAP #01
_TRAP02		EQU	$FFFFFD24		; TRAP #02
_TRAP03		EQU	$FFFFFD2A		; TRAP #03
_TRAP04		EQU	$FFFFFD30		; TRAP #04
_TRAP05		EQU	$FFFFFD36		; TRAP #05
_TRAP06		EQU	$FFFFFD3C		; TRAP #06
_TRAP07		EQU	$FFFFFD42		; TRAP #07
_TRAP08		EQU	$FFFFFD48		; TRAP #08
_TRAP09		EQU	$FFFFFD4E		; TRAP #09
_TRAP10		EQU	$FFFFFD54		; TRAP #10
_TRAP11		EQU	$FFFFFD5A		; TRAP #11
_TRAP12		EQU	$FFFFFD60		; TRAP #12
_TRAP13		EQU	$FFFFFD66		; TRAP #13
_TRAP14		EQU	$FFFFFD6C		; TRAP #14
_TRAP15		EQU	$FFFFFD72		; TRAP #15
_CHKERR		EQU	$FFFFFD78		; CHK exception
_ADRERR		EQU	$FFFFFD7E		; Address error
_CODERR		EQU	$FFFFFD7E		; Illegal instruction
_DIVERR		EQU	$FFFFFD84		; Division by zero
_TRPERR		EQU	$FFFFFD8A		; TRAPV
_NOCOD0		EQU	$FFFFFD90		; Line A emulator
_NOCOD1		EQU	$FFFFFD96		; Line F emulator
_SPVERR		EQU	$FFFFFD9C		; Privilege violation
_TRACE		EQU	$FFFFFDA2		; TRACE exception
_BURAM		EQU	$FFFFFDAE		; Cartridge Backup RAM handler

; -------------------------------------------------------------------------
; BIOS function codes
; -------------------------------------------------------------------------

BRMINIT		EQU	$00
BRMSTAT		EQU	$01
BRMSERCH	EQU	$02
BRMREAD		EQU	$03
BRMWRITE	EQU	$04
BRMDEL		EQU	$05
BRMFORMAT	EQU	$06
BRMDIR		EQU	$07
BRMVERIFY	EQU	$08

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

PALLNCOLORS	EQU	$10			; Colors per palette line
PALLINES	EQU	4			; Number of palette lines
VSCRLCNT	EQU	$14			; Number of vertial scroll entries
HSCRLCNT	EQU	$E0			; Number of horizontal scroll entries
SPRITECNT	EQU	$50			; Nunber of sprites

; -------------------------------------------------------------------------
; Palette line structure
; -------------------------------------------------------------------------

	rsreset
	RSRPT.W	palCol, PALLNCOLORS, 1		; Palette entries
PALLINESZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Palette structure
; -------------------------------------------------------------------------

	rsreset
	RSRPT.B	palLn, PALLINES, PALLINESZ	; Palette lines
PALETTESZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Scroll entry structure
; -------------------------------------------------------------------------

	rsreset
scrlFG		rs.w	1			; Foreground entry
scrlBG		rs.w	1			; Background entry
SCRLENTRYSZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Vertical scroll structure
; -------------------------------------------------------------------------

	rsreset
	RSRPT.B	vscrl, VSCRLCNT, SCRLENTRYSZ	; Scroll entries
VSCROLLSZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Horizontal scroll structure
; -------------------------------------------------------------------------

	rsreset
	RSRPT.B	hscrl, HSCRLCNT, SCRLENTRYSZ	; Scroll entries
HSCROLLSZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Sprite table entry structure
; -------------------------------------------------------------------------

	rsreset
sprY		rs.w	1			; Y position
sprSize		rs.b	1			; Sprite size
sprLink		rs.b	1			; Link data
sprTile		rs.w	1			; Tile attributes
sprX		rs.w	1			; X position
SPRENTRYSZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Sprite table structure
; -------------------------------------------------------------------------

	rsreset
	RSRPT.B	spr, SPRITECNT, SPRENTRYSZ	; Sprite entries
SPRTABLESZ	rs.b	0			; Structure size

; -------------------------------------------------------------------------
; YM2612 register bank structure
; -------------------------------------------------------------------------
	
	rsreset
ymAddr		rs.b	1			; Address
ymData		rs.b	1			; Data
YMREGSZ		rs.b	0			; Structure size

; -------------------------------------------------------------------------
; Request Z80 bus access
; -------------------------------------------------------------------------

Z80REQ macros
	move.w	#$100,Z80BUS			; Request Z80 bus access

; -------------------------------------------------------------------------
; Wait for Z80 bus request acknowledgement
; -------------------------------------------------------------------------

Z80WAIT macro
.Wait\@:
	btst	#0,Z80BUS			; Was the request acknowledged?
	bne.s	.Wait\@				; If not, wait
	endm

; -------------------------------------------------------------------------
; Request Z80 bus access
; -------------------------------------------------------------------------

Z80STOP macro
	Z80REQ					; Request Z80 bus access
	Z80WAIT					; Wait for acknowledgement
	endm

; -------------------------------------------------------------------------
; Release the Z80 bus
; -------------------------------------------------------------------------

Z80START macros
	move.w	#0,Z80BUS			; Release the bus

; -------------------------------------------------------------------------
; Request Z80 reset
; -------------------------------------------------------------------------

Z80RESON macro
	move.w	#0,Z80RESET			; Request Z80 reset
	ror.b	#8,d0				; Delay
	endm

; -------------------------------------------------------------------------
; Cancel Z80 reset
; -------------------------------------------------------------------------

Z80RESOFF macros
	move.w	#$100,Z80RESET			; Cancel Z80 reset

; -------------------------------------------------------------------------
; Wait for DMA to finish
; -------------------------------------------------------------------------
; PARAMETERS:
;	ctrl - (OPTIONAL) VDP control port address register
; -------------------------------------------------------------------------

DMAWAIT macro ctrl
.Wait\@:
	if narg>0
		btst	#1,1(\ctrl)		; Is DMA active?
	else
		move.w	VDPCTRL,d0		; Is DMA active?
		btst	#1,d0
	endif
	bne.s	.Wait\@				; If so, wait
	endm

; -------------------------------------------------------------------------
; VDP command instruction
; -------------------------------------------------------------------------
; PARAMETERS:
;	addr - Address in VDP memory
;	type - Type of VDP memory
;	rwd  - VDP command
;	end  - Destination, or modifier if end2 is defined
;	end2 - Destination if defined
; -------------------------------------------------------------------------

VRAMWRITE	EQU	$40000000		; VRAM write
CRAMWRITE	EQU	$C0000000		; CRAM write
VSRAMWRITE	EQU	$40000010		; VSRAM write
VRAMREAD	EQU	$00000000		; VRAM read
CRAMREAD	EQU	$00000020		; CRAM read
VSRAMREAD	EQU	$00000010		; VSRAM read
VRAMDMA		EQU	$40000080		; VRAM DMA
CRAMDMA		EQU	$C0000080		; CRAM DMA
VSRAMDMA	EQU	$40000090		; VSRAM DMA
VRAMCOPY	EQU	$000000C0		; VRAM DMA copy

; -------------------------------------------------------------------------

VDPCMD macro ins, addr, type, rwd, end, end2
	local	cmd
cmd	= (\type\\rwd\)|(((\addr)&$3FFF)<<16)|((\addr)/$4000)
	if narg=5
		\ins	#\#cmd,\end
	elseif narg>=6
		\ins	#(\#cmd)\end,\end2
	else
		\ins	cmd
	endif
	endm

; -------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
;	a6.l - VDP control port
; -------------------------------------------------------------------------

DMA68K2 macro src, dest, len, type
	; DMA data
	move.l	#$93009400|((((\len)/2)&$FF00)>>8)|((((\len)/2)&$FF)<<16),(a6)
	move.l	#$95009600|((((\src)/2)&$FF00)>>8)|((((\src)/2)&$FF)<<16),(a6)
	move.w	#$9700|(((\src)>>17)&$7F),(a6)
	VDPCMD	move.w,\dest,\type,DMA,>>16,(a6)
	VDPCMD	move.w,\dest,\type,DMA,&$FFFF,-(sp)
	move.w	(sp)+,(a6)

	; Manually write first word
	VDPCMD	move.l,\dest,\type,WRITE,(a6)
	move.w	\src,VDPDATA
	endm

; -------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; (Automatically sets VDP control port in a6)
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
; -------------------------------------------------------------------------

DMA68K macro src, dest, len, type
	lea	VDPCTRL,a6
	DMA68K2	\src,\dest,\len,\type
	endm

; -------------------------------------------------------------------------
; VDP DMA fill VRAM with byte
; -------------------------------------------------------------------------
; PARAMETERS:
;	addr - Address in VRAM
;	len  - Length of fill in bytes
;	byte - Byte to fill VRAM with
; -------------------------------------------------------------------------

DMAFILL macro addr, len, byte
	; DMA fill
	lea	VDPCTRL,a6
	move.w	#$8F01,(a6)
	move.l	#$93009400|((((\len)-1)&$FF00)>>8)|((((\len)-1)&$FF)<<16),(a6)
	move.w	#$9780,(a6)
	VDPCMD	move.l,\addr,VRAM,DMA,(a6)
	move.w	#(\byte)<<8,VDPDATA
	DMAWAIT	a6
	
	; Manually write first word
	VDPCMD	move.l,\addr,VRAM,WRITE,(a6)
	move.w	#((\byte)<<8)|(\byte),VDPDATA
	move.w	#$8F02,(a6)
	endm

; -------------------------------------------------------------------------
; VDP DMA copy region of VRAM to another location in VRAM
; Auto-increment should be set to 1 beforehand.
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in VRAM
;	dest - Destination address in VRAM
;	len  - Length of copy in bytes
; -------------------------------------------------------------------------

DMACOPY macro src, dest, len
	lea	VDPCTRL,a6
	move.w	#$8F01,(a6)
	move.l	#$93009400|((((\len)-1)&$FF00)>>8)|((((\len)-1)&$FF)<<16),(a6)
	move.l	#$95009600|(((\src)&$FF00)>>8)|(((\src)&$FF)<<16),(a6)
	move.w	#$97C0,(a6)
	VDPCMD	move.l,\addr,VRAM,COPY,(a6)
	DMAWAIT	a6
	move.w	#$8F02,(a6)
	endm

; -------------------------------------------------------------------------
; Copy image buffer to VRAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address
;	buf  - Buffer ID
;	part - Buffer part ID
; -------------------------------------------------------------------------

COPYIMG macro src, buf, part
	local off, len, vadr
	
	if (\part)=0
		off: = 0
		len: = IMGV1LEN
	else
		off: = IMGV1LEN
		len: = IMGLENGTH-IMGV1LEN
	endif
	
	vadr: = IMGVRAM+((\buf)*IMGLENGTH)
	if (\part)<>0
		vadr: = vadr+IMGV1LEN
	endif

	DMA68K	(\src)+off,vadr,\#len,VRAM
	endm

; -------------------------------------------------------------------------
