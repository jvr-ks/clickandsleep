# ClickAndSleep

Simple App (Windows > 10 only) to make clicks at user defined positions,  
go to sleep (shutdown to sleep mode),  
wake up and repeat all over again and again.  
In the following ClickAndSleep is called "app" or "CAS/cas".  
**This is not rocket science!**  

#### Status
**Beta, under construction!**


#### [-> Latest changes/ bug fixes](latest_changes.md)

#### Start:
"clickandsleep.exe" \[command-file (or path to)]  \[configuration-file (or path to)]  
**First file must be the command-file.**  
  
Path to the command-file can be relativ (subdirectory of running directorie) i.e. "\dirXYZ\clickandsleep.txt" or  
absolut, i.e. "C:\dir1\dir2\clickandsleep.txt"  
   
Command-file default is **"clickandsleep.txt"**.  
Configuration-file default is **"clickandsleep.ini"**.   
\[Download from github](https://github.com/jvr-ks/clickandsleep/raw/master/clickandsleep.exe)  
Viruscheck see below.  
   
The Command-file must have the extension ".txt", configuration-file must have the extension ".ini". (see "loadset" command).  
  
If you want to use the standby/wakeup-feature,  
you must run "clickandsleep.exe" as an "**administrator**"!  

#### Default hotkeys:
  
Hotkey | Action | Remarks
------------ | ------------- | -------------
**\[ALT] + \[q]** | open app menu | Hotkeys are changeable -> configuration-file
**\[SHIFT] + \[ALT] + \[q]** | remove app from memory | **Does not remove any wakeup tasks!** \*1)
**\[CTRL] + \[ALT] + \[q]** | record mouseposition \*2) | appended to the command-file  
  
\*1) Use Windows Taskscheduler (menu-button) instead to remove "wakup" task if necessary.     
\*2) Appends "//mouseClick,x,y" and "//mouseClickLikeliness,x,y,ca" to the command-file if clicked.  
Recording of the 2nd command can be turned of by setting recordlikeliness="OFF" -> configuration-file.   
To stop the Mouserecord-mode, push the hotkey again or make a right-click anywhere on the screen!  
  
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
On click on one of the Run-buttons, the commands in the command-file are executed sequentially, i.e. line by line.  

Commands are based on the underlying Autohotkey language.  
  
To distinguish them from the Autohotkey command,  
a CAS-command starts with a **lower case letter**, but is not case-sensitiv,  
so use camel-case for better readability.  
    
Command-parameters must be fixed values, variables are not allowed (besides "conditions, see below). 
They are delimited by a comma or a tab.
  
For more advanced scripts you should consider to use a native Autohotkey script.  
   
#### Standby:   
* Wondows cannot go to standby-mode if hibernate-mode is enabled.  
Use "hibernate_off.cmd" as admin to switch hibernate-mode "off".
  
* If you want to use the standby/wakeup-feature,  
you must run "clickandsleep.exe" as an "**administrator**"!  
  
#### Wakeup from Stadby
* After wakeup be patient, the app waits about a minute before continuing!   
  
* Early wakeup: An early-wakeup timer is started.  
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
**setWinCon** | Command to set winCon to true | no
**resetWinCon** | Set winCon to true | no
 

#### Web-Browser:  
Browser pathsto apps -> configuration-file->\[external]

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
\*2) winCon is false if closed.   
  
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
**showCasWin** | ,WinTitle, WinText, ExcludeTitle, ExcludeText | Brings the ClickandSleep-Window to the front |  | yes

\*1) "ahk_pid" can be use as a WinTitle, translates to: "ahk_pid runPID" -> runPID: Condition variables  
\*2) winCon is the "handle to window number HWND" (hex), interpreted as "true" if not zero.  
  
#### MouseMode:  
Command | Parameter | Action | Remarks | like AHK command  
------------ | ------------- | ------------- | ------------- | -------------  
**coordmousemode** | , RelativeTo | Sets mouse-coord-mode | can be: "Screen" or "Client" | no
**coordMode** | , TargetType , RelativeTo | Sets coord-mode of TargetType | look at AHK-docs | yes
  
Tip-command: CoordMode is preset to: Screen  

