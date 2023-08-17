@rem create_clickandsleep_exe_link_in_autostartfolder.bat

@set app=clickandsleep

@cd %~dp0

@powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\%app%.lnk');$s.TargetPath='%~dp0\%app%.exe';$s.Arguments='clickandsleep.txt clickandsleep.ini';$s.Save()"



