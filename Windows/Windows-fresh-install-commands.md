# First steps after installing Windows

Use Windows Terminal and open PowerShell with Admin privileges.

## Disable UAC

```bash
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```

## Windows Defender exclusions

The **Add-MpPreference** cmdlet modifies settings for Windows Defender. Use this cmdlet to add exclusions for file name extensions, paths, and processes, and to add default actions for high, moderate, and low threats.

```bash
Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\"
```

## Change Power settings

Do this in Terminal in administrator mode.
```bash
powercfg /setactive SCHEME_MIN # (Min power saving)
powercfg /hibernate on
powercfg /change monitor-timeout-ac 20
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change disk-timeout-ac 30
Rename-Computer -NewName "PC-Pernica"
# TASKBAR - Removes Widgets and Task View from the Taskbar / Alligns the taskbar to the left
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -Type DWord
# START - Hide recently added apps / Show most used apps
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowFrequentList" -Value "1" -Type DWord
# FILE EXPLORER - Show file extensions and Show hidden folders
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1" -Type DWord





```

Computer\HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows

set-service beep -startuptype disabled
8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

