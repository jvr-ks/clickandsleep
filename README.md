# ClickAndSleep  
  
Simple App (Windows &gt; 10 only) to make mouse-clicks at user defined positions,  
go to sleep (shutdown to sleep mode),  
wake up and repeat all over again and again.  
In the following ClickAndSleep is called "app" or "CAS/cas".  
Commands are only a linear sequence, no variables, no loops, no queries etc., besides internal things.   
**This is not rocket science!**  
Based on [Autohotkey](https://www.autohotkey.com).  
If you have advanced requirements, consider to use a native [Autohotkey](https://www.autohotkey.com) script.  
  
#### Status  
**Alpha, under construction!**  
  
#### [-&gt; Latest changes/ bug fixes](latest_changes.md)  
  
#### Known issues  
  
* Restart allways starts with default config  
* Coordinates are only window-position-independent NOT window-size-independent!  
* Browser refuses to close, if not opened by CAS.  
* If the taskbar is not hidden, a mouse-click at screen-position "0,0" is done to autohide  
  the taskbar!  
  You cannot use the taskbar as a click-target therefore!  
* All "hidden" operations (ControlCommands etc.) are not implemented yet.  
  
#### Gui:  
Fontsize can be set in the \[Configuration-file], section \[Config] (app restart required).  
  
#### Start:  
"clickandsleep.exe"  
  
#### Startparameter    
"clickandsleep.exe" \[Command-file (or path to)] \[Configuration-file (or path to)]  
"remove" to remove CAS-exe from memory (used to compile a new one).  
  
The Command-file has extension ".txt", defaults to "clickandsleep.txt".  
The Configuration-file has extension ".ini", defaults to "clickandsleep.ini".   
  
Each Command-file ("filename.txt") may have an associated Configuration-file ("filename.ini"),  
or the default Configuration-file ("clickandsleep.ini") is used.  
Configuration-file is possible changed by the "Loadset command", see below.  
  
"autorun" values are NOT commandline parameters, but part of the Configuration-file (see below).  
  
Path to the Command-file can be relativ (subdirectory of running directory) i.e. "dirXYZ\clickandsleep.txt" or  
absolut, i.e. "C:\dir1\dir2\clickandsleep.txt"  
  
#### Download via Updater (preferred method)  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Directory must be writable by the app!**  
  
Default installation-directory is: "C:\jvrks\clickandsleep".  
  
Download Updater from Github and start "updater.exe",  
it possibly makes a self-update then and  
copies itself to the installation-directory afterwards.  
  
The copy of Updater is started then and it downlods the desired app (and dependant files).  
(Later on it is used to update the app.)  
The downloaded Updater (and dependant files) are not required anymore,  
please confirm the request to delete the files.  
  
**clickandsleep.exe** 64 bit Windows use:  
[updater.exe 64 bit](https://github.com/jvr-ks/clickandsleep/raw/main/updater.exe)  
or  
**clickandsleep32.exe** 32 bit Windows use:  
[updater.exe 32 bit](https://github.com/jvr-ks/clickandsleep/raw/main/updater32.exe)  

[Updater viruscheck see Updater repository](https://github.com/jvr-ks/updater)   
  
* From time to time there are some false positiv virus detections  
[Virusscan](#virusscan) at Virustotal see below.  
  
**Make shure to use only one of the clickandsleep\*.exe files at a time!**  
  
#### Default hotkeys:  
  
Hotkey | Action | Remarks  
------------ | ------------- | -------------  
**\[ALT] + \[m]** | open app menu | Hotkeys are changeable -&gt; Configuration-file   
**\[SHIFT] + \[ALT] + \[m]** | remove app from memory | **Does not remove any wake up tasks!** \*1)  
**\[CTRL] + \[ALT] + \[m]** | record mouseposition \*2) | appended to the Command-file  
  
\*1) Use Windows Taskscheduler (menu-button) instead to remove "wakup" task if necessary.  
\*2)  
Appends to the Command-file:  
"mouseClick,x,y" or "mouseDblClick,x,y" or,  
"mouseClickLikeness,x,y,ca" if \[CTRL] ist hold during the mouseclick (DoubleClick is not supported) or,  
"mouseClickLikenessFast,x,y,ca" if \[SHIFT] ist hold during the mouseclick (DoubleClick is not supported).  
Recorded coordinates are of type "Client", i.e. relativ to the active window (not to the Screen)!  
(Other CoordModes are currently not supported in coordinate-record operations.)  
  
~~Recording of the 2nd command can be turned of by setting recordlikeness="OFF" -&gt; Configuration-file.~~   
**To stop the Mouserecord-mode, push the hotkey again or make a right-click anywhere on the screen!**  
  
#### App menu:  
In the menu there are the app-buttons in the top section,  
and the commands are listed as buttons below.  
You can click on any command-button to execute only this command immediately.  
(Step by step debugging).  
Comment-lines starting with a "//" are also executed in this mode.  
Additional key-functions:  
1. \[Ctrl] + click on a command-button: edit this command.  
2. \[Alt] + click on a command-button: toggle command as a comment on/off ("//").  
  
#### Command-list window:  
The commands are displayed in a list.  
To execute a single command (debug) select it and click on the \[Single Command] Button.  
To edit a single command select it and click on the \[Edit Single Command] Button or  
hold down \[STRG] and click on the \[Single Command] Button.  
To comment out a command, click on the \[Single Command] Button, while holding the \[ALT] Button down.  
  
#### Commands:  
On click on one of the Run-buttons, the commands in the Command-file are executed sequentially, i.e. line by line.  
  
Commands are based on the underlying [Autohotkey](https://www.autohotkey.com) language.  
  
To distinguish them from the [Autohotkey](https://www.autohotkey.com) command,  
a CAS-command starts with a **lower case letter**, but is not case-sensitiv,  
so use camel-case for better readability.  
  
Command-parameters must be fixed values, variables are not allowed (besides "conditions, see below). 
They are delimited by a comma or a tab.  
  
* Activating CAPSLOCK holds on current command, press CTRL-key then to abort all commands,  
press ALT-key to jump over current command only!  
CAPSLOCK is automatically released afterwards.  
  
#### Standby:   
* Windows cannot go to standby-mode if hibernate-mode is enabled.  
Use "hibernate_off.cmd" as admin to switch hibernate-mode "off".  
  
* If you want to use the standby / wake up feature,  
you must run "clickandsleep.exe" as an "**administrator**"!  
  
#### Wakeup from Standby  
* After wake up be patient, the app waits about a minute before continuing!   
  
* Early wake up: An early wake up timer is started.  
If you manually activate standby again this timer is not reset, i.e. adds to the delay.  
It is better then to start all over again.    
  
  
### Table of Commands:  
  
#### Comments:  
Command | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | -------------  
**rem** | A Comment line | Only valid at the line-start | no  
**;** | A Comment line | Only valid at the line-start | yes  
**//** | A Comment line | Only valid at the line-start \*1) | no  
  
\*1) not treated as a commentline in Single-Step-Mode,  
can be **toggled on/off by clicking with \[Alt] key down**.  
  
#### Condition variables:  
Name | Purpose  
------------ | -------------  
**winCon** | Status of last WinExist command  
**errorLevelMemo** | The last errorlevel  
**runPID** | PID of the last "Run" command. \*1)  
  
\*1) Not all Run commands return a valid PID.  
  
#### Condition variables commands:  
Command | Action | like AHK command  
------------ | ------------- | -------------  
**setWinCon** | Command to set winCon to true (!= 0) | no  
**resetWinCon** | Set winCon to false  (== 0)| no  
  
  
#### Web-Browser:  
see -&gt; Configuration-file -&gt; \[external]  
  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**openChrome** | URL | Opens the Google Chrome browser with the URL | The browser is closed and then reopened with the URL | no  
**openFirefox** | URL | Opens the Firefox browser with the URL | The browser is closed and then reopened with the URL | no  
**openEdge** | URL | Opens the Microsoft Edge browser with the URL | The browser is closed and then reopened with the URL | no  
**activateChrome** | URL | Opens the window with running Chrome | *1) | no  
**activateFirefox** | URL | Opens the window with running Firefox | *1) | no  
**activateEdge** | URL | Opens the window with running Edge | *1) | no  
**closeChrome** | | Closes Google Chrome \*2) | Timeout to close is fixed to 10 seconds | no  
**closeFirefox** |  | Closes Firefox \*2) | Timeout to close is fixed to 10 seconds | no  
**closeEdge** |  | Closes Microsoft Edge \*2) | Timeout to close is fixed to 10 seconds | no  
  
  
Browsers operate asynchron while loading a page, i.e. if the browser windows is ready,   
the content is still loading, so give enough sleeptime!  
   
