@rem compile.bat

@echo off

@cd %~dp0

@rem cannot remove if it runs as an admin!
@call clickandsleep.exe remove

@call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in clickandsleep.ahk /out clickandsleep.exe /icon clickandsleep.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

@timeout /T 3









