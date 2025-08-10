#### Latest changes: 
[-> README](README.md)
    
Version (>=)| Change
------------ | -------------
0.438 | Repeatcounter bug fixed
0.437 | A32 version removed, some bugfixes
0.428 | SingleStep with Doubleclick (or the Button)
0.236 | sleepLong: Is always displayed, besides using "-" as text, example: sleepLong,5,-
  
#### Known issues / bugs 
Issue / Bug | Type | fixed in version
------------ | ------------- | -------------
loadset: only configuration-files in the main directory are found | bug | -
  
#### Latest changes, older entries:  
* record mouseclick changed: default or with shift or ctrl modifier  
* "recordlikeness=" in config (default is "clickandsleep.ini") removed
* Small button "CAS" (the "Opener button)) is now shown at top-left, if CAS is in the backgound.   
(openerDeltaX = button x-distance to 0), \[config] -> showCLSOpener="yes"  
* CapsLock auto-released
* mousemove: \[config] -> defaultMouseSpeed, (default is: 20)
* Gui-paramter filename default is "clickandsleep.gui", filename is configurable, Config-file: \[config] -> \[setup] -> guiFile="(path\)filename"  
* Config-file: \[config] -> "internalDebug" parameter
* Config-file: dpiScale="" is default, optional dpiScale="-DPIScale"
* Config-file: "linesInList" entry removed, "listBoxHeight" entry added
* All "*likeness"-commands copy the calculated value to the clipboard!
* coordModeReset command
* coordMode command
* sleepLikenessFastLong
* debugShowMouseMoveON   
* debugShowMouseMoveOFF   
* The click is passed thru after the color values are recorded
* Capslock bug fixed
* Record DoubleClick by holding the Shift-key down!  
* * No mouseClickLikeness recorded then.  
* **mouseClickLikenessTimesDelay** parameter order changed, Text is last now.
* Typo "likeleness", must be "likeness"!s
* **sleepLikenessFast** waits until color (8 x 8 pixel) becomes the value.
* Scaling completely removed! Due to rounding errors positioning was inexact otherwise!
* deviationMax can be set in the \[config] section of Config-file.  
* "mouseclicklikeness/fast/TimesDelay" changed, made tolerant to small deviations.
* CoordMode (Mouse, Pixel, ToolTip and Caret) is set to "Client", not changable!
* "mouseclicklikenessfast" command, checks only 10 x 8 pixels, is faster therefor.  
* bug closing app after a few seconds
* **Sleep** and **sleeplong**: ToolTip only shown if the paramter "message" is not empty.
* "autorun" is inhibited if Capslock-key is activated during app-start!
* Next excution time-display is transparent
* \[run] section of Config-file, autorun= can be
* * off
* * runRepeated  
* * runAfterDelay  
* * runStandby  
* * runAfterDelayStandby  
* * otherwise equals to off 
* "mouseClickLikenessTimesDelay" parameter order changed, comment field added (displayed in TopTip)
* "mouseclicklikeness" comment field added (displayed in TopTip)
* SingleStep corrected
* ToolTip display changed
* **mousedblClick** command
* Mouseclicks are really done in Mouserecord-mode
* **Mouserecord mechanism changed:**  
1. Use hotkey (default: ^!q = \[CTRL] + \[ALT] + \[q]) to start the Mouserecord-function.  
While Mouserecord-function is running, the actual coordinates are displayed at the cursor-position.  
With each mousecklick (or double-click) this two commands are appended to the actual Command-file:  
1. //mouseClick, x-coordinate, y-coordinate   (or mousedblClick)
2. //mouseClickLikeness, x-coordinate, y-coordinate, ca-value \*1)  
To stop the Mouserecord-mode, push the hotkey again or make a right-click anywhere on the screen!   

\*1) Checks the colors in a 20 X 16 pixel area.  
"ca-value" is each mean-sum of R|G|B colors of the screen-pixels.  
Slow operation! (if in Config-file recordlikeness="ON")
 
 
* "showcaswin" command removed  
* Win operations renamed to: "pushWin", "popWin"  
* Exe is 64bit now
* Using DLL call to shutdown, no * psshutdown.exe needed.
* Remove bugs left over from combining the two Guis
*New commad: exit  
stops operation and completely removes ClickAndSleep from memory  
* New Gui
* Command **mouseClickLikeness** changed  
* New **mouseClickLikenessTimesDelay** command  
* ~openFirefox has bugs ...~
* ~Command: **mouseClickLikeness**  enhanced with more parameter~s  
* New command: **mouseClickLikeness**  
* Default hotkey changed again to **\[ ALT ] + \[ q ]**  
* Comment not ignored anymore
* New command:  **tipAt**   
* New command: mouseClickAround,x,y,maxoffset,\[increment]
Sometimes coordinates change a little bit (especially in browsers) from call to call.  
Use mouseClickAround to click at multible points around x,y incremented by optional "increment" (default: 1 \[px]) until "offset" is reached.  
* mouse commands changed  
Simplified, only 3 commands kept.  
  
  
##### TODO
* Run (repeated/standby), delayed (once/standby)

  
[-> README](README.md)


