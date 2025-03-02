#Requires AutoHotkey v2.0
#SingleInstance Force
SetCapsLockState "AlwaysOff"
InstallKeybdHook()
#Include ..\#lib\Functions.ahk
TraySetIcon '..\#stuff/altK.ico'

; Basic state tracking
EntCaps := false

; Group definitions
GroupAdd "CtrlBackspaceWindowGroup", "ahk_exe PowerShell Studio.exe"
GroupAdd "CtrlBackspaceWindowGroup", "ahk_exe Explorer.EXE"

; Basic key functionality
$CapsLock:: return
$Enter:: return

SendShortcutKeys(VSCodeShortcut, GenericShortcut := '') {
  if WinActive('ahk_exe code.exe')
    Send VSCodeShortcut
  else if GenericShortcut
    Send GenericShortcut
}

; Enter & CapsLock combo
Enter & CapsLock:: {
  EntCaps := true
}

; Space combinations
~Enter & Space:: Send "{Ctrl Down}{Space Up}"
~CapsLock & Space:: Send "{Ctrl Down}{Space Up}"

; Space up handler
*CapsLock Up:: {
  Send "{Ctrl Up}"
  Send "{Shift Up}"
  Send "{Alt Up}"
  Send "{LWin Up}"
}

*Enter up:: {
  Send "{Ctrl Up}"
  Send "{Shift Up}"
  Send "{Alt Up 2}"
  Send "{LWin Up}"
}

;* Hotkeys with CapsLock
; MARK: Caps

#HotIf AllPressed('CapsLock') AND AllNotPressed('Ctrl', 'Space', 'r', 'e')

f:: return
p:: Send "{Escape}"
m:: Send "{Home}"
.:: Send "{End}"
ග:: Send "{End}"
`;:: Send "^+p"

#HotIf AllPressed('CapsLock') AND AllNotPressed('Ctrl', 'Space', 'r', 'e', 'f')

u::BackSpace
i::Up
o::Delete
j::Left
k::Down
l::Right

#HotIf AllPressed('CapsLock', 'f') AND AllNotPressed('Ctrl', 'Space', 'r', 'e')
; MARK: Caps + f

u:: {
  if WinActive("ahk_group CtrlBackspaceWindowGroup")
    Send "^+{Left}{Backspace}"
  else
    Send "^{BackSpace}"
}
i::PgUp
o::^Delete
j::^Left
k::PgDn
l::^Right

; MARK: Caps + e
#HotIf GetKeyState("CapsLock", "P") and GetKeyState("e", "P")
e:: return

y:: Send "+5"
u:: Send "["
i:: Send "]"
o:: Send "&"
p:: SendText "!"
[:: Send "~"
h:: Send "$"
j:: Send "("
k:: Send ")"
l:: Send "-"
`;:: Send "="
':: Send "``"
n:: Send "_"
m:: SendText "{"
,:: SendText "}"
.:: SendText "+"
/:: Send "\"
RShift:: Send '|'

; MARK: Caps+r (numbers)
#HotIf AllPressed('CapsLock', 'r') AND AllNotPressed('Space')
r:: return

y:: Send "1"
u:: Send "2"
i:: Send "3"
o:: Send "4"
p:: Send "5"
h:: Send "6"
j:: Send "7"
k:: Send "8"
l:: Send "9"
`;:: Send "0"
ත:: Send "0"

; MARK: Caps + g
#HotIf AllPressed('CapsLock', 'g')
g:: return
j:: Send "!\"

; u::Send

;* Hotkeys with Enter

#HotIf
; Enter combinations
CapsLock & Enter:: {
  if GetKeyState("f", "P") {
    Send "^{Enter}"
    return
  }
  if GetKeyState("e", "P") {
    Send "^+{Enter}"
    return
  }
  Send "{Enter}"
}

; MARK: Ent+j (Deletions)
#HotIf AllPressed('Enter', 'j')
j:: return
w:: SendShortcutKeys('^!j', '+{Home 2}{Delete}')      ; delete up to start of line
e:: {
  SendShortcutKeys('^+k', '{End}+{Home 2}{Delete}')
  Send ('{Up}')
}                                                     ; delete the entire line and move up
r:: SendShortcutKeys('^!l', '+{End}{Delete}')         ; delete down to end of line
s:: return
d:: SendShortcutKeys('^+k', '{End}+{Home 2}{Delete}') ; delete the entire line and move down
f:: return

; MARK: Ent
#HotIf GetKeyState('Enter', 'P') and AllNotPressed("'", 'j')
s:: Send '+{Left}'
f:: Send '+{Right}'
d:: Send '+{Down}'
e:: Send '+{Up}'
x:: Send '+{ Home}'
v:: Send '+{End}'
#HotIf

; MARK: Ent+Quotes (Move)
#HotIf AllPressed('Enter', "'") and AllNotPressed('j')
':: return

e:: SendShortcutKeys("!{Up}")     ; move line up
d:: SendShortcutKeys("!{Down}")   ; move line down
s:: SendShortcutKeys("!s")        ; move selection left
f:: SendShortcutKeys("!f")        ; move selection right

t:: SendShortcutKeys('!+{up}')    ; duplicate line (up)
g:: SendShortcutKeys('!+{down}')  ; duplicate line (down)

;!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; CapsLock + Space + Key combinations
#HotIf AllPressed('CapsLock', 'Space') AND AllNotPressed('e')

j:: Send "{Ctrl Down}"
h:: Send "{Alt Down}"
k:: Send "{Shift Down}"
i:: Send "{LWin Down}"

; Enter + CapsLock combinations (EntCaps mode)
#HotIf EntCaps
j:: {
  if GetKeyState("e", "P")
    Send "!+{Left}"  ; Shrink selection
  else if GetKeyState("f", "P")
    Send "^+{Left}"  ; Select word left
  else
    Send "+{Left}"   ; Select character left
}

l:: {
  if GetKeyState("e", "P")
    Send "!+{Right}" ; Expand selection
  else if GetKeyState("f", "P")
    Send "^+{Right}" ; Select word right
  else
    Send "+{Right}"  ; Select character right
}

#HotIf