#### Mouse Move and Click:  
All mouse-move-commands support the coordinate-transformation.  
  
Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------  
**mouseMove** | ,x,y , \[Speed] | Move to coordinate x, y |  | no
**mouseClick** | ,x,y | Click with the left mousebutton at coordinate x, y  | Click at current cursor-position if x,y are empty | no 
**mousedblClick** | ,x,y | Click with the left mousebutton twice at coordinate x, y  | Click at current cursor-position if x,y are empty | no 
**mouseClickLikeliness** | ,x,y,ca,comment | Click left if screenarea is equal ca | use mouserecord-hotkey to get actual screenarea in clipboard  \*1) | no 
**mouseClickLikelinessTimesDelay** | ,x,y,ca,comment,n,d | Click left if screenarea is equal ca | use mouserecord-hotkey to get actual screenarea in clipboard \*2) | no 
**mouseClickRight** | ,x,y | Click with the right mousebutton at coordinate x, y  | Click at current cursor-position if x,y are empty| no 
**mouseClickRandom3** | ,x1,y1,x2,y2,x3,y3  | Click with the left mousebutton at coordinate x, y | Selects randomly one of three points to click on | no 
**mouseClickAround** | ,x,y,maxoffset,\[increment] | Click aroud a point | *3) | no

To **record the current mouseposition** look at -> Default hotkeys section.  
  
\*1) Checks the colors in a 20 X 16 pixel area.  
"ca" is each mean-sum of R|G|B colors of the screen-pixels.  
Slow operation!
   
A little slow, please be patient.  
**The "mouseClickLikeliness" "ca-values" are browser-dependant!**
 
\*2) As "mouseClickLikeliness" command, but repeated n times with d millisendseconds delay between,  
if not successfull.  
Default values:  
n: 3 (times)
d: 10000 (milliseconds)
Press "**Capslock**" to abort command!  
In case of  success, both commands behave identical!  
  
*3) Sometimes coordinates change a little bit (especially in browsers) from call to call.  
Use mouseClickAround to click at multible points around x,y incremented by optional "increment" (default: 1) until "offset" is reached.  
   
#### Sleep: 
Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------
**Sleep** | ,time, message  | t: delay execution for time t (milliseconds) | t defaults to "defaultShowTime" (default is 4000 -> configuration-file) i.e. 4 seconds \*1) | no
**sleeplong** | ,time, message  | t: delay execution for time t (seconds) | t defaults to "defaultShowTime" (default is 4000 -> configuration-file) i.e. 4 seconds \*2) | no  
**KeyWait** | , KeyName |  , Options  | has additional default values  
KeyName: defaults to ESCAPE  
See [List of Keys](https://www.autohotkey.com/docs/KeyList.htm)  
Options: defaults to D  
See [Options](https://www.autohotkey.com/docs/commands/KeyWait.htm)  
  
\*1) A ToolTip with the delay time and the message is shown at the top/center of the screen if t > 10000.
\*2) A ToolTip with remaining time and the message is shown at the top/center of the screen.
Default is: 10 seconds. 
You can:  
* pause sleeplong with "Capslock"-ON,*
* end sleeplong with \[Capslock"]-ON and holding the \[ALT] key down for a few seconds *
* cancel the run operation with \[Capslock"]-ON and holding the \[Ctrl] key down for a few seconds *

#### Error handling:  
Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------
**resetErrorlevel** | | Reset errorlevel |  | no 
**errorLevelHint** | ,message, timeout | Message popup, closed after timeout | timeout in milliseconds  | no 
**errorLevelStop** |  | Stops any Run execution |  | no 
**errorLevelExit** |  | Exit, removes CAS from memory |  | no  
**winconstop** |  | Stops any Run execution if winCon is false | to us with activateBrowser ommand | no 
**winconexit** |  | Stops and removes CAS from memory if winCon is false | to us with activateBrowser ommand | no 

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
  
##### Use script with other display resolution:
With the button \[Stamp with coordinates] in the menu you can stamp your script with the coordinates you are using!    
A scriptcoordinates-command is prepended to your commands.  

Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------  
**scriptcoordinates** | ,x,y | Records the screen resolution | \*1) | no 
  
\*1)
If you want to transfer the commandfile to another computer with a different screen-resolution,  
use this command. Then on the other computer, the coordinates are scaled accordingly.   
  
