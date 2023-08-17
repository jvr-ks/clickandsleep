@rem restart.bat
@rem !file is overwritten by update process!

@cd %~dp0


@echo !!! GUI size is fixed now !!!
@echo.
@echo Please press a key to restart clickandsleep (%1 bit)!
@echo.
@pause

@echo off

@set version=%1
@if [%1]==[64] set version=

@if [%2]==[noupdate] goto noupdate

@copy /Y clickandsleep.exe.tmp clickandsleep%version%.exe

:noupdate
@del clickandsleep.exe.tmp
@start clickandsleep%version%.exe showwindow

:end
@exit