\*1) uses winCon.   
\*2) winCon is false if closed.  **Can only close Browser if opened by ClickandSleep!**  
  
#### Window handling:  
AHK TitleMatchMode is allways set to "2".  
   
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**winClose** | ,WinTitle, WinText, SecondsToWait, ExcludeTitle, ExcludeText  | Close the current window | Apps are closed or moved to background | yes  
**winMinimize** | ,WinTitle, WinText, ExcludeTitle, ExcludeText | Minimizes the current window |  | yes  
**winMaximize** | ,WinTitle, WinText | Maximizes the current window |  | no  
**WinActivate** | ,WinTitle, WinText, ExcludeTitle, ExcludeText  | Waits until the specified window is active | **winCon** must be **true** | no  
**WinWaitActive** | , WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText  | Waits until the specified window is active | **winCon** must be **true**, Timeout is in seconds | no  
**Winwait** | ,WinTitle  *1), WinText, ExcludeTitle, ExcludeText  | Waits until the specified window exists. | **winCon** must be **false**, sets errorLevelMemo | no  
**WinExist** | ,WinTitle , WinText, ExcludeTitle, ExcludeText  | Checks if a matching window exists. | Sets winCon variable \*2)| no   
**pushWin** | | Memorizes current active window |  pushed on a stack | no  
**popWin** | | Restore memorized window |  poped from a stack | no   
**showCasWin** | ,WinTitle, WinText, ExcludeTitle, ExcludeText | Brings the ClickandSleep-Window to the front |  | no  
  
