;-------------------------------- cascommands --------------------------------
; clickandsleep enhanced commands

doAction(commandsArr, index){
  global wrkDir, winArr, hintTime, hintTimeShort, debug, showmousemove, runCas
  global casRunStart, casRunStartStandby
  global runCasOnceOnly, runCasStandby, runCasAfterDelay, runCasAfterDelayStandby
  global runDoLoop, debugShowSleep
  global downCounter, sleepDownCounter, counter, delayDownCounter
  global winCon, runPID, runSingleOp, errorLevelMemo
  global defaultShowTime, scriptcoordinateX, scriptcoordinateY
  global configFile, cmdFile, chrome, firefox, edge, errormessage
  global listBoxEntry, deviationMax
  global defaultMouseSpeed
  global Element3_8, Element3_10, Element3_11
  global likenessCheckLoopLongRun, showmousemoveSpeed
  
  enhancedCommand := false
  theCommand := commandsArr[1]
  
  GuiControl,guiMain:, Text5
  
  capslockWaitLoop:
  Loop
  {
    switch getKeyboardState()
    {
      case 1:
        tipWindow("ClickandSleep paused ...",0,0,false)
        sleep,1000
      case 3:
        tipWindow("Jumped over this command: " . theCommand,0,3000)
        sleep,1000
        enhancedCommand := true
        
        return
      case 5:
        runDoLoop := false
        casRunStop()
        tipWindow("Operation aborted!",0,3000)
        break capslockWaitLoop
      default:
        break capslockWaitLoop
    }
  }
  
  if (!runDoLoop)
    return
    
  if(commandsArr.Length() < 1)
    return
    
  if (debug && !eq(SubStr(theCommand,1,3),"rem") && !eq(SubStr(theCommand,1,1), ";") && !eq(SubStr(theCommand,1,2), "//")){
    s := ""
    
    Loop % commandsArr.Length() - 1
    {
      s := s . commandsArr[A_Index] . ", "
    }
    s := index . ": " . s . commandsArr[commandsArr.Length()]
    
    if (eq(theCommand, "sleep") != 0){
      if (debugShowSleep){
        showHint(s, hintTimeShort)
      }
    } else {
      showHint(s, hintTimeShort)
    }
  }

;must be evaluated first!
  if(eq(SubStr(theCommand, 1, 2), "//")){
    if (runSingleOp) {
      ; remove "//"
      if (debug)
        showHint("runSingleOp is activ, executing: " . theCommand, hintTimeShort)
        
      theCommand := Trim(RegExReplace(Trim(theCommand),"^\/\/ *",""))
    } else {
      enhancedCommand := true
      if (debug)
        showHint("Comment ignored: " . theCommand, hintTimeShort)
        
      return
    }
  }
  
    
  if(eq(SubStr(theCommand, 1, 3),"rem")){
    enhancedCommand := true
    return
  }
  
  if(eq(SubStr(theCommand, 1, 1),";")){
    enhancedCommand := true
    return
  }
  
  if(eq(theCommand,"keywait")){
    KeyName := "Escape"
    if (commandsArr[2] != "")
      KeyName := commandsArr[2]
  
    Options := "D"
    if (commandsArr[3] != "")
      Options := commandsArr[3]
  
    s := "Waiting for key to press: " . KeyName
    tipWindow(s,0,0)
    KeyWait, %KeyName%, %Options%
    tipWindowClose()
    
    enhancedCommand := true
    return
  }
  
  if(eq(theCommand,"scriptcoordinates")){
    ;scriptcoordinates command is deprecated: Scaling is removed from version >= 0.317 !
    showHint("Original sceensize was: " . commandsArr[2] . " x " . commandsArr[3], hintTime)
    enhancedCommand := true
  }
  
;random evaluation
  if(eq(theCommand,"errorlevelhint")){
    if errorLevelMemo
    {
      showHint("Errorlevel set to " . errorLevelMemo, hintTime)
    } else {
      showHint("Errorlevel is not set!", hintTime)
    }
    enhancedCommand := true
  }

  if(eq(theCommand,"errorlevelstop")){
    if errorLevelMemo
    {
      casRunStop()
      MsgBox, All operations are aborted`,  because Errorlevel is set to %ErrorLevel%
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"errorlevelexit")){
    if errorLevelMemo
    {
      MsgBox, Errorlevel set to %ErrorLevel%`, exiting!
      exit()
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"winconstop")){
    if (!wincon)
    {
      casRunStop()
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"winconexit")){
    if (!wincon)
    {
      MsgBox, winCon is set to %wincon%`, exiting!
      exit()
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"pushwin")){
    pushWin := WinActive("A")
    winArr.Push(pushWin)
    if (debug)
      showHint("HWND: " . pushWin, hintTimeShort)
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"popwin")){
    popWin := winArr.Pop()
    if (popWin != 0)
      WinActivate, ahk_id %popWin%
    
    if (debug)
      showHint("HWND: " . popWin, hintTimeShort)
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"setwincon")){
    winCon := 1
    enhancedCommand := true
  }
  
  if(eq(theCommand,"resetwincon")){
    winCon := 0
    enhancedCommand := true
  }
  
  if(eq(theCommand,"reseterrorlevel")){
    errorlevelmemo := 0
    enhancedCommand := true
  }
  
;UniqueID := WinExist(WinTitle , WinText, ExcludeTitle, ExcludeText)
  if(eq(theCommand,"winexist")){
    param1 := commandsArr[2]
    param2 := commandsArr[3]
    param3 := commandsArr[4]
    param4 := commandsArr[5]
    winCon := WinExist(param1, param2, param3, param4)
    enhancedCommand := true
  }
  
;WinActivate , WinTitle, WinText, ExcludeTitle, ExcludeText
  if(eq(theCommand,"winactivate")){
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
  if(eq(theCommand,"winwaitactive")){
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
  if(eq(theCommand,"winwait")){
  
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
  if(eq(theCommand,"winmaximize")){
    param1 := commandsArr[2]
    param2 := commandsArr[3]
    WinMaximize, %param1%, %param2%
    PostMessage, 0x112, 0xF030,,, %param1%, %param2%
    enhancedCommand := true
  }
  
;WinMinimize , WinTitle, WinText, ExcludeTitle, ExcludeText
  if(eq(theCommand,"winminimize")){
    param1 := commandsArr[2]
    param2 := commandsArr[3]
    param3 := commandsArr[4]
    param4 := commandsArr[5]
    WinMinimize, %param1%, %param2%, %param3%, %param4%
    enhancedCommand := true
  }

;WinClose , WinTitle, WinText, SecondsToWait, ExcludeTitle, ExcludeText
  if(eq(theCommand,"winclose")){
    param1 := commandsArr[2]
    param2 := commandsArr[3]
    param3 := commandsArr[4]
    param4 := commandsArr[5]
    param5 := commandsArr[6]
    WinClose, %param1%, %param2%, %param3%, %param4%, %param5%
    enhancedCommand := true
  }
  
  
;wait or sleep: identical
  if(eq(theCommand,"wait") || eq(theCommand,"sleep")){
    tipWindowClose()
    dst := defaultShowTime
    
    if (commandsArr[2] != "")
      dst := commandsArr[2]
      
    if (commandsArr[3] != "")
      tipWindow("Sleep " . dst . " milliseconds " . " " . commandsArr[3],0,dst,false)
      
    Sleep, dst

    enhancedCommand := true
  }
  
  if(eq(theCommand,"sleeplong")){
    tipWindowClose()
    dst := 10
    if (commandsArr[2] != "")
      dst := commandsArr[2]
    
    sleepDownCounter := 0 . dst
    
    sleepdown:
    Loop
    {
      switch getKeyboardState()
      {
        case 0:
          sleepDownCounter := sleepDownCounter - 1
          if (commandsArr[3] != "-")
            tipWindow("Sleeplong: " . formatTimeSeconds(sleepDownCounter) . " " . commandsArr[3],150,5000,false)
        case 1:
          tipWindow("Sleeplong hold on: " . formatTimeSeconds(sleepDownCounter) . " " . commandsArr[3],150,0,false)
        case 3:
          tipWindow("Sleeplong finished by user interaction!",0,2000)
          sleepDownCounter := 0
          break sleepdown
        case 5:
          casRunStop()
          tipWindow("Operation aborted!",0,2000)
          sleep, 1000
          break sleepdown
      }

      if (sleepDownCounter < 1){
        break sleepdown
      } else {
        sleep, 1000
      }
    }
    enhancedCommand := true
  }
  
  if(eq(theCommand, "mousemove")){
    x := 0 + commandsArr[2]
    y := 0 + commandsArr[3]
    speed := 0 + defaultMouseSpeed + commandsArr[4]
    if (speed > 100 || speed < 10)
      speed := defaultMouseSpeed
    
    if (showmousemove){
      MouseMove, x, y,%showmousemoveSpeed%
    } else {
      MouseMove, x, y, %speed%
    }
    MouseGetPos, posX, posY
    
    if(posX != x)
      msgbox, MouseMove-error, x should be: %x% but is: %posX%
      
    if(posY != y)
      msgbox, MouseMove-error, y should be: %y% but is: %posY%
    
    enhancedCommand := true
  }
  
  ;MouseClick , WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative
  ;1           ,X          ,2 , 3, 4          5      6         7
  if(eq(theCommand, "mouseclick")){

    updown := ""
    if (commandsArr[5] == "U")
      updown := "U"
      
    if (commandsArr[5] == "D")
      updown := "D"
      
    relativ := ""
    if (commandsArr[6] == "R")
      relativ := "R"
      
    posX := commandsArr[2]
    posY := commandsArr[3]
    speed := commandsArr[4]
    
    if (showmousemove){
      MouseMove, posX, posY,%showmousemoveSpeed%
      sleep,1000
    }
    
    MouseClick,Left, posX, posY,, speed, %updown%, %relativ%
    
    enhancedCommand := true
  }
  
  ;Click, Options
  if(eq(theCommand, "click")){
    options := "" . commandsArr[2]
    
    Click, %options%
    
    enhancedCommand := true
  }
  
  if(eq(theCommand, "mousedblclick")){
  
    updown := ""
    if (commandsArr[5] == "U")
      updown := "U"
      
    if (commandsArr[5] == "D")
      updown := "D"
      
    relativ := ""
    if (commandsArr[6] == "R")
      relativ := "R"
      
    posX := commandsArr[2]
    posY := commandsArr[3]
    speed := commandsArr[4]
    
    if (showmousemove){
      MouseMove, posX, posY,%showmousemoveSpeed%
      sleep,1000
    }
    
    MouseClick, Left, posX, posY, 2, speed, %updown%, %relativ%
      
    enhancedCommand := true
  }
  
  if(eq(theCommand, "mouseclickaround")){
    delta := 1
    increment := 1
    x := commandsArr[2]
    y := commandsArr[3]
    offset := commandsArr[4]
    if (commandsArr[5] != "")
      increment := commandsArr[5]
      
    if (showmousemove){
      MouseMove, x, y,%showmousemoveSpeed%
      sleep,1000
    }
    
    MouseClick,Left, %x%, %y%
    while (delta < offset)
    {
      a := x + delta
      b := y + delta
      c := x - delta
      d := y - delta
      MouseClick,Left, a, y
      MouseClick,Left, a, b
      MouseClick,Left, x, b
      MouseClick,Left, c, b
      MouseClick,Left, c, y
      MouseClick,Left, c, d
      MouseClick,Left, x, d
      MouseClick,Left, a, d
      
      delta := delta + 5
    }
    enhancedCommand := true
  }
  
  if(eq(theCommand, "mouseclickright")){
    x := commandsArr[2]
    y := commandsArr[3]
    speed := commandsArr[4]
    
    updown := ""
    if (commandsArr[5] == "U")
      updown := "U"
      
    if (commandsArr[5] == "D")
      updown := "D"
      
    relativ := ""
    if (commandsArr[6] == "R")
      relativ := "R"
    
    if (showmousemove){
      MouseMove, x, y,%showmousemoveSpeed%
      sleep,1000
    }
    
    MouseClick,Right, x, y,, speed, %updown%, %relativ%
    enhancedCommand := true
  }
  
  if(eq(theCommand, "mouseclickrandom3")){
    Random, rnd , 1, 3

    switch rnd
    {
      case 1:
        x := commandsArr[2]
        y := commandsArr[3]
        
        if (showmousemove){
          MouseMove, x, y,%showmousemoveSpeed%
          sleep,1000
        }
        
        MouseClick,Left, x, y
        if (debug)
          showHint("Selecteed random 1", hintTimeShort)
      case 2:
        x := commandsArr[4]
        y := commandsArr[5]
        
        if (showmousemove){
          MouseMove, x, y,%showmousemoveSpeed%
          sleep,1000
        }
        
        MouseClick,Left, x, y
        if (debug)
          showHint("Selected random 2", hintTimeShort)
      case 3:
        x := commandsArr[6]
        y := commandsArr[7]
        
        if (showmousemove){
          MouseMove, x, y,%showmousemoveSpeed%
          sleep,1000
        }
        
        MouseClick,Left, x, y
        if (debug)
          showHint("Selected random 3", hintTimeShort)
    }
    enhancedCommand := true
  }
  
  if(eq(theCommand,"send")){
    s := commandsArr[2]
    send, %s%
    enhancedCommand := true
  }
  
  if(eq(theCommand,"sendraw")){
    s := commandsArr[2]
    sendraw, %s%
    enhancedCommand := true
  }
  
  if(eq(theCommand,"sendtext")){
    s := "{Text}" . commandsArr[2]
    send, %s%
    enhancedCommand := true
  }

  if(eq(theCommand,"sendblindtext")){
    s := "{Blind}{Text}" . commandsArr[2]
    send, %s%
    enhancedCommand := true
  }
  
;Run, Target , WorkingDir, Options, OutputVarPID=runPID (name fixed!)
  if(eq(theCommand,"run")){
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
          Run %appPath%, %param2%, %param3%,runPID
          
      }
    } else {
      if(debug)
        showHint("Run not executed because winCon condition is true!", hintTimeShort)
    }
    enhancedCommand := true
  }
  
  if(eq(theCommand,"showhint")){
    dst := defaultShowTime
    if (commandsArr[3] != "")
      dst := commandsArr[3]
    showHint(commandsArr[2], dst)
    enhancedCommand := true
  }
  
  if(eq(theCommand,"showhinterror")){
    dst := defaultShowTime
    if (commandsArr[3] != "")
      dst := commandsArr[3]
      
    if errorLevelMemo
      showHint(commandsArr[2], dst)
      
    enhancedCommand := true
  }
  
  if(eq(theCommand,"showvar")){
    dst := defaultShowTime
    if (commandsArr[3] != "")
      dst := commandsArr[3]
        
    vName := commandsArr[2]
    vValue:= %vName%
      
    tipTopTime("Variable: " . vName . " has value: " . vValue, 10000)
      
    enhancedCommand := true
  }
  
  if(eq(theCommand,"showpid")){
    dst := defaultShowTime
    if (commandsArr[2] != "")
      dst := commandsArr[2]
    showHint(runPID, dst)
    enhancedCommand := true
  }
  
  if(eq(theCommand,"sendemail")){
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
  
  if(eq(theCommand,"debugstoprun")){
    setTimer,countDown,delete
  
    showHint("Run completely stopped because off debugStopRun!", hintTime)
    
    casRunStop()
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugon")){
    debug :=  true
    showhint("Debug ON", hintTimeShort)
      
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugoff")){
    if (debug)
      showhint("Debug OFF", hintTimeShort)
    
    debug :=  false
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugshowsleepoff")){
    debugShowSleep :=  false
    if (debug)
      showhint("debugShowSleep OFF", hintTimeShort)
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugshowsleepon")){
    debugShowSleep :=  true
    if (debug)
      showhint("debugShowSleep ON", hintTimeShort)
      
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugshowmousemoveon")){
    showmousemove :=  true
    showHint("DebugShowMouseMove is ON", hintTimeShort)
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"debugshowmousemoveoff")){
    showmousemove :=  false
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"tip")){
    Gui +OwnDialogs
    msg := commandsArr[2]
    s := StrReplace(msg,"^",",")
    ToolTip, %s%,,,1

    SetTimer,tipTopClose,-3000
    enhancedCommand := true
  }
  
  if(eq(theCommand,"tiptop")){
    Gui +OwnDialogs
    msg := commandsArr[2]
    s := StrReplace(msg,"^",",")
    ToolTip, %s%,(A_ScreenWidth / 2),2,3
    SetTimer,tipTopClose,-3000
    enhancedCommand := true
  }
  
  if(eq(theCommand,"tipat")){
    Gui +OwnDialogs
    msg := commandsArr[4]
    s := StrReplace(msg,"^",",")
    ToolTip, %s%,commandsArr[2],commandsArr[3],2

    SetTimer,tipTopClose,-5000
    enhancedCommand := true
  }
  
  if(eq(theCommand,"tipwindow")){
    Gui +OwnDialogs
    msg := commandsArr[2]
    
    transp := 0
    if(commandsArr[3] != "")
      transp := 0 + commandsArr[3]
      
    timeout := 0
    if(commandsArr[4] != "")
      timeout := 0 + commandsArr[4]     

    refresh := true
    if(eq(commandsArr[5],"norefresh"))
      refresh := false
      
    tipWindowRun(msg, transp, timeout, refresh)
    enhancedCommand := true
  }
  
   if(eq(theCommand,"tipwindowclose")){
    tipWindowRunClose()
    enhancedCommand := true
  } 
  
  
  if(eq(theCommand,"openchrome")){
    winCon := 0
    errorlevelmemo := 0
    winCon := WinExist("ahk_exe chrome.exe")
    if (winCon){
      WinClose, ahk_exe chrome.exe,,10
      sleep, 1000
    }
    winCon := WinExist("ahk_exe chrome.exe")
    if (!winCon){
      url := commandsArr[2]
      Run, %chrome% %url%,,,runPID 
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
      tipWindow("Error, Chrome not running!",0,3000)
    }
    WinGet, runPID, PID, ahk_exe chrome.exe
    if (debug)
      tipWindow("PID: " . runPID,0,3000)
    
    sleep, 5000
    if(runSingleOp)
      refreshGui()
    
    enhancedCommand := true
  }

  if(eq(theCommand,"activatechrome")){
    winCon := 0
    errorlevelmemo := 0
    winCon := WinExist("ahk_exe chrome.exe")
    if (winCon){
      WinActivate,ahk_class Chrome_WidgetWin_1
    } else {
      tipWindow("Error, Chrome not running!",0,3000)
    }

    enhancedCommand := true
  }

  if(eq(theCommand,"openedge")){
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
      Run, %chrome% %url%,,,runPID 
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
      tipWindow("Error, Chrome not running!",0,3000)
    }
    WinGet, runPID, PID, ahk_exe msedge.exe
    if (debug)
      tipWindow("PID: " . runPID,0,300)
    
    sleep, 5000
    if(runSingleOp)
      refreshGui()
      
    enhancedCommand := true
  }

  if(eq(theCommand,"activateedge")){
    winCon := 0
    errorlevelmemo := 0
    winCon := WinExist("ahk_exe msedge.exe")
    if (winCon){
      WinActivate,ahk_exe msedge.exe
    } else {
      tipWindow("Error, Edge not running!",0,3000)
    }
    
    enhancedCommand := true
  }  

  if(eq(theCommand,"openfirefox")){
    winCon := 0
    winCon := WinExist("ahk_class MozillaWindowClass")
    if (winCon){
      tipWindow("Please be patient, it takes a while to close the running Firefox!"0,1000)
      WinClose, ahk_id %winCon%,,10
      sleep,10000  
    }
    winCon := 0
    winCon := WinExist("ahk_class MozillaWindowClass")
    if (winCon){
      MsgBox, Error, could not close Firefox (%winCon%), continuing ...`n(with possible wrong URL)
    }
    url := commandsArr[2]
    Run, %firefox% %url%
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
      tipWindow("Error, Firefox not running!",0,3000)
    }
    WinGet, runPID, PID, ahk_id %winCon%
    if (debug)
      tipWindow("PID: " . runPID,0,3000)
    
    sleep, 5000
    if(runSingleOp)
      refreshGui()
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"activatefirefox")){
    winCon := 0
    errorlevelmemo := 0
    winCon := WinExist("ahk_class MozillaWindowClass")
    if (winCon){
      WinActivate,ahk_class MozillaWindowClass 
    } else {
      tipWindow("Error, Firefox not running!",0,3000)
    }  
    
    enhancedCommand := true
  }
  

  if(eq(theCommand,"closechrome")){
    WinClose, ahk_exe chrome.exe,,10
    sleep,1000
    winCon := 0
    winCon := WinExist("ahk_exe chrome.exe")

    enhancedCommand := true
  }

  if(eq(theCommand,"closefirefox")){
    WinClose, ahk_class MozillaWindowClass,,10
    sleep,1000
    winCon := 0
    winCon := WinExist("ahk_class MozillaWindowClass")

    enhancedCommand := true
  }
  
  if(eq(theCommand,"closeedge")){
    WinClose, ahk_exe msedge.exe,,10
    sleep,1000
    winCon := 0
    winCon := WinExist("ahk_exe msedge.exe")

    enhancedCommand := true
  }
  
  if(eq(theCommand,"loadset")){
    p := trim(commandsArr[2])
    p := cvtPath(p)
    
    if (FileExist(p . ".txt") != ""){
      cmdFile := p . ".txt"
      GuiControl,guiMain:,Element3_8,%cmdFile%
      removeErrorMessage()
    } else {
      showErrorMessage("File not found: " . p . ".txt, active Command-file not changed!")
    }
    
    if (FileExist(p . ".ini") != ""){
      configFile := p . ".ini"
      GuiControl,guiMain:,Element3_10,%configFile%
      removeErrorMessage()
    } else {
      showErrorMessage("Active Config-file not changed!")
    }
      
    setTimer,cmdselectSetEntryReset,-1000

    prepare()
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
  
  if(eq(theCommand,"mouseclicklikeness")){
    tipWindowClose()
    posX := commandsArr[2]
    posY := commandsArr[3]
    ;commandsArr[4] is a value
    ;commandsArr[5] is the displayed text
    
    if (showmousemove){
      MouseMove, posX, posY,%showmousemoveSpeed%
      sleep,1000
    }
    
    deltaX := 20 ;only even allowed!
    deltaY := 16 ;only even allowed!
    delay := 3000
    samplepoints := deltaX * deltaY

    tipWindow("Calculating ... " . commandsArr[5],0,0)
    
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
        PixelGetColor, cl, %x%, %y%
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

    shouldBe := commandsArr[4]
    shouldBeR := BaseToDec(SubStr(shouldBe,1,2),16)
    shouldBeG := BaseToDec(SubStr(shouldBe,3,2),16)
    shouldBeB := BaseToDec(SubStr(shouldBe,5,2),16)
    
    deviation := abs(sumR - shouldBeR) + abs(sumG - shouldBeG) + abs(sumB - shouldBeB)

    if (deviation <= deviationMax){
      MouseClick,Left,commandsArr[2], commandsArr[3]
      tipWindow("Likeness is ok!",0,delay)
    } else {
      likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
      clipboard := likeness
      tipWindow("Likeness (" . likeness  . "), deviation is: " . deviation . ", should be < " . deviationMax,0,delay)
      sleep, %delay%
    }

    enhancedCommand := true
  }
  
  if(eq(theCommand,"mouseclicklikenessfast")){
    tipWindowClose()
    posX := commandsArr[2]
    posY := commandsArr[3]
    ;commandsArr[4] is a value
    ;commandsArr[5] is the displayed text
    
    if (showmousemove){
      MouseMove, posX, posY,%showmousemoveSpeed%
      sleep,1000
    }
    
    deltaX := 8 ;only even allowed!
    deltaY := 8 ;only even allowed!
    delay := 3000
    samplepoints := deltaX * deltaY

    tipWindow("Calculating ... " . commandsArr[5],0,0)
    
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
        PixelGetColor, cl, %x%, %y%
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

    shouldBe := commandsArr[4]
    shouldBeR := BaseToDec(SubStr(shouldBe,1,2),16)
    shouldBeG := BaseToDec(SubStr(shouldBe,3,2),16)
    shouldBeB := BaseToDec(SubStr(shouldBe,5,2),16)
    
    deviation := abs(sumR - shouldBeR) + abs(sumG - shouldBeG) + abs(sumB - shouldBeB)

    if (deviation <= deviationMax){
      MouseClick,Left,commandsArr[2], commandsArr[3]
      tipWindow("Likeness is ok!",0,delay)
    } else {
      likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
      clipboard := likeness
      tipWindow("Likeness (" . likeness  . "), deviation is: " . deviation . ", should be < " . deviationMax,0,delay)
      sleep, %delay%
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"mouseClickLikenessTimesDelay")){
    tipWindowClose()
    posX := commandsArr[2]
    posY := commandsArr[3]
    ;commandsArr[4] is a value
    ;commandsArr[5] is trials
    ;commandsArr[6] is delay
    ;commandsArr[7] is the displayed text
    
    if (showmousemove){
      MouseMove, posX, posY,%showmousemoveSpeed%
      sleep,1000
    }
    
    deltaX := 20 ;only even allowed!
    deltaY := 16 ;only even allowed!
    trials := 3
    delay := 10000
    
    samplepoints := deltaX * deltaY
    
    if (commandsArr[6] != "")
      trials := 0 + commandsArr[5]
      
    if (commandsArr[7] != "")
      delay := 10 + commandsArr[6]
    
    TrialsLoop:
    Loop, %trials%
    {
      tipWindow("Calculating (trial: " . A_Index . " of " . trials . ") ... " . StrReplace(commandsArr[7],"^",","),0,0,false)
      if (getkeystate("Capslock","T")){
        tipWindow("Operation canceled, please release the Capslock-key!",0,0)
        sleep,2000
        Break TrialsLoop
      }
      
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
          PixelGetColor, cl, %x%, %y%
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
      
      shouldBe := commandsArr[4]
      shouldBeR := BaseToDec(SubStr(shouldBe,1,2),16)
      shouldBeG := BaseToDec(SubStr(shouldBe,3,2),16)
      shouldBeB := BaseToDec(SubStr(shouldBe,5,2),16)
      
      deviation := abs(sumR - shouldBeR) + abs(sumG - shouldBeG) + abs(sumB - shouldBeB)

      if (deviation <= deviationMax){
        MouseClick,Left,commandsArr[2], commandsArr[3]
        tipWindow("Likeness is ok!",0,delay)
        sleep, %delay%
        Break TrialsLoop
      } else {
        if (A_Index < trials){
          tipWindow("Likeness deviation is: " . deviation . ", should be < " . deviationMax . ", try it again ... ",0,delay)
        } else {
          likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
          clipboard := likeness
          tipWindow("Likeness (" . likeness  . "), deviation is: " . deviation . ", should be < " . deviationMax,0,delay)
        }
      }
      sleep, %delay%
    }
    enhancedCommand := true
  }
;----------------------------- sleeplikenessfast -----------------------------
  if(eq(theCommand,"sleeplikenessfast")){
    maxcount := 360
    if (commandsArr[5] != ""){
      maxcount := 0 + commandsArr[5]
    }
    
    likenessCheckLoop:
    Loop, %maxcount%
    {
      tipWindowClose()
      posX := commandsArr[2]
      posY := commandsArr[3]
      ;commandsArr[4] is a value
      ;commandsArr[5] is maxcount
      ;commandsArr[6] is the displayed text
      
      if (showmousemove){
        MouseMove, posX, posY,%showmousemoveSpeed%
        sleep,1000
      }
      
      deltaX := 8 ;only even allowed!
      deltaY := 8 ;only even allowed!
      delay := 10000
      samplepoints := deltaX * deltaY

      tipWindow("Calculating (trial: " . A_Index . " of " . maxcount . ") ... " . StrReplace(commandsArr[6],"^",","),0,0)
      
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
          PixelGetColor, cl, %x%, %y%
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

      shouldBe := commandsArr[4]
      shouldBeR := BaseToDec(SubStr(shouldBe,1,2),16)
      shouldBeG := BaseToDec(SubStr(shouldBe,3,2),16)
      shouldBeB := BaseToDec(SubStr(shouldBe,5,2),16)
      
      deviation := abs(sumR - shouldBeR) + abs(sumG - shouldBeG) + abs(sumB - shouldBeB)

      if (deviation <= deviationMax){
        tipWindow("Likeness is ok!",0,delay)
        break likenessCheckLoop
      } else {
        ;likeness := "" . DecToBase(sumR,16) . DecToBase(sumG,16) . DecToBase(sumB,16)
        likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
        clipboard := likeness
        tipWindow("Waiting: likeness (" . likeness  . "), deviation is: " . deviation . ", should be < " . deviationMax,0,delay)
        
        switch getKeyboardState()
        {
          case 1:
            tipWindow("Command aborted!",150,2000)
            break likenessCheckLoop
          case 5:
            tipWindow("Aborted!",150,2000)
            casRunStop()
            break likenessCheckLoop
          default:
            sleep, %delay%
        }
      }
    }
    
    enhancedCommand := true
  }
;--------------------------- sleeplikenessfastlong ---------------------------
  if(eq(theCommand,"sleeplikenessfastlong")){
    slflWin := WinActive("A")
    slflSleep := commandsArr[5]
    if (slflSleep == "")
      slflSleep := 1

    testtime := slflSleep * 60000
    delaybetween := 10000
    likenessCheckLoopCounter := 0
    likenessCheckLoopLongRun := true

    tipWindowClose()
    posX := commandsArr[2]
    posY := commandsArr[3]
    ;commandsArr[4] is a value
    ;commandsArr[5] is slflSleep (minutes) 
    ;commandsArr[6] is the displayed text
    
    deltaX := 8 ;only even allowed!
    deltaY := 8 ;only even allowed!
    delay := 10000
    samplepoints := deltaX * deltaY
    
    likenessCheckLoopLong:
    Loop
    {
      if (!likenessCheckLoopLongRun)
        break likenessCheckLoopLong
        
      likenessCheckLoopCounter:= A_Index
      if (slflWin != 0)
        WinActivate, ahk_id %slflWin%
      
      if (showmousemove){
        MouseMove, posX, posY,%showmousemoveSpeed%
        sleep,1000
      }
      
      tipWindow("Calculating ... " . StrReplace(commandsArr[6],"^",","),0,0)
      
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
          PixelGetColor, cl, %x%, %y%
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

      shouldBe := commandsArr[4]
      shouldBeR := BaseToDec(SubStr(shouldBe,1,2),16)
      shouldBeG := BaseToDec(SubStr(shouldBe,3,2),16)
      shouldBeB := BaseToDec(SubStr(shouldBe,5,2),16)
      
      deviation := abs(sumR - shouldBeR) + abs(sumG - shouldBeG) + abs(sumB - shouldBeB)

      if (deviation <= deviationMax){
        tipWindow("Likeness is ok!",0,delay)
        break likenessCheckLoopLong
      } else {
        remainingSeconds := (slflSleep - likenessCheckLoopCounter) * 60
        likeness := Format("{1:02x}{2:02x}{3:02x}",sumR,sumG,sumB)
        clipboard := likeness
        
        ; polling ... not the ultimate solution ...
        
        Loop, 60
        {
          nextTestIn := 60 - A_Index
           switch getKeyboardState()
          {
            case 1:
              if (WinActive("A") == slflWin){
                tipWindow("Command canceled!",150,3000)
                break likenessCheckLoopLong
              }
            case 5:
              if (WinActive("A") == slflWin){
                tipWindow("All operations aborted!",150,3000)
                casRunStop()
                break likenessCheckLoopLong
              }
            default:
              tipWindow("Likeness is " . likeness  . ", should be " . shouldBe . ", deviation is: " . deviation . ", should be < " . deviationMax . ", remaining test-duration: " . formatTimeSeconds(remainingSeconds - A_Index) . ", next test in: " . nextTestIn . " seconds!",150,0,false)
          }
        sleep, 1000
        }
      }
    }
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"coordmode")){
    param1 := commandsArr[2]
    param2 := commandsArr[3]
    CoordMode, %param1% , %param2%
    
    enhancedCommand := true
  }
  
  if(eq(theCommand,"coordmodereset")){
    CoordMode, Mouse, Client
    CoordMode, Pixel, Client
    CoordMode, Caret, Client
    CoordMode, ToolTip, Screen
    
    enhancedCommand := true
  }

