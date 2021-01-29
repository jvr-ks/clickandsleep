showHint(s, n){
	Gui, hint:Font, s14, Calibri
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show
	sleep, n
	Gui, hint:Destroy
	return
}