\*1) "ahk_pid" can be use as a WinTitle, translates to: "ahk_pid runPID" -&gt; runPID: Condition variables  
\*2) winCon is the "handle to window number HWND" (hex), interpreted as "true" if not zero.  
  
#### CoordMode  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**coordMode** | TargetType , RelativeTo  | Sets coordinate mode | use "Screen" if there is no client window! | yes  
**coordModeReset** | -  | Sets coordinate mode to default |  | no *1)  
  
*1) Default is:  
CoordMode, Mouse, Client  
CoordMode, Pixel, Client  
CoordMode, Caret, Client  
CoordMode, ToolTip, Screen  
  
#### Mouse Move and Click:   
  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**mouseMove** | ,x,y,\[Speed] | Move to coordinate x, y | Speed = 0 to 90, 90 is slowest | no  
**mouseClick** | ,x,y,Speed,DownOrUp,Relative | Click with the left mousebutton at coordinate x, y  | Click at current cursor-position if x,y are empty | no (no ClickCount parameter)  
**mousedblClick** | ,x,y | Click with the left mousebutton twice at coordinate x, y  | Click at current cursor-position if x,y are empty | no (no ClickCount parameter, ClickCount is set to 2)  
**mouseClickLikeness** | ,x,y,ca,comment | Click left if screenarea is equal ca | use mouserecord-hotkey to get actual screenarea in clipboard  \*1) | no  
**mouseClickLikenessTimesDelay** | ,x,y,ca,comment,n,d | Click left if screenarea is equal ca | use mouserecord-hotkey to get actual screenarea in clipboard \*2) | no  
**mouseClickLikenessFast** | ,x,y,ca,comment | Click left if screenarea is equal ca | use mouserecord-hotkey to get actual screenarea in clipboard  \*4) | no  
**mouseClickRight** | ,x,y | Click with the right mousebutton at coordinate x, y  | Click at current cursor-position if x,y are empty| no  
**mouseClickRandom3** | ,x1,y1,x2,y2,x3,y3  | Click with the left mousebutton at coordinate x, y | Selects randomly one of three points to click on | no  
**mouseClickAround** | ,x,y,maxoffset,\[increment] | Click aroud a point | *3) | no  
  
