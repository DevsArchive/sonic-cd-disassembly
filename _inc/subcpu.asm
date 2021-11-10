; -------------------------------------------------------------------------------
; Sonic CD Misc. Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------------
; Sub CPU definitions
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Memory map
; -------------------------------------------------------------------------

PRG_RAM		EQU	$00000			; PRG-RAM
WORDRAM_2M	EQU	$80000			; Word RAM in 2M mode	
WORDRAM_1M	EQU	$C0000			; Word RAM in 1M mode

SP_START	EQU	PRG_RAM+$6000		; Start of SP program

WORDRAM_2M_LEN	EQU	$40000			; Size of Word RAM in 2M mode
WORDRAM_1M_LEN	EQU	$20000			; Size of Word RAM in 1M mode

; -------------------------------------------------------------------------
; Gate array
; -------------------------------------------------------------------------

GA_BASE		EQU	$FFFF8000		; Gate array base
PCM_BASE	EQU	$FFFF0000		; PCM chip base

; -------------------------------------------------------------------------

gaReset		EQU	$0000			; Peripheral reset
gaMemMode	EQU	$0002			; Memory mode/Write protection
gaCDCMode	EQU	$0004			; CDC mode/Device destination
gaCRS1		EQU	$0006			; CDC control register
gaCDCHost	EQU	$0008			; 16 bit CDC data to host
gaDMAAddr	EQU	$000A			; DMA offset into destination area
gaStopwatch	EQU	$000C			; CDC/gp timer 30.72us LSB
gaComFlags	EQU	$000E			; Communication flags
gaMainFlag	EQU	$000E			; Main CPU communication flag
gaSubFlag	EQU	$000F			; Sub CPU communication flag
gaCmds		EQU	$0010			; Communication commands
gaCmd0		EQU	$0010			; Communication command 0
gaCmd1		EQU	$0011			; Communication command 1
gaCmd2		EQU	$0012			; Communication command 2
gaCmd3		EQU	$0013			; Communication command 3
gaCmd4		EQU	$0014			; Communication command 4
gaCmd5		EQU	$0015			; Communication command 5
gaCmd6		EQU	$0016			; Communication command 6
gaCmd7		EQU	$0017			; Communication command 7
gaCmd8		EQU	$0018			; Communication command 8
gaCmd9		EQU	$0019			; Communication command 9
gaCmdA		EQU	$001A			; Communication command A
gaCmdB		EQU	$001B			; Communication command B
gaCmdC		EQU	$001C			; Communication command C
gaCmdD		EQU	$001D			; Communication command D
gaCmdE		EQU	$001E			; Communication command E
gaCmdF		EQU	$001F			; Communication command F
gaStats		EQU	$0020			; Communication statuses
gaStat0		EQU	$0020			; Communication status 0
gaStat1		EQU	$0021			; Communication status 1
gaStat2		EQU	$0022			; Communication status 2
gaStat3		EQU	$0023			; Communication status 3
gaStat4		EQU	$0024			; Communication status 4
gaStat5		EQU	$0025			; Communication status 5
gaStat6		EQU	$0026			; Communication status 6
gaStat7		EQU	$0027			; Communication status 7
gaStat8		EQU	$0028			; Communication status 8
gaStat9		EQU	$0029			; Communication status 9
gaStatA		EQU	$002A			; Communication status A
gaStatB		EQU	$002B			; Communication status B
gaStatC		EQU	$002C			; Communication status C
gaStatD		EQU	$002D			; Communication status D
gaStatE		EQU	$002E			; Communication status E
gaStatF		EQU	$002F			; Communication status F
gaInt3Timer	EQU	$0030			; Interrupt 3 timer
gaIntMask	EQU	$0032			; Interrupt mask
gaCDFader	EQU	$0034			; Fader control/Spindle speed
gaCDDCtrl	EQU	$0036			; CDD control
gaCDDComm	EQU	$0038			; CDD communication
gaFontCol	EQU	$004C			; Source color values
gaFontBits	EQU	$004E			; Font data
gaFontData	EQU	$0056			; Read only
gaStampSz	EQU	$0058			; Stamp size/Map size
gaStampMap	EQU	$005A			; Stamp map base address
gaImgVCell	EQU	$005C			; Image buffer V size in cells
gaImgStart	EQU	$005E			; Image buffer start address
gaImgOff	EQU	$0060			; Image buffer offset
gaImgHDot	EQU	$0062			; Image buffer H size in dots
gaImgVDot	EQU	$0064			; Image buffer V size in dots
gaTrace		EQU	$0066			; Trace vector base address
gaSubAddr	EQU	$0068			; Subcode top address
gaSubcode	EQU	$0100			; 64 word subcode buffer
gaSubImg	EQU	$0180			; Image of subcode buffer

