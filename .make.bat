@echo off
set REGION=1
set OUTPUT=SCD.iso
set ASM68K=_bin\asm68k.exe /p /o ae- /o l. /e REGION=%REGION%

if not exist _built mkdir _built
if not exist _built\files mkdir _built\files
if not exist _built\sys mkdir _built\sys
if %REGION%==0 (copy _original\jpn\*.* _built\files > nul)
if %REGION%==1 (copy _original\usa\*.* _built\files > nul)
if %REGION%==2 (copy _original\eur\*.* _built\files > nul)
del _built\files\.gitkeep > nul

%ASM68K% cdip\ip.asm, _built\sys\IP.BIN , cdip\ip.lst
%ASM68K% cdip\ipx.asm, _built\files\IPX___.MMD, , cdip\ipx.lst
%ASM68K% cdsp\sp.asm, _built\sys\SP.BIN , cdsp\sp.lst
%ASM68K% cdsp\spx.asm, _built\files\SPX___.BIN, , cdsp\spx.lst
%ASM68K% buram\init\buraminit.asm, _built\files\BRAMINIT.MMD, , buram\init\buraminit.lst
%ASM68K% buram\buramsub.asm, _built\files\BRAMSUB.BIN, , buram\buramsub.lst
%ASM68K% mdinit\mdinit.asm, _built\files\MDINIT.MMD, , mdinit\mdinit.lst
%ASM68K% sound\pcm\ppz.asm, _built\files\SNCBNK1B.BIN, , sound\pcm\ppz.lst
%ASM68K% title\titlemain.asm, _built\files\TITLEM.MMD, , title\titlemain.lst
%ASM68K% title\titlesub.asm, _built\files\TITLES.BIN, , title\titlesub.lst

echo.
echo Compiling filesystem...
_bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o _built\sys\FILES.BIN _built\files

_bin\asm68k.exe /p /o ae- /o l. /e REGION=%REGION% main.asm, _built\%OUTPUT%
del _built\sys\FILES.BIN > nul

pause