;----------------------------------- exit -----------------------------------
  if(eq(theCommand,"exit")){
    casRunStop()
    exit()

    enhancedCommand := true
  }
  
;***************************************************************************
;must be last! function call mechanism *************************************
;***************************************************************************
  if (!enhancedCommand){
    if (debug)
      showhint("Command not found: """ . theCommand . """, trying a function-call!", hintTimeShort)
      
    l := commandsArr.Length()
      
    switch l
    {
      case 1: 
        command := theCommand
        result := %command%()
        if (result != "")
          showHint("Result: " . result, hintTime)
      case 2: 
        command := theCommand
        result := %command%(commandsArr[2])
        if (result != "")
          showHint("Result: " . result, hintTime)
      case 3: 
        command := theCommand
        result := %command%(commandsArr[2], commandsArr[3])
        if (result != "")
          showHint("Result: " . result, hintTime)
      case 4: 
        command := theCommand
        result := %command%(commandsArr[2], commandsArr[3], commandsArr[4])
        if (result != "")
          showHint("Result: " . result, hintTime)
      case 5: 
        command := theCommand
        result := %command%(commandsArr[2], commandsArr[3], commandsArr[4], commandsArr[5])
        if (result != "")
          showHint("Result: " . result, hintTime)
      case 6: 
        command := theCommand
        result := %command%(commandsArr[2], commandsArr[3], commandsArr[4], commandsArr[5], commandsArr[6])
      case 7: 
        command := theCommand
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
;--------------------------------- sendEmail ---------------------------------
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
;------------------------------- tipWindowRun -------------------------------
tipWindowRun(msg, transp, timeout, refresh := true){
  ; using own Gui
  global font, fontsize
  
  static text1Hwnd := 0
  static tipWindowTextWidth := 0
  static newtipWindowTextWidth := 0
  
  s := StrReplace(msg,"^",",")
    
  if (refresh){
    tipWindowRunClose()
    sleep,100
  }
  
  DetectHiddenWindows, On
  tipWindowRunhwnd := WinExist("ThetipWindowRun")
  
  if (tipWindowRunhwnd == 0){
    Gui, tipWindowRun:New,-Caption +AlwaysOnTop -dpiScale HwndtipWindowRunhwnd

    Gui, tipWindowRun:Font, s%fontsize%, %font%
    Gui, tipWindowRun:Margin, 2, 2
    Gui, tipWindowRun:Add, Text, Hwndtext1Hwnd R1 Center
    newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
    Gui, tipWindowRun:Show, xCenter y1 NoActivate Autosize,ThetipWindowRun
    tipWindowTextWidth := newtipWindowTextWidth
  } else {   
    newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
    if (newtipWindowTextWidth != tipWindowTextWidth){
      tipWindowTextWidth := newtipWindowTextWidth
      tipWindowRunClose()
      Gui, tipWindowRun:New,-Caption +AlwaysOnTop -dpiScale
      Gui, tipWindowRun:Font, s%fontsize%, %font%
      Gui, tipWindowRun:Margin, 2, 2
      Gui, tipWindowRun:Add, Text, Hwndtext1Hwnd R1 Center
      newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
      Gui, tipWindowRun:Show, xCenter y1 NoActivate Autosize,ThetipWindowRun
    }
  }
  
  if (transp != 0){
    WinSet, Transparent, %transp%, ahk_id %tipWindowRunhwnd%
  }
    
  if (timeout != 0){
    t := -1 * timeout
    setTimer,tipWindowRunClose,delete
    setTimer,tipWindowRunClose,%t%
  }


  return
}
;----------------------------- tipWindowRunClose -----------------------------
tipWindowRunClose(){
  global tipWindowRun

  setTimer,tipWindowRunClose,delete
  Gui,tipWindowRun:Destroy
  
  return
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
;------------------------------- commands end -------------------------------














