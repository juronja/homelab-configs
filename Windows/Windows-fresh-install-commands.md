# First steps after installing Windows

Use Windows Terminal with Admin privileges.

## Desktop PC tweaks

Disable UAC, Change power settings, update taskbar, start and file explorer, Windows defender exclusions.

```bash
powercfg /setactive SCHEME_MIN # (Min power saving)
powercfg /hibernate on
powercfg /change monitor-timeout-ac 20
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change disk-timeout-ac 0
Rename-Computer -NewName "PC-Pernica"
# Enable VMP and Install Windows Subsystem for Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -all
wsl --install -d Ubuntu

# Disable UAC
Set-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Type DWord
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
Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\"

```

### Backup command for UAC

```bash
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```



## TO DO Windows setup ##
- [ ] disable sounds
- [ ] Install power toys
- [ ] Add for laptop in the future if you need. Some of the tweaks are specific for DC powered plan. 
