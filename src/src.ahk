#Requires Autohotkey v2
#SingleInstance Force


/*
 * Program: Shutdown Timer
 * Author: Tuan Viet Nguyen
 * Website: https://github.com/vezyldicode
 * Date: Feb 11, 2025
 * Description: 
 * 
 * This code is copyrighted by Tuan Viet Nguyen.
 * You may not use, distribute, or modify this code without the author's permission.
*/


class Shutdown_Timer{
    static Gui_setup()
    {	
        
        static day_Opt := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        static hour_Opt := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
        static mins_Opt := []
        Loop 60
            mins_Opt.Push(A_Index - 1)
        myGui := Gui()
        myGui.BackColor := 0xFBFBFB
        myGui.SetFont("c484b6a")
        myGui.Opt("-MaximizeBox")
        myGui.SetFont("s20")
        myGui.Add("Text", "x32 y24 w305 h58 +0x200", "Shutdown Timer")
        myGui.SetFont("s12")
        static ButtonOK := myGui.Add("Button", "x360 y24 w138 h58", "execute")
        myGui.Add("Text", "x16 y120 w131 h33 +0x200", "Select an action")
        myGui.Add("Text", "x-8 y96 w527 h2 +0x10")
        static action_picker := myGui.Add("DropDownList", "x176 y120 w134", ["Shutdown", "Sleep", "Restart", "Lock"])
        static days_picker := myGui.Add("ComboBox", "x128 y208 w58 h27", day_Opt)
        static hours_picker := myGui.Add("ComboBox", "x224 y208 w58 h27", hour_Opt)
        static mins_picker := myGui.Add("ComboBox", "x320 y208 w58 h27", mins_Opt)
        static seconds_picker := myGui.Add("ComboBox", "x416 y208 w58 h27", mins_Opt)
        myGui.Add("Text", "x-56 y192 w664 h42 +0x10")
        myGui.Add("Text", "x288 y208 w19 h27 +0x200", "h")
        myGui.Add("Text", "x384 y208 w19 h27 +0x200", "m")
        myGui.Add("Text", "x480 y208 w19 h27 +0x200", "s")
        myGui.Add("Text", "x192 y208 w19 h27 +0x200", "d")
        static hour_picker := myGui.Add("ComboBox", "x128 y256 w58 h27", hour_Opt)
        static min_picker := myGui.Add("ComboBox", "x224 y256 w58 h27", mins_Opt)
        static second_picker := myGui.Add("ComboBox", "x320 y256 w58 h27", mins_Opt)
        myGui.Add("Text", "x192 y256 w19 h27 +0x200", ":")
        myGui.Add("Text", "x288 y256 w19 h27 +0x200", ":")
        myGui.Add("Text", "x384 y256 w19 h27 +0x200", "...")
        myGui.SetFont("s10")
        myGui.Add("Text", "x10 300 +0x200", "Version: 1.0.0 - Vezyldicode")
        static delay_mode := myGui.Add("Radio", "x8 y208 w112 h26", "Exec after:")
        static scheduled_mode := myGui.Add("Radio", "x8 y256 w117 h26", "Exec at:")
        days_picker.OnEvent("Change", (*)=>delay_mode.value :=1)
        hours_picker.OnEvent("Change", (*)=>delay_mode.value :=1)
        mins_picker.OnEvent("Change", (*)=>delay_mode.value :=1)
        seconds_picker.OnEvent("Change", (*)=>delay_mode.value :=1)

        hour_picker.OnEvent("Change", (*)=>scheduled_mode.value :=1)
        min_picker.OnEvent("Change", (*)=>scheduled_mode.value :=1)
        second_picker.OnEvent("Change", (*)=>scheduled_mode.value :=1)
        ButtonOK.OnEvent("Click", confirm_action)
        myGui.OnEvent('Close', (*) => ExitApp())
        myGui.Title := "Shutdown Timer"

        ; điền các giá trị mặc định vào vùng nhập dữ liệu trên UI
        static default_vars_filling(*){
            vars := [action_picker, days_picker, hours_picker, mins_picker, seconds_picker, hour_picker, min_picker, second_picker, delay_mode]
            for var in vars{
                var.value := 1
            }
        }

        ; Xác nhận hành động
        static confirm_action(*){
            ; hành động cần thực thi
            global action := action_picker.text
            if delay_mode.value{
                second_remaining := Shutdown_Timer.time_to_second(days_picker.text, hours_picker.text, mins_picker.text, seconds_picker.text)
                userResponse := MsgBox("bạn đang thực hiện hành động " action_picker.text " sau " 
                                        days_picker.text " ngày " hours_picker.text " giờ " 
                                        mins_picker.text " phút " seconds_picker.text " giây ","Shutdown_Timer", "262180")
                if (userResponse = "Yes"){
                    Yes_response(second_remaining)
                } else if (userResponse = "No"){
                    return
                }
            }else If scheduled_mode.value{
                second_remaining := Shutdown_Timer.calculateRemainingTime(hour_picker.text, min_picker.text, second_picker.text)
                userResponse := MsgBox("bạn đang thực hiện hành động " action_picker.text " vào lúc " 
                                    hour_picker.text " giờ " min_picker.text " phút " second_picker.text " giây "
                                    "tức là sau " Shutdown_Timer.format_Time(second_remaining)
                                    ,"Shutdown_Timer", "262180")
                if (userResponse = "Yes"){
                    Yes_response(second_remaining)
                } else if (userResponse = "No"){
                    return
                }
            }
        }
        static Yes_response(second){
            ; thuộc tính cho phép tiếp tục hay tạm dừng đếm ngược
            global countdown_allowed := True
            TrayTip "Countdown is started", "Warning", "2"
            ButtonOK.OnEvent("Click", confirm_action, 0)
            ButtonOK.OnEvent("Click", Exit)
            ButtonOK.Text := "Cancel"
            Tray.Enable("Show Window")
            Shutdown_Timer.countdown_GUI(second)
            Shutdown_Timer.countdown_banner(second)
        }

        default_vars_filling
        return myGui
    }

