@echo off
set REGION=1
set OUTPUT=SCD.iso
set ASM68K=_Bin\asm68k.exe /p /o ae- /o l. /e REGION=%REGION%
set AS=_Bin\asw.exe -q -xx -n -A -L -U -E -i .
set P2BIN=_Bin\p2bin.exe

if not exist _Built mkdir _Built
if not exist _Built\Files mkdir _Built\Files
if not exist _Built\Misc mkdir _Built\Misc
if %REGION%==0 (copy _Original\Japan\*.* _Built\Files > nul)
if %REGION%==1 (copy _Original\USA\*.* _Built\Files > nul)
if %REGION%==2 (copy _Original\Europe\*.* _Built\Files > nul)
del _Built\Files\.gitkeep > nul

%AS% "Sound Drivers\FM\_Driver.asm"
if exist "Sound Drivers\FM\_Driver.p" (
    %P2BIN% "Sound Drivers\FM\_Driver.p" "_Built\Misc\FM Sound Driver.bin"
    del "Sound Drivers\FM\_Driver.p" > nul
) else (
    echo **************************************************************************************
    echo *                                                                                    *
    echo * FM sound driver failed to build. See "Sound Drivers\FM\_Driver.log" for more info. *
    echo *                                                                                    *
    echo **************************************************************************************
)

%ASM68K% "CD Initial Program\IP.asm", "_Built\Misc\IP.BIN", , "CD Initial Program\IP.lst"
%ASM68K% "CD Initial Program\IPX.asm", "_Built\Files\IPX___.MMD",  , "CD Initial Program\IPX.lst"
%ASM68K% "CD System Program\SP.asm", "_Built\Misc\SP.BIN", , "CD System Program\SP.lst"
%ASM68K% "CD System Program\SPX.asm", "_Built\Files\SPX___.BIN", , "CD System Program\SPX.lst"
%ASM68K% "Backup RAM\Initialization\Main.asm", "_Built\Files\BRAMINIT.MMD", , "Backup RAM\Initialization\Main.lst"
%ASM68K% "Backup RAM\Sub.asm", "_Built\Files\BRAMSUB.BIN", , "Backup RAM\Sub.lst"
%ASM68K% "Mega Drive Init\Main.asm", "_Built\Files\MDINIT.MMD", , "Mega Drive Init\Main.lst"
%ASM68K% "Sound Drivers\PCM\Palmtree Panic.asm", "_Built\Files\SNCBNK1B.BIN", , "Sound Drivers\PCM\Palmtree Panic.lst"
%ASM68K% "Sound Drivers\PCM\Collision Chaos.asm", "_Built\Files\SNCBNK3B.BIN", , "Sound Drivers\PCM\Collision Chaos.lst"
%ASM68K% "Sound Drivers\PCM\Tidal Tempest.asm", "_Built\Files\SNCBNK4B.BIN", , "Sound Drivers\PCM\Tidal Tempest.lst"
%ASM68K% "Sound Drivers\PCM\Wacky Workbench.asm", "_Built\Files\SNCBNK6B.BIN", , "Sound Drivers\PCM\Wacky Workbench.lst"

%ASM68K% "Title Screen\Main.asm", "_Built\Files\TITLEM.MMD", , "Title Screen\Main.lst"
%ASM68K% "Title Screen\Sub.asm", "_Built\Files\TITLES.BIN", , "Title Screen\Sub.lst"
%ASM68K% /e DATAFILE=0 "FMV\Sub.asm", "_Built\Files\GOODEND.BIN", , "FMV\Sub (Good Ending).lst"
%ASM68K% /e DATAFILE=1 "FMV\Sub.asm", "_Built\Files\BADEND.BIN", , "FMV\Sub (Bad Ending).lst"
%ASM68K% "Sound Test\Main.asm", "_Built\Files\SOSEL_.MMD", , "Sound Test\Main.lst"

%ASM68K% /e EASTEREGG=0 "Sound Test\Easter Egg\Main.asm", "_Built\Files\NISI.MMD", , "Sound Test\Easter Egg\Main (Fun Is Infinite).lst"
%ASM68K% /e EASTEREGG=1 "Sound Test\Easter Egg\Main.asm", "_Built\Files\DUMMY0.MMD", , "Sound Test\Easter Egg\Main (M.C. Sonic).lst"
%ASM68K% /e EASTEREGG=2 "Sound Test\Easter Egg\Main.asm", "_Built\Files\DUMMY1.MMD", , "Sound Test\Easter Egg\Main (Tails).lst"
%ASM68K% /e EASTEREGG=3 "Sound Test\Easter Egg\Main.asm", "_Built\Files\DUMMY2.MMD", , "Sound Test\Easter Egg\Main (Batman).lst"
%ASM68K% /e EASTEREGG=4 "Sound Test\Easter Egg\Main.asm", "_Built\Files\DUMMY3.MMD", , "Sound Test\Easter Egg\Main (Cute Sonic).lst"

%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\R11A__.MMD", , "Level\Palmtree Panic\Act 1 Present.lst"
%ASM68K% /e DEMO=1 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\DEMO11A.MMD", , "Level\Palmtree Panic\Act 1 Present (Demo).lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Past.asm", "_Built\Files\R11B__.MMD", , "Level\Palmtree Panic\Act 1 Past.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Good Future.asm", "_Built\Files\R11C__.MMD", , "Level\Palmtree Panic\Act 1 Good Future.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Bad Future.asm", "_Built\Files\R11D__.MMD", , "Level\Palmtree Panic\Act 1 Bad Future.lst"

%ASM68K% /e DEMO=0 "Level\Wacky Workbench\Act 1 Present.asm", "_Built\Files\R61A__.MMD", , "Level\Wacky Workbench\Act 1 Present.lst"

echo.
echo Compiling filesystem...
_Bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o _Built\Misc\Files.BIN _Built\Files

%ASM68K% main.asm, _Built\%OUTPUT%
del _Built\Misc\Files.BIN > nul

pause