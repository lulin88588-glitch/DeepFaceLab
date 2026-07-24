Option Explicit

Dim shell, fileSystem, root, scriptPath, command
Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

root = fileSystem.GetParentFolderName(WScript.ScriptFullName)
scriptPath = fileSystem.BuildPath(root, "DeepFaceLab-GUI.ps1")
command = "powershell.exe -NoLogo -NoProfile -STA -WindowStyle Hidden " & _
          "-ExecutionPolicy Bypass -File " & Chr(34) & scriptPath & Chr(34)

shell.CurrentDirectory = root
shell.Run command, 0, False
