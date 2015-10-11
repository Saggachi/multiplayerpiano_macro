#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
The gui:
9 tabs, 1 for every macro
list box with a note to select
	and button to add more, or remove notes
input box that copies the text of the selected note
ok button to confirm changes to that note



How to use:
Press Insert to open macro creation/modification gui
	Modify saved macro 1-9

Press 1-9 to play that macro
Press + to toggle looping



todo:
load macro file into gui
save gui to macro file
*/

;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/
;	Initialize
;_________________________________/

IfNotExist, README.txt
{
	FileDelete, README.txt
	FileAppend,
	(
	How to use:
		Change all of this
		blah blah, if length is 0, use for chords
		
	Macro files:
		You may edit/save any of the macro files. 
		Files edited in this way must be reloaded by re-opening the script.
		Make sure to leave a blank line at the end of macro files!

		Key, Color, Delay
		1,1,1
		
			Max key = 	52 for white
					36 for black
					
			Color 1 = white
				  2 = black
			
			Delay, Seconds
			1	,	.001
			10	,	.01
			100	,	.1
			1000	,	1








	Created by Saggachi
	),README.txt
}

Loop, 9		;make this smarter
{
	IfExist, Macro%a_index%.txt
		win = 1
	else
	{
		MsgBox, 4,, Missing Macro%a_index%.txt`nCreate new file?
		IfMsgBox Yes
		{
			FileAppend,,Macro%a_index%.txt
			FileAppend,
			(
			BPM=100
			),Macro%a_index%.txt
		}
	}
}



;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/
;	Functions
;_________________________________/




								;sleep before note is played
Rest(bpm,length,multi:=0)
{
	qtr := (((60/bpm)*1000)*100000)/100000
	whole := qtr * 4
	half := qtr * 2
	eigth := qtr / 2
	sixt := qtr / 4
	
	if multi = 0
	{
		if length = 0
			Sleep 1
		else if length = 1
			Sleep %whole%
		else if length = 2
			Sleep %half%
		else if length = 4
			Sleep %qtr%
		else if length = 8
			Sleep %eigth%
		else if length = 16
			Sleep %sixt%
		else
		{
			msgbox, Length error = %length%
		}
	}
	
	else
	{
		loop, %multi%
		{
			if length = 1
				Sleep %whole%
			else if length = 2
				Sleep %half%
			else if length = 4
				Sleep %qtr%
			else if length = 8
				Sleep %eigth%
			else if length = 16
				Sleep %sixt%
			else
			{
				msgbox, Length error = %length%
			}
		}
	}
	
}



SendPiano(key,type)
{						;first, check if white or black key
	if type = 1	;white
	{
		startX = 40
		startY = 540
		
		incr := 29 * key
	}
	
	else if type = 2		;black
	{
		startX = 55
		startY = 400
		inc1 = 29
		
		incrmod := key * inc1
		
		if key = 1
			incr = 0
		else if key between 2 and 3		;2
			incr := inc1 * 1
		else if key between 4 and 6		;3
			incr := inc1 * 2
		else if key between 7 and 8		;2
			incr := inc1 * 3
		else if key between 9 and 11	;3
			incr := inc1 * 4
		else if key between 12 and 13
			incr := inc1 * 5
		else if key between 14 and 16
			incr := inc1 * 6
		else if key between 17 and 18
			incr := inc1 * 7
		else if key between 19 and 21
			incr := inc1 * 8
		else if key between 22 and 23
			incr := inc1 * 9
		else if key between 24 and 26
			incr := inc1 * 10
		else if key between 27 and 28
			incr := inc1 * 11
		else if key between 29 and 31
			incr := inc1 * 12
		else if key between 32 and 33
			incr := inc1 * 13
		else if key between 34 and 36
			incr := inc1 * 14
											;this can surely be improved with fancy maths
		incr += incrmod
	}
	
	else
	{
		msgbox, error`ntype = %type%`nstartX = %startX%`nstartY = %startY%
	}
	

	x := startX + incr
	y := startY
	MouseClick, left, x, y
}


SplitData(input,key1,key2,waste1,waste2)
{
	if key1 = 0
		pos1 = 1
	else
	{
		pos1 := InStr(input, key1)			;position of 1st key
	}

	if key2 = 0
		pos2 = 10000000000000000000
	else
	{
		pos2 := InStr(input, key2)			;position of 2nd key
	}
	
	pos1 += waste1					;this stuff man
	pos2 -= waste2

	pos2 -= pos1
	return SubStr(input, pos1, pos2)
	Sleep 50
}