To **record the current mouseposition** look at -&gt; Default hotkeys section.  
**All "*likeness"-commands copy the calculated value to the clipboard!**  
  
\*1) Checks the colors in a 20 X 16 pixel area.  
"ca" is each mean-sum of R|G|B colors of the screen-pixels.  
Color calculation takes time!  
   
**The "mouseClickLikeness" "ca-values" are browser-dependant!**  
Depends on screen brightness also!  
  
\*2) As "mouseClickLikeness" command, but repeated n times with d millisendseconds delay between,  
if not successfull.  
Default values:  
n: 3 (times)  
d: 10000 (milliseconds)  
Press "**Capslock**" to abort command!  
In case of  success, both commands behave identical!  
  
*3) Use mouseClickAround to click at multible points around x,y incremented by optional "increment" (default: 1) until "offset" is reached. 
   
\*4) As "mouseClickLikeness" but checked area is only 8 x 8 pixel in size.  
Color mean-values are different from that of "mouseClickLikeness"!  
To get the correct mean-value (Hexadezimal RGB), use any value i.e. FFFFFF and execute a singlestep.  
The correct value is displayed in the Tooltip then!  
   
#### Sleep: 
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**Sleep** | ,time, message  | t: delay execution for time t (milliseconds) | t defaults to "defaultShowTime" (default is 4000 -&gt; Configuration-file ) i.e. 4 seconds \*1) | no  
**sleeplong** | ,time, message  | t: delay execution for time t (seconds) | t defaults to "defaultShowTime" (default is 4000 -&gt; Configuration-file ) i.e. 4 seconds \*2) | no  
**KeyWait** | , KeyName |  , Options  | has additional default values  
KeyName: defaults to ESCAPE  
See [List of Keys](https://www.autohotkey.com/docs/KeyList.htm)  
Options: defaults to D  
See [Options](https://www.autohotkey.com/docs/commands/KeyWait.htm)  
**sleepLikenessFast**| ,x,y,ca,trials,comment | no \*3)  
**sleepLikenessFastLong**| ,x,y,ca,wait-time [minutes],comment | no \*4)  
  
\*1) A ToolTip with the delay time and the parameter "message" is shown at the top/center of the screen, if the parameter "message" is not empty.  
\*2) A ToolTip with remaining time and the parameter "message" is shown at the top/center of the screen,  if the parameter "message" is not empty.  
Default is: 10 seconds.  
You can:  
* pause sleeplong with "Capslock"-ON,  
* end sleeplong with \[Capslock"]-ON and holding the \[ALT] key down for a few seconds  
* cancel the run operation with \[Capslock"]-ON and holding the \[Ctrl] key down for a few seconds  
  
\*3) Checks if mean-color becomes ca-values (hexadezimal RGB) in a 8 x 8 pixel area, if not sleeps 10 seconds and tries again maximal trials times, trials defaults to 360 times, i.e. 36000 seconds. Trials should not exceed 30000.  
Activate CAPSLOCK to abort!  
  
\*4) As "sleepLikenessFast" but tries forever until mean-color becomes ca-values with wait-time minutes between.  
Does NOT goto sleep-mode but saves/restores the active window before wait-delay.  
If the start-window is in front:  
* activating the \[CAPSLOCK]-key: command is canceled  
* activating the \[CAPSLOCK] + \[Ctrl]-key: all operations are aborted  
  