    ; hàm tính thời gian còn lại cho đến lúc thực hiện hành động (trả về giây) (input là giờ, phút, giây lúc hành động)
    static calculateRemainingTime(hour, min, sec){
        ; Lấy thời gian hiện tại
        now := A_Now
        ; Định dạng thời gian hiện tại thành giây từ đầu ngày
        FormatTime(, "yyyy-MM-dd HH:mm:ss")
        nowSeconds := (A_Hour * 3600) + (A_Min * 60) + A_Sec

        ; Tính tổng giây của thời gian mục tiêu
        targetSeconds := (hour * 3600) + (min * 60) + sec

        ; Nếu thời gian mục tiêu đã qua trong ngày hôm nay, thêm 1 ngày (86400 giây)
        if (targetSeconds <= nowSeconds) {
            targetSeconds += 86400
        }

        ; Tính khoảng thời gian còn lại
        remainingSeconds := targetSeconds - nowSeconds
        return remainingSeconds
    }

    ; hàm định dạng từ giây thành định dạng giờ phút giây
    static format_Time(sec){
        hours := Floor(sec / 3600)
        sec := Mod(sec, 3600)
        minutes := Floor(sec / 60)
        seconds := Mod(sec, 60)

        ; Trả về kết quả
        return hours " giờ, " minutes " phút, " seconds " giây" 
    }

