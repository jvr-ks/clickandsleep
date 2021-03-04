#### Latest changes: [-> README](README.md)

* "autorun" is inhibited if Capslock-key is activated during app-start!
* Next excution time-display is transparent
* [run] section of Config-file, autorun= can be
* * off
* * runRepeated  
* * runAfterDelay  
* * runStandby  
* * runAfterDelayStandby  
* * otherwise equals to off 
* "mouseClickLikelinessTimesDelay" parameter order changed, comment field added (displayed in TopTip)
* "mouseclicklikeliness" comment field added (displayed in TopTip)
* SingleStep corrected
* ToolTip display changed
* **mousedblClick** command
* Mouseclicks are really done in Mouserecord-mode
* **Mouserecord mechanism changed:**  
1. Use hotkey (default: ^!q = \[CTRL] + \[ALT] + \[q]) to start the Mouserecord-function.  
While Mouserecord-function is running, the actual coordinates are displayed at the cursor-position.  
With each mousecklick (or double-click) this two commands are appended to the actual Command-file:  
1. //mouseClick, x-coordinate, y-coordinate   (or mousedblClick)
2. //mouseClickLikeliness, x-coordinate, y-coordinate, ca-value \*1)  
To stop the Mouserecord-mode, push the hotkey again or make a right-click anywhere on the screen!   

\*1) Checks the colors in a 20 X 16 pixel area.  
"ca-value" is each mean-sum of R|G|B colors of the screen-pixels.  
Slow operation! (if in Config-file recordlikeliness="ON")
 
* Memory-leaks removed  
* New Button "Toggle comment ;"  
* Button "hide" removed  
* "showcaswin" command removed  
* Win operations renamed to: "pushWin", "popWin"  
* Exe is 64bit now
* Using DLL call to shutdown, no * psshutdown.exe needed.
* Remove bugs left over from combining the two Guis
*New commad: exit  
stops operation and completely removes ClickAndSleep from memory  
* New Gui
* Command **mouseClickLikeliness** changed  
* New **mouseClickLikelinessTimesDelay** command  
* ~openFirefox has bugs ...~
* ~Command: **mouseClickLikeliness**  enhanced with more parameter~s  
* New command: **mouseClickLikeliness**  
* Default hotkey changed again to **[ ALT ] + [ q ]**  
* Comment not ignored anymore
* New command:  **tipAt**   
* New command: mouseClickAround,x,y,maxoffset,[increment]
Sometimes coordinates change a little bit (especially in browsers) from call to call.  
Use mouseClickAround to click at multible points around x,y incremented by optional "increment" (default: 1 [px]) until "offset" is reached.  
* mouse commands changed  
Simplified, only 3 commands kept.  
  
  
##### TODO
* Run (repeated/standby), delayed (once/standby)

  
[-> README](README.md)


