@echo off
set REGION=1
if %REGION%==0 (set REGPATH=jpn)
if %REGION%==1 (set REGPATH=usa)
if %REGION%==2 (set REGPATH=eur)

fc /b _original\%REGPATH%\IPX___.MMD _built\files\IPX___.MMD
fc /b _original\%REGPATH%\SPX___.BIN _built\files\SPX___.BIN
fc /b _original\%REGPATH%\BRAMINIT.MMD _built\files\BRAMINIT.MMD
fc /b _original\%REGPATH%\BRAMSUB.BIN _built\files\BRAMSUB.BIN
fc /b _original\%REGPATH%\MDINIT.MMD _built\files\MDINIT.MMD
fc /b _original\%REGPATH%\SNCBNK1B.BIN _built\files\SNCBNK1B.BIN
fc /b _original\%REGPATH%\TITLEM.MMD _built\files\TITLEM.MMD
fc /b _original\%REGPATH%\TITLES.BIN _built\files\TITLES.BIN
fc /b _original\%REGPATH%\NISI.MMD _built\files\NISI.MMD
fc /b _original\%REGPATH%\DUMMY0.MMD _built\files\DUMMY0.MMD
fc /b _original\%REGPATH%\DUMMY1.MMD _built\files\DUMMY1.MMD
fc /b _original\%REGPATH%\DUMMY2.MMD _built\files\DUMMY2.MMD
fc /b _original\%REGPATH%\DUMMY3.MMD _built\files\DUMMY3.MMD

pause