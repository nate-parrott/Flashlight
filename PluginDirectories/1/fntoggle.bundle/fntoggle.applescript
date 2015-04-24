tell application "System Preferences"
    reveal anchor "keyboardTab" of pane "com.apple.preference.keyboard"
end tell
tell application "System Events" to tell process "System Preferences"
    click checkbox 1 of tab group 1 of window 1
end tell
quit application "System Preferences"