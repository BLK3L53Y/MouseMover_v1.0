/*
    MouseMover_v1.0
    Created by: BLK3L53Y
    Created on: 2025-04-25

    Description:
    Lightweight AutoHotkey v2.0 application that simulates mouse movements
    to prevent system idling, with fully customizable settings and GUI.

    Features:
    - Customizable move interval and distance
    - Manual move hotkey (Ctrl+Alt+M)
    - Save/load settings
    - Idle detection and dynamic auto-start
    - Minimize to tray
    - Reset settings button
*/

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
SetWorkingDir A_ScriptDir

; ---------------------------
; Global Variables
; ---------------------------
global isRunning := false
, isManualMoving := false
, moveInterval := 30000 ; default 30 seconds
, moveDistance := 10    ; default 10 pixels
, settingsFile := A_ScriptDir . "\settings.ini"
, logFile := A_ScriptDir . "\mousemover.log"
, featureStates := Map()
, currentProfile := "Default"

global MainGui, statusText

; ---------------------------
; Initialize Files
; ---------------------------
if !FileExist(settingsFile)
    FileAppend("[Default]`nInterval=30000`nDistance=10`nIdleTime=300`nPauseThreshold=5`n[Features]`nMode=Simplified`nTheme=Light`nLogging=false`nAutoStart=false`nDynamicAutoStart=false", settingsFile)

; ---------------------------
; Build GUI
; ---------------------------
MainGui := Gui()
MainGui.Title := "MouseMover_v1.0"
GuiTabs := MainGui.Add("Tab3", , ["General", "Movement", "Advanced"])

; --- General Tab ---
GuiTabs.UseTab("General")
MainGui.Add("Text",, "Move Interval (seconds):")
intervalInput := MainGui.Add("Edit", "w100 vInterval")
MainGui.Add("Text",, "Move Distance (pixels):")
distanceInput := MainGui.Add("Edit", "w100 vDistance")
startupCheckbox := MainGui.Add("Checkbox", "vAutoStart", "Run at Startup")

; --- Movement Tab ---
GuiTabs.UseTab("Movement")
mouseClicksCheckbox := MainGui.Add("Checkbox", "vMouseClicks", "Simulate Mouse Clicks")
MainGui.Add("Text",, "Idle Time (seconds):")
idleTimeInput := MainGui.Add("Edit", "w100 vIdleTime")
MainGui.Add("Text",, "Pause Threshold (seconds):")
pauseThresholdInput := MainGui.Add("Edit", "w100 vPauseThreshold")

; --- Advanced Tab ---
GuiTabs.UseTab("Advanced")
loggingCheckbox := MainGui.Add("Checkbox", "vLogging", "Enable Logging")
dynamicAutoStartCheckbox := MainGui.Add("Checkbox", "vDynamicAutoStart", "Dynamic AutoStart on Idle")

; --- Bottom Buttons ---
GuiTabs.UseTab()
applyButton := MainGui.Add("Button", "w100", "Apply Settings")
saveButton := MainGui.Add("Button", "w100 x+10", "Save Settings")
resetButton := MainGui.Add("Button", "w100 x+10", "Reset Settings")
startButton := MainGui.Add("Button", "w100 x+10", "Start")
stopButton := MainGui.Add("Button", "w100 x+10", "Stop")
exitButton := MainGui.Add("Button", "w100 x+10", "Exit")
statusText := MainGui.Add("Text", "w400", "Status: Stopped")

; --- Footer Labels ---
MainGui.Add("Text", "xm y+20 w400 Center", "Created by BLK3L53Y")
MainGui.Add("Text", "xm y+5 w400 Center", "Press Ctrl+Alt+M to manually move mouse")

; --- Button Events ---
applyButton.OnEvent("Click", (*) => ApplySettings())
saveButton.OnEvent("Click", (*) => SaveSettings())
resetButton.OnEvent("Click", (*) => ResetSettings())
startButton.OnEvent("Click", (*) => StartMover())
stopButton.OnEvent("Click", (*) => StopMover())
exitButton.OnEvent("Click", (*) => SafeExit())

; --- GUI Behavior Events ---
MainGui.OnEvent("Close", (*) => MainGui.Hide())
MainGui.OnEvent("Size", GuiSizeHandler)

; ---------------------------
; System Tray Menu
; ---------------------------
Tray := A_TrayMenu
Tray.Delete()
Tray.Add("Restore", (*) => MainGui.Show())
Tray.Add("Start", (*) => StartMover())
Tray.Add("Stop", (*) => StopMover())
Tray.Add("Exit", (*) => SafeExit())

; ---------------------------
; Hotkeys
; ---------------------------
^!m::ToggleManualMove() ; Ctrl+Alt+M hotkey to toggle manual mouse move

; ---------------------------
; Load Settings AFTER GUI created
; ---------------------------
LoadSettings()
ApplySettings()
MainGui.Show()

