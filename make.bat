@echo off
if not exist _built mkdir _built

_bin\asm68k.exe /p /o ae- /o l. ip\ipx.asm, _built\IPX___.MMD, , ip\ipx.lst
fc /b _built\IPX___.MMD _original\IPX___.MMD

_bin\asm68k.exe /p /o ae- /o l. sp\sp.asm, _built\SP.BIN , sp\sp.lst
fc /b _built\SP.BIN _original\SP.BIN

_bin\asm68k.exe /p /o ae- /o l. sp\spx.asm, _built\SPX___.BIN, , sp\spx.lst
fc /b _built\SPX___.BIN _original\SPX___.BIN

_bin\asm68k.exe /p /o ae- /o l. buram\init\buraminit.asm, _built\BRAMINIT.MMD, , buram\init\buraminit.lst
fc /b _built\BRAMINIT.MMD _original\BRAMINIT.MMD

_bin\asm68k.exe /p /o ae- /o l. buram\buramsub.asm, _built\BRAMSUB.BIN, , buram\buramsub.lst
fc /b _built\BRAMSUB.BIN _original\BRAMSUB.BIN
pause