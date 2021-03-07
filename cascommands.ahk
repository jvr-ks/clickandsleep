;******************************** cascommands ********************************
; clickandsleep commands

doAction(commandsArr){
	global wrkDir
	global winArr
	global activeWin
	global hintTime
	global hintTimeShort
	global debug
	
	global runCas

	global casRunStart
	global casRunStartStandby
	
	global runCasOnceOnly
	global runCasStandby
	global runCasAfterDelay
	global runCasAfterDelayStandby

	global runDoLoop
	global debugShowSleep
	
	global downCounter
	global sleepDownCounter
	global counter
	global delayDownCounter
	
	global winCon
	global runPID
	global runSingleOp
	global errorLevelMemo
	global defaultShowTime
	global scriptcoordinateX
	global scriptcoordinateY
	global scaleX
	global scaleY
	global iniFile
	global cmdFile
	global chrome
	global firefox
	global edge
	global errormessage
	global listBoxEntry
	
	
	enhancedCommand := false
			
	capslockWaitLoop:
	Loop
	{
		switch getKeyboardState()
		{
			case 1:
				tipRefreshed("ClickandSleep paused ...")
				sleep,1000
			case 3:
				tip("Jumped over this command: " . commandsArr[1])
				sleep,1000
				enhancedCommand := true
				tipRefreshedClose()
				return
			case 5:
				tip("Operation aborted!")
				sleep,1000
				runDoLoop := false
				casRunStop()
				break capslockWaitLoop
			default:
				tipClose()
				tipRefreshedClose()
				break capslockWaitLoop
		}

	}	
			
	if (!runDoLoop)
		return
		
	if(commandsArr.Length() < 1)
		return
		
	if (debug && !eq(SubStr(commandsArr[1], 1, 3),"rem") && !eq(SubStr(commandsArr[1], 1, 1), ";") && !eq(SubStr(commandsArr[1], 1, 2), "//")){
		s := "Command: "
		
		Loop % commandsArr.Length() - 1
		{
			s := s . commandsArr[A_Index] . ", "
		}
		s := s . commandsArr[commandsArr.Length()]
		
		if (eq(commandsArr[1], "sleep") != 0){
			if (debugShowSleep){
				showHint(s, hintTimeShort)
			}
		} else {
			showHint(s, hintTimeShort)
		}
	}

;must be evaluated first!
	if(eq(SubStr(commandsArr[1], 1, 2), "//")){
		if (runSingleOp) {
			; remove "//"
			commandsArr[1] := Trim(RegExReplace(Trim(commandsArr[1]),"^\/\/ *",""))
		} else {
			enhancedCommand := true
			return
		}
	}
	
		
	if(eq(SubStr(commandsArr[1], 1, 3),"rem")){
		enhancedCommand := true
		return
	}
	
	if(eq(SubStr(commandsArr[1], 1, 1),";")){
		enhancedCommand := true
		return
	}
	
	if(eq(commandsArr[1],"keywait")){
		KeyName := "Escape"
		if (commandsArr[2] != "")
			KeyName := commandsArr[2]
	
		Options := "D"
		if (commandsArr[3] != "")
			Options := commandsArr[3]
	
		s := "Waiting for key: " . KeyName
		tip(s)	
		KeyWait,%KeyName%,%Options%
		tipClose()
		
		enhancedCommand := true
		return
	}
	
	if(eq(commandsArr[1],"scriptcoordinates")){
			if((!eq(commandsArr[2],"") && (!eq(commandsArr[3],"")))){
				sourceScriptcoordinateX := commandsArr[2]
				sourceScriptcoordinateY := commandsArr[3]
				scaleX := Floor(scriptcoordinateX/sourceScriptcoordinateX)
				scaleY := Floor(scriptcoordinateY/sourceScriptcoordinateY)

				if (debug)
					showHint("Scale is X: " . scaleX . " and Y: " . scaleY, hintTime)
		}	
		enhancedCommand := true
	}
	
;random evaluation
	if(eq(commandsArr[1],"errorlevelhint")){
		if errorLevelMemo
		{
			showHint("Errorlevel set to " . errorLevelMemo, hintTime)
		} else {
			showHint("Errorlevel is not set!", hintTime)
		}
		enhancedCommand := true
	}

	if(eq(commandsArr[1],"errorlevelstop")){
		if errorLevelMemo
		{
			casRunStop()
			MsgBox, All operations are aborted`,  because Errorlevel is set to %ErrorLevel%
		}
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"errorlevelexit")){
		if errorLevelMemo
		{
			MsgBox, Errorlevel set to %ErrorLevel%`, exiting!
			exit()
		}
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"winconstop")){
		if (!wincon)
		{
			casRunStop()			
		}
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"winconexit")){
		if (!wincon)
		{
			MsgBox, winCon set to %wincon%`, exiting!
			exit()
		}
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"pushwin")){
		pushWin := WinActive("A")
		winArr.Push(pushWin)
		if (debug)
			showHint("HWND: " . pushWin, hintTimeShort)
	
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"popwin")){
		popWin := winArr.Pop()
		if (popWin != 0)
			WinActivate, ahk_id %popWin%
			
		if (debug)
			showHint("HWND: " . popWin, hintTimeShort)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"setwincon")){
		winCon := 1
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"resetwincon")){
		winCon := 0
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"reseterrorlevel")){
		errorlevelmemo := 0
		enhancedCommand := true
	}
	
;UniqueID := WinExist(WinTitle , WinText, ExcludeTitle, ExcludeText)
	if(eq(commandsArr[1],"winexist")){
		param1 := commandsArr[2]
		param2 := commandsArr[3]
		param3 := commandsArr[4]
		param4 := commandsArr[5]
		winCon := WinExist(param1, param2, param3, param4)
		enhancedCommand := true
	}
	
;WinActivate , WinTitle, WinText, ExcludeTitle, ExcludeText
	if(eq(commandsArr[1],"winactivate")){
		if (winCon){
			param1 := commandsArr[2]
			param2 := commandsArr[3]
			param3 := commandsArr[4]
			param4 := commandsArr[5]
			winactivate, %param1%, %param2%, %param3%, %param4%
		} else {
			if(debug)
				showHint("WinActivate failed because winCon condition is false!", hintTimeShort)
		}
		enhancedCommand := true
	}
	
;WinWaitActive, WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText
	if(eq(commandsArr[1],"winwaitactive")){
		if (winCon){
			param1 := commandsArr[2]
			param2 := commandsArr[3]
			param3 := commandsArr[4]
			param4 := commandsArr[5]
			param5 := commandsArr[6]
			WinWaitActive, %param1%, %param2%, %param3%, %param4%, %param5%
			errorLevelMemo := ErrorLevel
		} else {
			if(debug)
				showHint("WinWaitActive failed because winCon condition is false!", hintTimeShort)
		}
		enhancedCommand := true
	}
	
;WinWait, WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText
	if(eq(commandsArr[1],"winwait")){
	
		if (!winCon){
			param1 := commandsArr[2]
			if (InStr(param1,"ahk_pid") != 0)
				param1 := "ahk_pid " . runPID
			param2 := commandsArr[3]
			param3 := commandsArr[4]
			param4 := commandsArr[5]
			param5 := commandsArr[6]
			WinWait, %param1%, %param2%, %param3%, %param4%, %param5%
			errorLevelMemo := ErrorLevel
		}
		enhancedCommand := true
	}
	
;WinMaximize , WinTitle, WinText
	if(eq(commandsArr[1],"winmaximize")){
		param1 := commandsArr[2]
		param2 := commandsArr[3]
		WinMaximize, %param1%, %param2%
		PostMessage, 0x112, 0xF030,,,%param1%,%param2%
		enhancedCommand := true
	}
	
;WinMinimize , WinTitle, WinText, ExcludeTitle, ExcludeText
	if(eq(commandsArr[1],"winminimize")){
		param1 := commandsArr[2]
		param2 := commandsArr[3]
		param3 := commandsArr[4]
		param4 := commandsArr[5]
		WinMinimize, %param1%, %param2%, %param3%, %param4%
		enhancedCommand := true
	}

;WinClose , WinTitle, WinText, SecondsToWait, ExcludeTitle, ExcludeText
	if(eq(commandsArr[1],"winclose")){
		param1 := commandsArr[2]
		param2 := commandsArr[3]
		param3 := commandsArr[4]
		param4 := commandsArr[5]
		param5 := commandsArr[6]
		WinClose, %param1%, %param2%, %param3%, %param4%, %param5%
		enhancedCommand := true
	}
	
	
;wait or sleep: identical
	if(eq(commandsArr[1],"wait") || eq(commandsArr[1],"sleep")){
		dst := defaultShowTime
		if (commandsArr[2] != "")
			dst := commandsArr[2]
			
		if (commandsArr[3] != "")
			tip("Sleep " . dst . " milliseconds!" . " " . commandsArr[3])
			
		Sleep, dst

		tip("")
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"sleeplong")){
		dst := 10
		if (commandsArr[2] != "")
			dst := commandsArr[2]
			
		sleepDownCounter := 0 . dst
		
		tipRefreshedClose()
		
		sleepdown:
		Loop
		{
			switch getKeyboardState()
			{
				case 0:
					sleepDownCounter := sleepDownCounter - 1
					if (commandsArr[3] != "")
						tipRefreshed("Sleeplong: " . formatTimeSeconds(sleepDownCounter) . " " . commandsArr[3])
				case 1:
					tipRefreshed("Sleeplong hold on: " . formatTimeSeconds(sleepDownCounter) . " " . commandsArr[3])
				case 3:
					tipRefreshedClose()
					tipRefreshed("Sleeplong finished by user interaction!")
					sleepDownCounter := 0
					break sleepdown
				case 5:
					casRunStop()
					tipRefreshedClose()
					tipRefreshed("Operation aborted!")
					sleep, 1000
					break sleepdown
			}

			if (sleepDownCounter <= 0){
				tipRefreshedClose()
				break sleepdown
			} else {
				sleep, 1000
			}
		}
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1], "mousemove")){
		MouseMove, Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY) , commandsArr[4]
		enhancedCommand := true
	}
	
	;MouseClick , WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative
	if(eq(commandsArr[1], "mouseclick")){
	
		if (commandsArr[6] == ""){
			if (commandsArr[7] == "")
				MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY), commandsArr[4], commandsArr[5]
			
			if (commandsArr[7] == "R")
				MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY), commandsArr[4], commandsArr[5],,R
				
		} else {
			msgbox, DownOrUp not supported!
		}
						
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1], "mousedblclick")){
		if (commandsArr[7] == "")
			MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY),2,commandsArr[5]
			
		if (commandsArr[7] == "R")
			MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY),2,commandsArr[5],,R		
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1], "mouseclickaround")){
		delta := 1
		increment := 1
		x := Floor(commandsArr[2] * scaleX)
		y := Floor(commandsArr[3] * scaleY)
		offset := commandsArr[4]
		if (commandsArr[5] != "")
			increment := commandsArr[5]
		
		MouseClick,Left,x, y
		while (delta < offset)
		{
			MouseClick,Left,x + delta, y
			MouseClick,Left,x + delta, y + delta
			MouseClick,Left,x, y + delta
			MouseClick,Left,x - delta, y + delta
			MouseClick,Left,x - delta, y
			MouseClick,Left,x - delta, y - delta
			MouseClick,Left,x, y - delta
			MouseClick,Left,x + delta, y - delta
			
			delta := delta + 5
		}
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1], "mouseclickright")){
		MouseClick,Right,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY)
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1], "mouseclickrandom3")){
		Random, rnd , 1, 3

		switch rnd
		{
			case 1:
				MouseClick,,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY)
				if (debug)
					showHint("Selectd random 1", hintTimeShort)
			case 2:
				MouseClick,,Floor(commandsArr[4] * scaleX), Floor(commandsArr[5] * scaleY)
				if (debug)
					showHint("Selectd random 2", hintTimeShort)
			case 3:
				MouseClick,,Floor(commandsArr[6] * scaleX), Floor(commandsArr[7] * scaleY)
				if (debug)
					showHint("Selectd random 3", hintTimeShort)
		}
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"send")){
		s := commandsArr[2]
		send, %s%
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"sendraw")){
		s := commandsArr[2]
		sendraw, %s%
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"sendtext")){
		s := "{Text}" . commandsArr[2]
		send, %s%
		enhancedCommand := true
	}

	if(eq(commandsArr[1],"sendblindtext")){
		s := "{Blind}{Text}" . commandsArr[2]
		send, %s%
		enhancedCommand := true
	}
	
;Run, Target , WorkingDir, Options, OutputVarPID=runPID (name fixed!)
	if(eq(commandsArr[1],"run")){
		param2 := ""
		param3 := ""
		
		l := commandsArr.Length() - 1  ; command name is also in array

		if (!winCon){
			switch l
			{
				case 1: 
					appPath := cvtPath(commandsArr[2])
					Run %appPath%,,,runPID
					
				case 2: 
					appPath := cvtPath(commandsArr[2])
					param2 := commandsArr[3]
					Run %appPath%, %param2%,,runPID
					
				case 3: 
					appPath := cvtPath(commandsArr[2])
					param2 := commandsArr[3]
					param3 := commandsArr[4]
					Run %appPath%,%param2%,%param3%,runPID
					
			}	
		} else {
			if(debug)
				showHint("Run not executed because winCon condition is true!", hintTimeShort)
		}
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"showhint")){
		dst := defaultShowTime
		if (commandsArr[3] != "")
			dst := commandsArr[3]
		showHint(commandsArr[2], dst)
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"showhinterror")){
		dst := defaultShowTime
		if (commandsArr[3] != "")
			dst := commandsArr[3]
			
		if errorLevelMemo
			showHint(commandsArr[2], dst)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"showvar")){
		dst := defaultShowTime
		if (commandsArr[3] != "")
			dst := commandsArr[3]
				
		vName := commandsArr[2]
		vValue:= %vName%
			
		tipTopTime("Variable: " . vName . " has value: " . vValue, 10000)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"showpid")){
		dst := defaultShowTime
		if (commandsArr[2] != "")
			dst := commandsArr[2]
		showHint(runPID, dst)
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"sendemail")){
		; param:
		; 1. mailto
		; 2. subject
		; 3. body
		; 4. bcc, ... (optional)
		
		bccArr := []
		if(commandsArr.Length() > 3){
			loop, % (commandsArr.Length() - 4){
				bccArr.push(commandsArr[5])
			}
		}
		sendEmail(commandsArr[2], commandsArr[3], commandsArr[4], bccArr)
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"debugstoprun")){
		setTimer,countDown,delete
	
		showHint("Run completely stopped because off debugStopRun!", hintTime)
		
		casRunStop()
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"debugon")){
		debug :=  true
		showhint("Debug ON", hintTimeShort)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"debugoff")){
		if (debug)
			showhint("Debug OFF", hintTimeShort)
			
		debug :=  false
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"debugshowsleepoff")){
		debugShowSleep :=  false
		if (debug)
			showhint("debugShowSleep OFF", hintTimeShort)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"debugshowsleepon")){
		debugShowSleep :=  true
		if (debug)
			showhint("debugShowSleep ON", hintTimeShort)
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"tip")){
		Gui +OwnDialogs
		msg := commandsArr[2]
		s := StrReplace(msg,"^",",")
		ToolTip, %s%,,,1

		SetTimer,tipTopClose,-3000
		enhancedCommand := true
	}	
	
	if(eq(commandsArr[1],"tiptop")){
		Gui +OwnDialogs
		msg := commandsArr[2]
		s := StrReplace(msg,"^",",")
		ToolTip, %s%,(A_ScreenWidth / 2),2,3
		SetTimer,tipTopClose,-3000
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"tipat")){
		Gui +OwnDialogs
		msg := commandsArr[4]
		s := StrReplace(msg,"^",",")
		ToolTip, %s%,commandsArr[2],commandsArr[3],2

		SetTimer,tipTopClose,-5000
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"coordmousemode")){
		m := commandsArr[2]
		CoordMode, Mouse, %m%
		enhancedCommand := true
	}
		
	if(eq(commandsArr[1],"coordmode")){
		p1 := commandsArr[2]
		p2 := commandsArr[3]
		CoordMode, %p1%, %p2%
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"openchrome")){
		winCon := 0
		errorlevelmemo := 0
		winCon := WinExist("ahk_exe chrome.exe")
		if (winCon){
			WinClose, ahk_exe chrome.exe,,10
			sleep,1000
		}
		winCon := WinExist("ahk_exe chrome.exe")
		if (!winCon){
			url := commandsArr[2]
			Run,%chrome% %url%,,,runPID 
			WinWait,ahk_exe chrome.exe,,20
			errorLevelMemo := ErrorLevel
		} else {
			MsgBox, Error, could not close Chrome, exiting
			exit()
		}
		if (errorLevelMemo){
			MsgBox, During openchrom: Errorlevel set to %ErrorLevel%`, exiting!
			exit()
		}	
		;bring to front
		winCon := 0
		winCon := WinExist("ahk_exe chrome.exe")
		if (winCon){
			WinActivate,ahk_class Chrome_WidgetWin_1 
		} else {
			tip("Error, Chrome not running!")
		}
		WinGet, runPID, PID, ahk_exe chrome.exe
		if (debug)
			tipTopEternal("PID: " . runPID)
		
		sleep, 5000
		if(runSingleOp)
			refreshGui()
			
		enhancedCommand := true
	}	

	if(eq(commandsArr[1],"activatechrome")){
		winCon := 0
		errorlevelmemo := 0
		winCon := WinExist("ahk_exe chrome.exe")
		if (winCon){
			WinActivate,ahk_class Chrome_WidgetWin_1 
		} else {
			tip("Error, Chrome not running!")
		}	
			
		enhancedCommand := true
	}	

	if(eq(commandsArr[1],"openedge")){
		winCon := 0
		errorlevelmemo := 0
		winCon := WinExist("ahk_exe msedge.exe")
		if (winCon){
			WinClose, ahk_exe msedge.exe,,10
			sleep,1000
		}
		winCon := WinExist("ahk_exe msedge.exe")
		if (!winCon){
			url := commandsArr[2]
			Run,%chrome% %url%,,,runPID 
			WinWait,ahk_exe msedge.exe,,20
			errorLevelMemo := ErrorLevel
		} else {
			MsgBox, Error, could not close Chrome, exiting
			exit()
		}
		if (errorLevelMemo){
			MsgBox, During openchrom: Errorlevel set to %ErrorLevel%`, exiting!
			exit()
		}	
		;bring to front
		winCon := 0
		winCon := WinExist("ahk_exe msedge.exe")
		if (winCon){
			WinActivate,ahk_class Chrome_WidgetWin_1 
		} else {
			tip("Error, Chrome not running!")
		}
		WinGet, runPID, PID, ahk_exe msedge.exe
		if (debug)
			tipTopEternal("PID: " . runPID)
		
		sleep, 5000
		if(runSingleOp)
			refreshGui()
			
		enhancedCommand := true
	}

	if(eq(commandsArr[1],"activateedge")){
		winCon := 0
		errorlevelmemo := 0
		winCon := WinExist("ahk_exe msedge.exe")
		if (winCon){
			WinActivate,ahk_exe msedge.exe
		} else {
			tip("Error, Edge not running!")
		}	
			
		enhancedCommand := true
	}	

	if(eq(commandsArr[1],"openfirefox")){
		winCon := 0
		winCon := WinExist("ahk_class MozillaWindowClass")
		if (winCon){
			tipTopEternal("Please be patient, it takes a while to close the running Firefox!")
			WinClose, ahk_id %winCon%,,10
			sleep,10000	
		}
		tipTopEternal("")
		winCon := 0
		winCon := WinExist("ahk_class MozillaWindowClass")
		if (winCon){
			MsgBox, Error, could not close Firefox (%winCon%), continuing ...`n(with possible wrong URL)
		}
		url := commandsArr[2]
		Run,%firefox% %url%
		WinWait,ahk_class MozillaWindowClass,,20
		errorLevelMemo := ErrorLevel

		if (errorLevelMemo){
			MsgBox, During openfirefox: Errorlevel set to %ErrorLevel%`, exiting!
			exit()
		}	
		;bring to front
		winCon := 0
		winCon := WinExist("ahk_class MozillaWindowClass")
		if (winCon){
			WinActivate,ahk_id %winCon% 
		} else {
			tip("Error, Firefox not running!")
		}
		WinGet, runPID, PID, ahk_id %winCon%
		if (debug)
			tipTopEternal("PID: " . runPID)
		
		sleep, 5000
		if(runSingleOp)
			refreshGui()
			
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"activatefirefox")){
		winCon := 0
		errorlevelmemo := 0
		winCon := WinExist("ahk_class MozillaWindowClass")
		if (winCon){
			WinActivate,ahk_class MozillaWindowClass 
		} else {
			tip("Error, Firefox not running!")
		}	
			
		enhancedCommand := true
	}	
	

	if(eq(commandsArr[1],"closechrome")){
		WinClose, ahk_exe chrome.exe,,10
		sleep,1000
		winCon := 0
		winCon := WinExist("ahk_exe chrome.exe")

		enhancedCommand := true
	}	

	if(eq(commandsArr[1],"closefirefox")){
		WinClose, ahk_class MozillaWindowClass,,10
		sleep,1000
		winCon := 0
		winCon := WinExist("ahk_class MozillaWindowClass")

		enhancedCommand := true
	}	
	
	if(eq(commandsArr[1],"closeedge")){
		WinClose, ahk_exe msedge.exe,,10
		sleep,1000
		winCon := 0
		winCon := WinExist("ahk_exe msedge.exe")

		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"loadset")){
		p := trim(commandsArr[2])
		p := cvtPath(p)
		
		if (FileExist(p . ".txt") != ""){
			cmdFile := p . ".txt"
		} else {
			showErrorMessage("File not found: " . p . ".txt,`nactive Command-file not changed!")
		}
		
		if (FileExist(p . ".ini") != ""){
			iniFile := p . ".ini"
		} else {
			showErrorMessage("File not found: " . p . ".ini,`nactive Ini-file not changed!")
		}
			
		setTimer,cmdselectSetEntryReset,-1000

		refreshGui()
		
		if (runCasOnceOnly){
			casRunStop()			
			casRunStartOnceOnly()
		}
		if (runCasStandby){
			casRunStop()
			casRunStandby()
		}
		if (runCasStandby){
			casRunStop()
			casRunAfterDelay()
		}
		if (runCasStandby){
			casRunStop()
			casRunAfterDelayStandby()
		}
		
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"mouseclicklikeliness")){
		posX := Floor(commandsArr[2] * scaleX)
		posY := Floor(commandsArr[3] * scaleY)
		;commandsArr[4] is a value
		;commandsArr[5] is the displayed text
		
		deltaX := 20
		deltaY := 16
		trials := 3
		delay := 3000
		samplepoints := Floor(deltaX * deltaY)
		

		tip("Calculating ... " . commandsArr[5])
		MouseMove, posX, posY,10
		
		sumR := 0
		sumG := 0
		sumB := 0
		xpos := Floor(posX - deltaX/2)
		ypos := Floor(posY - deltaY/2)
		

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
				
				;tip(x . "|" . y . "|" . cs . "|" . rR . "|" . rG . "|" . rB)
				sumR := (0 + rB) + sumR
				sumG := (0 + rG) + sumG
				sumB := (0 + rB) + sumB
				;sleep,1500
				;tip(cs . "|" . sumR . "|" . sumG . "|" . sumB . "|")
				;sleep,1500
			}
		}
		sumR := Floor(sumR/samplepoints)
		sumG := Floor(sumG/samplepoints)
		sumB := Floor(sumB/samplepoints)
		
		tip("" . sumR . " " . sumG . " " . sumB)
		sR := SubStr("" sumR,1,2)
		sG := SubStr("" sumG,1,2)
		sB := SubStr("" sumR,1,2)
		s := sR . sG . sB

		if (commandsArr[4] == s){
			MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY)
			tip("Likeliness is ok!")
		} else {
			tip("Likeliness is bad: " . s . " should be: " . commandsArr[4])
			sleep, %delay%
		}

		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"mouseClickLikelinessTimesDelay")){
		posX := Floor(commandsArr[2] * scaleX)
		posY := Floor(commandsArr[3] * scaleY)
		;commandsArr[4] is a value
		;commandsArr[5] is the displayed text
		;commandsArr[6] is trials
		;commandsArr[7] is delay
		
		deltaX := 20
		deltaY := 16
		trials := commandsArr[6]
		delay := commandsArr[7]
		samplepoints := Floor(deltaX * deltaY)
		
		if (trials == "")
			trials := 3
			
		if (delay == "")
			delay := 10000			
			
		TrialsLoop:		
		Loop, %trials%
		{
			tip("Calculating (trial: " . A_Index . " of " . trials . ") ... " . commandsArr[5])
			
			if (getkeystate("Capslock","T")=1){
				tip("Operation canceled, please release the Capslock-key!")
				sleep,2000
				Break TrialsLoop
			}
			
			MouseMove, posX, posY,10
			
			sumR := 0
			sumG := 0
			sumB := 0
			xpos := Floor(posX - deltaX/2)
			ypos := Floor(posY - deltaY/2)
			
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
					
					;tip(x . "|" . y . "|" . cs . "|" . rR . "|" . rG . "|" . rB)
					sumR := (0 + rB) + sumR
					sumG := (0 + rG) + sumG
					sumB := (0 + rB) + sumB
					;sleep,1500
					;tip(cs . "|" . sumR . "|" . sumG . "|" . sumB . "|")
					;sleep,1500
				}
			}
			sumR := Floor(sumR/samplepoints)
			sumG := Floor(sumG/samplepoints)
			sumB := Floor(sumB/samplepoints)
			
			tip("" . sumR . " " . sumG . " " . sumB)
			sR := SubStr("" sumR,1,2)
			sG := SubStr("" sumG,1,2)
			sB := SubStr("" sumR,1,2)
			s := sR . sG . sB

			if (commandsArr[4] == s){
				MouseClick,Left,Floor(commandsArr[2] * scaleX), Floor(commandsArr[3] * scaleY)
				tip("Likeliness is ok!")
				Break TrialsLoop
			} else {
				if (A_Index < trials)
					tip("Likeliness is bad: " . s . " should be: (" . commandsArr[4]  . ") , try it again ...")
				else
					tip("Likeliness is bad: " . s . " should be: (" . commandsArr[4]  . ")")
				sleep, %delay%
				tipClose()
			}
		}
		enhancedCommand := true
	}
	
	if(eq(commandsArr[1],"exit")){
		casRunStop()
		exit()

		enhancedCommand := true
	}	
	