LoadPlay(macnum)		;reads through macro file, plays notes
{								;add something to check for looping later
	noteExist = 1
	readtick = 1
	FileReadLine, bpmvar, Macro%macnum%.txt, 1		;get Beats Per Minute
	bpmvar := SplitData(bpmvar,"=",0,1,0)	;bpmvar := StrSplit(bpmvar, "=")[2]
	StringReplace, bpmvar, bpmvar, `,,, All
	if not (bpmvar is integer and bpmvar >= 1 and bpmvar <= 500)	;if invalid BPM
		msgbox bpmvar = %bpmvar%`n invalid

			;parse notes
	while noteExist = 1
	{
		readtick++
		FileReadLine, linecheck, Macro%macnum%.txt, %readtick%		;get note
		
		if linecheck =		;make sure note isn't blank, if blank, end macro
		{
			noteExist = 0
			break
		}
		
		note := StrSplit(linecheck,"`,")		;create an array for that note
		multicheck := note.MaxIndex()
		if multicheck = 4					;if rest is multiplied
			multivar := note[4]
		else
			multivar = 0
			
		keyvar := note[1]					;grab note data
		typevar := note[2]
		lengthvar := note[3]
		
											;play the note
		Rest(bpmvar,lengthvar,multivar)
		SendPiano(keyvar,typevar)
		
		;check for looping here
		
						;prepare for next line
		linecheck :=
	}
}


LoadGUI(macnum)		;load macro file to GUI Listbox
{
	FileRead, wholefile, Macro%macnum%.txt
	FileReadLine, bpmvar, Macro%macnum%.txt, 1		;get Beats Per Minute
	bpmvar := SplitData(bpmvar,"=",0,1,0)	;bpmvar := StrSplit(bpmvar, "=")[2]
	StringReplace, bpmvar, bpmvar, `,,, All
	if not (bpmvar is integer and bpmvar >= 1 and bpmvar <= 500)	;if invalid BPM
		msgbox bpmvar = %bpmvar%`n invalid
		
	notearray := StrSplit(wholefile,"`r")		;split notes into array
	;notearray.RemoveAt(1)
	;testme := notearray.MaxIndex()
	;msgbox % notearray[testme]
	
	return notearray
}

/*
SaveGUI(macnum, array, bpm) ;save modified macro to file
{
	FileOpen("Macro" MacNum ".txt", "w`n").Write("BPM=" bpm Join(Array, ""))	;issue here, last note isn't loading onto a new line.
	msgbox, Macro%macnum% saved.
}
 
Join(List, Delim)		;figure this shit out
{
	for k, v in List
		Out .= Delim . v
	return SubStr(Out, 1+StrLen(Delim))
}
*/

;/*
;old
SaveGUI(macnum,array,bpm)		;save modified macro to file
{
	FileDelete, Macro%macnum%.txt	;delete old file and write to new
	
	FileAppend,
	(
	BPM=%bpm%
	),Macro%macnum%.txt		;add BPM line first
	
	GO := array.MaxIndex()
	if GO <= 0
		msgbox, array empty`n invalid	;this doesn't show

	Loop, %GO%
	{
		noteGO := array[a_index]
		msgbox % noteGO
		FileAppend,
		(
		%noteGO%`r
		),Macro%macnum%.txt
	}
	msgbox, Macro%macnum% saved.
}
;*/

;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/
;	GUI
;_________________________________/


/*
brainstorm here

make save to macro function

ask if you want to save changes when switching tabs

apply save function to save button

make the set button actually set the bpm to the file


when switching tabs, check if the file is empty


*/