#### Error handling:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**resetErrorlevel** | | Reset errorlevel |  | no  
**errorLevelHint** | ,message, timeout | Message popup, closed after timeout | timeout in milliseconds  | no  
**errorLevelStop** |  | Stops any Run execution |  | no  
**errorLevelExit** |  | Exit, removes CAS from memory |  | no  
**winconstop** |  | Stops any Run execution if winCon is false | to use with activateBrowser command | no 
**winconexit** |  | Stops and removes CAS from memory if winCon is false | to use with activateBrowser command | no 
  
#### Start external apps:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**run** | ,Target, WorkingDir, Options, OutputVarPID | Set debug-mode to on | PATH: path to the file (*.exe or URL etc.),  
Environment-variables are translated,    
"winCon" must be **false**. | no  
  
#### Send:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**send** | ,text/characters to send  | type the text/chacaters as if you type them on your keyboard |  | no 
**sendText** | ,text/characters to send  | type the text/chacaters as if you type them on your keyboard  | send in text mode | no  
**sendBlindText** | ,text/characters to send  | type the text/chacaters as if you type them on your keyboard  | send in blind-text mode | no  
  
##### Email:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**sendEmail** | ,mailto,subject,body,bcc,bcc, ... | Generates an eMail by using your default eMail-App | Needs an extra click (send-button) to send it | no  
  
##### Use script on another computer with different display resolution:  
With the button \[Stamp with coordinates], you can stamp your script with the coordinates you are using!    
This is an information only that the coordinates may not be correct.  
  
#### Debug:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**debugOn** | | Set debug-mode to on |  | no 
**debugOff** | | Set debug-mode to off |  | no  
**debugShowMouseMoveON** | | Mouse ist slowly move to point before action takes place |  | no  
**debugShowMouseMoveOFF** | | default | silently | no  
**debugStopRun** | | Stops at this command if debug is on |  | no 
**debugShowSleepOff** | | Do not show sleep-command-popup during debug-mode | Sleep-ToolTips are allways displayed | no 
**debugShowSleepOn** | | Show sleep-command-popup during debug-mode | Sleep-ToolTips are allways displayed | no 
**showHintColored** | text,autoclose-time,forgroundcolor,backgroundcolor \*1)| Popup with colored text | color: c + Hexvalue | no 
**showTextFile** | ,path,autoclose-time \*1)| Popup with Text-file content  | Text is not editable | no 
**tip** | ,text | Show ToolTip at cursor position | Automatically removed after 3 seconds | no 
**tipTop** | ,text | Show ToolTip at top/center \*2) | Automatically removed after 3 seconds | no  
**tipAt** | ,x ,y ,text | Show ToolTip at x, y | Automatically removed after 5 seconds | no 
**tipWindow** | text, transp,remove, "NoRefresh"| Show top-centered ToolTip | Removed after "remove" milli-seconds \*3) | no 
**tipWindowClose** | | Forced close of tipWindow|  | no  
**showHint** | ,message,**time to display** (milliseconds) | Popup with message, time defaults to "defaultShowTime" -&gt; Configuration-file  |  | no  
**showHintError** | ,hint-message to show,**time to display** (milliseconds) | Show popup | Only shown if errorLevelMemo is set | no 
  
**showvar** | ,n | ToolTip (at top, center, 10 seconds displayed) with content of the variable | n is name of variable to show | no 
**showPid** | ,t | Popup with the PID (runPID) from the last "run" command | t is time to display (milliseconds, defaults to "defaultShowTime" -&gt; Configuration-file  | no  
  
\*1) Uses the function-call mechanismn.  
**No comma is allowed in function-call-parameters!**  
(Because it is used as the delimiter!)  
\*2) Tooltips with system-messages are shifted to the right/left, parameter is openerDeltaX -&gt; Configuration-file 
\*3) transp : transparency, 0 (min) to 255 (max), default 0  
Word "NoRefresh": do not delete previous tipWindow, avoids flickering, but keeps size of previous  
  
##### Multiline text:  
In multiline text use (eMail etc.):  
Quotationmarks -&gt; as \"  
Linebreaks -&gt; as "%0A" \[% zero A]  
  
#### Configuration-file:  
The Configuration-file  (default is "clickandsleep.ini") contains the configuration-parameters.  
  
