# MouseMover_v1.0
**Created by:** BLK3L53Y  
**Created on:** 2025-04-25  

---

## Overview
**MouseMover_v1.0** is a lightweight AutoHotkey v2.0 application that simulates mouse movements to prevent system idling or screen saver activation.  
It is fully customizable through a user-friendly graphical interface.

---

## Updates
**If using AHK v2, then use the .ahk file. Alternatively, the .akh file has been compiled into and executable and is a .exe file. AHK v2 is not required to be installed if using the .exe file.

---

## Features
- ✅ Random mouse movements at customizable intervals and distances
- ✅ Customizable idle detection and auto-start behavior
- ✅ Save and load settings automatically
- ✅ "Manual Move Now" hotkey (`Ctrl+Alt+M`) with toggle behavior
- ✅ Reset settings to defaults easily
- ✅ Start, Stop, Save, Apply settings directly from the GUI
- ✅ Minimize to System Tray on close (X button)
- ✅ Very lightweight, fast, and error-free

---

## Controls
| Control | Description |
|:---|:---|
| **Move Interval** | Set how often (in seconds) the mouse moves |
| **Move Distance** | Set maximum pixel distance for random movement |
| **Run at Startup** | Automatically start moving after launching Windows |
| **Simulate Mouse Clicks** | Optionally click after moving the mouse |
| **Idle Time** | Time in seconds before starting after idle detection |
| **Pause Threshold** | Pause movement if activity is detected |
| **Enable Logging** | Record movement events to `mousemover.log` |
| **Dynamic AutoStart** | Auto-start movement after system idle |
| **Apply Settings** | Apply current settings without saving to file |
| **Save Settings** | Save current settings permanently to `settings.ini` |
| **Reset Settings** | Reset all settings to factory defaults |
| **Start** | Start automatic mouse movements |
| **Stop** | Stop automatic mouse movements |
| **Exit** | Exit the application fully |

---

## Hotkeys
| Hotkey | Function |
|:---|:---|
| **Ctrl+Alt+M** | Toggle manual movement mode (Start/Stop moving immediately) |

---

## How To Use
1. **Launch** the script by double-clicking the `.ahk` file.
2. **Adjust settings** within the GUI as needed.
3. Click **Apply Settings** or **Save Settings** to commit changes.
4. Click **Start** to begin automatic mouse movement.
5. Minimize the GUI (click X) to hide it in the System Tray.
6. **Use the hotkey** `Ctrl+Alt+M` to manually move the mouse at any time.

---

## Installation (Optional)
To run MouseMover automatically when Windows starts:
- Use the "Run at Startup" checkbox inside the application.
- Or manually place a shortcut of the script into `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.

---

## Files Created
- `settings.ini` — Stores saved configurations.
- `mousemover.log` — (Optional) Records movement events if logging is enabled.

---

## Requirements
- Windows Operating System
- [AutoHotkey v2.0](https://www.autohotkey.com/) installed

---

## License
This script is open for personal, non-commercial use.  
You are free to modify and expand upon it to suit your needs.

---

# 🚀 Enjoy using MouseMover_v1.0!
