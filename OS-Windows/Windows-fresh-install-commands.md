# First steps after installing Windows

Use Windows Terminal with Admin privileges!

## Desktop PC tweaks

To disable windows defender you have to manually toggle the Tamper Protection OFF.

```shell
# Disable UAC
Set-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Type DWord
# Disable Password expiry
wmic UserAccount set PasswordExpires=False
# Disable Defender
Set-itemproperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value "1" -Type DWord -Force

# Dynamic Lightning - turn uff because it is screwing with the Logitech G hub settings
Set-itemproperty "HKLM:\SOFTWARE\Microsoft\Lighting" -Name "AmbientLightingEnabled" -Value "0" -Type DWord #-Force

# Renames the computer
Rename-Computer -NewName "PC-Pernica"

# Enable VMP and Install Windows Subsystem for Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -all
wsl --update
wsl --install -d Ubuntu

# Power settings
powercfg /setactive SCHEME_MIN # (Min power saving)
powercfg /hibernate on
powercfg /change monitor-timeout-ac 20 # Wall power
powercfg /change monitor-timeout-dc 5 # Battery
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 10
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

# Disable Print screen key to open screen capture
Set-itemproperty "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value "0" -Type DWord
# TASKBAR - Removes Widgets and Task View from the Taskbar / Alligns the taskbar to the left
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -Type DWord
# START - Hide recently added apps / Show most used apps
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowFrequentList" -Value "1" -Type DWord
# Personalize theme
Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value "0" -Type DWord
Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value "0" -Type DWord


# FILE EXPLORER - Show file extensions and Show hidden folders
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1" -Type DWord
Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\","M:\","X:\"

```

## Install Apps
```shell

winget install -e --id Google.Chrome
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.PowerToys --source winget
winget install -e --id Adobe.Acrobat.Reader.64-bit
winget install -e --id Plex.Plex
winget install -e --id Plex.Plexamp
winget install -e --id Telegram.TelegramDesktop
winget install -e --id WhatsApp.WhatsApp
winget install -e --id Discord.Discord
winget install -e --id Google.Drive
winget install -e --id Logitech.GHUB
winget install -e --id Nvidia.GeForceExperience
winget install -e --id Valve.Steam
winget install -e --id Docker.DockerDesktop
winget install -e --id Logitech.OptionsPlus
winget install -e --id Amazon.AWSCLI
winget install -e --id WireGuard.WireGuard

# For NPM if needed after install run the node.JS command prompt to initialize
#winget install -e --id OpenJS.NodeJS.LTS
```

## Uninstall apps



### Backup command for UAC

```shell
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```

## Map network drives
```shell
New-PSDrive -Name "M" -Root "\\nas.lan\media" -Persist -PSProvider "FileSystem" -Credential juronja

New-PSDrive -Name "X" -Root "\\nas.lan\cubbit" -Persist -PSProvider "FileSystem" -Credential juronja

```


## TO DO Windows setup ##
- [ ] disable sounds
- [ ] uninstall programs

