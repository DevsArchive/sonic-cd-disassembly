; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden track titles
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"

; -------------------------------------------------------------------------

	org	$12C00
DAGrdnTrkTitles:
	obj	WORDRAM2M+*
Art_TrkBoss:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Boss).nem"
	even
Art_TrkCCZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Collision Chaos).nem"
	even
Art_TrkCCZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Collision Chaos B Mix).nem"
	even
Art_TrkCCZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Collision Chaos G Mix).nem"
	even
Art_TrkFinal:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Final Fever).nem"
	even
Art_TrkGameOver:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Game Over).nem"
	even
Art_TrkInvincible:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Invincible).nem"
	even
Art_TrkLittlePlanet:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Little Planet).nem"
	even
Art_TrkMMZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Metallic Madness).nem"
	even
Art_TrkMMZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Metallic Madness B Mix).nem"
	even
Art_TrkMMZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Metallic Madness G Mix).nem"
	even
Art_TrkPPZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Palmtree Panic).nem"
	even
Art_TrkPPZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Palmtree Panic B Mix).nem"
	even
Art_TrkPPZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Palmtree Panic G Mix).nem"
	even
Art_TrkQQZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Quartz Quadrant).nem"
	even
Art_TrkQQZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Quartz Quadrant B Mix).nem"
	even
Art_TrkQQZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Quartz Quadrant G Mix).nem"
	even
Art_TrkSpecStg:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Special Stage).nem"
	even
Art_TrkSpeedUp:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Speed Up).nem"
	even
Art_TrkSSZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Stardust Speedway).nem"
	even
Art_TrkSSZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Stardust Speedway B Mix).nem"
	even
Art_TrkSSZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Stardust Speedway G Mix).nem"
	even
Art_TrkTitle:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Title).nem"
	even
	
	; Unknown amalgamation of track names
	incbin	"DA Garden/Objects/Track Title/Data/Art (Unknown).nem"
	even
	
Art_TrkTTZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Tidal Tempest).nem"
	even
Art_TrkTTZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Tidal Tempest B Mix).nem"
	even
Art_TrkTTZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Tidal Tempest G Mix).nem"
	even
Art_TrkWWZ:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Wacky Workbench).nem"
	even
Art_TrkWWZB:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Wacky Workbench B Mix).nem"
	even
Art_TrkWWZG:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Wacky Workbench G Mix).nem"
	even
Art_TrkZoneClear:
	incbin	"DA Garden/Objects/Track Title/Data/Art (Zone Clear).nem"
	even
	
	if REGION=USA
Art_TrkOpening:
		incbin	"DA Garden/Objects/Track Title/Data/Art (Opening, USA).nem"
		even
Art_TrkEnding:
		incbin	"DA Garden/Objects/Track Title/Data/Art (Ending, USA).nem"
		even
	else
Art_TrkOpening:
		incbin	"DA Garden/Objects/Track Title/Data/Art (Opening, Japan, Europe).nem"
		even
Art_TrkEnding:
		incbin	"DA Garden/Objects/Track Title/Data/Art (Ending, Japan, Europe).nem"
		even
	endif
	objend

; -------------------------------------------------------------------------
