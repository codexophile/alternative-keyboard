#Requires AutoHotkey v2.0
#SingleInstance Force

; Script to generate a cheat sheet for all hotkeys defined in the main script
GenerateCheatSheet()

GenerateCheatSheet() {
  ; Path to the main script file
  scriptPath := A_ScriptDir . "\alternative-keyboard.ahk"

  ; Read the script file
  If !FileExist(scriptPath) {
    MsgBox "Script file not found: " . scriptPath
    Return
  }

  scriptContent := FileRead(scriptPath)

  ; Initialize arrays and objects for storing categorized hotkeys
  categories := Map()
  currentCategory := "Uncategorized"
  categories[currentCategory] := []

  ; Parse script content line by line
  Loop Parse, scriptContent, "`n", "`r" {
    line := Trim(A_LoopField)

    ; Check for category markers (MARK comments)
    If InStr(line, "; MARK:") {
      currentCategory := Trim(SubStr(line, 8))
      If !categories.Has(currentCategory)
        categories[currentCategory] := []
      Continue
    }

    ; Skip empty lines, comments, and function definitions
    If line = "" || SubStr(line, 1, 1) = ";" || InStr(line, "()") || InStr(line, "return")
      Continue

    ; Process hotkey definitions
    If RegExMatch(line, "^[^\s:]*::", &match) {
      hotkey := SubStr(match[0], 1, -2)  ; Remove the :: from the end

      ; Get the action (everything after the ::)
      action := ""
      If RegExMatch(line, "::(.*)", &actionMatch)
        action := Trim(actionMatch[1])

      ; If action is empty or just contains a block start, check the next line
      If action = "" || action = "{" {
        nextLineIndex := A_Index + 1
        nextLine := ""

        ; Get the first non-empty line that isn't a comment within the next 5 lines
        Loop 5 {
          If nextLineIndex > StrSplit(scriptContent, "`n").Length
            Break

          nextLine := Trim(StrSplit(scriptContent, "`n")[nextLineIndex])
          If nextLine != "" && SubStr(nextLine, 1, 1) != ";" && !InStr(nextLine, "return")
            Break

          nextLineIndex++
        }

        ; Extract the action from the next line
        If nextLine != "" {
          If RegExMatch(nextLine, "Send\s+[" "']?(.*?)[" "']?[\)\s]", &sendMatch)
            action := "Send " . sendMatch[1]
          Else If RegExMatch(nextLine, "SendText\s+[" "']?(.*?)[" "']?[\)\s]", &sendTextMatch)
            action := "SendText " . sendTextMatch[1]
          Else If RegExMatch(nextLine, "SendShortcutKeys\s*\((.*?)\)", &shortcutMatch)
            action := "SendShortcutKeys " . shortcutMatch[1]
          Else
            action := nextLine
        }
      }

      ; Clean up the hotkey and action
      hotkey := StrReplace(hotkey, "$", "")
      hotkey := StrReplace(hotkey, "~", "")
      hotkey := StrReplace(hotkey, "*", "")

      ; Format the combination in a more readable way
      readableHotkey := FormatHotkeyName(hotkey)

      ; Add to the current category
      categories[currentCategory].Push([readableHotkey, action])
    }
  }

  ; Generate the cheat sheet content
  cheatSheetContent := "# AutoHotkey Cheat Sheet`n`n"
  cheatSheetContent .= "Generated on: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n`n"

  ; Add each category to the cheat sheet
  For category, hotkeys in categories {
    If hotkeys.Length > 0 {
      cheatSheetContent .= "## " . category . "`n`n"
      cheatSheetContent .= "| Hotkey | Action |`n"
      cheatSheetContent .= "| ------ | ------ |`n"

      For index, hotkeyInfo in hotkeys {
        hotkey := hotkeyInfo[1]
        action := hotkeyInfo[2]

        ; Clean up action for display
        action := StrReplace(action, "Send ", "")
        action := StrReplace(action, "SendText ", "")
        action := StrReplace(action, "SendShortcutKeys ", "")
        action := StrReplace(action, "{", "")
        action := StrReplace(action, "}", "")

        cheatSheetContent .= "| " . hotkey . " | " . action . " |`n"
      }

      cheatSheetContent .= "`n"
    }
  }

  ; Write to a Markdown file
  cheatSheetPath := A_ScriptDir . "\AutoHotkey_CheatSheet.md"
  FileDelete cheatSheetPath
  FileAppend cheatSheetContent, cheatSheetPath

  ; Create an HTML file with better formatting
  htmlContent := "<!DOCTYPE html>`n"
  htmlContent .= "<html>`n<head>`n"
  htmlContent .= "<title>AutoHotkey Cheat Sheet</title>`n"
  htmlContent .= "<style>`n"
  htmlContent .= "body { font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; }`n"
  htmlContent .= "h1, h2 { color: #333; }`n"
  htmlContent .= "table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }`n"
  htmlContent .= "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }`n"
  htmlContent .= "th { background-color: #f2f2f2; }`n"
  htmlContent .= "tr:nth-child(even) { background-color: #f9f9f9; }`n"
  htmlContent .= "tr:hover { background-color: #e9e9e9; }`n"
  htmlContent .= "</style>`n"
  htmlContent .= "</head>`n<body>`n"

  htmlContent .= "<h1>AutoHotkey Cheat Sheet</h1>`n"
  htmlContent .= "<p>Generated on: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "</p>`n"

  ; Add each category to the HTML
  For category, hotkeys in categories {
    If hotkeys.Length > 0 {
      htmlContent .= "<h2>" . category . "</h2>`n"
      htmlContent .= "<table>`n"
      htmlContent .= "<tr><th>Hotkey</th><th>Action</th></tr>`n"

      For index, hotkeyInfo in hotkeys {
        hotkey := hotkeyInfo[1]
        action := hotkeyInfo[2]

        ; Clean up action for display
        action := StrReplace(action, "Send ", "")
        action := StrReplace(action, "SendText ", "")
        action := StrReplace(action, "SendShortcutKeys ", "")
        action := StrReplace(action, "{", "")
        action := StrReplace(action, "}", "")

        htmlContent .= "<tr><td>" . hotkey . "</td><td>" . action . "</td></tr>`n"
      }

      htmlContent .= "</table>`n"
    }
  }

  htmlContent .= "</body>`n</html>"

  ; Write to an HTML file
  htmlPath := A_ScriptDir . "\AutoHotkey_CheatSheet.html"
  FileDelete htmlPath
  FileAppend htmlContent, htmlContent

  ; Show a message and open the HTML file
  MsgBox "Cheat sheet generated!`n`nSaved to:`n" . cheatSheetPath . "`n" . htmlPath
  Run htmlPath
}

