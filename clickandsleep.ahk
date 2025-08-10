/*
 *********************************************************************************
 * 
 * clickandsleep.ahk
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *********************************************************************************
*/
; Attention: Old "Spaghetti"-Code! :-)
; but I use it daily! (to shutdown the "NAS" [Fritzbox 7490])
/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

; *********************************** settings *******************************
#NoEnv
#Warn
#SingleInstance, force
#Persistent
#MaxThreads 10
#InstallKeybdHook
#InstallMouseHook
#KeyHistory 100

#Include %A_ScriptDir%

#include Lib\additions.ahk
#include Lib\ahk_common.ahk

FileEncoding, UTF-8-RAW
internalDebug := false
mode := 0
; 0 => idle
; 0 => idle
;------------------------------- Gui parameter -------------------------------
windowPosX := 0
windowPosY := 0

HMain := 0
borderX := 10
borderY := 100 ; reserve statusbar space
buttonHeight := 20 ; TODO depends on fontsize

; doAction():
#Include, %A_ScriptDir%\cascommands.ahk

; *********************************** prepare *******************************
SendMode Input
SetWorkingDir %A_ScriptDir%

wrkDir := A_ScriptDir . "\"

DetectHiddenText, On

CoordMode, Mouse, Client
CoordMode, Pixel, Client
CoordMode, Caret, Client
CoordMode, ToolTip, Screen

;mousemove
defaultMouseSpeedDefault := 10
defaultMouseSpeed := defaultMouseSpeedDefault

debug := false
showmousemove := false
showmousemoveSpeed := 40
runDoLoop := false
downCounter := 0
sleepDownCounter := 0
counter := 0
delayDownCounter := 0
downCounterShutdown := 0
cancelShutdown := false

debugShowSleep := false
runSingleOp := false
errorLevelMemo := false
likenessCheckLoopLongRun := false

cmdSelected := ""
listBoxEntry := 1

xPosActu := 0
yPosActu := 0

openerDeltaXDefault := 250
openerDeltaX := openerDeltaXDefault

MainStatusBarHwnd := 0

; *********************************** constants ****************************
appName := "ClickAndSleep"
appnameLower := "clickandsleep"
appExtension:= ".exe"
appVersion := "0.441"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

app := appName . " " . appVersion . " " . bit . "-bit"


configFile := "clickandsleep.ini"
cmdFile := "clickandsleep.txt"

guiFileDefault := wrkDir . "clickandsleep.gui"
guiFile := guiFileDefault ; possible overwritten

server := "https://github.com/jvr-ks/" . appnameLower . "/raw/main/"
downLoadURL := server . appnameLower . bitName . appExtension
downLoadFilename := appnameLower . ".exe.tmp"
restartFilename := "restart.bat"
downLoadURLrestart := server . restartFilename

