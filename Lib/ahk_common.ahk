; ahk_common.ahk

;----------------------------------- StrQ -----------------------------------
; from https://www.autohotkey.com/boards/viewtopic.php?t=57295#p328684

StrQ(Q, I, Max:=10, D:="|") { ;          StrQ v.0.90,  By SKAN on D09F/D34N @ tiny.cc/strq
Local LQ:=StrLen(Q), LI:=StrLen(I), LD:=StrLen(D), F:=0
Return SubStr(Q:=(I)(D)StrReplace(Q,InStr(Q,(I)(D),,0-LQ+LI+LD)?(I)(D):InStr(Q,(D)(I),0,LQ
-LI)?(D)(I):InStr(Q,(D)(I)(D),0)?(D)(I):"","",,1),1,(F:=InStr(Q,D,0,1,Max))?F-1:StrLen(Q))
}
;--------------------------- getVersionFromGithub ---------------------------
getVersionFromGithub(){
	global appName

	r := "unknown!"
	StringLower, name, appName
	url := "https://github.com/jvr-ks/" . name . "/raw/master/version.txt"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Try
	{
		whr.Open("GET", url)
		whr.Send()
		Sleep 500
		status := whr.Status
		if (status == 200)
			r := whr.ResponseText
	}
	catch e
	{
		msgbox, Connection to %url% failed! [Error: %e%]
	}

	return r
}
;-------------------------- checkVersionFromGithub --------------------------
checkVersionFromGithub(){
	global appVersion
	global msgDefault
	
	vers := getVersionFromGithub()
	if (vers != "unknown"){
		if (vers > appVersion){
			msg := "New version available, this is: " . appVersion . " ,available on Github is: " . vers
			showMessage(msg)
		}
	}
					
	return
}
;-------------------------------- showMessage --------------------------------
showMessage(msg){

	SB_SetText("  " . msg,1,1)
	
	return
}
;------------------------------- removeMessage -------------------------------
removeMessage(){
	global msgDefault
	
	showMessage(msgDefault)
	
	return
}
;******************************** getLenPixel ********************************
;---- generate hidden gui to get pixelsize of string
getLenPixel(EditTxt,font,fontsize){
	global MyText
	global dpiScale

	Gui StringWidth:font, s%fontsize%, %font%
	if (StrLower(dpiScale) == "on")
  	Gui StringWidth: +DPIScale
	Gui StringWidth:Add, Text, R1, %EditTxt%
	GuiControlGet T, StringWidth:Pos, Static1
	Gui StringWidth:Destroy
	
	return TW
}
;--------------------------------- tipCreate ---------------------------------
tipCreate(){
	global font
	global fontsize
	
; ToolTip window

	global Tip

	Gui, tip:New,-Caption +AlwaysOnTop
	Gui, tip:Font, s%fontsize%, %font%
}
;------------------------------------ tip ------------------------------------
tip(msg){
	global font
	global fontsize
	
	; allways create new
	
	Gui, tip:destroy
	Gui, tip:New,-Caption +AlwaysOnTop
	Gui, tip:Font,  s%fontsize%, %font%
	
	s := StrReplace(msg,"^",",")
	Gui, tip:Add, Text, vTip R1 Center,%s%
	Gui,tip:Show, xCenter y0 Autosize NoActivate,tip-Window

	return
}
;--------------------------------- tipClose ---------------------------------
tipClose(){

	Gui,tip:Destroy
	return
}
;--------------------------------- tipTimed ---------------------------------
tipTimed(msg){
	
	setTimer,tipClose,-3000
	tip(msg)

	return
}
;------------------------------- tipRefreshed -------------------------------
tipRefreshed(msg){
	;created only once,fixed width of text of first call

	tipHwnd := WinExist("tipRefreshedWindow")
	if ( tipHwnd == 0){
		tipRefreshedCreate(msg)
	}
	s := StrReplace(msg,"^",",")
	Guicontrol,tipRefreshed:,TipRefreshed,%s%
	return
}
;---------------------------- tipRefreshedCreate ----------------------------
tipRefreshedCreate(msg){
	global font
	global fontsize
	global TipRefreshed
	
	Gui, tipRefreshed:New,-Caption +AlwaysOnTop
	Gui, tipRefreshed:Font, s%fontsize%, %font%
	widthPixel := getLenPixel(msg,"Calibri",11)
	Gui, tipRefreshed:Add, Text, vTipRefreshed R1 w%widthPixel% Center
	Gui,tipRefreshed:Show, xCenter y0 Autosize NoActivate,tipRefreshedWindow
}
;----------------------------- tipRefreshedClose -----------------------------
tipRefreshedClose(){

	Gui,tipRefreshed:Destroy
	
	return
}
;------------------------------- tipTopTransp -------------------------------
tipTopTransp(msg, widthPixel){
	global TipTopTranspText
	static tipTranspHwnd
	global font
	global fontsize
	
	s := StrReplace(msg,"^",",")
	tipTranspHwnd := WinExist("tipTopTranspWindow")
	
	if ( tipTranspHwnd == 0){
	
		widthPixel := getLenPixel(msg,font,fontsize)
		Gui, tipTopTransp:New,-Caption +AlwaysOnTop
		Gui, tipTopTransp:Font, s%fontsize%, %font%
		Gui, tipTopTransp:Add, Text, vTipTopTranspText Center R1 w%widthPixel%
	}

	GuiControl,tipTopTransp:,TipTopTranspText,%s%
	Gui, tipTopTransp:Show, xCenter y0 Autosize NoActivate,tipTopTranspWindow
	
	tipTranspHwnd := WinExist("tipTopTranspWindow")
	WinSet, Transparent, 150, ahk_id %tipTranspHwnd%

	return
}
;---------------------------- tipTopTranspRemove ----------------------------
tipTopTranspClose(){
	global TipTopTransp

	Gui, tipTopTransp:destroy
}
;********************************** tipTop **********************************
tipTop(msg){
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")
	ToolTip, %s%,toolX,toolY,3
}
;******************************** tipTopTime ********************************
tipTopTime(msg, t := 2000){
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")
	ToolTip, %s%,toolX,toolY,3
	tvalue := -1 * t
	SetTimer,tipTopClose,%tvalue%
}
;******************************* tipTopEternal *******************************
tipTopEternal(msg){
	global font
	global fontsize
	
	toolX := Max(0,Floor(A_ScreenWidth / 2) - getLenPixel(msg,font,fontsize))
	toolY := 2
	
	s := StrReplace(msg,"^",",")

	ToolTip, %s%,toolX,toolY,3
}
;-------------------------------- tipTopClose --------------------------------
tipTopClose(){
	ToolTip,,,,1
	ToolTip,,,,2
	ToolTip,,,,3
}
;******************************** GuiGetSize ********************************
GuiGetSize( ByRef W, ByRef H, GuiID=1 ) {
	Gui %GuiID%:+LastFoundExist
	IfWinExist
	{
		VarSetCapacity( rect, 16, 0 )
		DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
		W := NumGet( rect, 8, "int" )
		H := NumGet( rect, 12, "int" )
	}
}
;********************************* GuiGetPos *********************************
GuiGetPos( ByRef X, ByRef Y, ByRef W, ByRef H, GuiID=1 ) {
	Gui %GuiID%:+LastFoundExist
	IfWinExist
	{
		WinGetPos X, Y
		VarSetCapacity( rect, 16, 0 )
		DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
		W := NumGet( rect, 8, "int" )
		H := NumGet( rect, 12, "int" )
	}
}
;******************************** stringUpper ********************************
stringUpper(s){
	r := ""
	StringUpper, r, s
	
	return r
}
;********************************* StrLower *********************************
StrLower(s){
	r := ""
	StringLower, r, s
	
	return r
}
;******************************** openShell ********************************
openShell(commands) {
    shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(ComSpec " /Q /K echo off")
	exec.StdIn.WriteLine(commands "`nexit") 
	r := exec.StdOut.ReadAll()
	msgbox, %r%
	
    return
}
;******************************** showObject ********************************
showObject(a){
	s := ""

	for index,element in a
	{
		s := s . element .  ", "
	}
	msgbox, showObject: %s%
}
;*************************** GetProcessMemoryUsage ***************************
GetProcessMemoryUsage(ProcessID)
{
	static PMC_EX, size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

	if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID)) {
		if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
			if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
				return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
		DllCall("CloseHandle", "ptr", hProcess)
		return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
	}
	return (ErrorLevel := 1) & 0
}
;--------------------------------- showHint ---------------------------------
showHint(s, n){
	global font
	global fontsize
	
	Gui, hint:Font, s%fontsize%, %font%
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show
	sleep, n
	Gui, hint:Destroy
	return
}
;-------------------------------- showHintAt --------------------------------
showHintAt(s, n, x, y){
	global font
	global fontsize
	
	Gui, hint:Font, s%fontsize%, %font%
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show, x%x% y%y%
	Sleep, n
	Gui, hint:Destroy
	
	return
}