;***************************************************************************
;must be last! function call mechanism *************************************
;***************************************************************************
	if (!enhancedCommand){
		if (debug)
			showhint("Command not found: """ . commandsArr[1] . """, trying a function-call!", hintTimeShort)
			
		l := commandsArr.Length()
			
		switch l
		{
			case 1: 
				command := commandsArr[1]
				result := %command%()
				if (result != "")
					showHint("Result: " . result, hintTime)
			case 2: 
				command := commandsArr[1]
				result := %command%(commandsArr[2])
				if (result != "")
					showHint("Result: " . result, hintTime)
			case 3: 
				command := commandsArr[1]
				result := %command%(commandsArr[2], commandsArr[3])
				if (result != "")
					showHint("Result: " . result, hintTime)
			case 4: 
				command := commandsArr[1]
				result := %command%(commandsArr[2], commandsArr[3], commandsArr[4])
				if (result != "")
					showHint("Result: " . result, hintTime)
			case 5: 
				command := commandsArr[1]
				result := %command%(commandsArr[2], commandsArr[3], commandsArr[4], commandsArr[5])
				if (result != "")
					showHint("Result: " . result, hintTime)
			case 6: 
				command := commandsArr[1]
				result := %command%(commandsArr[2], commandsArr[3], commandsArr[4], commandsArr[5], commandsArr[6])
			case 7: 
				command := commandsArr[1]
				result := %command%(commandsArr[2], commandsArr[3], commandsArr[4], commandsArr[5], commandsArr[6],commandsArr[7])
				if (result != "")
					showHint("Result: " . result, hintTime)
		}
		IfWinExist, ahk_class #32770
		{
			Sleep 20
			WinActivate, ahk_class #32770
		}
	}
	
	return
}
;********************************* sendEmail *********************************
sendEmail(mailto, subject, body, bccArr){
	global emailpath
	
	bcc := ""
	sub := ""
	bod := ""
	if (bccArr.Length() > 0) {
		loop, % (bccArr.Length()){
			if (A_Index == 1) {
				bcc := "?BCC=" . bccArr[A_Index]
			} else {
				bcc := bcc . "&BCC=" . bccArr[A_Index]
			}
		}
		if (subject == ""){
			bod := "&body="
			sub := ""
		} else {
			sub := "&subject="
			bod := "&body="
		}
	} else {
		if (subject == ""){
			bod := "?body="
			sub := ""
		} else {
			sub := "?subject="
			bod := "&body="
		}
	}
	
	a := emailpath . " " . "mailto:" . mailto . bcc . sub . subject . bod . body
	
	clipboard := a
	run %a%,,max
	return
}
;********************************** nearBy **********************************
nearBy(a,b,d){
	r := true
	
	if (a > b + d)
		r := false
		
	if (a < b - d)
		r := false

	return r
}
;********************************* uriEncode *********************************
; not used
uriEncode(s){
	s := StrReplace(s, A_Space, "%20")
	s := StrReplace(s, "`r", "%0A")
	s := StrReplace(s, "§", "%C2%A7")
	s := StrReplace(s, "$", "%24")
	s := StrReplace(s, "%", "%25")
	s := StrReplace(s, "&", "%26")
	s := StrReplace(s, "/", "%2F")
	s := StrReplace(s, "=", "%3D")
	s := StrReplace(s, "?", "%3F")
	s := StrReplace(s, "@", "%40")
	s := StrReplace(s, "€", "%E2%82%AC")
	s := StrReplace(s, "#", "%23")
	s := StrReplace(s, ";", "%3B")
	s := StrReplace(s, "<", "%3C")
	s := StrReplace(s, ">", "%3E")
	s := StrReplace(s, "[", "%5B")
	s := StrReplace(s, "]", "%5D")
	s := StrReplace(s, "{", "%7B")
	s := StrReplace(s, "}", "%7D")
	s := StrReplace(s, ":", "%3A")
	s := StrReplace(s, "'", "%27")
	s := StrReplace(s, "ß", "%C3%9F")
	
	return s
}
;******************************* commands end *******************************
















