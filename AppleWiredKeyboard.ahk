; Note: Go to line 63 to map your command to the Eject key.
;

#InstallKeybdHook
#SingleInstance force
SetTitleMatchMode 2


#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
Gui, Show, x0 y0 h0 w0, FnMapper
fnPressed := 0
HomePath=AutohotkeyRemoteControl.dll
hModule := DllCall("LoadLibrary", "str", HomePath)
OnMessage(0x00FF, "InputMsg")
EditUsage := 1
EditUsagePage := 12
HWND := WinExist("FnMapper")
nRC := DllCall("AutohotkeyRemoteControl\RegisterDevice", INT, EditUsage, INT, EditUsagePage, INT, HWND, "Cdecl UInt")
WinHide, FnMapper
InputMsg(wParam, lParam, msg, hwnd) 
{
  DeviceNr = -1
  nRC := DllCall("AutohotkeyRemoteControl\GetWM_INPUTDataType", UINT, wParam, UINT, lParam, "INT *", DeviceNr, "Cdecl UInt")
  if (errorlevel <> 0) || (nRC == 0xFFFFFFFF) 
  {
        MsgBox GetWM_INPUTHIDData fehlgeschlagen. Errorcode: %errorlevel%
        gosub cleanup
  }
  ;Tooltip, %DeviceNr%
  ifequal, nRC, 2
  {
    ProcessHIDData(wParam, lParam)
  }
  else 
  {
        MsgBox, Error - no HID data
  }
}
Return

ProcessHIDData(wParam, lParam)
{
        ; Make sure this variable retains its value outside this function
        global fnPressed
        global ejectPressed
        
  DataSize = 5000
  VarSetCapacity(RawData, %DataSize%, 0)
  RawData = 1
  nHandle := DllCall("AutohotkeyRemoteControl\GetWM_INPUTHIDData", UINT, wParam, UINT, lParam, "UINT *" , DataSize, "UINT", &RawData, "Cdecl UInt")
  KeyStatus := NumGet(RawData, 1,"UChar")
  Transform, FnValue, BitAnd, 16, KeyStatus
  Transform, EjectValue, BitAnd, 8, KeyStatus
   
  if (FnValue = 16) {
        MsgBox function pressed
        fnPressed := 1
        SendInput {F21}
        return
  } else {
                fnPressed := 0
  }

  if (EjectValue = 8) {
        ejectPressed := 1

        SendInput {F20}

        } else {
        ejectPressed := 0
  }

} ; END: ProcessHIDData

skype() {
  IfWinExist ahk_class tSkMainForm
  {  
    WinActivate
  }
  else
  {
    run C:\Program Files (x86)\Skype\Phone\Skype.exe
    WinWait ahk_class tSkMainForm
    WinActivate
  }

}

SendMode Input

; --------------------------------------------------------------
; NOTES
; --------------------------------------------------------------
; ! = ALT
; ^ = CTRL
; + = SHIFT
; # = WIN

; media/function keys all mapped to the right option key
RAlt & F7::SendInput {Media_Prev}
RAlt & F8::SendInput {Media_Play_Pause}
RAlt & F9::SendInput {Media_Next}
RAlt & F10::SendInput {Volume_Mute}
RAlt & F11::SendInput {Volume_Down}
RAlt & F12::SendInput {Volume_Up}

; swap left command/windows key with left control
*LWin::Send {LControl Down}
*LWin Up::Send {LControl Up}
*LControl::Send {LWin Down}
*LControl Up::Send {LWin Up}

; Eject Key
F20::SendInput {Insert}

; F13-15, standard windows mapping
F13::SendInput {PrintScreen}
F14::SendInput {ScrollLock}
F15::SendInput {Pause}

;F16-19 custom app launchers, see http://www.autohotkey.com/docs/Tutorial.htm for usage info
F16::Run "C:\Program Files\Sublime Text 2\sublime_text.exe"
F17::Run calc.exe
F18::Run https://mail.google.com
F19::skype()


; If there was an error retrieving the HID data, cleanup
cleanup:
DllCall("FreeLibrary", "UInt", hModule)  ; It is best to unload the DLL after using it (or before the script exits).
ExitApp