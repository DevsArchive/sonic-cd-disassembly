@echo off
set REGION=1
if %REGION%==0 (set REGPATH=Japan)
if %REGION%==1 (set REGPATH=USA)
if %REGION%==2 (set REGPATH=Europe)

fc /b _Original\%REGPATH%\IPX___.MMD _built\files\IPX___.MMD
fc /b _Original\%REGPATH%\SPX___.BIN _built\files\SPX___.BIN
fc /b _Original\%REGPATH%\BRAMINIT.MMD _built\files\BRAMINIT.MMD
fc /b _Original\%REGPATH%\BRAMSUB.BIN _built\files\BRAMSUB.BIN
fc /b _Original\%REGPATH%\MDINIT.MMD _built\files\MDINIT.MMD
fc /b _Original\%REGPATH%\SNCBNK1B.BIN _built\files\SNCBNK1B.BIN
fc /b _Original\%REGPATH%\TITLEM.MMD _built\files\TITLEM.MMD
fc /b _Original\%REGPATH%\TITLES.BIN _built\files\TITLES.BIN
fc /b _Original\%REGPATH%\SOSEL_.MMD _built\files\SOSEL_.MMD
fc /b _Original\%REGPATH%\NISI.MMD _built\files\NISI.MMD
fc /b _Original\%REGPATH%\DUMMY0.MMD _built\files\DUMMY0.MMD
fc /b _Original\%REGPATH%\DUMMY1.MMD _built\files\DUMMY1.MMD
fc /b _Original\%REGPATH%\DUMMY2.MMD _built\files\DUMMY2.MMD
fc /b _Original\%REGPATH%\DUMMY3.MMD _built\files\DUMMY3.MMD
fc /b _Original\%REGPATH%\R11A__.MMD _built\files\R11A__.MMD
fc /b _Original\%REGPATH%\DEMO11A.MMD _built\files\DEMO11A.MMD
fc /b _Original\%REGPATH%\R11B__.MMD _built\files\R11B__.MMD
fc /b _Original\%REGPATH%\R11C__.MMD _built\files\R11C__.MMD
fc /b _Original\%REGPATH%\R11D__.MMD _built\files\R11D__.MMD

pause