The configuration-parameters are divided into sections:  
  
Section \[hotkeys]:  
Hotkeys can be set to "off" by adding the word "off" to the definition.  
  
Hotkeys characters:  
^ = CONTROL key  
! = ALT key  
\+ = SHIFT key  
\# = WIN key  
All [Autohotkey Hotkeys](https://www.autohotkey.com/docs/Hotkeys.htm) hotkeys-characters are usable, but only these four are displayed correctly in the menu.  
  
Default Hotkeys are:  
open menu ="!q",  
exit app = "+!q",  
record mouse position = "^!q".  
  
Section \[timing]:  
Default timing parameters  
  
Section \[external]:  
Pathes to Windows apps.  
  
Section \[run]:  
Allowed "autorun" values are (not casesensitiv):  
* runOnce **(changed!)**  
* runRepeated **(changed!)**  
* runAfterDelay  
* runStandby  
* runAfterDelayStandby  
* off  
  
**"autorun" is inhibited if Capslock-key is activated during app-start!**  
  
  
#### Loadset command:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**loadset** | ,\[fileset-prefix] | Loads the 2 files: Command-file: "fileset-prefix.txt" and Configuration-file:  "fileset-prefix.ini". | The running operation (runOnce etc. ) is continued with the new commands. | no  
  
#### Requirements  
* Windows 10 or later.  
* To use sleep-mode suspend-mode must be turned off: "hibernate_off.cmd"  
* [Notepad ++](https://notepad-plus-plus.org/) to edit the commands-file (**not in the source!**)  
* **clickandsleep.txt** command-file (UTF-8 or ANSI)   
* **clickandsleep.ini** \[Configuration-file]  (UTF-8 or ANSI)   
* Directory must be writable, created files:  
"wakeup.xml"  
    
#### Files created  
* "wakeup.xml"  
Used to create a Windows wake up task.  
(Kept at the moment for debugging purposes).  
  
[Sourecode at Github](https://github.com/jvr-ks/clickandsleep), "clickandsleep.ahk" an [Autohotkey](https://www.autohotkey.com) script.  
#### Additional information: 
Command: **openChrome**, URL   
Combines the following commands:  
resetWinCon  
resetErrorlevel  
winExist, ahk_class Chrome_WidgetWin_1  
WinClose, ahk_class Chrome_WidgetWin_1; only executed if (winCon)  
winExist, ahk_class Chrome_WidgetWin_1  
run,%chrome% %url%,,,runPID ; only executed if (!winCon)  
winWait,ahk_class Chrome_WidgetWin_1,,20  
errorLevelStop  
  
#### Drawbacks  
* After wake up execute of "clickandsleep.exe remove" may fail. 
Remove it in the tray or restart Windows instead. 
  
* Only a single instance of "clickandsleep.exe" is allowed.  
  
##### Hotkeys  
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/clickandsleep/blob/main/hotkeys.md)  
  
#### Gui-paramter  
Window position and size are stored in the guiFile (default: "caswindow.cas").  
The filename is configurable, Config-file: \[config] -&gt; \[setup] -&gt; guiFile="(path\)filename"  
The directory must be writable by the app!  
  
#### License: MIT  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
  
Copyright (c) 2020 J. v. Roos  
  
<a name="virusscan"></a>  


##### Virusscan at Virustotal 
[Virusscan at Virustotal, clickandsleep.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/2a5654dc761f9b8fe934591cc1d77634f4e91fd6d1377fea5af7de6604d699a8/detection/u-2a5654dc761f9b8fe934591cc1d77634f4e91fd6d1377fea5af7de6604d699a8-1754809979
)  
[Virusscan at Virustotal, clickandsleep32.exe 32bit-exe, Check here](https://www.virustotal.com/gui/url/84885749cfabdd66c74dfb4bf2b972761d244e4ca5d28f1695e3053838b16341/detection/u-84885749cfabdd66c74dfb4bf2b972761d244e4ca5d28f1695e3053838b16341-1754809980
)  
Use [CTRL] + Click to open in a new window! 