GA_RESET	EQU	GA_BASE+gaReset		; Peripheral reset
GA_MEM_MODE	EQU	GA_BASE+gaMemMode	; Memory mode/Write protection
GA_CDC_MODE	EQU	GA_BASE+gaCDCMode	; CDC mode/Device destination
GA_CRS1		EQU	GA_BASE+gaCRS1		;  CDC control register
GA_CDC_HOST	EQU	GA_BASE+gaCDCHost	; 16 bit CDC data to host
GA_DMA_ADDR	EQU	GA_BASE+gaDMAAddr	; DMA offset into destination area
GA_STOPWATCH	EQU	GA_BASE+gaStopwatch	; CDC/gp timer 30.72us LSB
GA_COM_FLAGS	EQU	GA_BASE+gaFlags		; Communication flags
GA_MAIN_FLAG	EQU	GA_BASE+gaMainFlag	; Main CPU communication flag
GA_SUB_FLAG	EQU	GA_BASE+gaSubFlag	; Sub CPU communication flag
GA_CMDS		EQU	GA_BASE+gaCmds		; Communication commands
GA_CMD_0	EQU	GA_BASE+gaCmd0		; Communication command 0
GA_CMD_1	EQU	GA_BASE+gaCmd1		; Communication command 1
GA_CMD_2	EQU	GA_BASE+gaCmd2		; Communication command 2
GA_CMD_3	EQU	GA_BASE+gaCmd3		; Communication command 3
GA_CMD_4	EQU	GA_BASE+gaCmd4		; Communication command 4
GA_CMD_5	EQU	GA_BASE+gaCmd5		; Communication command 5
GA_CMD_6	EQU	GA_BASE+gaCmd6		; Communication command 6
GA_CMD_7	EQU	GA_BASE+gaCmd7		; Communication command 7
GA_CMD_8	EQU	GA_BASE+gaCmd8		; Communication command 8
GA_CMD_9	EQU	GA_BASE+gaCmd9		; Communication command 9
GA_CMD_A	EQU	GA_BASE+gaCmdA		; Communication command A
GA_CMD_B	EQU	GA_BASE+gaCmdB		; Communication command B
GA_CMD_C	EQU	GA_BASE+gaCmdC		; Communication command C
GA_CMD_D	EQU	GA_BASE+gaCmdD		; Communication command D
GA_CMD_E	EQU	GA_BASE+gaCmdE		; Communication command E
GA_CMD_F	EQU	GA_BASE+gaCmdF		; Communication command F
GA_STATS	EQU	GA_BASE+gaStats		; Communication statuses
GA_STAT_0	EQU	GA_BASE+gaStat0		; Communication status 0
GA_STAT_1	EQU	GA_BASE+gaStat1		; Communication status 1
GA_STAT_2	EQU	GA_BASE+gaStat2		; Communication status 2
GA_STAT_3	EQU	GA_BASE+gaStat3		; Communication status 3
GA_STAT_4	EQU	GA_BASE+gaStat4		; Communication status 4
GA_STAT_5	EQU	GA_BASE+gaStat5		; Communication status 5
GA_STAT_6	EQU	GA_BASE+gaStat6		; Communication status 6
GA_STAT_7	EQU	GA_BASE+gaStat7		; Communication status 7
GA_STAT_8	EQU	GA_BASE+gaStat8		; Communication status 8
GA_STAT_9	EQU	GA_BASE+gaStat9		; Communication status 9
GA_STAT_A	EQU	GA_BASE+gaStatA		; Communication status A
GA_STAT_B	EQU	GA_BASE+gaStatB		; Communication status B
GA_STAT_C	EQU	GA_BASE+gaStatC		; Communication status C
GA_STAT_D	EQU	GA_BASE+gaStatD		; Communication status D
GA_STAT_E	EQU	GA_BASE+gaStatE		; Communication status E
GA_STAT_F	EQU	GA_BASE+gaStatF		; Communication status F
GA_INT3_TIMER	EQU	GA_BASE+gaInt3Timer	; Interrupt 3 timer
GA_INT_MASK	EQU	GA_BASE+gaIntMask	; Interrupt mask
GA_CD_FADER	EQU	GA_BASE+gaCDFader	; Fader control/Spindle speed
GA_CDD_CTRL	EQU	GA_BASE+gaCDDCtrl	; CDD control
GA_CDD_COMM	EQU	GA_BASE+gaCDDComm	; CDD communication
GA_FONT_COLOR	EQU	GA_BASE+gaFontCol	; Source color values
GA_FONT_BITS	EQU	GA_BASE+gaFontBits	; Font data
GA_FONT_DATA	EQU	GA_BASE+gaFontData	; Read only
GA_STAMP_SIZE	EQU	GA_BASE+gaStampSz	; Stamp size/Map size
GA_STAMP_MAP	EQU	GA_BASE+gaStampMap	; Stamp map base address
GA_IMG_VCELL	EQU	GA_BASE+gaImgVCell	; Image buffer V size in cells
GA_IMG_START	EQU	GA_BASE+gaImgStart	; Image buffer start address
GA_IMG_OFFSET	EQU	GA_BASE+gaImgOff	; Image buffer offset
GA_IMG_HDOT	EQU	GA_BASE+gaImgHDot	; Image buffer H size in dots
GA_IMG_VDOT	EQU	GA_BASE+gaImgVDot	; Image buffer V size in dots
GA_IMG_TRACE	EQU	GA_BASE+gaTrace		; Trace vector base address
GA_SUBCODE_ADDR	EQU	GA_BASE+gaSubAddr	; Subcode top address
GA_SUBCODE	EQU	GA_BASE+gaSubcode	; 64 word subcode buffer
GA_SUBCODE_IMG	EQU	GA_BASE+gaSubImg	; Image of subcode buffer

