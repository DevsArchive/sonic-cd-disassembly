@echo off
set REGION=1
set OUTPUT=SCD.iso
set ASM68K=_Bin\asm68k.exe /p /o ae-,l.,ow+ /e REGION=%REGION%
set AS=_Bin\asw.exe -q -xx -n -A -L -U -E -i .
set P2BIN=_Bin\p2bin.exe

if not exist _Built mkdir _Built
if not exist _Built\Files mkdir _Built\Files
if not exist _Built\Misc mkdir _Built\Misc
if %REGION%==0 (copy _Original\Japan\*.* _Built\Files > nul)
if %REGION%==1 (copy _Original\USA\*.* _Built\Files > nul)
if %REGION%==2 (copy _Original\Europe\*.* _Built\Files > nul)
del _Built\Files\.gitkeep > nul

if %REGION%==0 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")
if %REGION%==1 (set FMVWAV="FMV\Data\Opening (USA).wav")
if %REGION%==2 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")

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

%ASM68K% "DA Garden\Track Titles.asm", "_Built\Files\PLANET_D.BIN", "DA Garden\Track Titles.sym"
_Bin\GetPsyQSyms.exe "DA Garden\Track Titles.sym" "DA Garden\Track Title Labels.i"
if exist "DA Garden\Track Titles.sym" ( del "DA Garden\Track Titles.sym" > nul )
%ASM68K% "DA Garden\Main.asm", "_Built\Files\PLANET_M.MMD", , "DA Garden\Main.lst"
%ASM68K% "DA Garden\Sub.asm", "_Built\Files\PLANET_S.BIN", , "DA Garden\Sub.lst"

%ASM68K% "CD Initial Program\IP.asm", "_Built\Misc\IP.BIN", , "CD Initial Program\IP.lst"
%ASM68K% "CD Initial Program\IPX.asm", "_Built\Files\IPX___.MMD",  , "CD Initial Program\IPX.lst"
%ASM68K% "CD System Program\SP.asm", "_Built\Misc\SP.BIN", , "CD System Program\SP.lst"
%ASM68K% "CD System Program\SPX.asm", "_Built\Files\SPX___.BIN", , "CD System Program\SPX.lst"
%ASM68K% "Backup RAM\Initialization\Main.asm", "_Built\Files\BRAMINIT.MMD", , "Backup RAM\Initialization\Main.lst"
%ASM68K% "Backup RAM\Sub.asm", "_Built\Files\BRAMSUB.BIN", , "Backup RAM\Sub.lst"
%ASM68K% "Mega Drive Init\Main.asm", "_Built\Files\MDINIT.MMD", , "Mega Drive Init\Main.lst"
%ASM68K% "Time Warp Cutscene\Main.asm", "_Built\Files\WARP__.MMD", , "Time Warp Cutscene\Main.lst"
%ASM68K% "Sound Drivers\PCM\Palmtree Panic.asm", "_Built\Files\SNCBNK1B.BIN", , "Sound Drivers\PCM\Palmtree Panic.lst"
%ASM68K% "Sound Drivers\PCM\Collision Chaos.asm", "_Built\Files\SNCBNK3B.BIN", , "Sound Drivers\PCM\Collision Chaos.lst"
%ASM68K% "Sound Drivers\PCM\Tidal Tempest.asm", "_Built\Files\SNCBNK4B.BIN", , "Sound Drivers\PCM\Tidal Tempest.lst"
%ASM68K% "Sound Drivers\PCM\Quartz Quadrant.asm", "_Built\Files\SNCBNK5B.BIN", , "Sound Drivers\PCM\Quartz Quadrant.lst"
%ASM68K% "Sound Drivers\PCM\Wacky Workbench.asm", "_Built\Files\SNCBNK6B.BIN", , "Sound Drivers\PCM\Wacky Workbench.lst"
%ASM68K% "Sound Drivers\PCM\Stardust Speedway.asm", "_Built\Files\SNCBNK7B.BIN", , "Sound Drivers\PCM\Stardust Speedway.lst"
%ASM68K% "Sound Drivers\PCM\Metallic Madness.asm", "_Built\Files\SNCBNK8B.BIN", , "Sound Drivers\PCM\Metallic Madness.lst"
%ASM68K% "Sound Drivers\PCM\Boss.asm", "_Built\Files\SNCBNKB1.BIN", , "Sound Drivers\PCM\Boss.lst"
%ASM68K% "Sound Drivers\PCM\Final Boss.asm", "_Built\Files\SNCBNKB2.BIN", , "Sound Drivers\PCM\Final Boss.lst"

