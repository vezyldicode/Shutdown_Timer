
#Requires Autohotkey v2



class Shutdown_Timer{
    static Gui_setup()
    {	
        static day_Opt := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        static hour_Opt := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
        static mins_Opt := []
        Loop 60
            mins_Opt.Push(A_Index - 1)
        myGui := Gui()
        myGui.Opt("-MaximizeBox")
        myGui.SetFont("s20")
        myGui.Add("Text", "x32 y24 w305 h58 +0x200", "Shutdown Timer")
        myGui.SetFont("s12")
        ButtonOK := myGui.Add("Button", "x360 y24 w138 h26", "OK")
        ButtonCancel := myGui.Add("Button", "x360 y56 w138 h26", "Cancel")
        myGui.Add("Text", "x16 y120 w131 h33 +0x200", "Select an action")
        myGui.Add("Text", "x-8 y96 w527 h2 +0x10")
        static action_picker := myGui.Add("DropDownList", "x176 y120 w134", ["Shutdown", "Sleep", "Restart"])
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
        static delay_mode := myGui.Add("Radio", "x8 y208 w112 h26", "Exec after:")
        static scheduled_mode := myGui.Add("Radio", "x8 y256 w117 h26", "Exec at:")
        ButtonOK.OnEvent("Click", confirm_action)
        ButtonCancel.OnEvent("Click", confirm_action)
        myGui.OnEvent('Close', (*) => ExitApp())
        myGui.Title := "Shutdown Timer"

        static default_filling(*){
            vars := [action_picker, days_picker, hours_picker, mins_picker, seconds_picker, hour_picker, min_picker, second_picker, delay_mode]
            for var in vars{
                var.value := 1
            }
        }

        static confirm_action(*){
            if delay_mode.value{
                userResponse := MsgBox("bạn đang thực hiện hành động " action_picker.text " sau " days_picker.text " ngày " hours_picker.text " giờ " mins_picker.text " phút " seconds_picker.text " giây ","Shutdown_Timer", "262180")
                if (userResponse = "Yes"){
                    myGui.Hide()
                } else if (userResponse = "No"){
                    return
                }
            }else If  scheduled_mode.value{
                
                userResponse := MsgBox("bạn đang thực hiện hành động " action_picker.text " vào lúc " hour_picker.text " giờ " min_picker.text " phút " second_picker.text " giây "
                                    "tức là sau " Shutdown_Timer.format_Time(Shutdown_Timer.calculateRemainingTime(hour_picker.text, min_picker.text, second_picker.text))
                                    ,"Shutdown_Timer", "262180")
                if (userResponse = "Yes"){
                    myGui.Hide()
                } else if (userResponse = "No"){
                    return
                }
            }
        }
        default_filling
        return myGui
    }

    ; hàm tính thời gian còn lại cho đến lúc thực hiện hành động (trả về giây)
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
}


if A_LineFile = A_ScriptFullPath && !A_IsCompiled
    {
        myGui := Shutdown_Timer.Gui_setup()
        myGui.Show("w516 h322")
    }