; -------------------------------------------------------------------------
; PCM chip registers
; -------------------------------------------------------------------------

pcmEnv		EQU	$0000*2+1		; Volume
pcmPan		EQU	$0001*2+1		; Pan
pcmFDL		EQU	$0002*2+1		; Frequency (low)
pcmFDH		EQU	$0003*2+1		; Frequency (high)
pcmLSL		EQU	$0004*2+1		; Wave memory stop address (high)
pcmLSH		EQU	$0005*2+1		; Wave memory stop address (low)
pcmST		EQU	$0006*2+1		; Start of wave memory
pcmCtrl		EQU	$0007*2+1		; Control
pcmOnOff	EQU	$0008*2+1		; On/Off
pcmWaveAddr	EQU	$0010*2+1		; Wave address
pcmWaveData	EQU	$1000*2+1		; Wave data

; -------------------------------------------------------------------------

PCM_ENV		EQU	PCM_BASE+pcmEnv		; Volume
PCM_PAN		EQU	PCM_BASE+pcmPan		; Pan
PCM_FDL		EQU	PCM_BASE+pcmFDL		; Frequency (low)
PCM_FDH		EQU	PCM_BASE+pcmFDH		; Frequency (high)
PCM_LSL		EQU	PCM_BASE+pcmLSL		; Wave memory stop address (high)
PCM_LSH		EQU	PCM_BASE+pcmLSH		; Wave memory stop address (low)
PCM_ST		EQU	PCM_BASE+pcmST		; Start of wave memory
PCM_CTRL	EQU	PCM_BASE+pcmCtrl	; Control
PCM_ON_OFF	EQU	PCM_BASE+pcmOnOff	; On/Off
PCM_WAVE_ADDR	EQU	PCM_BASE+pcmWaveAddr	; Wave address
PCM_WAVE_DATA	EQU	PCM_BASE+pcmWaveData	; Wave data

; -------------------------------------------------------------------------
; BIOS function codes
; -------------------------------------------------------------------------

MSCSTOP		EQU	$0002
MSCPAUSEON	EQU	$0003
MSCPAUSEOFF	EQU	$0004
MSCSCANFF	EQU	$0005
MSCSCANFR	EQU	$0006
MSCSCANOFF	EQU	$0007

ROMPAUSEON	EQU	$0008
ROMPAUSEOFF	EQU	$0009

DRVOPEN		EQU	$000A
DRVINIT		EQU	$0010

