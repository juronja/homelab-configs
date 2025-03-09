# Disable UAC
Set-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Type DWord
# Disable Password expiry
#wmic UserAccount set PasswordExpires=False
# TASKBAR - Removes Widgets and Task View from the Taskbar / Alligns the taskbar to the left
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -Type DWord
# START - Hide recently added apps / Show most used apps
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowFrequentList" -Value "1" -Type DWord
# Personalize theme
Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value "0" -Type DWord
Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value "0" -Type DWord
# FILE EXPLORER - Show file extensions, Show hidden folders, do not use check boxes to select items
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1" -Type DWord
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value "0" -Type DWord
# StorageSense - set to run every day.
Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "2048" -Value "1" -Type DWord #-Force
# Defender exclusion list
Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\","M:\","X:\"
# Defender - disable
#Set-itemproperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value "1" -Type DWord -Force

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

# Install / Uninstall apps
Get-AppxPackage -alluser Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.BingWeather | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.WindowsMaps | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.MicrosoftStickyNotes | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.Todos | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.YourPhone | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.People | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.OutlookForWindows | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.ZuneVideo | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.WindowsFeedbackHub | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.WindowsSoundRecorder | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.GetHelp | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.Getstarted | Remove-AppxPackage
Get-AppxPackage -alluser Clipchamp.Clipchamp | Remove-AppxPackage
Get-AppxPackage -alluser MicrosoftCorporationII.QuickAssist | Remove-AppxPackage
Get-AppxPackage -alluser microsoft.windowscommunicationsapps | Remove-AppxPackage # Mail app
Get-AppxPackage -alluser MicrosoftWindows.Client.WebExperience | Remove-AppxPackage # Widget app
Get-AppxPackage -alluser Microsoft.549981C3F5F10 | Remove-AppxPackage # Cortana appGet-AppxPackage -alluser Microsoft.549981C3F5F10 | Remove-AppxPackage # Cortana app
Get-AppxPackage -alluser Microsoft.Teams | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.Copilot | Remove-AppxPackage
Get-AppxPackage -alluser Microsoft.WindowsAlarms | Remove-AppxPackage
winget uninstall onedrive
winget install -e --id Google.Chrome
winget install -e --id Adobe.Acrobat.Reader.64-bit
winget install -e --id Microsoft.PowerToys --source winget
