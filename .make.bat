@echo off
set REGION=1
set OUTPUT=SCD.iso

if not exist _built mkdir _built
if not exist _built\files mkdir _built\files
if not exist _built\sys mkdir _built\sys
copy _original\*.* _built\files > nul
del _built\files\.gitkeep

_bin\asm68k.exe /p /o ae- /o l. /e REGION=%REGION% cdip\ip.asm, _built\sys\IP.BIN , cdip\ip.lst
_bin\asm68k.exe /p /o ae- /o l. cdip\ipx.asm, _built\files\IPX___.MMD, , cdip\ipx.lst
_bin\asm68k.exe /p /o ae- /o l. cdsp\sp.asm, _built\sys\SP.BIN , cdsp\sp.lst
_bin\asm68k.exe /p /o ae- /o l. cdsp\spx.asm, _built\files\SPX___.BIN, , cdsp\spx.lst
_bin\asm68k.exe /p /o ae- /o l. buram\init\buraminit.asm, _built\files\BRAMINIT.MMD, , buram\init\buraminit.lst
_bin\asm68k.exe /p /o ae- /o l. buram\buramsub.asm, _built\files\BRAMSUB.BIN, , buram\buramsub.lst
_bin\asm68k.exe /p /o ae- /o l. mdinit\mdinit.asm, _built\files\MDINIT.MMD, , mdinit\mdinit.lst
_bin\asm68k.exe /p /o ae- /o l. sound\pcm\ppz.asm, _built\files\SNCBNK1B.BIN, , sound\pcm\ppz.lst
_bin\asm68k.exe /p /o ae- /o l. title\titlemain.asm, _built\files\TITLEM.MMD, , title\titlemain.lst
_bin\asm68k.exe /p /o ae- /o l. title\titlesub.asm, _built\files\TITLES.BIN, , title\titlesub.lst

echo Compiling filesystem...
_bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o _built\sys\FILES.BIN _built\files

_bin\asm68k.exe /p /o ae- /o l. /e REGION=%REGION% main.asm, _built\%OUTPUT%
del _built\sys\FILES.BIN > nul

pause