Ins::		;opens the gui
{
	Gui, Add, Button, gSave x12 y330 w80 h20 , Save
	Gui, Add, Text, x112 y330 w70 h30 , Note format: key`,type`,rest
	Gui, Add, Text, x122 y360 w50 h30 , Example: 10`,1`,16
	Gui, Add, Text, x12 y360 w80 h30 , Key: Number of the key to press
	Gui, Add, Text, x12 y400 w110 h30 , Type: 1 = white keys               2 = black keys
	Gui, Add, Text, x12 y440 w90 h40 , Rest: 1 = Whole              4 = Quarter            etc.
	Gui, Add, Text, x112 y440 w70 h40 , Perform whole rest twice: 10`,1`,1`,2
	Gui, Add, GroupBox, x2 y320 w190 h170 , 
	;^ shown regardless of tab
	;load macro notes into whichever tab you open
	;NoteArray := Object()
	;Gui, Add, Tab, gSwitchTabs x2 y0 w190 h56 , 1|2|3|4|5|6|7|8|9
	;Gui, Tab, 1
	;Gui, Tab, 2
	Gui, Add, ListBox, AltSubmit vListBox gListBox x92 y80 w80 h230 ;, 10`,1`,4
	Gui, Add, Edit, vTempo x12 y230 w60 h20 ,
	NoteArray := LoadGUI(1)		;load macro 1 into listbox
	;msgbox % loadarray[1]

	Tempo := NoteArray[1]				;assign tempo to GUI
	Tempo := SubStr(Tempo,5,1000000)
	GuiControl, Text, Tempo, %Tempo%
	NoteArray.RemoveAt(1)
	
	loop % NoteArray.MaxIndex()
	{
		element := NoteArray[A_Index]
		magic .= "|" . element
	}
	GuiControl,, ListBox, %magic%
	magic :=
	
	
	Gui, Add, Button, gAddNote x82 y60 w50 h20 , Add
	Gui, Add, Button, gRemoveNote x132 y60 w50 h20 , Remove
	Gui, Add, Text, x12 y90 w60 h20 , Modify Note
	Gui, Add, Edit, vEditMe x2 y110 w80 h20 ;+Buttons +Buttons,
	Gui, Add, Button, gApply x12 y130 w60 h20 , Apply
	Gui, Add, Button, gSet x12 y250 w60 h20 , Set				;Just remove this???
	Gui, Add, Text, x12 y200 w60 h30 , Set Tempo`n(BPM)
	Gui, Show, x197 y155 h496 w198, ~Saggachi		;^builds gui items
	Gui, Add, Tab, vTab gSwitchTabs x2 y0 w190 h56 , 1|2|3|4|5|6|7|8|9
	GuiControl, Choose, Tab, |4
	GuiControl, Choose, Tab, |1
	Return

	;~~~~~~~~~~~~~~~~~~~Button events~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	
	Set:		;set BPM		;possibly remove this, and just add functionality to save
		GuiControlGet, Tempo
		
		;doBPM = %Tempo%
		;msgbox, doBPM = %doBPM%
	return
	
	Apply:						;send modified note to listbox
		GuiControlGet, EditMe
		GuiControlGet, ListBox
		NoteArray[ListBox] := EditMe			;add actual change to list box after
		loop % NoteArray.MaxIndex()
		{
			element := NoteArray[A_Index]
			magic .= "|" . element
		}
		GuiControl,, ListBox, %magic%
		magic :=
	return
;instead of loop % NoteArray.MaxIndex() { element := NoteArray[A_Index]
;you can just do "for index, element in NoteArray {"
	
	AddNote:					;add default note to listbox
		GuiControl,, ListBox, 1`,1`,1
		NoteArray.Insert("1`,1`,1")			;appends item to array
	return

	
						;remove selected note
	RemoveNote:
		GuiControlGet, ListBox			; Retrieve the ListBox's current selection.
		NoteArray.Remove(ListBox)			;remove selected item
		
		loop % NoteArray.MaxIndex()		;repopulate listbox
		{
			element := NoteArray[A_Index]
			magic .= "|" . element
		}
		GuiControl,, ListBox, %magic%
		magic :=
	return
	
	
	SwitchTabs:				;ask to save this macro, then load macro of tab clicked
		GuiControlGet, Tab
		NoteArray := LoadGUI(Tab)		;load macro into listbox
		
		Tempo := NoteArray[1]				;assign tempo to GUI
		Tempo := SubStr(Tempo,5,1000000)
		GuiControl, Text, Tempo, %Tempo%
		NoteArray.RemoveAt(1)
		
		if (NoteArray.MaxIndex() = "")
		{
			GuiControl,,ListBox,
			
			loop % NoteArray.MaxIndex()
			{
				NoteArray.Pop()					;wonky shit happening here
			}
		}
		else
		{
			loop % NoteArray.MaxIndex()
			{
				element := NoteArray[A_Index]		;nope, it's not saving the last note
				magic .= "|" . element
			}
			GuiControl,, ListBox, %magic%
			magic :=
		}
	return
	
					;save current tab
	Save:
		GuiControlGet, Tab
		GuiControlGet, Tempo
		;doBPM = %Tempo%					;tempo doesn't set correctly.
		SaveGUI(Tab,NoteArray,Tempo)
	return
	
	/*
	;preview test
	{
		test = 1
		SetTimer, Tester, -500
		SoundBeep, 1000, 1000
		SetTimer, Tester, 1
		;SoundBeep, 500, 500
		;Sleep 500
		
		;SetTimer, Tester, 1
		Tester:
		{
			if test = 1
			{
				test = 0
				SoundBeep, 500, 500
			}
		}
		return
	}
	*/
	
	
	ListBox:					;on doubleclick, put that note into modify field
		if A_GuiEvent <> DoubleClick
			return
		; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
		; So fall through to the next label.
		ButtonOK:
		GuiControlGet, ListBox  ; Retrieve the ListBox's current selection.
		element := NoteArray[ListBox]
		;msgbox, element = %element%
		GuiControl, Text, EditMe, %element%			;move text to edit field
		;GuiControl, Text, EditMe, %ListBox%
	return
	
	GuiClose:
		Gui, Destroy
	return
}
return


Numpad1::LoadPlay(1)
Numpad2::LoadPlay(2)
Numpad3::LoadPlay(3)
Numpad4::LoadPlay(4)
Numpad5::LoadPlay(5)
Numpad6::LoadPlay(6)
Numpad7::LoadPlay(7)
Numpad8::LoadPlay(8)
Numpad9::LoadPlay(9)


Esc::ExitApp