notepadpathDefault := "C:\Program Files\Notepad++\notepad++.exe"
emailpathDefault := "C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe"
chromeDefault := "C:\Program Files\Google\Chrome\Application\chrome.exe"
firefoxDefault := "C:\Program Files\Mozilla Firefox\firefox.exe"
recordlikenessDefault:= "ON"
quot := """"
edgeDefault := quot . "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" . quot . "--profile-directory=Default"

DetectHiddenWindows, On
winArr := []
allcmdsArr := []

; overwritten by Config-file
notepadpath := notepadpathDefault
emailpath := emailpathDefault

fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 9
fontsize := fontsizeDefault
buttonHeight := 26
listBoxWidth := 400
listBoxHeight := 400

chrome := chromeDefault
firefox := firefoxDefault
edge := edgeDefault

wakeUpFile := "wakeup.xml"

scriptcoordinateX := A_ScreenWidth
scriptcoordinateY := A_ScreenHeight

wakeupbeforeeMinutesDefault := 5
wakeupbeforeeMinutes := wakeupbeforeeMinutesDefault

startTime := A_TickCount

repeattimeDefault := 7800 ;2h10m
repeatTime := repeattimeDefault

repeatCounterDefault := 1
repeatCounterStart := repeatCounterDefault
repeatCounter := repeatCounterStart

delayTimeDefault := 300 ; 5 minutes
delayTime := delayTimeDefault

systemNeededMillisToShutdownDefault := 30000
systemNeededMillisToShutdown := systemNeededMillisToShutdownDefault

defaultShowTimeDefault := 4000
defaultShowTime := defaultShowTimeDefault

wakeupDateTime := 0

menuhotkeyDefault := "!m"
menuhotkey := menuhotkeyDefault

exitHotkeyDefault := "+!m"
exitHotkey := exitHotkeyDefault

mouserecordHotkeyDefault :="^!m"
mouserecordHotkey := mouserecordHotkeyDefault

runCas := false
runCasOnceOnly := false
runCasStandby := false
runCasAfterDelay := false
runCasAfterDelayStandby := false

autorun := "off"

deviationMaxDefault := 20
deviationMax := deviationMaxDefault

hintTimeShortDefault := 1500
hintTimeMediumDefault := 2000
hintTimeDefault := 3000
hintTimeLongDefault := 5000

hintTimeShort := hintTimeShortDefault
hintTimeMedium := hintTimeMediumDefault
hintTime := hintTimeDefault
hintTimeLong := hintTimeLongDefault

SetTitleMatchMode, 2
winCon := false
runPID := 0

showOpener := false
openerDeltaX := 200

;-------------------------------- read param --------------------------------
Loop % A_Args.Length()
{
  if(eq(A_Args[A_index],"remove")){
    showHint("Removed!", 1000)
    ExitApp
  }
  
  if(InStr(A_Args[A_index], ".txt")){
    cmdFile := A_Args[A_index]
  }
  
  if(InStr(A_Args[A_index], ".ini")){
    configFile := A_Args[A_index]
  }
  
}

cmdFile := resolvepath(wrkDir, cmdFile)
configFile := resolvepath(wrkDir, configFile)

Lb1 := 0

; ********** autorun
if (getKeyboardState() != 1){
;Capslock is off
  IniRead, autorun, %configFile%, run, autorun , "off"
  
  autorun := StrLower(autorun)
  switch autorun
  {
  case "runonce":
    mainWindow()
    casRunStartOnceOnly()
  case "runrepeated":
    mainWindow()
    casRunStartRepeated()
  case "runafterdelay":
    mainWindow()
    casRunAfterDelay()
  case "runstandby":
    mainWindow()
    casRunStandby()
  case "runafterdelaystandby":
    mainWindow()
    casRunAfterDelayStandby()
  case "off":
    mainWindow()
  default:
    mainWindow()
  }
} else {
  ;Capslock is on
  setTimer,showCapslock,-2000
  mainWindow()
}

return

;-------------------------------- mainWindow --------------------------------
mainWindow() {
  global appName, HMainHwnd, buttonHeight, hintTime
  global configFile, app, runCas, cmdFile, Lb1
  global exitHotkey, menuHotkey, mouserecordHotkey
  global repeatTime, delayTime, allcmdsArr, cmdSeleted
  global font, fontsize
  global listBoxWidth, listBoxHeight
  global appVersion, msgDefault, cmdSelected
  global windowPosX, windowPosY
  global MainStatusBarHwnd, repeatCounterDefault, repeatCounterStart
  global Element3_1, Element3_2, Element3_3, Element3_4, Element3_5, Element3_6
  global Element3_7, Element3_8, Element3_9, Element3_10, Element3_11, Element3_12, Element3_13
  global openerDeltaX
  
  prepare()
  
  Gui, guiMain:Destroy

  Gui, guiMain:New, +OwnDialogs +LastFound hwndHMainHwnd, %app%
  Gui, guiMain:Font,s%fontsize%,%font%
  Gui, guiMain:Color,cF0F0F0
  
  timeInterval := formatTimeSeconds(repeatTime)
  timeDelay := formatTimeSeconds(delayTime)
  
  Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.
  Menu, MainMenu, NoDefault
  if (ErrorLevel == 0) {
    Menu, MainMenu, DeleteAll
  }
  
  Menu, MainMenu, Add,Update-check,checkUpdate
  Menu, MainMenu, Add,Update,startUpdate
  
  Menu, MainMenu, Add, Kill this app, exit

  buttonWidth := 130
  buttonWidthLarge := 250
  
  deltaX3 := buttonWidth + 10
  
  textWidth := 2 + (buttonHeight + 2) * 6
  
  listBoxHeight := (buttonHeight + 2) * 14
  
  cmdList := getCmdList()
  
  Gui, guiMain:Add, ListBox, 0x100 hwndLb1 x3 y3 w%listBoxWidth% h%listBoxHeight% vcmdSelected gcmdselectGetEntry, %cmdList%

  Gui, guiMain:Add, Button, x+m section w%buttonWidthLarge% gcasRunStartRepeated, RUN at Repeat-interval
  
  Gui, guiMain:Add, Button, xs w%buttonWidthLarge% gcasRunStandby, RUN/STANDBY at Repeat-interval
  
  Gui, guiMain:Add, Button, xs w%buttonWidthLarge% gcasRunAfterDelay, RUN delayed at Repeat-interval
  
  Gui, guiMain:Add, Button, xs w%buttonWidthLarge% gcasRunAfterDelayStandby, RUN/STANDBY delayed at Repeat-interval
  
  Gui, guiMain:Add, Button, xs w%buttonWidthLarge% r2 geditCmdFile, &Edit Command-file
  
  column2 := buttonWidth + 10
  Gui, guiMain:Add, Button, xs w%buttonWidth% r2 geditSingleOp, Edit selected command
  Gui, guiMain:Add, Button, xs+%column2% yp+0 w%buttonWidth% r2 gdeleteSingleOp, Delete selected command
  
  Gui, guiMain:Add, Button, xs w%buttonWidth% gfileInsertEmpty, Prepend command
  Gui, guiMain:Add, Button, xs+%column2% yp+0 w%buttonWidth% gfileAppendEmpty, Append command
  
  Gui, guiMain:Add, Button, xs gToogleComment, Toggle comment //
  Gui, guiMain:Add, Button, xs+%column2% yp+0 gToogleCommentSemi, Toggle comment `;
  
  Gui, guiMain:Add, Button, xs w%buttonWidth% gopenTaskschd, Windows Taskscheduler  
  Gui, guiMain:Add, Button, xs+%column2% w%buttonWidth% yp+0 gcheckUpdate, Update-check
  
  Gui, guiMain:Add, Button, xs w%buttonWidth% gopenGitHubPage, HELP at Github
  Gui, guiMain:Add, Button, xs+%column2% w%buttonWidth% yp+0 gShowHistory, System / history
  
  Gui, guiMain:Add, Button, xs w%buttonWidth% gmouserecordOnce, Record a mouse-click
  Gui, guiMain:Add, Button, xs+%column2% yp+0 w%buttonWidth% gloadset, Loadset
    
  mouserecordHotkeyText := "Record mouse-clicks `n" . hotkeyToText(mouserecordHotkey)
  Gui, guiMain:Add, Button, xs r2 w%buttonWidth% gmouserecordToggle, %mouserecordHotkeyText%

  Gui, guiMain:Add, Button, xs+%column2% yp+0 w%buttonWidth% r2 geditconfigFile, &Edit Config-file
  
  Gui, guiMain:Add, Button,xs r2 w%buttonWidth% vElement3_1 gguiAction_singleOp, Singlestep
  
  exitHotkeyText := "Kill this app `n" . hotkeyToText(exitHotkey)
  Gui, guiMain:Add, Button, xs+%column2% yp+0 w%buttonWidth% r2 gexit, %exitHotkeyText%
  
  ;left row below listbox
  
  Gui, guiMain:Add, Button,x3 yp+0 w%buttonWidthLarge% r2 vElement3_2 gcasRunStartOnceOnly, RUN once only
  
  Gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% r2 gcasRunStopStart, STOP RUN  
  
  ; Gui, guiMain:Add, Button,x+m yp+0 w%buttonWidth% r2 vElement3_1 gguiAction_singleOp, Singlestep
  
  ; exitHotkeyText := "Kill this app `n" . hotkeyToText(exitHotkey)
  ; Gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% r2 gexit, %exitHotkeyText%
  

  Gui, guiMain:Add, Button,x3 w%buttonWidth% genterInterval vElement3_3, Set Repeat-interval
  Gui, guiMain:Add, Text,w90 xp+%deltaX3% yp+0 vElement3_4, [%timeInterval%]
  

  Gui, guiMain:Add, Button,x+m w%buttonWidth% genterWaitDelay vElement3_5, Set Start-delay
  Gui, guiMain:Add, Text,w90 xp+%deltaX3% yp+0 vElement3_6, [%timeDelay%]
  
  Gui, guiMain:Add, Button,x+m w%buttonWidth% genterCount vElement3_12, Set Repeat-Count
  Gui, guiMain:Add, Text,w90 xp+%deltaX3% yp+0 vElement3_13, [%repeatCounterStart%]
  
  
  Gui, guiMain:Add, Text,x3 vElement3_7,Command-file:
  Gui, guiMain:Add, Text,w%textWidth% xp+%deltaX3% yp+0 vElement3_8, %cmdFile%
  
  Gui, guiMain:Add, Text,x3 vElement3_9,Config-file:
  Gui, guiMain:Add, Text,w%textWidth% xp+%deltaX3% yp+0 vElement3_10, %configFile%
  
  ; Errormessage
  Gui, guiMain:Add, Text,w400 r2 cRed x3 vElement3_11

  Gui, guiMain:Add, StatusBar, hwndMainStatusBarHwnd -Theme +BackgroundSilver
  
  Gui, guiMain:Menu, MainMenu
  
  showMessageDefaultCAS()
  
  
  Gui,guiOpener:new,+E0x08000000 -Caption -Border -SysMenu +Owner +AlwaysOnTop +ToolWindow
  Gui, guiOpener:Margin, 0, 0
  Gui,guiOpener:Add, Button,x0 y0 gopenOpener,CAS
  
  Gui,guiOpener:Show,x%openerDeltaX% y2 hide autosize
  
  OnMessage(515, "OnDblClick")  ;Intercept WM_LBUTTONDBLCLK notifications
  
  showWindow()
  
  return
}

;-------------------------------- openOpener --------------------------------
openOpener(){
  casRunStopStart()
  showWindowRefreshed()
  
  return
}

;-------------------------------- showWindow --------------------------------
showWindow(){
  global listBoxWidth, listBoxHeight, buttonHeight, windowPosX, windowPosY
  global xPosActu, yPosActu
  
  setTimer,checkFocus,delete
  setTimer,checkFocus,3000

  Gui, guiMain:Show,autosize
  
  ControlGetPos, X, Y, Width, bH, Button1
  
  if (bH > 0)
    buttonHeight := Round(bH * 96/A_ScreenDPI)
    
  return
}

;-------------------------------- refreshGui --------------------------------
refreshGui(){
  global buttonHeight, cmdSelected, HMainHwnd
  global repeatTime, delayTime, repeatCounterStart
  global Element3_4, Element3_6, Element3_13

  Gui, guiMain: Default
  cmdList := getCmdList()
  GuiControl,guiMain:,cmdSelected,|%cmdList% ; prefix the list with the delimiter (|) to replace the control's contents
  
  cmdselectSetEntry()
  
  timeInterval := formatTimeSeconds(repeatTime)
  timeDelay := formatTimeSeconds(delayTime)
  
  GuiControl,guiMain:,Element3_4,%timeInterval%
  GuiControl,guiMain:,Element3_6,%timeDelay%
  GuiControl,guiMain:,Element3_13,%repeatCounterStart%
  
  return
}

;---------------------------------- prepare ----------------------------------
prepare() {
  readIni()
  readGuiParam()
  
  return
}

;********************************** readIni **********************************
readIni(){
  global internalDebug, repeatTime, repeattimeDefault
  global delayTime, delayTimeDefault
  global repeatCounterDefault, repeatCounterStart
  global wakeupbeforeeMinutesDefault, wakeupbeforeeMinutes
  global defaultShowTimeDefault, defaultShowTime
  global menuHotkey, menuhotkeyDefault
  global exitHotkey, exitHotkeyDefault
  global mouserecordHotkey, mouserecordhotkeyDefault, hintTimeShort
  global hintTimeShortDefault, hintTimeMedium, hintTimeMediumDefault, hintTime, hintTimeDefault, hintTimeLong, hintTimeLongDefault
  global wrkDir, configFile, guiFile, guiFileDefault
  global autorun, notepadpath, notepadpathDefault, emailpath, emailpathDefault
  global systemNeededMillisToShutdown, systemNeededMillisToShutdownDefault
  global chrome, chromeDefault
  global firefox, firefoxDefault
  global edge, edgeDefault
  global fontDefault, font, fontsizeDefault, fontsize
  global deviationMaxDefault, deviationMax
  global defaultMouseSpeedDefault, defaultMouseSpeed
  global showOpener
  global openerDeltaX
  global openerDeltaXDefault

  guiFileRead := iniReadSave("guiFileRead", "setup", guiFileDefault)
  if (guiFileRead != "")
    guiFile := resolvepath(wrkDir, guiFileRead)
  
  autorun := iniReadSave("autorun", "run", "off")
  
  repeatTime := iniReadSave("repeatTime", "timing", repeattimeDefault)
  
  delayTime := iniReadSave("delayTime", "timing", delaytimeDefault)
  
  repeatCounterStart := iniReadSave("repeatCounterStart", "config", repeatCounterDefault )
  
  wakeupbeforeeMinutes := iniReadSave("wakeupbeforeeMinutes", "timing", wakeupbeforeeMinutesDefault)
  
  defaultShowTime := iniReadSave("defaultShowTime", "timing", defaultShowTimeDefault)
  
  systemNeededMillisToShutdown := iniReadSave("systemNeededMillisToShutdown", "timing", systemNeededMillisToShutdownDefault)
  
  menuHotkey := iniReadSave("menuHotkey", "hotkeys", menuhotkeyDefault)
  if (InStr(menuHotkey, "off") > 0){
    s := StrReplace(menuHotkey, "off" , "")
    Hotkey, %s%, showWindowRefreshed, off
  } else {
    Hotkey, %menuHotkey%, showWindowRefreshed
  }

  exitHotkey := iniReadSave("exitHotkey", "hotkeys", exitHotkeyDefault)
  if (InStr(exitHotkey, "off") > 0){
    s := StrReplace(exitHotkey, "off" , "")
    Hotkey, %s%, exit, off
  } else {
    Hotkey, %exitHotkey%, exit
  }

  mouserecordHotkey := iniReadSave("mouserecordHotkey", "hotkeys", mouserecordhotkeyDefault)
  
  Hotkey, %mouserecordHotkey%, mouserecordToggle
  
  ;IniRead, hintTimeShort, %configFile%, timing, hintTimeShort , %hintTimeShortDefault%
  hintTimeShort := iniReadSave("hintTimeShort", "timing", hintTimeShortDefault)
  
  hintTimeMedium := iniReadSave("hintTimeMedium", "timing", hintTimeMediumDefault)
  hintTime := iniReadSave("hintTime", "timing", hintTimeDefault)
  hintTimeLong := iniReadSave("hintTimeLong", "timing", hintTimeLongDefault)
  
  notepadpath := iniReadSave("notepadpath", "external", notepadpathDefault)
  emailpath := iniReadSave("emailpath", "external", emailpathDefault)
  
  chrome := iniReadSave("chrome", "external", chromeDefault)
  firefox := iniReadSave("firefox", "external", firefoxDefault)
  edge := iniReadSave("edge", "external", edgeDefault)
  
  deviationMax := iniReadSave("deviationMax", "config", deviationMaxDefault)
  debugRead := iniReadSave("debugRead", "config", "off")
  if (StrLower(debugRead) == "on" || StrLower(debugRead) == "yes" || StrLower(debugRead) == "y")
    internalDebug := true
    
  IniRead, defaultMouseSpeed, %configFile%, config, defaultMouseSpeed, %defaultMouseSpeedDefault%
  SetDefaultMouseSpeed, defaultMouseSpeed
  SendMode Event

  openerDeltaX := iniReadSave("openerDeltaX", "config", openerDeltaXDefault)
  showCLSOpener := iniReadSave("showCLSOpener", "config", "no")
  if(showCLSOpener == "yes")
    showOpener := true

  
  return
}

;------------------------------- readGuiParam -------------------------------
readGuiParam(){
  global configFile, guiFile, fontDefault, font, fontsizeDefault, fontsize
  global windowPosX, windowPosY
  
  IniRead, windowPosX, %guiFile%, window, windowPosX, 0
  
  IniRead, windowPosY, %guiFile%, window, windowPosY, 0
  
  IniRead, font, %configFile%, config, font, %fontDefault%
  IniRead, fontsize, %configFile%, config, fontsize, %fontsizeDefault%
  
  fontsize := Min(16,fontsize)
  fontsize := Max(6,fontsize)

  return
}

;----------------------------- formatTimeSeconds -----------------------------
formatTimeSeconds(timeSeconds){
  hoursValue := SubStr("0" . (timeSeconds // 3600), -1)
  minutesValue := SubStr("0" . ((timeSeconds - hoursValue * 3600) // 60), -1)
  secondsValue := SubStr("0" . (Mod(timeSeconds, 60)), -1)
  timeValue = %hoursValue%:%minutesValue%:%secondsValue%
  
  return timeValue
}

;---------------------------- casRunStartOnceOnly ----------------------------
casRunStartOnceOnly(){
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, hintTimeMedium
  
  global downCounter, repeatTime, debug, errorLevelMemo
  
  errorLevelMemo := false
  
  if (isRunning()){
    showOpRunning()
  } else {
    runDoLoop := true
    runCasOnceOnly := true
    casRunOnce()
    casRunStop()
  }
  
  if (debug)
    tipWindow("Execution finished!",0,3000,true)
  
  showWindowRefreshed(true)
  
  return
}

;------------------------------- showOpRunning -------------------------------
showOpRunning(){
  global hintTime
  
  showHint("An operation is already running! You have to stop it beforee starting a new one!", hintTime)

  return
}

;-------------------------------- casRunOnce --------------------------------
casRunOnce(){
  global cmdFile, runCas, runDoLoop, debug, errorLevelMemo
  
  errorLevelMemo := false
  
  hideWindow()
  
  cmdselectSetEntryReset()

  Loop, read, %cmdFile%
  {
    index := A_Index
    commandArr := []
    Loop, parse, A_LoopReadLine,%A_Tab%`,
    {
      if(A_Index = 1){
        s := Trim(A_LoopField)
        StringLower, s, s
        commandArr.Push(s)
      } else {
        commandArr.Push(Trim(A_LoopField))
      }
    }
    if (!runDoLoop)
      break

    waitUntilTaskbarHidden()
    
    doAction(commandArr, index)

  }
  ;showWindowRefreshed()
  ;showWindow()
  
  return
}

;------------------------------ casRunStopStart ------------------------------
casRunStopStart(){
  
  casRunStop()
  tipWindow("Execution STOP requested!",0,3000,true)
  
  return
}

;-------------------------------- casRunStop --------------------------------
casRunStop(){
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, runCasAfterDelay, runCasAfterDelayStandby
  global errorLevelMemo, downCounter, sleepDownCounter
  global counter, delayDownCounter, likenessCheckLoopLongRun
  
  errorLevelMemo := false
    
  likenessCheckLoopLongRun := false
  setTimer,countDown,delete
  setTimer,casRunAfterDelayCountdown,delete
  setTimer,casRunAfterDelayStandbyCountdown,delete

  downCounter := 0
  sleepDownCounter := 0
  counter := 0
  delayDownCounter := 0
  
  
  runDoLoop := false
  runCas := false
  runCasOnceOnly := false
  runCasStandby := false
  runCasAfterDelay := false
  runCasAfterDelayStandby := false
  
  showWindow()
  
  SetCapsLockState, off
  tipWindow("Capslock released!",0,3000,true)
  
  return
}

;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(posCursor := false){
  global menuHotkey, mouserecordHotkey, xPosActu, yPosActu, defaultMouseSpeed

  prepare()
  
  showWindow()
  
  Gui,guiOpener:Hide
  
  refreshGui()
  
  showMessageDefaultCAS()
  
  if(posCursor){
    MouseMove,xPosActu,yPosActu, %defaultMouseSpeed%
  }
    
  return
}

;-------------------------------- hideWindow --------------------------------
hideWindow(){
  global showOpener
  
  setTimer,checkFocus,delete
  Gui, guiMain:Hide
  
  sleep,1000
  
  if(showOpener){
    a := WinExist("A")
    Gui,guiOpener:Show
    WinActivate, ahk_id %a%
  }
  
  sleep,1000
  
  return
}

;-------------------------- cmdselectSetEntryReset --------------------------
cmdselectSetEntryReset(){
  global listBoxEntry, ListBox1

  listBoxEntry := 1

  GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%

  updateSingleStepButton()
  
  return
}

;--------------------------- showMessageDefaultCAS ---------------------------
showMessageDefaultCAS(){
  global menuHotkey, mouserecordHotkey
  
  msg1 := "Hotkey: " . hotkeyToText(menuHotkey)
  msg2 := " Record-hotkey (on/off): " . hotkeyToText(mouserecordHotkey) . ", off: Right-click"
  
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  resolution := "[" . A_ScreenWidth . " x " . A_ScreenHeight . "]"

  showMessageCAS(msg1, msg2, resolution, memory)
  
  return
}

;------------------------------ showMessageCAS ------------------------------
showMessageCAS(hk1, hk2, reso, memory){

  SB_SetParts(110,380,80)
  SB_SetText(" " . hk1 , 1, 1)
  SB_SetText(" " . hk2 , 2, 1)
  SB_SetText("`t`t" . reso , 3, 2)
  SB_SetText("`t`t" . memory , 4, 2)

  return
}

;----------------------------- cmdselectSetEntry -----------------------------
cmdselectSetEntry(){
  global listBoxEntry, ListBox1

  GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%
  updateSingleStepButton()
  
  return
}
;-------------------------- updateSingleStepButton --------------------------
updateSingleStepButton(){
  global Element3_1, listBoxEntry
  
  GuiControl,guiMain:, Element3_1, Singestep (%listBoxEntry%)
  
  return
}

;------------------------------- showCapslock -------------------------------
showCapslock(){
  
  GuiControl,guiMain:, Element3_11, Capslock is activated, no autorun!
  
  return
}

;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global internalDebug, HMainHwnd, configFile, guiFile
  global windowPosX, windowPosY

  h := WinActive("A")
  Gui +LastFound
  if (HMainHwnd != h){
    hideWindow()
  } else {
    static xOld := 0
    static yOld := 0
    static wOld := 0
    static hOld := 0
    
    X := 0
    Y := 0
    Width := 0
    Height := 0
    Offset_Left := 0
    Offset_Top := 0
    Offset_Right := 0
    Offset_Right := 0

    WinGetPosEx(HMainHwnd,X,Y,Width,Height,Offset_Left,Offset_Top,Offset_Right,Offset_Bottom)
    ;WinGetPos,xn1,yn1,wn1,hn1,A
    xn1 := X - Offset_Left
    yn1 := Y - Offset_Top
    wn1 := Width - Offset_Right
    hn1 := Height - (4 * Offset_Bottom)
    
    if (xOld != xn1 || yOld != yn1 || wOld != wn1 || hOld != hn1){
      ;Tiptop(hn1 . "/" . hOld . "/" . Offset_X1)
      xOld := xn1
      yOld := yn1
      wOld := wn1
      hOld := hn1
      
      if(internalDebug){
        a := "X:" . X . " Y: " . Y . " w: " . Width . " h: " . Height . " Offset_Left: " . Offset_Left . " Offset_Top: " . Offset_Top . " Offset_Right" . Offset_Right . " Offset_Bottom" . Offset_Bottom
        tooltip, %a%
      }
      
      IniWrite, %xn1% , %guiFile%, window, windowPosX
      IniWrite, %yn1%, %guiFile%, window, windowPosY
      
      if(internalDebug)
        Tiptop("Coords saved!")
    }
  }
    
  return
}

;***************************** cmdselectGetEntry *****************************
cmdselectGetEntry(){
  global listBoxEntry, ListBox1

  if(listBoxEntry == 0){
    listBoxEntry := 1
  } else {
    GuiControl,guiMain:+AltSubmit, ListBox1
    GuiControlGet, listBoxEntry,guiMain:, ListBox1
    GuiControl,guiMain:-AltSubmit, ListBox1
  }

  updateSingleStepButton()
  
  if (A_GuiEvent = "DoubleClick"){
    guiAction_singleOp(true)
  }
  
  return
}

;***************************** showErrorMessage *****************************
showErrorMessage(msg){
  global Element3_11

  ; a single line only!
  GuiControl,guiMain:, Element3_11, %msg%
  
  return
}

;**************************** removeErrorMessage ****************************
removeErrorMessage(){
  showErrorMessage("")
  
  return
}

;**************************** guiAction_singleOp ****************************
guiAction_singleOp(showOp := false){
  global cmdSelected, listBoxEntry
  global xPosActu, yPosActu
  
  MouseGetPos, xPosActu, yPosActu
  
  Gui, Submit, NoHide
  singleOp(showOp)
  showWindowRefreshed()
  
  return
}

;------------------------------- editSingleOp -------------------------------
editSingleOp(){
  global cmdSelected, listBoxEntry
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  Gui, Submit, NoHide
  
  singleOpEdit()
  
  showWindowRefreshed()
  
  return
}

;------------------------------- singleOpEdit -------------------------------
singleOpEdit(){
  global cmdFile, hintTimeShort, hintTimeMedium, hintTime
  global runDoLoop, debug

  global allcmdsArr, cmdSelected, listBoxEntry
  
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, runCasAfterDelay, runCasAfterDelayStandby

  cmd:= ""

  if (!runDoLoop && !runCas && !runCasOnceOnly && !runCasStandby && !runCasAfterDelay && !runCasAfterDelayStandby){
    ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)

    if (ok1 != 0){
      cmd := allcmdsArr[key1] ;key1 is used below too!
      
      SetTimer,MoveCursorToEnd,-100
      InputBox,inp,Edit command,,,,100,,,,,%cmd%

      if(!ErrorLevel){
        ;save
        allcmdsArr[key1] := inp
        
        content := ""
        
        l := allcmdsArr.Length()
        
        Loop, %l%
        {
          content := content . allcmdsArr[A_Index] . "`n"
        }

        FileDelete, %cmdFile%
        FileAppend, %content%, %cmdFile%, UTF-8-RAW
        listBoxEntry := key1
        Gui, Input:Destroy
        updateSingleStepButton()
      } else {
        showHint("Edit canceled!", hintTimeMedium)
      }
    }
  } else {
    showHint("Edit is not possible during running operation!", hintTimeMedium)
  }
  
  return
}

;------------------------------ deleteSingleOp ------------------------------
deleteSingleOp(){
  global cmdFile, hintTimeShort, hintTimeMedium, hintTime, debug

  global allcmdsArr, cmdSelected, listBoxEntry
  
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, runCasAfterDelay, runCasAfterDelayStandby
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  Gui, Submit, NoHide

  cmd:= ""

  if (!runDoLoop && !runCas && !runCasOnceOnly && !runCasStandby && !runCasAfterDelay && !runCasAfterDelayStandby){
    ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)

    if (ok1 != 0){
      entryToDelete := 0 + key1
      allcmdsArr.RemoveAt(entryToDelete)

      ;save
      content := ""
      
      allcmdsArrLength := allcmdsArr.Length()
      Loop, % allcmdsArrLength
      {
        content := content . allcmdsArr[A_Index] . "`n"
      }
      FileDelete, %cmdFile%
      FileAppend, %content%, %cmdFile%, UTF-8-RAW

      listBoxEntry := Max(1,listBoxEntry - 1)
      Gui, Input:Destroy
      GuiControl,guiMain:, Element3_1, Singestep (listBoxEntry)
    }
  } else {
    showHint("Delete is not possible during running operation!", hintTimeMedium)
  }
  
  showWindowRefreshed()
  
  return
}

;************************* ToogleComment *************************
ToogleComment(){
  global cmdSelected, xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  Gui, Submit, NoHide
  if (cmdSelected == ""){
    showErrorMessage("Please select a Command-line first!")
  } else {
    singleOpToogleComment()
  }
  
  return
}

;************************* ToogleCommentSemi *************************
ToogleCommentSemi(){
  global cmdSelected, xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  Gui, Submit, NoHide
  if (cmdSelected == ""){
    showErrorMessage("Please select a Command-line first!")
  } else {
    singleOpToogleCommentSemi()
  }
  
  return
}
;*************************** ShowHistory ***************************
ShowHistory(){
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  KeyHistory
  
  return
}

;******************************** getCmdList ********************************
getCmdList(){
  global cmdFile, allcmdsArr
  
  allcmdsArr := []
  r := ""
  Loop, read, %cmdFile%
  {
    line := A_LoopReadLine
    allcmdsArr.Push(line)
    r := r . A_Index . " " . line . "|"
  }
  
  r := SubStr(r,1,-1)
  
  return r
}
; *********************************** openGithubPage ******************************
openGithubPage(){
  global appName
  
  StringLower, name, appName
  Run https://github.com/jvr-ks/%name%
  
  return
}

;******************************* CmdMenu_Close *******************************
CmdMenu_Close(theGui) { ; Declaring this parameter is optional.
  showHint("close",1000)
  
  return true ; true = 1
}

;******************************* openTaskschd *******************************
openTaskschd(){
  p := cvtPath("%windir%")
  Run, %p%\system32\taskschd.msc /s,,max
  
  return
}

;********************************* isRunning *********************************
isRunning(force := false){
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, runCasAfterDelay, runCasAfterDelayStandby
  
  retValue := false
  
  if (!force){
    if (runDoLoop && ( runCas || runCasOnceOnly || runCasStandby || runCasAfterDelay || runCasAfterDelayStandby)){
      retValue := true
    }
  }
  
  return retValue
}

;********************************* singleOp *********************************
singleOp(showOp := false){
  global cmdFile, hintTimeShort, hintTimeMedium
  global runDoLoop, debug, runSingleOp
  global allcmdsArr, cmdSelected, listBoxEntry
  global xPosActu, yPosActu

  commandArr := []

  
  cmd:= ""

  ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)
  
  if (ok1 != 0){
    cmd := allcmdsArr[key1] ;key1 is used below too!

    Loop, parse, cmd,%A_Tab%`,
    {
      if(A_Index == 1){
        s := Trim(Trim(A_LoopField))
        StringLower, s, s
        
        commandArr.Push(s)
      } else {
        commandArr.Push(Trim(A_LoopField))
      }
    }
    
    if (showOp){
      CoordMode, Mouse, Client
      CoordMode, Tooltip, Client
      MouseGetPos, xPosTmp, yPosTmp
      tmpX := xPosTmp + 20
      tmpY := yPosTmp - 10
      tooltip, %cmd%,%tmpX%,%tmpY%,9
    }
    
    hideWindow()
    
    runSingleOp := true
    runDoLoop := true
      
    doAction(commandArr, key1)
    
    if (showOp){
      tooltip,,,,9
    }
    
    runSingleOp := false
    runDoLoop := false
    
    listBoxEntry := key1 + 1
    
    while (eq(SubStr(allcmdsArr[listBoxEntry], 1, 3),"rem") || eq(SubStr(allcmdsArr[listBoxEntry], 1, 1), ";")){
      listBoxEntry := listBoxEntry + 1 ; jump over normal comments (not //)
    }
    
    updateSingleStepButton()
    
    showWindow()
    
    
  }
  
  return
}

;****************************** MoveCursorToEnd ******************************
MoveCursorToEnd(){
  send {End}
  SetTimer,MoveCursorToEnd,delete
  
  return
}

;*************************** singleOpToogleComment ***************************
singleOpToogleComment(){
  global cmdFile, hintTimeShort, hintTimeMedium
  global runDoLoop, debug, runSingleOp
  global allcmdsArr, cmdSelected, listBoxEntry, ListBox1, Lb1

  commandArr := []
  
  cmd:= ""

  ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)
  
  if (ok1 != 0){
    hasComment := false
    guiCmd := Trim(A_GuiControl)

    if (SubStr(Trim(allcmdsArr[key1]),1,2) == "//")
      hasComment := true
    
    if (hasComment){
      allcmdsArr[key1] := SubStr(allcmdsArr[key1],3) ; remove "//"
    } else {
      allcmdsArr[key1] := "//" . allcmdsArr[key1] ; add "//"
    }

    content := ""
    
    Loop, % allcmdsArr.Length()
    {
      content := content . allcmdsArr[A_Index] . "`n"
    }

    FileDelete, %cmdFile%
    FileAppend, %content%, %cmdFile%, UTF-8-RAW
    listBoxEntry := key1
    
    position := listBoxEntry - 1
    SendMessage, (LB_DELETESTRING:=0x182),%position%,0,, ahk_id %Lb1%
    String := listBoxEntry . " " . allcmdsArr[listBoxEntry]
    SendMessage, (LB_INSERTSTRING:=0x181),%position%,&String,, ahk_id %Lb1%
    
    GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%
    updateSingleStepButton()
  }
  
  return
}

;*************************** singleOpToogleCommentSemi ***************************
singleOpToogleCommentSemi(){
  global cmdFile, hintTimeShort, hintTimeMedium
  global runDoLoop, debug, runSingleOp
  global allcmdsArr, cmdSelected, listBoxEntry
  global Lb1

  commandArr := []
  
  cmd:= ""

  ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)
  
  if (ok1 != 0){
    hasComment := false
    guiCmd := Trim(A_GuiControl)

    if (SubStr(Trim(allcmdsArr[key1]),1,1) == ";")
      hasComment := true
    
    if (hasComment){
      allcmdsArr[key1] := SubStr(allcmdsArr[key1],2) ; remove ";"
    } else {
      allcmdsArr[key1] := ";" . allcmdsArr[key1] ; add ";"
    }

    content := ""
    
    Loop, % allcmdsArr.Length()
    {
      content := content . allcmdsArr[A_Index] . "`n"
    }

    FileDelete, %cmdFile%
    FileAppend, %content%, %cmdFile%, UTF-8-RAW
    listBoxEntry := key1
    
    position := listBoxEntry - 1
    SendMessage, (LB_DELETESTRING:=0x182),%position%,0,, ahk_id %Lb1%
    String := listBoxEntry . " " . allcmdsArr[listBoxEntry]
    SendMessage, (LB_INSERTSTRING:=0x181),%position%,&String,, ahk_id %Lb1%
    
    GuiControl,guiMain:Choose, ListBox1, %listBoxEntry%
    updateSingleStepButton()
  }
  
  return
}

;**************************** casRunStartRepeated ****************************
casRunStartRepeated(continue := false){
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby
  
  global hintTimeMedium, downCounter, repeatTime, repeatCounterStart, repeatCounter, errorLevelMemo
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  errorLevelMemo := false
  
  repeatCounter := repeatCounterStart
  if(repeatCounter >= 0){
    if (!continue && isRunning()){
      showOpRunning()
    } else {
      runDoLoop := true
      runCas := true
      
      casRunOnce()
      repeatCounter -= 1
      if (repeatCounter > 0){
        downCounter := repeatTime
        setTimer,countDown,delete
        setTimer,countDown,1000
      } else {
        setTimer,countDown,delete
        casRunStop()
        tipWindow("Finished!",0,30000,true)
        showWindow()
      }
    }
  } else {
    setTimer,countDown,delete
    casRunStop()
    tipWindow("Repeat-counter is zero!")
    showWindow()
  }
  
  return
}

;--------------------------------- countDown ---------------------------------
countDown(){
  global hintTime, downCounter
  global runCas, runCasOnceOnly, repeatTime, repeatCounter, repeatCounterStart


  switch getKeyboardState()
  {
    case 0:
      downCounter -= 1
      
      tipWindow("Countdown: " . formatTimeSeconds(downCounter) . " (" . repeatCounter . ")",150,0,false)
      Gui, guiMain:Hide
      
      if(downCounter < 1){
        if (runCasOnceOnly){
          setTimer,countDown,delete
          casRunOnce()
          casRunStop()
        }
        if (runCas){
          setTimer,countDown,delete
          casRunOnce()
          downCounter := repeatTime
          
          repeatCounter -= 1
          if (repeatCounter > 0){
            setTimer,countDown,delete
            setTimer,countDown,1000
          } else {
            setTimer,countDown,delete
            casRunStop()
            tipWindow("Finished!",0,30000,true)
            showWindow()
          } 
        }
      }

    case 1:
      tipWindow("Hold on!",150,0,false)
    case 5:
      setTimer,countDown,delete
      casRunStop()
      tipWindow("All operations aborted!",0,2000)
      
      showWindow()
  }

  return
}

;******************************* casRunStandby *******************************
casRunStandby(continue := false){
  global runDoLoop, runCas, runCasOnceOnly, runCasStandby, repeatCounterStart, repeatCounter
  
  global hintTime, hintTimeMedium, downCounter, repeatTime, systemNeededMillisToShutdown, errorLevelMemo, cancelShutdown
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  if (!A_IsAdmin){
    msgbox, ERROR, no Admin, cannot run in Standby Mode!
    showWindow()
    
    return
  }
  
  errorLevelMemo := false
  
  repeatCounter := repeatCounterStart
  if(repeatCounter >= 0){
  
    if (!continue && isRunning()){
      showOpRunning()
    } else {
      runDoLoop := true
      runCasStandby := true
      
      casRunStandbyLoop:
      Loop
      {

        switch getKeyboardState()
        {
          case 0:
            casRunOnce()
            
            activateWakeup()  
            if (!cancelShutdown){
              sleep, systemNeededMillisToShutdown ; give time to sleep
              
              ; back from sleep or cancel shutdown
              showHint("Wakeup!", 10000)
              waitUntilCorrectTime()
            } else {
              casRunStop()
              tipWindow("Operation aborted!",0,2000)
              showWindow()
              break casRunStandbyLoop
            }

          case 3,5:
            casRunStop()
            tipWindow("Operation aborted!",0,2000)
            showWindow()
            break casRunStandbyLoop
        }
      }
    }
  } else {
    casRunStop()
    tipWindow("Repeat-counter is zero!")
    showWindow()
  }
  
  return
}

;*************************** waitUntilCorrectTime ***************************
waitUntilCorrectTime(){
  global runDoLoop, hintTime, hintTimeMedium, startTime, repeatTime, counter
  
  t := A_TickCount
  
  if (t < (startTime + (repeatTime * 1000))){
    secondsToWait := ((startTime + (repeatTime * 1000)) - t)//1000

    counter := secondsToWait
    
    waitUntilCorrectTimeLoop:
    Loop, %secondsToWait%
    {
      switch getKeyboardState()
      {
        case 0:
          counter -= 1
          if (counter < 0){
            return
          }
          
          tipWindow("Wakeup early, waiting: " . formatTimeSeconds(counter),0,0,false)
        case 1:
          tipWindow("Wakeup early, (hold on): " . formatTimeSeconds(counter),0,0,false)
        case 3:
          tipWindow("Wakeup early waiting finished by user interaction!",0,2000)
          break waitUntilCorrectTimeLoop
        case 5:
          casRunStop()
          tipWindow("Operation aborted!",0,2000)
          showWindow()
          return
      }
      sleep, 1000
    }
  }

  return
}

;***************************** casRunAfterDelay *****************************
casRunAfterDelay(){
  global runDoLoop, hintTimeMedium, runCasAfterDelay
  global delayDownCounter, delayTime, errorLevelMemo
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  errorLevelMemo := false
  
  if (isRunning()){
    showOpRunning()
  } else {
    runDoLoop := true
    runCasAfterDelay := true
    
    delayDownCounter := delayTime 
    setTimer,casRunAfterDelayCountdown,delete
    setTimer,casRunAfterDelayCountdown,1000
    hideWindow()
  }
  
  return
}

;************************* casRunAfterDelayCountdown *************************
casRunAfterDelayCountdown(){
  global runDoLoop, downCounter, runCas, runCasOnceOnly, delayTime, runCasAfterDelay, delayDownCounter, hintTime, repeatTime, errorLevelMemo, runDoLoop
  
  errorLevelMemo := false
  
  if (runCasAfterDelay){
  
    switch getKeyboardState()
    {
      case 0:
        delayDownCounter := delayDownCounter - 1
        msg := "Until Start: " . formatTimeSeconds(delayDownCounter)
        tipWindow(msg,150,0,false)
      case 1:
        msg := "Until Start (hold on): " . formatTimeSeconds(delayDownCounter)
        tipWindow(msg,150,0,false)
      case 3:
        tipWindow("Wait until start finished by user interaction!",0,2000)
        delayDownCounter := 0
      case 5:
        casRunStop()
        tipWindow("Operation aborted!",0,2000)
        showWindow()
    }

    if(delayDownCounter <= 0){
      
      runCasAfterDelay := false
      setTimer,casRunAfterDelayCountdown,delete
      setTimer,countDown,delete
      
      casRunStartRepeated(true)
    }
  }
  
  return
}

;************************** casRunAfterDelayStandby **************************
casRunAfterDelayStandby(){
  global runDoLoop, hintTimeMedium, runCasAfterDelayStandby, delayDownCounter, delayTime
  global errorLevelMemo
  global xPosActu, yPosActu
  
  global repeatCounterStart, repeatCounter

  MouseGetPos, xPosActu, yPosActu
  
  if (!A_IsAdmin){
    msgbox, ERROR, no Admin, cannot run in Standby Mode!
    showWindow()
    
    return
  }
  
  errorLevelMemo := false
  
  repeatCounter := repeatCounterStart
  if(repeatCounter >= 0){
    if (isRunning()){
      showOpRunning()
    } else {
    
      repeatCounter -= 1
      if (repeatCounter > 0){
        runDoLoop := true
        runCasAfterDelayStandby := true
        
        delayDownCounter := delayTime 
        setTimer,casRunAfterDelayStandbyCountdown,delete
        setTimer,casRunAfterDelayStandbyCountdown,1000
        hideWindow()
      } else {
        setTimer,casRunAfterDelayStandbyCountdown,delete
        casRunStop()
        tipWindow("Finished!",0,30000,true)
        showWindow()
      }
    }
  } else {
    setTimer,casRunAfterDelayStandbyCountdown,delete
    casRunStop()
    tipWindow("Repeat-counter is zero!")
    showWindow()
  }
    
  return
}

;********************* casRunAfterDelayStandbyCountdown *********************
casRunAfterDelayStandbyCountdown(){
  global downCounter, runCasStandby, runCasAfterDelayStandby
  global delayDownCounter, runDoLoop
  
  if (runCasAfterDelayStandby){
  
    switch getKeyboardState()
    {
      case 0:
        delayDownCounter := delayDownCounter - 1
        msg := "Until Start (with standby): " . formatTimeSeconds(delayDownCounter)
        tipWindow(msg,150,0,false)
      case 1:
        
        msg := "Until Start (with standby) (hold on): " . formatTimeSeconds(delayDownCounter)
        tipWindow(msg,150,0,false)
      case 3:
        tipWindow("Wait until start (with standby) finished by user interaction!",0,2000)
        delayDownCounter := 0
      case 5:
        casRunStop()
        tipWindow("Operation aborted!",0,2000)
        showWindow()
        return
    }
  
    if(delayDownCounter <= 0){
      
      runCasAfterDelayStandby := false

      setTimer,casRunAfterDelayStandbyCountdown,delete
      
      casRunStandby(true)
    } else {
      setTimer,casRunAfterDelayStandbyCountdown,delete
      setTimer,casRunAfterDelayStandbyCountdown,-1000
    }
  }
  
  return
}

;******************************* enterInterval *******************************
enterInterval(){
  global repeatTime, configFile, Element3_4
  
  ;InputBox, inp , Edit command, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default
  InputBox, delaySeconds, Repeat-Delay, Please enter interval in seconds:,,,120,,,,,%repeatTime%
  if(!ErrorLevel){
    repeatTime := delaySeconds
    IniWrite, %repeatTime%, %configFile%, timing, repeatTime
  }
  timeInterval := formatTimeSeconds(repeatTime)

  GuiControl,guiMain:, Element3_4, [%timeInterval%]
  
  showWindow()
  
  return
}

;****************************** enterWaitDelay ******************************
enterWaitDelay(){
  global delayTime, configFile, Element3_6
  
  InputBox, delaySeconds, Delay time first run, Please enter delay in seconds:,,,120,,,,,%delayTime%
  if(!ErrorLevel) {
    delayTime := delaySeconds
    IniWrite, %delayTime%, %configFile%, timing, delayTime
  }
  timeDelay := formatTimeSeconds(delayTime)
  GuiControl,guiMain:, Element3_6, [%timeDelay%]
  
  showWindow()

  return
}

;-------------------------------- enterCount --------------------------------
enterCount(){
  global repeatCounterDefault, repeatCounterStart

  global repeatTime, configFile, Element3_13
  
  InputBox, repeatCounterIn, Repeat-count, Please enter Repeat-count:,,,120,,,,,%repeatCounterStart%
  if(!ErrorLevel){
    repeatCounterStart := repeatCounterIn
    IniWrite, %repeatCounterStart%, %configFile%, config, repeatCounterStart
  }

  GuiControl,guiMain:, Element3_13, [%repeatCounterStart%]
  
  showWindow()
  
  return
}

;------------------------------ mouserecordOnce ------------------------------
mouserecordOnce(){
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  hideWindow()
  
  Hotkey, *LBUTTON, mouserecordClickOnce, ON
  
  return
}

;-------------------------------- mouserecordToggle --------------------------------
mouserecordToggle(){
  
  static mouseRecordRunning := false
  
  mouseRecordRunning := mouseRecordRunning ? false : true
  
  hideWindow()
  
  if (mouseRecordRunning){
    Hotkey, *LBUTTON, mouserecordClick, ON
    Hotkey, *RBUTTON, mouserecordStop, ON
    tipWindow("Mouse-record active now, click-right or press hotkey again to finish!",0,180,true)
  } else {
    mouserecordStop()
    tipWindowClose()
  }
  
  return
}

;------------------------------ mouserecordStop ------------------------------
mouserecordStop(){

  Hotkey, *LBUTTON, mouserecordClick, OFF
  Hotkey, *RBUTTON, mouserecordStop, OFF
  
  showWindowRefreshed()
  
  return
}

;--------------------------- mouserecordClickOnce ---------------------------
mouserecordClickOnce(){
  mouserecordClick(true)

  return
}

;----------------------------- mouserecordClick -----------------------------
mouserecordClick(onlyOnce := false){

  global cmdFile, hintTimeShort, hintTime
  
  Hotkey, *LBUTTON, mouserecordClick, OFF
  Hotkey, *RBUTTON, mouserecordStop, OFF
  
  
  doubleClick := false
  if (getKeyboardState() == 8){
    doubleClick := true
  }
  
  CoordMode, Mouse , Client
  MouseGetPos, posX, posY
  
  clickModifier := getKeyboardState()
  
  switch clickModifier
  {
  case 4:
    ; Ctrl
    ;integrate colors over 20 x 16 px region
    deltaX := 20 ;only even allowed!
    deltaY := 16 ;only even allowed!
    samplepoints := deltaX * deltaY
    
    sumR := 0
    sumG := 0
    sumB := 0
    xpos := posX - deltaX/2
    ypos := posY - deltaY/2
    
    tipWindow("Calculating, please be patient ...", 0, 3000, true)
    
    Loop, %deltaY%
    {
      y := ypos + A_Index
      
      Loop, %deltaX%
      {
        x := xpos + A_Index
        
        cl := 0
        PixelGetColor, cl, %x%, %y%, RGB
        cs := "" cl
        rR := BaseToDec(SubStr(cs,3,2), 16)
        rG := BaseToDec(SubStr(cs,5,2), 16)
        rB := BaseToDec(SubStr(cs,7,2), 16)
        
        sumR := rR + sumR
        sumG := rG + sumG
        sumB := rB + sumB
      }
    }

    sumR := Floor(sumR/samplepoints)
    sumG := Floor(sumG/samplepoints)
    sumB := Floor(sumB/samplepoints)
    
    likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
    
    FileAppend , `mouseClickLikeness`,%posX%`,%posY%`,%likeness%`n, %cmdFile%, UTF-8-RAW
    tipWindow("Last recorded likeness-value was: " . likeness . " calculating, please be patient ...", 0, 3000, true)
    sleep, 3000
    
  case 8:
    ; Shift
    ;Fast: integrate colors over 8 x 8 px region
    deltaX := 8 ;only even allowed!
    deltaY := 8 ;only even allowed!
    samplepoints := deltaX * deltaY
    
    sumR := 0
    sumG := 0
    sumB := 0
    xpos := posX - deltaX/2
    ypos := posY - deltaY/2
    
    Loop, %deltaY%
    {
      y := ypos + A_Index
      
      Loop, %deltaX%
      {
        x := xpos + A_Index
        
        cl := 0
        PixelGetColor, cl, %x%, %y%, RGB
        cs := "" cl
        rR := BaseToDec(SubStr(cs,3,2), 16)
        rG := BaseToDec(SubStr(cs,5,2), 16)
        rB := BaseToDec(SubStr(cs,7,2), 16)
        
        sumR := rR + sumR
        sumG := rG + sumG
        sumB := rB + sumB
      }
    }

    sumR := Floor(sumR/samplepoints)
    sumG := Floor(sumG/samplepoints)
    sumB := Floor(sumB/samplepoints)
    
    likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
    
    FileAppend , `mouseClickLikenessFast`,%posX%`,%posY%`,%likeness%`n`n, %cmdFile%, UTF-8-RAW
    tipWindow("Last recorded likenessFast-value was: " . likeness, 0, 3000, true)
    sleep, 3000
      
  Default:
    ; no modifier key
    if (doubleClick)
      FileAppend , `mousedblClick`,%posX%`,%posY%`n, %cmdFile%, UTF-8-RAW
    else
      FileAppend , `mouseClick`,%posX%`,%posY%`n, %cmdFile%, UTF-8-RAW
    
  }
  
  tipWindow("Recorded: posX=" posX " posY=" posY, 0, 3000, true)
  sleep, 3000
  
  if (doubleClick){
    Click, 2
  } else {
    Click
  }
  
  if(!onlyOnce){
    Hotkey, *LBUTTON, mouserecordClick, ON
    Hotkey, *RBUTTON, mouserecordStop, ON
    tipWindow("Please move mouse to next position now!", 0, 3000, true)
  } else {
    showWindowRefreshed()
  }
  
  return
}

;------------------------------ fileInsertEmpty ------------------------------
fileInsertEmpty() {
  global listBoxEntry, cmdFile
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  content := ""
    
  Loop, read, %cmdFile%
  {
    if (A_Index == listBoxEntry)
      content := content . "`n"
    
    content := content . A_LoopReadLine . "`n"
  }
  
  FileDelete %cmdFile%
  FileAppend , %content%, %cmdFile%, UTF-8-RAW
  
  
  showWindowRefreshed()
  
  return
}

;------------------------------ fileAppendEmpty ------------------------------
fileAppendEmpty() {
  global listBoxEntry, cmdFile
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  content := ""
    
  Loop, read, %cmdFile%
  {
    content := content . A_LoopReadLine . "`n"
    
    if (A_Index == listBoxEntry)
      content := content . "`n"
  }
  
  FileDelete %cmdFile%
  FileAppend , %content%, %cmdFile%, UTF-8-RAW
  
  
  showWindowRefreshed()
  
  return
}

;******************************** editCmdFile ********************************
editCmdFile() {
  global wrkDir, cmdFile, configFile, notepadpath, notepadpathDefault
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu

  showErrorMessage("Please close the editor before continuing!")
  f := notepadpath . " " . cmdFile
  runWait %f%,,max

  removeErrorMessage()
  
  showWindowRefreshed()
  
  return
}

;******************************** editconfigFile ********************************
editconfigFile() {
  global configFile, notepadpath, appName, bitName

  f := notepadpath . " " . configFile
  runWait %f%,,max
  
  removeErrorMessage()
  
  showWindowRefreshed()
  
  showHint(appName . bitName . " restarts now!",2000)
  restartAppNoupdate()
  
  return
}

; *********************************** hotkeyToText ******************************
; in Lib
; *********************************** hkToDescription ******************************
; in Lib

;****************************** activateWakeup ******************************
activateWakeup(){
  global wrkDir, wakeUpFile, hintTime, hintTimeShort
  global appName, repeatTime, wakeupbeforeeMinutes
  global configFile, wakeupDateTime
  global downCounterShutdown, cancelShutdown
    
  StringLower, appn, appName
  exeToRun := wrkDir . appn . ".exe"
  ;exeToRun := ""

  if (FileExist(wakeUpFile))
    FileDelete %wakeUpFile%
  
  wakeupDateTime := A_now
  
  hoursInterval := SubStr("0" . (repeatTime // 3600), -1)
  minutesInterval := SubStr("0" . ((repeatTime - hoursInterval * 3600) // 60), -1)
  secondsInterval := SubStr("0" . (Mod(repeatTime, 60)), -1)
  
  FormatTime, regDateTime , %wakeupDateTime%, yyyy-MM-ddTHH:mm:ss.0
  
  if (repeatTime < 300){
    showHint("Minimum sleep-interval is 5 minutes. Interval set to 5 minutes!", hintTimeShort)
    minutesInterval := 5
  }
  
  wakeupDateTime += hoursInterval, Hours
  wakeupDateTime += (minutesInterval - wakeupbeforeeMinutes), Minutes
  wakeupDateTime += secondsInterval, Seconds
  
  FormatTime, wakeupAt , %wakeupDateTime%, yyyy-MM-ddTHH:mm:ss
  FormatTime, wakeupAtShow , %wakeupDateTime%, yyyy-MM-dd HH:mm:ss
  
  sid := getSid()
  username := A_UserName

FileAppend,
(
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>%regDateTime%</Date>
    <Author>%username%</Author>
    <URI>\wakeup</URI>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <StartBoundary>%wakeupAt%</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>%sid%</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>true</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>%exeToRun%</Command>
    </Exec>
  </Actions>
</Task>

), %wakeUpFile%, CP1200
  
  downCounterShutdown := 20
  tipWindow("Last chance to holdon/cancel Shutdown/Wakeup, press [Capslock] within " . downCounterShutdown . " seconds!",0,0,true)
  
  cancelShutdown := false
  countDownShutdown()
  

  if (!cancelShutdown){
    task := A_ComSpec . " /c " .  "C:\Windows\System32\schtasks.exe /Create /TN wakeup /XML " . wrkDir . wakeUpFile . " /F"
    
    showHint("Wakeup will be at: " . wakeupAt,8000)
    sleep,8000
    Run %task%

    showHint("Wakeup task ""wakeup"" created`, running at: " . wakeupAtShow . "`, activating SLEEP now!", hintTime)
    sleep, %hintTime%
    activateStandby()
  }
  
  return
}

;****************************** activateStandby ******************************
activateStandby(){
  global wrkDir, startTime, hintTime, wakeUpFile
  
  startTime := A_TickCount
  
  showHint("Goto sleep!", hintTime)
  DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)

  return
}

;***************************** countDownShutdown *****************************
countDownShutdown(){
  global hintTime, downCounterShutdown, runCas, runCasOnceOnly
  global repeatTime, wrkDir, wakeUpFile
  global cancelShutdown

  tipWindow("",0,0,true)
  countDownShutdownLoop:
  Loop
  {
    switch getKeyboardState()
    {
      case 0:
        downCounterShutdown := downCounterShutdown - 1
        s := "Shutdown in: " . formatTimeSeconds(downCounterShutdown)
        tipWindow(s,150,0,false)
      case 1:
        tipWindow("Shutdown in (hold on), press Ctrl to cancel shutdown, Alt to immediately start shutdown: " . formatTimeSeconds(downCounterShutdown),150,0,false)
      case 3:
        tipWindow("Shutdown wait finished by user, immediate shutdown now!",0,2000)
        downCounterShutdown := 0
        Break countDownShutdownLoop
      case 5:
        tipWindow("Shutdown canceled by user, no shutdown, direct goto wakeup!",0,2000)
        cancelShutdown := true
        Break countDownShutdownLoop
    }

    if(downCounterShutdown <= 0){
      Break countDownShutdownLoop
    }
    
    sleep,1000
  }
  
  return
}

;********************************** getSid **********************************
getSid(){
  r := "not found!"
  Loop, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, 2
  if (A_LoopRegType = "key" && StrLen(A_LoopRegName) > 20){
    r := A_LoopRegName
  }
  
  return r
}

;****************************** showpixelcolor ******************************
showpixelcolor(){
  MouseGetPos, xpos, ypos
  PixelGetColor, cl, xpos, ypos , Slow RGB
  tipWindow(cl,0,3000,true)
  
  return
}

;********************************** cvtPath **********************************
cvtPath(s){
  r := s
  pos := 0

  While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
    a := match.1
    r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
  }
  
  return r
}

;****************************** envVariConvert ******************************
envVariConvert(s){
  r := s
  if (InStr(s,"%")){
    s := StrReplace(s,"`%","")
    EnvGet, v, %s%
    Transform, r, Deref, %v%
  }

  return r
}

;********************************** loadset **********************************
loadset(){
  global wrkDir, cmdFile, configFile
  global xPosActu, yPosActu

  MouseGetPos, xPosActu, yPosActu
  
  FileSelectFile, path, 1, %wrkDir%, Loadset a Command/Config-file pair, Command-file (*.txt)
  found := false

  if (ErrorLevel == 0){
    cmdFile := path
    found := true
    
    inif := StrReplace(path,".txt",".ini")

    if (FileExist(inif) != ""){
      configFile := inif
    } else {
      showErrorMessage("Active Config-file not changed!")
      sleep,2000
    }
  } else {
    showErrorMessage("Active Command-file not changed!")
    sleep,4000
  }
  
  if (found){
    setTimer,cmdselectSetEntryReset,delete
    setTimer,cmdselectSetEntryReset,-1000
    showWindowRefreshed()
  }
  
  return
}

;-------------------------- waitUntilTaskbarHidden --------------------------
waitUntilTaskbarHidden(){
  TaskbarHiddenCounter := 0

  checkloop:
  loop
  {
    WinGetPos, , Y, , Height, ahk_class Shell_TrayWnd
    If (Y = (A_ScreenHeight-Height)){
      sleep,3000
      TaskbarHiddenCounter += 1
      CoordMode, Mouse, Screen
      click,0 0
      CoordMode, Mouse, Client
      if(TaskbarHiddenCounter > 10)
        break checkloop
    } else {
      break checkloop
    }
  }
  
  return
}

;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global wrkdir, appname, bitName, appextension

  updaterExeVersion := "updater" . bitName . appextension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found, using old update mechanism is deprecated, please reinstall the app!
    ; updateApp()
  }
  
  showWindow()

  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  return r
}
;----------------------------- startCheckUpdate -----------------------------
startCheckUpdate(){
  
  checkUpdate()
  showWindow()
  
  return
}
;*********************************** exit ***********************************
exit(){
  global app, hintTimeShort

  casRunStop()
  Gui, guiMain:Destroy
  showHint("""" . app . """ removed from memory!", hintTimeShort)
  ToolTip
  tipWindowClose()
  
  ExitApp
}
;----------------------------------------------------------------------------