; Auto-start if enabled
if featureStates["AutoStart"] && FileExist(A_Startup . "\" . A_ScriptName . ".lnk")
    StartMover()

; ---------------------------
; Functions
; ---------------------------

; LoadSettings - Reads from INI file and applies to GUI controls
LoadSettings() {
    global featureStates, moveInterval, moveDistance
    featureStates := Map(
        "IdleTime", 300,
        "PauseThreshold", 5,
        "Mode", "Simplified",
        "Theme", "Light",
        "AutoStart", false,
        "Logging", false,
        "DynamicAutoStart", false
    )
    if FileExist(settingsFile) {
        moveInterval := IniRead(settingsFile, "Default", "Interval", 30000)
        moveDistance := IniRead(settingsFile, "Default", "Distance", 10)
        featureStates["IdleTime"] := IniRead(settingsFile, "Default", "IdleTime", 300)
        featureStates["PauseThreshold"] := IniRead(settingsFile, "Default", "PauseThreshold", 5)
        featureStates["Logging"] := (IniRead(settingsFile, "Features", "Logging", "false") = "true")
        featureStates["AutoStart"] := (IniRead(settingsFile, "Features", "AutoStart", "false") = "true")
        featureStates["DynamicAutoStart"] := (IniRead(settingsFile, "Features", "DynamicAutoStart", "false") = "true")
    }

    ; Set GUI control values
    intervalInput.Value := moveInterval // 1000
    distanceInput.Value := moveDistance
    idleTimeInput.Value := featureStates["IdleTime"]
    pauseThresholdInput.Value := featureStates["PauseThreshold"]
    startupCheckbox.Value := featureStates["AutoStart"]
    loggingCheckbox.Value := featureStates["Logging"]
    dynamicAutoStartCheckbox.Value := featureStates["DynamicAutoStart"]
}

; ApplySettings - Applies current GUI input to active memory
ApplySettings() {
    global moveInterval, moveDistance, featureStates
    moveInterval := (intervalInput.Value != "" ? intervalInput.Value : 30) * 1000
    moveDistance := (distanceInput.Value != "" ? distanceInput.Value : 10)
    featureStates["IdleTime"] := (idleTimeInput.Value != "" ? idleTimeInput.Value : 300)
    featureStates["PauseThreshold"] := (pauseThresholdInput.Value != "" ? pauseThresholdInput.Value : 5)
    featureStates["Logging"] := loggingCheckbox.Value
    featureStates["DynamicAutoStart"] := dynamicAutoStartCheckbox.Value
    featureStates["AutoStart"] := startupCheckbox.Value
    UpdateStatus("Settings applied.")

    if (isRunning) {
        SetTimer(MouseMoveAction, 0)
        SetTimer(MouseMoveAction, moveInterval)
    }
}

; SaveSettings - Saves current settings to INI file
SaveSettings() {
    global settingsFile, moveInterval, moveDistance, featureStates
    IniWrite(moveInterval, settingsFile, "Default", "Interval")
    IniWrite(moveDistance, settingsFile, "Default", "Distance")
    IniWrite(featureStates["IdleTime"], settingsFile, "Default", "IdleTime")
    IniWrite(featureStates["PauseThreshold"], settingsFile, "Default", "PauseThreshold")
    IniWrite(featureStates["Logging"] ? "true" : "false", settingsFile, "Features", "Logging")
    IniWrite(featureStates["AutoStart"] ? "true" : "false", settingsFile, "Features", "AutoStart")
    IniWrite(featureStates["DynamicAutoStart"] ? "true" : "false", settingsFile, "Features", "DynamicAutoStart")
    UpdateStatus("Settings saved.")
}

; ResetSettings - Resets GUI fields to defaults
ResetSettings() {
    intervalInput.Value := 30
    distanceInput.Value := 10
    idleTimeInput.Value := 300
    pauseThresholdInput.Value := 5
    startupCheckbox.Value := false
    mouseClicksCheckbox.Value := false
    loggingCheckbox.Value := false
    dynamicAutoStartCheckbox.Value := false
    UpdateStatus("Settings reset.")
}

; StartMover - Starts the automatic mouse mover
StartMover() {
    global isRunning
    if !isRunning {
        isRunning := true
        SetTimer(MouseMoveAction, 0)
        SetTimer(MouseMoveAction, moveInterval)
        UpdateStatus("Running.")
    }
}

; StopMover - Stops automatic movement
StopMover() {
    global isRunning
    if isRunning {
        isRunning := false
        SetTimer(MouseMoveAction, 0)
        UpdateStatus("Stopped.")
    }
}

; ToggleManualMove - Toggles manual movement on/off
ToggleManualMove() {
    global isManualMoving
    if (isManualMoving) {
        SetTimer(ManualMoveNow, 0)
        isManualMoving := false
        UpdateStatus("Manual Move Stopped.")
    } else {
        SetTimer(ManualMoveNow, 1000)
        isManualMoving := true
        UpdateStatus("Manual Move Started.")
    }
}

; ManualMoveNow - Manually move once
ManualMoveNow() {
    MouseMoveAction()
}

; MouseMoveAction - Moves mouse randomly within allowed screen
MouseMoveAction() {
    global featureStates, moveDistance
    if (featureStates["PauseThreshold"] > 0) {
        if (A_TimeIdlePhysical < featureStates["PauseThreshold"] * 1000) {
            return
        }
    }

    MouseGetPos(&x, &y)
    dx := Random(-moveDistance, moveDistance)
    dy := Random(-moveDistance, moveDistance)
    minX := SysGet(76), minY := SysGet(77)
    maxX := SysGet(78), maxY := SysGet(79)

    newX := Clamp(x + dx, minX, maxX)
    newY := Clamp(y + dy, minY, maxY)
    speed := Random(5, 15)

    MouseMove(newX, newY, speed)
    if featureStates["Logging"]
        FileAppend(A_Now . ": Moved to (" . newX . ", " . newY . ")`n", logFile)
}

; Clamp - Restricts value inside min/max range
Clamp(val, minVal, maxVal) {
    return (val < minVal) ? minVal : (val > maxVal) ? maxVal : val
}

; GuiSizeHandler - Handles GUI minimize behavior
GuiSizeHandler(guiObj, eventInfo, width, height) {
    if (eventInfo = "Minimize")
        guiObj.Hide()
}

; UpdateStatus - Updates status bar text
UpdateStatus(msg) {
    global statusText
    statusText.Value := "Status: " . msg
}

; SafeExit - Exits application safely
SafeExit(*) {
    ExitApp()
}