MSCPLAY		EQU	$0011
MSCPLAY1	EQU	$0012
MSCPLAYR	EQU	$0013
MSCPLAYT	EQU	$0014
MSCSEEK		EQU	$0015
MSCSEEKT	EQU	$0016

ROMREAD		EQU	$0017
ROMSEEK		EQU	$0018

MSCSEEK1	EQU	$0019
TESTENTRY	EQU	$001E
TESTENTRYLOOP	EQU	$001F

ROMREADN	EQU	$0020
ROMREADE	EQU	$0021

CDBCHK		EQU	$0080
CDBSTAT		EQU	$0081
CDBTOCWRITE	EQU	$0082
CDBTOCREAD	EQU	$0083
CDBPAUSE	EQU	$0084

FDRSET		EQU	$0085
FDRCHG		EQU	$0086

CDCSTART	EQU	$0087
CDCSTARTP	EQU	$0088
CDCSTOP		EQU	$0089
CDCSTAT		EQU	$008A
CDCREAD		EQU	$008B
CDCTRN		EQU	$008C
CDCACK		EQU	$008D

SCDINIT		EQU	$008E
SCDSTART	EQU	$008F
SCDSTOP		EQU	$0090
SCDSTAT		EQU	$0091
SCDREAD		EQU	$0092
SCDPQ		EQU	$0093
SCDPQL		EQU	$0094

LEDSET		EQU	$0095

CDCSETMODE	EQU	$0096

WONDERREQ	EQU	$0097
WONDERCHK	EQU	$0098

CBTINIT		EQU	$0000
CBTINT		EQU	$0001
CBTOPENDISC	EQU	$0002
CBTOPENSTAT	EQU	$0003
CBTCHKDISC	EQU	$0004
CBTCHKSTAT	EQU	$0005
CBTIPDISC	EQU	$0006
CBTIPSTAT	EQU	$0007
CBTSPDISC	EQU	$0008
CBTSPSTAT	EQU	$0009

BRMINIT		EQU	$0000
BRMSTAT		EQU	$0001
BRMSERCH	EQU	$0002
BRMREAD		EQU	$0003
BRMWRITE	EQU	$0004
BRMDEL		EQU	$0005
BRMFORMAT	EQU	$0006
BRMDIR		EQU	$0007
BRMVERIFY	EQU	$0008

; -------------------------------------------------------------------------
; BIOS entry points
; -------------------------------------------------------------------------

_ADRERR		EQU	$00005F40
_BOOTSTAT	EQU	$00005EA0
_BURAM		EQU	$00005F16
_CDBIOS		EQU	$00005F22
_CDBOOT		EQU	$00005F1C
_CDSTAT		EQU	$00005E80
_CHKERR		EQU	$00005F52
_CODERR		EQU	$00005F46
_DEVERR		EQU	$00005F4C
_LEVEL1		EQU	$00005F76
_LEVEL2		EQU	$00005F7C
_LEVEL3		EQU	$00005F82
_LEVEL4		EQU	$00005F88
_LEVEL5		EQU	$00005F8E
_LEVEL6		EQU	$00005F94
_LEVEL7		EQU	$00005F9A
_NOCOD0		EQU	$00005F6A
_NOCOD1		EQU	$00005F70
_SETJMPTBL	EQU	$00005F0A
_SPVERR		EQU	$00005F5E
_TRACE		EQU	$00005F64
_TRAP00		EQU	$00005FA0
_TRAP01		EQU	$00005FA6
_TRAP02		EQU	$00005FAC
_TRAP03		EQU	$00005FB2
_TRAP04		EQU	$00005FB8
_TRAP05		EQU	$00005FBE
_TRAP06		EQU	$00005FC4
_TRAP07		EQU	$00005FCA
_TRAP08		EQU	$00005FD0
_TRAP09		EQU	$00005FD6
_TRAP10		EQU	$00005FDC
_TRAP11		EQU	$00005FE2
_TRAP12		EQU	$00005FE8
_TRAP13		EQU	$00005FEE
_TRAP14		EQU	$00005FF4
_TRAP15		EQU	$00005FFA
_TRPERR		EQU	$00005F58
_USERCALL0	EQU	$00005F28
_USERCALL1	EQU	$00005F2E
_USERCALL2	EQU	$00005F34
_USERCALL3	EQU	$00005F3A
_USERMODE	EQU	$00005EA6
_WAITVSYNC	EQU	$00005F10

; -------------------------------------------------------------------------
