@echo off
set REGION=1

if %REGION%==0 (set REGPATH=Japan)
if %REGION%==1 (set REGPATH=USA)
if %REGION%==2 (set REGPATH=Europe)

if %REGION%==0 fc /b _Original\IP_JPN.BIN _Built\Misc\IP.BIN
if %REGION%==1 fc /b _Original\IP_USA.BIN _Built\Misc\IP.BIN
if %REGION%==2 fc /b _Original\IP_EUR.BIN _Built\Misc\IP.BIN
fc /b _Original\SP.BIN _Built\Misc\SP.BIN
fc /b _Original\%REGPATH%\IPX___.MMD _Built\Files\IPX___.MMD
fc /b _Original\%REGPATH%\SPX___.BIN _Built\Files\SPX___.BIN
fc /b _Original\%REGPATH%\BRAMINIT.MMD _Built\Files\BRAMINIT.MMD
fc /b _Original\%REGPATH%\BRAMSUB.BIN _Built\Files\BRAMSUB.BIN
fc /b _Original\%REGPATH%\MDINIT.MMD _Built\Files\MDINIT.MMD
fc /b _Original\%REGPATH%\WARP__.MMD _Built\Files\WARP__.MMD
fc /b _Original\%REGPATH%\SNCBNK1B.BIN _Built\Files\SNCBNK1B.BIN
fc /b _Original\%REGPATH%\SNCBNK3B.BIN _Built\Files\SNCBNK3B.BIN
fc /b _Original\%REGPATH%\SNCBNK4B.BIN _Built\Files\SNCBNK4B.BIN
fc /b _Original\%REGPATH%\SNCBNK5B.BIN _Built\Files\SNCBNK5B.BIN
fc /b _Original\%REGPATH%\SNCBNK6B.BIN _Built\Files\SNCBNK6B.BIN
fc /b _Original\%REGPATH%\SNCBNK7B.BIN _Built\Files\SNCBNK7B.BIN
fc /b _Original\%REGPATH%\SNCBNK8B.BIN _Built\Files\SNCBNK8B.BIN
fc /b _Original\%REGPATH%\SNCBNKB1.BIN _Built\Files\SNCBNKB1.BIN
fc /b _Original\%REGPATH%\SNCBNKB2.BIN _Built\Files\SNCBNKB2.BIN
fc /b _Original\%REGPATH%\TITLEM.MMD _Built\Files\TITLEM.MMD
fc /b _Original\%REGPATH%\TITLES.BIN _Built\Files\TITLES.BIN
fc /b _Original\%REGPATH%\STSEL_.MMD _Built\Files\STSEL_.MMD
fc /b _Original\%REGPATH%\SOSEL_.MMD _Built\Files\SOSEL_.MMD
fc /b _Original\%REGPATH%\NISI.MMD _Built\Files\NISI.MMD
fc /b _Original\%REGPATH%\DUMMY0.MMD _Built\Files\DUMMY0.MMD
fc /b _Original\%REGPATH%\DUMMY1.MMD _Built\Files\DUMMY1.MMD
fc /b _Original\%REGPATH%\DUMMY2.MMD _Built\Files\DUMMY2.MMD
fc /b _Original\%REGPATH%\DUMMY3.MMD _Built\Files\DUMMY3.MMD
fc /b _Original\%REGPATH%\DUMMY4.MMD _Built\Files\DUMMY4.MMD
fc /b _Original\%REGPATH%\DUMMY5.MMD _Built\Files\DUMMY5.MMD
fc /b _Original\%REGPATH%\DUMMY6.MMD _Built\Files\DUMMY6.MMD
fc /b _Original\%REGPATH%\DUMMY7.MMD _Built\Files\DUMMY7.MMD
fc /b _Original\%REGPATH%\DUMMY8.MMD _Built\Files\DUMMY8.MMD
fc /b _Original\%REGPATH%\DUMMY9.MMD _Built\Files\DUMMY9.MMD
fc /b _Original\%REGPATH%\SPEEND.MMD _Built\Files\SPEEND.MMD
fc /b _Original\%REGPATH%\OPEN_M.MMD _Built\Files\OPEN_M.MMD
fc /b _Original\%REGPATH%\OPEN_S.BIN _Built\Files\OPEN_S.BIN
fc /b _Original\%REGPATH%\OPN.STM _Built\Files\OPN.STM
fc /b _Original\%REGPATH%\GOODEND.BIN _Built\Files\GOODEND.BIN
fc /b _Original\%REGPATH%\BADEND.BIN _Built\Files\BADEND.BIN
fc /b _Original\%REGPATH%\PTEST.BIN _Built\Files\PTEST.BIN
fc /b _Original\%REGPATH%\PLANET_M.MMD _Built\Files\PLANET_M.MMD
fc /b _Original\%REGPATH%\PLANET_S.BIN _Built\Files\PLANET_S.BIN
fc /b _Original\%REGPATH%\PLANET_D.BIN _Built\Files\PLANET_D.BIN
fc /b _Original\%REGPATH%\VM____.MMD _Built\Files\VM____.MMD
fc /b _Original\%REGPATH%\R11A__.MMD _Built\Files\R11A__.MMD
fc /b _Original\%REGPATH%\DEMO11A.MMD _Built\Files\DEMO11A.MMD
fc /b _Original\%REGPATH%\R11B__.MMD _Built\Files\R11B__.MMD
fc /b _Original\%REGPATH%\R11C__.MMD _Built\Files\R11C__.MMD
fc /b _Original\%REGPATH%\R11D__.MMD _Built\Files\R11D__.MMD
fc /b _Original\%REGPATH%\R61A__.MMD _Built\Files\R61A__.MMD
fc /b _Original\%REGPATH%\SPMM__.MMD _Built\Files\SPMM__.MMD
fc /b _Original\%REGPATH%\SPSS__.BIN _Built\Files\SPSS__.BIN

pause