#### Debug:  
Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------  
**debugOn** | | Set debug-mode to on |  | no 
**debugOff** | | Set debug-mode to off |  | no 
**debugStopRun** | | Stops at this command if debug is on |  | no 
**debugShowSleepOff** | | Do not show sleep-command-popup during debug-mode | Sleep-ToolTips are allways displayed | no 
**debugShowSleepOn** | | Show sleep-command-popup during debug-mode | Sleep-ToolTips are allways displayed | no 
**showHintColored** | text,autoclose-time,forgroundcolor,backgroundcolor \*1)| Popup with colored text | color: c + Hexvalue | no 
**showTextFile** | ,path,autoclose-time \*1)| Popup with Text-file content  | Text is not editable | no 
**tip** | ,text | Show ToolTip at cursor position | Automatically removed after 3 seconds | no 
**tipTop** | ,text | Show ToolTip at top/center \*2) | Automatically removed after 3 seconds | no  
**tipAt** | ,x ,y ,text | Show ToolTip at x, y | Automatically removed after 5 seconds | no 

**showHint** | ,message,**time to display** (milliseconds) | Popup with message, time defaults to "defaultShowTime" -> configuration-file |  | no 
**showHintError** | ,hint-message to show,**time to display** (milliseconds) | Show popup | Only shown if errorLevelMemo is set | no 

**showvar** | ,n | ToolTip (at top, center, 10 seconds displayed) with content of the variable | n is name of variable to show | no 
**showPid** | ,t | Popup with the PID (runPID) from the last "run" command | t is time to display (milliseconds, defaults to "defaultShowTime" -> configuration-file | no 
  
\*1) Uses the function-call mechanismn.  
**No comma is allowed in function-call-parameters!**  
(Because it is used as the delimiter!)  
\*2) Tooltips with system-messages are shifted to the right/left, parameter is tipOffsetDeltaX -> Configuration-file


##### Multiline text:  
In multiline text use (eMail etc.):
Quotationmarks -> as \"  
Linebreaks -> as "%0A" \[% zero A] 
  
#### Configuration-file:  
The configuration-file (default is "clickandsleep.ini") contains the configuration-parameters.  

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
Allowed "autorun" values are:  
* off  
* runRepeated **(changed!)**  
* runAfterDelay  
* runStandby  
* runAfterDelayStandby  
  
#### Startparameter  
"clickandsleep.exe" \[command-file]  \[configuration-file]  
Filenames or the path to the files or  
"remove" to remove CAS-exe from memory (used to compile a new one).  
  
  
#### Loadset command:  
Command | Parameter | Action | Remarks | like AHK command
------------ | ------------- | ------------- | ------------- | -------------  
**loadset** | ,\[fileset-prefix] | Loads the 2 files: command-file: "fileset-prefix.txt" and configuration-file: "fileset-prefix.ini". | The running operation (runOnce etc. ) is continued with the new commands. | no 
  
#### Requirements  
* Windows 10 or later.  
* To use sleep-mode suspend-mode must be turned off: "hibernate_off.cmd"  
* [Notepad ++](https://notepad-plus-plus.org/) to edit the commands-file (**not in the source!**)  
* **clickandsleep.txt** command-file (UTF-8 or ANSI)   
* **clickandsleep.ini** configuration-file (UTF-8 or ANSI)   
* Directory must be writable, created files:  
"wakeup.xml"  
    
#### Files created  
* "wakeup.xml"  
Used to create a Windows wake-up-task.  
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
* After wakeup execute of "clickandsleep.exe remove" may fail. 
Remove it in the tray or restart Windows instead. 
  
* Only a single instance of "clickandsleep.exe" is allowed.
  
##### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
  

#### License: MIT  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2020 J. v. Roos



##### Viruscheck at Virustotal 
[Check here](https://www.virustotal.com/gui/url/6e5e4abb359844bf8917884a42c929d19f5d94f7fe0a60ac716da372a2a5d798/detection/u-6e5e4abb359844bf8917884a42c929d19f5d94f7fe0a60ac716da372a2a5d798-1614800912
)  
Use [CTRL] + Click to open in a new window! 
