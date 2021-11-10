@echo off
if not exist _built mkdir _built
_bin\asm68k.exe /p /o ae- /o l. sp\sp.asm, _built\sp.bin, , sp\sp.lst
_bin\asm68k.exe /p /o ae- /o l. sp\spx.asm, _built\SPX___.BIN, , sp\spx.lst
_bin\asm68k.exe /p /o ae- /o l. buram\buramsub.asm, _built\BRAMSUB.BIN, , buram\buramsub.lst
pause