    static time_to_second(days, hours, mins, secs){
        return days*24*60*60+ hours*60*60 + mins*60 +secs
    }
    static countdown_GUI(second){
        myGui.Show("w516 h100")
    }
    static countdown_banner(second){
        global action, banner
        banner := Gui("+AlwaysOnTop -Caption +ToolWindow")
        banner.SetFont("s9", "Arial")
        banner.Add("Text", "vActionText w80 h25", "Shutdown in:")
        banner.Add("Text", "vCountdownText yp w80 h25", "00:00")  ; yp means use same y position as previous control x+2 yp 
        banner.BackColor := "FFFFFF"
        
        banner["ActionText"].Value := action " in:"
        ; Initialize timer variables
        startTime := second  ; 1 hour in seconds
        currentTime := startTime
        
        Shutdown_Timer.banner_visibility
        ; Set initial transparency
        WinSetTransparent(100, banner)
        
        ; Create a variable to track mouse state
        global isMouseOver := false
        
        ; Monitor mouse movement
        SetTimer(CheckMouse, 100)
        
        CheckMouse() {
            MouseGetPos(,, &mouseWin)
            
            if (mouseWin = banner.Hwnd) {
                if (!isMouseOver) {
                    isMouseOver := true
                    WinSetTransparent(255, banner)
                }
            } else {
                if (isMouseOver) {
                    isMouseOver := false
                    WinSetTransparent(100, banner)
                }
            }
        }
        
        ; Timer function for countdown
        UpdateTimer() {
            global countdown_allowed
            if countdown_allowed{
                if (currentTime > 0) {
                    currentTime--
                    minutes := Floor(currentTime / 60)
                    seconds := Mod(currentTime, 60)
                    timeString := Format("{:02d}:{:02d}", minutes, seconds)
                    
                    ; Update the display text
                    banner["CountdownText"].Value := timeString
                    
                    ; Continue the timer
                    SetTimer(UpdateTimer, 1000)
                } else {
                    ; Timer finished
                    banner["CountdownText"].Value := "00:00"
                    Shutdown_Timer.Exec(action)
                    return
                }
                switch currentTime{
                    case 600, 300:
                        SoundBeep 750, 500
                    case 120, 60:
                        SoundBeep 750, 500
                        SoundBeep 750, 500
                    case 10, 5, 2, 1: 
                        SoundBeep 750, 500
                        SoundBeep 750, 500
                        SoundBeep 750, 500
                }
            }
        }
        
        ; Start the countdown timer
        SetTimer(UpdateTimer, 1000)

    }

    static change_banner_visibility(*){
        global visibility
        visibility := !visibility
        Tray.ToggleCheck("Show Timer")
        Shutdown_Timer.banner_visibility

    }

    static banner_visibility(){
        global visibility, banner
        switch visibility{
            case True:
                try {
                    banner.Show("x0 y0 w150 h25")
                } catch Error as e {
                    
                }
                
            case False:
                try {
                    banner.Hide()
                } catch Error as e {
                    
                }
                
        }
    }

    static change_window_visibility(*){
        global window_visibility
        window_visibility := !window_visibility
        Tray.ToggleCheck("Show Window")
        ; Shutdown_Timer.banner_visibility
        switch window_visibility{
            case True:
                try {
                    myGui.Show()
                } catch Error as e {
                    
                }
                
            case False:
                try {
                    myGui.Hide()
                } catch Error as e {
                    
                }
                
        }

    }

    static Exec(act){
        switch act{
            case "Shutdown":
                Shutdown(1)
            case "Restart":
                Shutdown(2)
            case "Sleep":
                DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
            case "Lock":
                DllCall("LockWorkStation")
        }
        ExitApp()
    }

}

Exit(*){
    global countdown_allowed := False
    userResponse := MsgBox("bạn có chắc chắn muốn thoát không?","Shutdown_Timer", "262180")
                if (userResponse = "Yes"){
                    ExitApp
                } else if (userResponse = "No"){
                    countdown_allowed := True
                    return
                }
    return
}

NoneFunc(){
    return
}
;thuộc tính hiện ẩn cửa sổ khi chạy đếm ngược
global window_visibility := true 
; thuộc tính hiện ẩn banner khi chạy đếm ngược
global visibility := true 

Tray := A_TrayMenu
Tray.Delete()
Tray.Add("Show Window", Shutdown_Timer.change_window_visibility)

Tray.ToggleCheck("Show Window")
Tray.Disable("Show Window")

Tray.Add("Show Timer", Shutdown_Timer.change_banner_visibility)

Tray.ToggleCheck("Show Timer")
A_TrayMenu.Add()
Tray.Add("Stop Timer and Exit", Exit)

myGui := Shutdown_Timer.Gui_setup()
myGui.Show("w516 h322")