; Function to format hotkey names to make them more readable
FormatHotkeyName(hotkeyName) {
  ; Replace special operator characters with readable text
  hotkeyName := StrReplace(hotkeyName, " & ", "+")

  ; Make key names more readable
  keysMap := Map(
    "CapsLock", "Caps",
    "BackSpace", "Backspace",
    "LWin", "Win",
    "RShift", "Right Shift"
  )

  For key, replacement in keysMap {
    hotkeyName := StrReplace(hotkeyName, key, replacement)
  }

  ; Format #HotIf conditions
  If InStr(hotkeyName, "#HotIf") {
    hotkeyName := RegExReplace(hotkeyName, "#HotIf\s+AllPressed\((.*?)\)", "($1)")
    hotkeyName := RegExReplace(hotkeyName, "#HotIf\s+GetKeyState\([" "'](.*?)[" "'],\s*[" "']P[" "']\)", "($1)")
    hotkeyName := RegExReplace(hotkeyName, "#HotIf\s+AllNotPressed\((.*?)\)", "")
    hotkeyName := RegExReplace(hotkeyName, "#HotIf", "")
    hotkeyName := StrReplace(hotkeyName, "AllPressed", "")
    hotkeyName := StrReplace(hotkeyName, "GetKeyState", "")
    hotkeyName := StrReplace(hotkeyName, "'", "")
    hotkeyName := StrReplace(hotkeyName, "" "", "")
    hotkeyName := StrReplace(hotkeyName, "AND", "")
    hotkeyName := StrReplace(hotkeyName, "(", "")
    hotkeyName := StrReplace(hotkeyName, ")", "")
    hotkeyName := StrReplace(hotkeyName, ",", "+")
    hotkeyName := StrReplace(hotkeyName, "'P'", "")
    hotkeyName := Trim(hotkeyName)
  }

  Return hotkeyName
}