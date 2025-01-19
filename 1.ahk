#Requires AutoHotkey v2.0

; Create the GUI
MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
MyGui.SetFont("s12", "Arial")
MyGui.Add("Text", "w250 h30", "Thời gian còn lại: ")
MyGui.Add("Text", "vCountdownText x+2 yp w80 h30", "60:00")  ; yp means use same y position as previous control
MyGui.BackColor := "FFFFFF"

; Initialize timer variables
startTime := 3600  ; 1 hour in seconds
currentTime := startTime

; Position the GUI in the top-left corner with some padding
MyGui.Show("x10 y10")

; Set initial transparency
WinSetTransparent(100, MyGui)

; Create a variable to track mouse state
global isMouseOver := false

; Monitor mouse movement
SetTimer(CheckMouse, 100)

CheckMouse() {
    global isMouseOver, MyGui
    MouseGetPos(,, &mouseWin)
    
    if (mouseWin = MyGui.Hwnd) {
        if (!isMouseOver) {
            isMouseOver := true
            WinSetTransparent(255, MyGui)
        }
    } else {
        if (isMouseOver) {
            isMouseOver := false
            WinSetTransparent(100, MyGui)
        }
    }
}

; Timer function for countdown
UpdateTimer() {
    global currentTime, MyGui
    
    if (currentTime > 0) {
        currentTime--
        minutes := Floor(currentTime / 60)
        seconds := Mod(currentTime, 60)
        timeString := Format("{:02d}:{:02d}", minutes, seconds)
        
        ; Update the display text
        MyGui["CountdownText"].Value := timeString
        
        ; Continue the timer
        SetTimer(UpdateTimer, 1000)
    } else {
        ; Timer finished
        MyGui["CountdownText"].Value := "00:00"
        MsgBox("Time's up!")
        ExitApp()
    }
}

; Start the countdown timer
SetTimer(UpdateTimer, 1000)

; Add hotkey to exit
#HotIf WinActive("ahk_class AutoHotkeyGUI")
Esc::ExitApp()
#HotIf