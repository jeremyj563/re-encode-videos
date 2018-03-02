; ReEncodeVideos v2.0.0.5
;
; Script Name: ReEncodeVideos.ahk
; Author: Jeremy Johnson
; Date: 03/01/2018
;
; Purpose: Provides a quick an easy way to re-encode videos into various formats.
;          Uses opensource command-line tools to do the actual encoding. This
;          script simply automates the process.
;
; Dependencies: HandBrakeCLI.exe and ffmpeg.exe (in the 'tools' folder)

#NoEnv
#SingleInstance IGNORE
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
input_dir = %A_ScriptDir%\input

CleanUpStubFiles() ; Stub files needed for nuget package

If IsEmpty(input_dir)
{
    MsgBox, , Error, Error: No files found in input folder. Exiting.
    ExitApp
}

Gui, New, , ReEncodeVideos
Gui, Add, Text,, Choose output format:
Gui, Add, ListBox, vFormatListBox gFormatListBox w230 r2 ; Number of rows in listbox
Gui, Add, Button, x80 w100, OK
GuiControl,, FormatListBox, General Purpose (MP4)
GuiControl,, FormatListBox, PowerPoint 2010 (WMV)
Gui, Show
Return

FormatListBox:
    If A_GuiEvent <> DoubleClick ; Accept a double click
        Return

ButtonOK:
    GuiControlGet, FormatListBox  ; Get the listbox current selection
    Gui, Hide
    Loop, %A_ScriptDir%\input\*.*
    {
        SplitPath, A_LoopFileFullPath, filename, , , file_prefix
        RunEncoder(FormatListBox, A_LoopFileFullPath, file_prefix)
        If ErrorLevel
        {
            MsgBox, , Error, Error: ReEncoding was unsuccessful! Input file (%filename%) will not be moved to 'processed' folder.
        }
        Else
        {
            FileMove, %A_LoopFileFullPath%, %A_ScriptDir%\input\processed\
        }
    }

IsEmpty(dir)
{
   Loop %dir%\*, 0, 0
      Return 0
   Return 1
}

RunEncoder(format, file, file_prefix)
{
    IfInString, format, MP4
    {
        RunWait, "%A_ScriptDir%\tools\HandBrakeCLI.exe" -i "%file%" -o "%A_ScriptDir%\output\%file_prefix%.mp4" --preset="Very Fast 1080p30"
    } Else IfInString, format, WMV
    {
        RunWait, "%A_ScriptDir%\tools\ffmpeg.exe" -y -i "%file%" -c:v wmv2 -c:a wmav2 "%A_ScriptDir%\output\%file_prefix%.wmv"
    }
    Else
    {
        MsgBox, , Error, Error(RunEncoder): Invalid value(s) passed to the function
    }
}

CleanUpStubFiles()
{
    FileDelete %A_ScriptDir%\input\.stub
    FileDelete %A_ScriptDir%\input\processed\.stub
    FileDelete %A_ScriptDir%\output\.stub
    FileDelete %A_ScriptDir%\*.nupkg
}

GuiClose:
GuiEscape:
ExitApp