%ASM68K% "Title Screen\Main.asm", "_Built\Files\TITLEM.MMD", , "Title Screen\Main.lst"
%ASM68K% "Title Screen\Sub.asm", "_Built\Files\TITLES.BIN", , "Title Screen\Sub.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Sound Test.asm", "_Built\Files\SOSEL_.MMD", , "Title Screen\Secrets\Sound Test.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Stage Select.asm", "_Built\Files\STSEL_.MMD", , "Title Screen\Secrets\Stage Select.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=1 "Title Screen\Secrets\Best Staff Times.asm", "_Built\Files\DUMMY4.MMD", , "Title Screen\Secrets\Best Staff Times.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Special Stage 8 Credits.asm", "_Built\Files\SPEEND.MMD", , "Title Screen\Secrets\Special Stage 8 Credits.lst"

if exist "_Built\Files\DUMMY5.MMD" (del "_Built\Files\DUMMY5.MMD" > nul)
%ASM68K% /e PROTOTYPE=1 /e H32=0 "Title Screen\Secrets\Sound Test (Prototype).asm", "_Built\Files\DUMMY5.MMD", , "Title Screen\Secrets\Sound Test (Prototype).lst"
if exist "_Built\Files\DUMMY5.MMD" (
    copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY6.MMD" > nul
    copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY7.MMD" > nul
    copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY8.MMD" > nul
    copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY9.MMD" > nul
)

%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=0 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\NISI.MMD", , "Title Screen\Secrets\Sound Test Image (Fun Is Infinite).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=1 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY0.MMD", , "Title Screen\Secrets\Sound Test Image (M.C. Sonic).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=2 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY1.MMD", , "Title Screen\Secrets\Sound Test Image (Tails).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=3 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY2.MMD", , "Title Screen\Secrets\Sound Test Image (Batman).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=4 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY3.MMD", , "Title Screen\Secrets\Sound Test Image (Cute Sonic).lst"

%ASM68K% "FMV\Main (Opening).asm", "_Built\Files\OPEN_M.MMD", , "FMV\Main (Opening).lst"
%ASM68K% "FMV\Sub (Opening).asm", "_Built\Files\OPEN_S.BIN", , "FMV\Sub (Opening).lst"
%ASM68K% /e DATAFILE=0 "FMV\Sub (Ending).asm", "_Built\Files\GOODEND.BIN", , "FMV\Sub (Good Ending).lst"
%ASM68K% /e DATAFILE=1 "FMV\Sub (Ending).asm", "_Built\Files\BADEND.BIN", , "FMV\Sub (Bad Ending).lst"
%ASM68K% "FMV\Sub (Pencil Test).asm", "_Built\Files\PTEST.BIN", , "FMV\Sub (Pencil Test).lst"
echo.
echo Making opening FMV STM...
_Bin\MakeSTM.exe "FMV\Data\Opening.gif" %FMVWAV% 0 0 "_Built\Files\OPN.STM"

%ASM68K% "Visual Mode\Main.asm", "_Built\Files\VM____.MMD", , "Visual Mode\Main.lst"

%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\R11A__.MMD", , "Level\Palmtree Panic\Act 1 Present.lst"
%ASM68K% /e DEMO=1 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\DEMO11A.MMD", , "Level\Palmtree Panic\Act 1 Present (Demo).lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Past.asm", "_Built\Files\R11B__.MMD", , "Level\Palmtree Panic\Act 1 Past.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Good Future.asm", "_Built\Files\R11C__.MMD", , "Level\Palmtree Panic\Act 1 Good Future.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Bad Future.asm", "_Built\Files\R11D__.MMD", , "Level\Palmtree Panic\Act 1 Bad Future.lst"

%ASM68K% /e DEMO=0 "Level\Wacky Workbench\Act 1 Present.asm", "_Built\Files\R61A__.MMD", , "Level\Wacky Workbench\Act 1 Present.lst"

%ASM68K% "Special Stage\Stage Data.asm", "Special Stage\Stage Data.bin", "Special Stage\Stage Data.sym"
_Bin\GetPsyQSyms.exe "Special Stage\Stage Data.sym" "Special Stage\Stage Data Labels.i"
if exist "Special Stage\Stage Data.sym" ( del "Special Stage\Stage Data.sym" > nul )
%ASM68K% "Special Stage\Main.asm", "_Built\Files\SPMM__.MMD", , "Special Stage\Main.lst"
%ASM68K% "Special Stage\Sub.asm", "_Built\Files\SPSS__.BIN", , "Special Stage\Sub.lst"

echo.
echo Compiling filesystem...
_Bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o _Built\Misc\Files.BIN _Built\Files

%ASM68K% main.asm, _Built\%OUTPUT%
del _Built\Misc\Files.BIN > nul

pause