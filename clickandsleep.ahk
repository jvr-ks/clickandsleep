/*
 *********************************************************************************
 * 
 * clickandsleep.ahk
 * 
 * 
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *********************************************************************************
*/
; Attention: Spaghetti-Code! :-)
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

#include %A_ScriptDir%\Lib\additions.ahk
#include %A_ScriptDir%\Lib\ahk_common.ahk

OwnPID := DllCall("GetCurrentProcessId")

FileEncoding, UTF-8-RAW
activeWin := 0

;  doAction():
#Include, %A_ScriptDir%\cascommands.ahk

; *********************************** prepare *******************************
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

wrkDir := A_ScriptDir . "\"

DetectHiddenText, On
CoordMode, ToolTip, Screen

pid := "unknown"
debug := false
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

cmdSelected := ""
listBoxEntry := 1

xPosSave := 0
yPosSave := 0

tipOffsetDeltaXDefault := 200
tipOffsetDeltaX := tipOffsetDeltaXDefault

; *********************************** constants ****************************
appName := "ClickAndSleep"
appVersion := "0.293"
app := appName . " " . appVersion
iniFile := "clickandsleep.ini"
cmdFile := "clickandsleep.txt"
notepadpathDefault := "C:\Program Files\Notepad++\notepad++.exe"
emailpathDefault := "C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe"
chromeDefault := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
firefoxDefault := "C:\Program Files\Mozilla Firefox\firefox.exe"
recordlikelinessDefault:= "ON"
quot := """"
edgeDefault := quot . "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" . quot . "--profile-directory=Default"

DetectHiddenWindows, On
winArr := []
allcmdsArr := []

; overwritten by ini-file
notepadpath := notepadpathDefault
emailpath := emailpathDefault
recordlikeliness := recordlikelinessDefault

dpiScale := "on"

fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 10
fontsize := fontsizeDefault

linesInListDefault := 22
linesInList := linesInListDefault

chrome := chromeDefault
firefox := firefoxDefault
edge := edgeDefault

wakeUpFile := "wakeup.xml"

scriptcoordinateX := A_ScreenWidth
scriptcoordinateY := A_ScreenHeight

scaleX := 1
scaleY := 1
				
wakeupbeforeeMinutesDefault := 5
wakeupbeforeeMinutes := wakeupbeforeeMinutesDefault

startTime := A_TickCount

repeattimeDefault := 7800 ;2h10m
repeatTime := repeattimeDefault

delayTimeDefault := 300 ; 5 minutes
delayTime := delayTimeDefault

systemNeededMillisToShutdownDefault := 30000
systemNeededMillisToShutdown := systemNeededMillisToShutdownDefault

defaultShowTimeDefault := 4000
defaultShowTime := defaultShowTimeDefault

wakeupDateTime := 0

menuhotkeyDefault := "!q"
menuhotkey := menuhotkeyDefault

exithotkeyDefault := "+!q"
exithotkey := exithotkeyDefault

mouserecordHotkeyDefault :="^!q"
mouserecordHotkey := mouserecordHotkeyDefault

runCas := false
runCasOnceOnly := false
runCasStandby := false
runCasAfterDelay := false
runCasAfterDelayStandby := false

autorun := "off"

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

msgDefault := ""

; ********** mouse mode
CoordMode, ToolTip, Screen
CoordMode, Mouse, Screen

; **********  read param
hasParams := A_Args.Length()

if (hasParams == 1){
	if(A_Args[1] = "remove"){
		showHint("Removed!", 1000)
		ExitApp
	}
	
	cmdFile := A_Args[1]
	FoundPos := InStr(cmdFile, ".txt")
	if (FoundPos < 1){
		msgbox, Incorrect Command-file extension, exiting app!
		ExitApp
	}
}
	
if (hasParams == 2){
	cmdFile := A_Args[1]
	iniFile := A_Args[2]
	
	FoundPos := InStr(cmdFile, ".txt")
	if (FoundPos < 1){
		msgbox, Incorrect Command-file extension, exiting app!
		ExitApp
	}
	
	FoundPos := InStr(iniFile, ".ini")
	if (FoundPos < 1){
		msgbox, Incorrect Configuration-file extension, exiting app!
		ExitApp
	}
}

cmdFile := resolvepath(wrkDir,cmdFile)
iniFile := resolvepath(wrkDir,iniFile)

Text1 := ""
Text2 := ""
Text3 := ""
Text4 := ""
Text5 := ""
Lb1 := 0

; ********** autorun
if (getKeyboardState() != 1){
;Capslock is off
	IniRead, autorun, %iniFile%, run, autorun , "off"
		
	switch autorun
	{
	case "runOnce":
		mainWindow()
		casRunStartOnceOnly()
	case "runRepeated":
		mainWindow()
		casRunStartRepeated()
	case "runAfterDelay":
		mainWindow()
		casRunAfterDelay()
	case "runStandby":
		mainWindow()
		casRunStandby()
	case "runAfterDelayStandby":
		mainWindow()
		casRunAfterDelayStandby()
	case "off":
		mainWindow()
	default:
		mainWindow()
	}
} else {
	msgbox, Capslock is activated, no autorun!
	mainWindow()
}

return
;************************************ eq ************************************
eq(a, b) {
	if (InStr(a, b) && InStr(b, a))
		return 1
	return 0
}
;****************************** defaultMousePos ******************************
defaultMousePos(){ ; not used
	; Move to menuposition
	WinGetPos, winTopL_x, winTopL_y, width, height, A
	winCenter_x := winTopL_x + width/2
	;winCenter_y := winTopL_y + height/2
	MouseMove, winCenter_x - 500, 100, 0
	;DllCall("SetCursorPos", int, winCenter_x, int, winCenter_y)
	return
}
;********************************** readIni **********************************
readIni(){
	global repeatTime
	global repeattimeDefault
	global delayTime
	global delayTimeDefault
	global wakeupbeforeeMinutesDefault
	global wakeupbeforeeMinutes
	global defaultShowTimeDefault
	global defaultShowTime
	global menuHotkey
	global menuhotkeyDefault
	global exitHotkey
	global exithotkeyDefault
	global menuhotkeyDefault
	global mouserecordHotkey
	global mouserecordhotkeyDefault
	global hintTimeShort
	global hintTimeShortDefault
	global hintTimeMedium
	global hintTimeMediumDefault
	global hintTime
	global hintTimeDefault
	global hintTimeLong
	global hintTimeLongDefault
	global iniFile
	global autorun
	global notepadpath
	global notepadpathDefault
	global emailpath
	global emailpathDefault
	global systemNeededMillisToShutdown
	global systemNeededMillisToShutdownDefault
	global recordlikelinessDefault
	global recordlikeliness
	global chrome
	global chromeDefault
	global firefox
	global firefoxDefault
	global edge
	global edgeDefault
	global tipOffsetDeltaX
	global fontDefault
	global font
	global fontsizeDefault
	global fontsize
	global linesInListDefault
	global linesInList
	
	IniRead, autorun, %iniFile%, run, autorun , "off"
	
	IniRead, tipOffsetDeltaX, %iniFile%, run, tipOffsetDeltaX , tipOffsetDeltaXDefault
	
	IniRead, recordlikeliness, %iniFile%, run, recordlikeliness , recordlikelinessDefault
	
	IniRead, repeatTime, %iniFile%, timing, repeatTime, %repeattimeDefault%
	
	IniRead, delayTime, %iniFile%, timing, delayTime, %delaytimeDefault%
	
	IniRead, wakeupbeforeeMinutes, %iniFile%, timing, wakeupbeforeeMinutes, %wakeupbeforeeMinutesDefault%
	
	IniRead, defaultShowTime, %iniFile%, timing, defaultShowTime, %defaultShowTimeDefault%
	
	IniRead, systemNeededMillisToShutdown, %iniFile%, timing, systemNeededMillisToShutdown, %systemNeededMillisToShutdownDefault%
	
	IniRead, menuHotkey, %iniFile%, hotkeys, menuHotkey, %menuhotkeyDefault%
	if (InStr(menuHotkey, "off") > 0){
		s := StrReplace(menuHotkey, "off" , "")
		Hotkey, %s%, showWindowRefreshed, off
	} else {
		Hotkey, %menuHotkey%, showWindowRefreshed
	}

	IniRead, exitHotkey, %iniFile%, hotkeys, exitHotkey, %exithotkeyDefault%
	if (InStr(exitHotkey, "off") > 0){
		s := StrReplace(exitHotkey, "off" , "")
		Hotkey, %s%, exit, off
	} else {
		Hotkey, %exitHotkey%, exit
	}

	IniRead, mouserecordHotkey, %iniFile%, hotkeys, mouserecordhotkey , %mouserecordhotkeyDefault%
	Hotkey, %mouserecordHotkey%, mouserecordToggle

	IniRead, font, %iniFile%, config, font, %fontDefault%
	IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
	
	IniRead, linesInList, %iniFile%, config, linesInList, %linesInListDefault%
	
	IniRead, hintTimeShort, %iniFile%, timing, hintTimeShort , %hintTimeShortDefault%
	IniRead, hintTimeMedium, %iniFile%, timing, hintTimeMedium , %hintTimeMediumDefault%
	IniRead, hintTime, %iniFile%, timing, hintTime , %hintTimeDefault%
	IniRead, hintTimeLong, %iniFile%, timing, hintTimeLong , %hintTimeLongDefault%
	
	IniRead, notepadpath, %iniFile%, external, notepadpath, %notepadpathDefault%
	IniRead, emailpath, %iniFile%, external, emailpath, %emailpathDefault%
	
	IniRead, chrome, %iniFile%, external, chrome, %chromeDefault%
	IniRead, firefox, %iniFile%, external, firefox, %firefoxDefault%
	IniRead, edge, %iniFile%, external, edge, %edgeDefault%
	
	return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(){
	global menuHotkey
	global mouserecordHotkey
	global msgDefault
	global OwnPID

	readIni()
	
	showWindow()
	refreshGui()
	
	mem := GetProcessMemoryUsage(OwnPID) " MB"
	showHotkeyText := hotkeyToText(menuHotkey)
	mrhk := " Record-hotkey: " . hotkeyToText(mouserecordHotkey)
	screen := "(" . A_ScreenWidth . " x " . A_ScreenHeight . ")"
	msgDefault := "Hotkey: " . showHotkeyText . mrhk . " Res.: " . screen . " [" . mem . "]"
	
	showMessage(msgDefault)
	
	return
}
;-------------------------------- refreshGui --------------------------------
refreshGui(){
	global cmdSelected

	Gui, guiMain: Default
	cmdList := getCmdList()
	GuiControl,guiMain:,cmdSelected,|%cmdList% ; prefix the list with the delimiter (|) to replace the control's contents
	
	cmdselectSetEntry()

	tipClose()
	
	return
}
;****************************** registerWindow ******************************
registerWindow(){
	global activeWin
	global listBoxEntry
	
	activeWin := WinActive("A")

	GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%

	updateSingleStepButton()

	return
}
;******************************** checkFocus ********************************
checkFocus(){
	global activeWin

	h := WinActive("A")
	if (activeWin != h){
		hideWindow()
	}
	
	return
}
;********************************* mainWindow() *********************************
mainWindow() {
	global hintTime
	global iniFile
	global app
	global runCas
	global cmdFile
	
	global exitHotkey
	global menuHotkey
	global mouserecordHotkey
	
	global repeatTime
	global delayTime
	global allcmdsArr
	global cmdSeleted
	
	global Text1Desciption,Text1,Text2Desciption,Text2,Text3,Text4,Text5
	global Lb1
	global Errormessage
	global ButtonSingestep
	global font
	global fontsize
	global linesInList
	global appVersion
	global OwnPID
	global msgDefault
	global cmdSelected

	readIni()
	
	Gui, guiMain:Destroy

	Gui, guiMain:New,+hWndguiMainHandle +OwnDialogs
	Gui, guiMain:Font, s%fontsize%, %font%
	Gui, guiMain:Color,cF0F0F0
	
	timeInterval := formatTimeSeconds(repeatTime)
	timeDelay := formatTimeSeconds(delayTime)
	
	;cmdList := getCmdList()
	;GuiControl,guiMain:, ListBox1 , |%cmdList%

	deltaY := fontsize * 2 + 2 ;between buttons
	
	column2X := 370
	deltaX := column2X + 10
	deltaX2 := deltaX + 140
	deltaX3 := 130
	
	deltaY1C1 := 140
	deltaY1C2 := 2 * deltaY
	textWidth := 550
	
	startY := 355 ;start of below button area
		
	cmdList := getCmdList()
	Gui, guiMain:Add, ListBox, hwndLb1 x3 y3 w%column2X% r%linesInList% vcmdSelected gcmdselectGetEntry, %cmdList%
	
	Gui, guiMain:Add, Button, x3 y%startY% genterInterval, Set Repeat-interval
	Gui, guiMain:Add, Text, vText3 w90 xp+%deltaX3% yp+0, [%timeInterval%]
	
	Gui, guiMain:Add, Button, w150 h40 Center xp+90 yp+0 0x100 vButtonSingestep gguiAction_singleOp, Singlestep
	
	Gui, guiMain:Add, Button, x3 yp+%deltaY% genterWaitDelay, Set Start-delay
	Gui, guiMain:Add, Text,vText4 w90 xp+%deltaX3% yp+0, [%timeDelay%]
	
	Gui, guiMain:Add, Text,vText1Desciption x3 yp+%deltaY%,Command-file:
	Gui, guiMain:Add, Text,vText1 w%textWidth% xp+%deltaX3% yp+0, %cmdFile%
	
	Gui, guiMain:Add, Text,vText2Desciption x3 yp+%deltaY%,Ini-file:	
	Gui, guiMain:Add, Text,vText2 w%textWidth% xp+%deltaX3% yp+0, %iniFile%		

	Gui, guiMain:Add, Button, x%deltaX% y3 gcasRunStartOnceOnly, RUN once only
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcasRunStartRepeated, RUN at Repeat-interval	
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcasRunStandby, RUN/STANDBY at Repeat-interval
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcasRunAfterDelay, RUN delayed at Repeat-interval
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcasRunAfterDelayStandby, RUN/STANDBY delayed at Repeat-interval
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcasRunStop, STOP RUN (refresh menu)	

	Gui, guiMain:Add, Button, x%deltaX% y%deltaY1C1% geditCmdFile, &Edit Command-file
	
	Gui, guiMain:Add, Button, Center x%deltaX2% yp+0 0x100 gloadset, Loadset
	
	Gui, guiMain:Add, Button, Center x%deltaX% yp+%deltaY%  0x100 gEditSingleOp, Edit selected command
	
	Gui, guiMain:Add, Button, Center x%deltaX% yp+%deltaY% 0x100 gToogleComment, Toggle comment //
	
	Gui, guiMain:Add, Button, x%deltaX2%  yp+0 0x100 gToogleCommentSemi, Toggle comment `;
	
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gcoordsrecord, Stamp with coordinates
	
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% geditIniFile, &Edit Ini-file
	
	
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY1C2% gopenTaskschd, Open Windows Taskscheduler	
	Gui, guiMain:Add, Button, x%deltaX% yp+%deltaY% gopenGitHubPage, HELP at Github
	
	Gui, guiMain:Add, Button, Center x%deltaX2% yp+0 0x100 gShowHistory, System / history

		
	exitHotkeyText := "Exit: " . hotkeyToText(exitHotkey)
	
	exitStart := deltaY + 10
	Gui, guiMain:Add, Button, x%deltaX% yp+%exitStart% 0x100 gexit, %exitHotkeyText%
	
	Gui, guiMain:Add, Text, vErrormessage w250 cRed x%deltaX% y%startY%
	
	Gui, guiMain:Add, StatusBar,,
	
	showHotkeyText := hotkeyToText(menuHotkey)
	screen := "(" . A_ScreenWidth . " x " . A_ScreenHeight . ")"
	
	mrhk := " Record-hotkey: " . hotkeyToText(mouserecordHotkey)
	mem := GetProcessMemoryUsage(OwnPID) " MB"	
	msgDefault := "Hotkey: " . showHotkeyText . mrhk . " Res.: " . screen . " [" . mem . "]"
	SB_SetText("  " . msgDefault,1,1)
	
	checkVersionFromGithub()
	
	setTimer,registerWindow,-500
	setTimer,checkFocus,3000

	Gui, guiMain:Show, Autosize,%app%
	
	return
}
;******************************** showWindow ********************************
showWindow(){
	global app

	setTimer,checkFocus,3000
	Gui, guiMain:Show, Autosize,%app%

	return
}
;********************************* hideWindow *********************************
hideWindow(){
	setTimer,checkFocus,delete
	Gui, guiMain:Hide
	
	return
}
;***************************** cmdselectSetEntry *****************************
cmdselectSetEntry(){
	global listBoxEntry
	global ListBox1

	GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%
	updateSingleStepButton()
	
	return
}
;************************** cmdselectSetEntryReset **************************
cmdselectSetEntryReset(){
	global listBoxEntry
	global ListBox1

	listBoxEntry := 1

	GuiControl,guiMain:Choose,ListBox1,%listBoxEntry%

	updateSingleStepButton()
	
	return
}
;***************************** cmdselectGetEntry *****************************
cmdselectGetEntry(){
	global listBoxEntry
	global ListBox1

	if(listBoxEntry == 0){
		listBoxEntry := 1
	} else {
		GuiControl, guiMain:+AltSubmit, ListBox1
		GuiControlGet, listBoxEntry, guiMain:, ListBox1
		GuiControl, guiMain:-AltSubmit, ListBox1
	}

	updateSingleStepButton()
			
	return
}
;***************************** showErrorMessage *****************************
showErrorMessage(msg){
	global Errormessage

	GuiControl,guiMain:, Errormessage, %msg%
	
	return
}
;**************************** removeErrorMessage ****************************
removeErrorMessage(){
	showErrorMessage("")
	
	return
}
;**************************** guiAction_singleOp ****************************
guiAction_singleOp(){
	global cmdSelected
	global listBoxEntry
	
	Gui, Submit, NoHide
	singleOp()
	showWindowRefreshed()
	
	return
}
;************************** EditSingleOp **************************
EditSingleOp(){
	global cmdSelected
	global listBoxEntry
	
	Gui, Submit, NoHide
	
	singleOpEdit()
	
	showWindowRefreshed()
	
	return
}
;************************* ToogleComment *************************
ToogleComment(){
	global cmdSelected
	
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
	global cmdSelected
	
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
	KeyHistory
	
	return
}
;******************************** getCmdList ********************************
getCmdList(){
	global cmdFile
	global allcmdsArr
	
	allcmdsArr := []
	r := ""
	Loop, read, %cmdFile%
	{
		line := A_LoopReadLine
		allcmdsArr.Push(line)
		r := r . A_Index . " "  . line . "|"
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
CmdMenu_Close(theGui) {  ; Declaring this parameter is optional.
	showHint("close",1000)
	
	return true  ; true = 1
}
;******************************* openTaskschd *******************************
openTaskschd(){
	p := cvtPath("%windir%")
	Run, %p%\system32\taskschd.msc /s,,max
	
	return
}
;***************************** formatTimeSeconds *****************************
formatTimeSeconds(timeSeconds){
	hoursValue := SubStr("0" . (timeSeconds // 3600), -1)
	minutesValue := SubStr("0" . ((timeSeconds - hoursValue * 3600) // 60), -1)
	secondsValue := SubStr("0" . (Mod(timeSeconds, 60)), -1)
	timeValue = %hoursValue%:%minutesValue%:%secondsValue%
	
	return timeValue
}
;********************************* isRunning *********************************
isRunning(force := false){
	global runDoLoop
	global runCas
	global runCasOnceOnly
	global runCasStandby
	global runCasAfterDelay
	global runCasAfterDelayStandby
	
	retValue := false
	
	if (!force){
		if (runDoLoop && ( runCas || runCasOnceOnly || runCasStandby || runCasAfterDelay || runCasAfterDelayStandby)){
			retValue := true
		}
	}
	
	return retValue
}
;********************************* singleOp *********************************
singleOp(){
	global cmdFile
	global hintTimeShort
	global hintTimeMedium
	global runDoLoop
	global debug
	global runSingleOp
	global allcmdsArr
	global cmdSelected
	global listBoxEntry
	global xPosSave
	global yPosSave

	commandArr := []
	runSingleOp := true
	
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
		
		hideWindow()
		
		runDoLoop := true
		
		MouseGetPos,xPosSave,yPosSave
		
		doAction(commandArr)
		
		listBoxEntry := key1 + 1
		
		while (eq(SubStr(allcmdsArr[listBoxEntry], 1, 3),"rem") || eq(SubStr(allcmdsArr[listBoxEntry], 1, 1), ";")){
			listBoxEntry := listBoxEntry + 1 ; jump over normal comments (not //)
		}
		
		updateSingleStepButton()
		
		MouseMove,xPosSave,yPosSave
		
		runDoLoop := false
		
		runSingleOp := false
		
		showWindow()

	}
	
	return
}
;******************************* singleOpEdit *******************************
singleOpEdit(){
	global cmdFile
	global hintTimeShort
	global hintTimeMedium
	global hintTime
	global runDoLoop
	global debug
	global runSingleOp
	global allcmdsArr
	global cmdSelected
	global listBoxEntry

	commandArr := []
	runSingleOp := true

	cmd:= ""

	ok1 := RegExMatch(cmdSelected,"^(\d+) ",key)
	
	if (ok1 != 0){
		cmd := allcmdsArr[key1] ;key1 is used below too!
		
		SetTimer,MoveCursorToEnd,1
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
			showHint("Edit canceld!", hintTimeMedium)
		}
	}
	
	return
}
;****************************** MoveCursorToEnd ******************************
MoveCursorToEnd(){
    send {End}
    SetTimer,MoveCursorToEnd,Off
	
    return
}
;*************************** singleOpToogleComment ***************************
singleOpToogleComment(){
	global cmdFile
	global hintTimeShort
	global hintTimeMedium
	global runDoLoop
	global debug
	global runSingleOp
	global allcmdsArr
	global cmdSelected
	global listBoxEntry
	global ListBox1
	global Lb1

	commandArr := []
	runSingleOp := true
	
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
	global cmdFile
	global hintTimeShort
	global hintTimeMedium
	global runDoLoop
	global debug
	global runSingleOp
	global allcmdsArr
	global cmdSelected
	global listBoxEntry
	global Lb1

	commandArr := []
	runSingleOp := true
	
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
		
		GuiControl, guiMain:Choose, ListBox1, %listBoxEntry%
		updateSingleStepButton()
	}
	
	return
}
;******************************** casRunOnce ********************************
casRunOnce(){
	global cmdFile
	global runCas
	global runDoLoop
	global debug
	global errorLevelMemo
	
	errorLevelMemo := false
	
	hideWindow()
	
	cmdselectSetEntryReset()

	Loop, read, %cmdFile%
	{
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

		doAction(commandArr)

	}
	showWindowRefreshed()
	
	return
}
;******************************* showOpRunning *******************************
showOpRunning(){
	global hintTime
	
	showHint("An operation is already running! You have to stop it beforee starting a new one!", hintTime)

	return
}
;**************************** casRunStartOnceOnly ****************************
casRunStartOnceOnly(){
	global runDoLoop
	global runCas
	global runCasOnceOnly
	global runCasStandby
	global hintTimeMedium
	
	global downCounter
	global repeatTime
	global debug
	global errorLevelMemo
	
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
		tip("Execution finished!")
		
	showWindowRefreshed()
	
	return
}
;**************************** casRunStartRepeated ****************************
casRunStartRepeated(continue := false){
	global runDoLoop
	global runCas
	global runCasOnceOnly
	global runCasStandby
	
	global hintTimeMedium
	global downCounter
	global repeatTime
	global errorLevelMemo
	
	errorLevelMemo := false
	
	if (!continue && isRunning()){
		showOpRunning()
	} else {
		runDoLoop := true
		runCas := true
		casRunOnce()
		downCounter := repeatTime
		setTimer,countDown,delete
		setTimer,countDown,1000
	}
	
	return
}
;********************************* countDown *********************************
countDown(){
	global hintTime
	global downCounter
	global runCas
	global runCasOnceOnly
	global repeatTime

	switch getKeyboardState()
	{
		case 0:
			downCounter := downCounter - 1
			msg := "Next execution in: " . formatTimeSeconds(downCounter)
			n := StrLen(msg)
			tipTopTransp(msg, 7 * n - ((n+20)/10))
			Gui, guiMain:Hide
		case 1:
			msg := "Next execution in (hold on): " . formatTimeSeconds(downCounter)
			n := StrLen(msg)
			tipTopTransp(msg, 7 * n - ((n+20)/10))
		case 3:
			tipTopTranspClose()
			tipTimed("Execution wait finished by user!")
			downCounter := 0
		case 5:
			tipTopTranspClose()
			tipTimed("Operation aborted!")
			casRunStop()
			showWindow()
			return
	}	
	
		
	if(downCounter <= 0){
		if (runCasOnceOnly){
			setTimer,countDown,delete
			casRunOnce()
			casRunStop()
		}
		if (runCas){
			casRunOnce()
			downCounter := repeatTime
			setTimer,countDown,delete
			setTimer,countDown,1000
		}
	}
	return
}
;******************************* casRunStandby *******************************
casRunStandby(continue := false){
	global runDoLoop
	global runCas
	global runCasOnceOnly
	global runCasStandby
	
	global hintTime
	global hintTimeMedium
	global downCounter
	global repeatTime
	global systemNeededMillisToShutdown
	global errorLevelMemo
	global cancelShutdown
	
	errorLevelMemo := false
	
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
					/*
					if (A_IsAdmin){
						activateWakeup()
					} else {
						msgBox, WARNING! Not admin, no Shutdown/Wake Up!
						
						return
					}
					*/	
					if (!cancelShutdown){
						sleep, systemNeededMillisToShutdown ; give time to sleep
						
						; back from sleep or cancel shutdown
						showHint("Wakeup!", 10000)
						waitUntilCorrectTime()
					} else {
						casRunStop()
						tipTimed("Operation aborted!")
						showWindow()
						break casRunStandbyLoop
					}

				case 3,4:
					casRunStop()
					tipTimed("Operation aborted!")
					showWindow()
					break casRunStandbyLoop
			}
		}
	}
	
	return
}
;*************************** waitUntilCorrectTime ***************************
waitUntilCorrectTime(){
	global runDoLoop
	global hintTime
	global hintTimeMedium
	global startTime
	global repeatTime
	global counter
	
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
					
					tipRefreshed("Wakeup early, waiting: " . formatTimeSeconds(counter))
				case 1:
					tipRefreshed("Wakeup early, waiting (hold on): " . formatTimeSeconds(counter))
				case 3:
					tipTop("Wakeup early waiting finished by user interaction!")
					break waitUntilCorrectTimeLoop
				case 5:
					casRunStop()
					tipTimed("Operation aborted!")
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
	global runDoLoop
	global hintTimeMedium
	global runCasAfterDelay
	global delayDownCounter
	global delayTime
	global errorLevelMemo
	
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
	global runDoLoop
	global downCounter
	global runCas
	global runCasOnceOnly
	global delayTime
	global runCasAfterDelay
	global delayDownCounter
	global hintTime
	global repeatTime
	global errorLevelMemo
	global runDoLoop
	
	errorLevelMemo := false
	
	if (runCasAfterDelay){
	
		switch getKeyboardState()
		{
			case 0:
				delayDownCounter := delayDownCounter - 1
				msg := "Until Start: " . formatTimeSeconds(delayDownCounter)
				n := StrLen(msg)
				tipTopTransp(msg, 7 * n - ((n+20)/10))
			case 1:
				msg := "Until Start (hold on): " . formatTimeSeconds(delayDownCounter)
				n := StrLen(msg)
				tipTopTransp(msg, 7 * n - ((n+20)/10))
			case 3:
				tipTopTranspClose()
				tip("Wait until start finished by user interaction!")
				delayDownCounter := 0
			case 5:
				casRunStop()
				tipTopTranspClose()
				tipTimed("Operation aborted!")
				showWindow()
		}

		if(delayDownCounter <= 0){
			tipClose()
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
	global runDoLoop
	global hintTimeMedium
	global runCasAfterDelayStandby
	global delayDownCounter
	global delayTime
	global errorLevelMemo
	
	errorLevelMemo := false
	
	if (isRunning()){
		showOpRunning()
	} else {
		runDoLoop := true
		runCasAfterDelayStandby := true
		
		delayDownCounter := delayTime 
		setTimer,casRunAfterDelayStandbyCountdown,delete
		setTimer,casRunAfterDelayStandbyCountdown,1000
		hideWindow()
	}
	
	return
}
;********************* casRunAfterDelayStandbyCountdown *********************
casRunAfterDelayStandbyCountdown(){
	global downCounter
	global runCasStandby
	global runCasAfterDelayStandby
	global delayDownCounter
	global runDoLoop
	
	if (runCasAfterDelayStandby){
	
		switch getKeyboardState()
		{
			case 0:
				delayDownCounter := delayDownCounter - 1
				msg := "Until Start (with standby): " . formatTimeSeconds(delayDownCounter)
				n := StrLen(msg)
				tipTopTransp(msg, 7 * n - ((n+20)/10))
			case 1:
				msg := "Until Start (with standby) (hold on): " . formatTimeSeconds(delayDownCounter)
				n := StrLen(msg)
				tipTopTransp(msg, 7 * n - ((n+20)/10))
			case 3:
				tipTopTranspClose()
				tipTop("Wait until start (with standby) finished by user interaction!")
				delayDownCounter := 0
			case 5:
				casRunStop()
				tipTopTranspClose()
				tipTimed("Operation aborted!")
				showWindow()
				return
		}
	
		if(delayDownCounter <= 0){
			tipClose()
			runCasAfterDelayStandby := false

			setTimer,casRunAfterDelayStandbyCountdown,delete
			
			casRunStandby(true)
		}
	}
	
	return
}
;******************************** casRunStop ********************************
casRunStop(){
	global runDoLoop
	global runCas
	global runCasOnceOnly
	global runCasStandby
	global runCasAfterDelay
	global runCasAfterDelayStandby
	global errorLevelMemo
	
	global downCounter
	global sleepDownCounter
	global counter
	global delayDownCounter
	
	errorLevelMemo := false
	
	downCounter := 0
	sleepDownCounter := 0
	counter := 0
	delayDownCounter := 0
	
	setTimer,countDown,delete
	setTimer,casRunAfterDelayCountdown,delete
	setTimer,casRunAfterDelayStandbyCountdown,delete

	runDoLoop := false
	runCas := false
	runCasOnceOnly := false
	runCasStandby := false
	runCasAfterDelay := false
	runCasAfterDelayStandby := false
	
	showWindow()
	
	return
}
;******************************* enterInterval *******************************
enterInterval(){
	global repeatTime
	global iniFile
	
	;InputBox, inp , Edit command, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default
	InputBox, delaySeconds, Repeat-Delay, Please enter interval in seconds:,,,120,,,,,%repeatTime%
	if(!ErrorLevel){
		repeatTime := delaySeconds
		IniWrite, %repeatTime%, %iniFile%, timing, repeatTime
	}
	timeInterval := formatTimeSeconds(repeatTime)

	GuiControl, , Text3, |[%timeInterval%]
	
	showWindow()
	
	return
}
;****************************** enterWaitDelay ******************************
enterWaitDelay(){
	global delayTime
	global iniFile
	
	InputBox, delaySeconds, Delay time first run, Please enter delay in seconds:,,,120,,,,,%delayTime%
	if(!ErrorLevel) {
		delayTime := delaySeconds
		IniWrite, %delayTime%, %iniFile%, timing, delayTime
	}
	timeDelay := formatTimeSeconds(delayTime)
	GuiControl, , Text4, |[%timeDelay%]
	
	showWindow()

	return
}
;-------------------------------- mouserecordToggle --------------------------------
mouserecordToggle(){
	
	static showPosition := false
	
	showPosition := showPosition ? false : true
	
	hideWindow()
	
	CoordMode, Mouse, Screen
	
	if (showPosition){
		SetTimer, Update, 250
		Hotkey, LBUTTON, mouserecordClick, ON
		Hotkey, RBUTTON, mouserecordStop, ON
	} else {
		mouserecordStop()
	}
	
	return
}
;------------------------------ mouserecordStop ------------------------------contextmenu
mouserecordStop(){

	SetTimer, Update, delete
	Hotkey, LBUTTON, mouserecordClick, OFF
	Hotkey, RBUTTON, mouserecordStop, OFF
	ToolTip,,,,9
	
	showWindowRefreshed()
		
	return
}
;----------------------------- mouserecordClick -----------------------------
mouserecordClick(){
	global cmdFile
	global hintTimeShort
	global hintTime
	global recordlikeliness
	
	SetTimer, Update, delete
	Hotkey, LBUTTON, mouserecordClick, OFF
	Hotkey, RBUTTON, mouserecordStop, OFF
	
	; do the click
	doubleClick := false
	;dblClick?
	If (A_ThisHotkey == A_PriorHotkey and A_TimeSincePriorHotkey < 200)
		doubleClick := true

	if (doubleClick)
		Click, 2
	else
		Click
		
	
	MouseGetPos, posX, posY
	tip("Recorded: " . posX . "/" . posY)
			
	if (doubleClick)
		FileAppend , `//mousedblClick`,%posX%`,%posY%`n, %cmdFile%, UTF-8-RAW
	else
		FileAppend , `//mouseClick`,%posX%`,%posY%`n, %cmdFile%, UTF-8-RAW
		
	
	if (eq(stringUpper(recordlikeliness), "ON")){
		;integrate colors over 20 x 15px region
		deltaX := 20
		deltaY := 16
		sumR := 0
		sumG := 0
		sumB := 0
		xpos := Floor(posX - deltaX/2)
		ypos := Floor(posY - deltaY/2)
		samplepoints := Floor(deltaX * deltaY)
		
		tip("Calculating ...")
		Loop, %deltaY%
		{
			j := A_Index
			Loop, %deltaX%
			{
				i := A_Index
				x := xpos + i
				y := ypos + j
				cl := 0
				PixelGetColor, cl, %x%, %y%
				cs := "" cl
				rR := "0x" . SubStr(cs,3,2)
				rG := "0x" . SubStr(cs,5,2)
				rB := "0x" . SubStr(cs,7,2)
				
				sumR := (0 + rB) + sumR
				sumG := (0 + rG) + sumG
				sumB := (0 + rB) + sumB
			}
		}

		sumR := Floor(sumR/samplepoints)
		sumG := Floor(sumG/samplepoints)
		sumB := Floor(sumB/samplepoints)
		;tip("" . sumR . " " . sumG . " " . sumB)
		
		sR := SubStr("" sumR,1,2)
		sG := SubStr("" sumG,1,2)
		sB := SubStr("" sumR,1,2)
		s := sR . sG . sB
		FileAppend , `n`//mouseClickLikeliness`,%posX%`,%posY%`,%s%`n, %cmdFile%, UTF-8-RAW
		tip(sR . "|" . sG . "|" . sB)
	}
	
	SetTimer, Update, 250
	Hotkey, LBUTTON, mouserecordClick, ON
	Hotkey, RBUTTON, mouserecordStop, ON
		
	return
}
;---------------------------------- Update ----------------------------------
Update(){

	MouseGetPos, posX, posY
	ToolTip, %posX% %posY%,posX,posY,9
	
	return
}
;******************************* coordsrecord *******************************
coordsrecord(){
	global cmdFile
	global hintTimeShort
	
	FilePrepend("scriptcoordinates," . A_ScreenWidth . "," . A_ScreenHeight . "`n", cmdFile)
	
	showWindowRefreshed()
	
	return
}
;******************************** FilePrepend ********************************
FilePrepend(Prepend, FilePath) {
	global debug
	global hintTime
	global cmdFile
	
	content := Prepend
		
	Loop, read, %FilePath%
	{
		content := content . A_LoopReadLine . "`n"
	}
	
	FileDelete %FilePath%
	FileAppend , %content%, %FilePath%, UTF-8-RAW
	
	if (debug)
		showHint(content,hintTime)
		
	return
}
;****************************** copyToClipboard ******************************
copyToClipboard(s){
	clipboard := s
	
	return
}
;******************************** editCmdFile ********************************
editCmdFile() {
	global wrkDir
	global cmdFile
	global iniFile
	global notepadpath
	global notepadpathDefault

	showErrorMessage("Please close editor before continuing!")
	f := notepadpath . " " . cmdFile
	runWait %f%,,max

	removeErrorMessage()
	
	showWindowRefreshed()
	
	return
}
;******************************** editIniFile ********************************
editIniFile() {
	global cmdFile
	global iniFile
	global notepadpath
	global notepadpathDefault

	showErrorMessage("Please close editor before continuing!")
	f := notepadpath . " " . iniFile
	runWait %f%,,max
	
	removeErrorMessage()
	
	showWindowRefreshed()
	
	return
}
; *********************************** hotkeyToText ******************************
; in Lib
; *********************************** hkToDescription ******************************
; in Lib


;****************************** activateWakeup ******************************
activateWakeup(){
	global wrkDir
	global wakeUpFile
	global hintTime
	global hintTimeShort
	global appName
	global repeatTime
	global wakeupbeforeeMinutes
	global iniFile
	global wakeupDateTime
	global downCounterShutdown
	global cancelShutdown
		
	StringLower, appn, appName
	exeToRun := wrkDir . appn . ".exe"
	;exeToRun := ""

	FileDelete %wakeUpFile%
	
	wakeupDateTime :=  A_now
	
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
	tip("Last chance to holdon/cancel Shutdown/Wakeup, press [Capslock] within " . downCounterShutdown . " seconds!")
	
	cancelShutdown := false
	countDownShutdown()
	
	if (!cancelShutdown){
		task := A_ComSpec . " /c " . cvtPath("%windir%") . "\system32\schtasks.exe /Create /TN wakeup /XML " . wrkDir . wakeUpFile . " /F"
		showHint("Wakeup will be at: " . wakeupAt,5000)
		Run *RunAs, % task
		sleep, 3000
		RunAs
		showHint("Wakeup task ""wakeup"" created`, running at: " . wakeupAtShow . "`, activating SLEEP now!", hintTime)
			
		activateStandby()
	}
	return
}
;****************************** activateStandby ******************************
activateStandby(){
	global wrkDir
	global startTime
	global hintTime
	global wakeUpFile
	
	startTime := A_TickCount
	
	showHint("Goto sleep!", hintTime)
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)

	return
}
;***************************** countDownShutdown *****************************
countDownShutdown(){
	global hintTime
	global downCounterShutdown
	global runCas
	global runCasOnceOnly
	global repeatTime
	global wrkDir
	global wakeUpFile
	global cancelShutdown

	countDownShutdownLoop:
	Loop
	{
		switch getKeyboardState()
		{
			case 0:
				downCounterShutdown := downCounterShutdown - 1
				tipRefreshed("Shutdown in: " . formatTimeSeconds(downCounterShutdown))
			case 1:
				tipRefreshed("Shutdown in (hold on), press Ctrl to cancel shutdown, Alt to immediately start shutdown: " . formatTimeSeconds(downCounterShutdown))
			case 3:
				tip("Shutdown wait finished by user, immediate shutdown now!")
				downCounterShutdown := 0
				Break countDownShutdownLoop
			case 5:
				tip("Shutdown canceled by user, no shutdown, direct goto wakeup!")
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
;***************************** getKeyboardState *****************************
getKeyboardState(){
	r := 0
	if (getkeystate("Capslock","T") == 1)
		r := r + 1
		
	if (getkeystate("Alt","P") == 1)
		r := r + 2
		
	if (getkeystate("Ctrl","P") == 1)
		r := r + 4	

	return r
}
;****************************** showpixelcolor ******************************
showpixelcolor(){
	MouseGetPos, xpos, ypos
	PixelGetColor, cl, xpos, ypos , Slow RGB
	tip(cl)
	
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
;************************** updateSingleStepButton **************************
updateSingleStepButton(){
	global ButtonSingestep
	global listBoxEntry
	
	GuiControl, guiMain:, ButtonSingestep, Singestep (%listBoxEntry%)
	
	return
}
;********************************** loadset **********************************
loadset(){
	global wrkDir
	global cmdFile
	global iniFile
	
	FileSelectFile, path, 1, %wrkDir%, Loadset a Command/Config-file pair, Command-file (*.txt)
	found := false

	if (ErrorLevel == 0){
		cmdFile := path
		found := true
		
		inif := StrReplace(path,".txt",".ini")

		if (FileExist(inif) != ""){
			iniFile := inif
		} else {
			showErrorMessage("Active Ini-file not changed!")
			sleep,2000
		}		
	} else {
		showErrorMessage("Active Command-file not changed!")
		sleep,4000
	}
	
	if (found){
		setTimer,cmdselectSetEntryReset,-1000
		showWindowRefreshed()
	}
	
	return
}
;*********************************** exit ***********************************
exit(){
	global app
	global hintTimeShort

	casRunStop()
	Gui, guiMain:Destroy
	showHint("""" . app . """ removed from memory!", hintTimeShort)
	ToolTip
	tipTopTranspClose()
	tipRefreshedClose()
	
	ExitApp
}
;************************************ *** ************************************


					