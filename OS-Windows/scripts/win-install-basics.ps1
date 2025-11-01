# Set error action preference to stop script on error
$ErrorActionPreference = "Stop"

# --- Function to display messages and handle flow ---
function Confirm-Step {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [scriptblock]$Action
    )
    
    # Display the step description and prompt
    Write-Host ""
    Write-Host -ForegroundColor Yellow ">> STEP: $Description"
    $prompt = "y/n to run step, 'abort' to stop script"
    $choice = Read-Host -Prompt $prompt

    # Loop until a valid choice is made
    while ($choice -ne 'y' -and $choice -ne 'n' -and $choice -ne 'abort') {
        Write-Host "Invalid choice. Please type 'y', 'n', or 'abort'." -ForegroundColor Red
        $choice = Read-Host -Prompt $prompt
    }

    if ($choice -eq 'y') {
        Write-Host "-> Continuing with step: $Description" -ForegroundColor Green
        & $Action # Execute the script block (the actual step logic)
    } elseif ($choice -eq 'n') {
        Write-Host "-> Skipping step: $Description" -ForegroundColor DarkGray
    } else {
        Write-Host "`n!! ABORTING SCRIPT as requested. !!" -ForegroundColor Red
        exit # Terminate the script
    }
    Write-Host ""
    Start-Sleep -Seconds 1
}

# --- MAIN SCRIPT EXECUTION ---

# Step 1: System Settings
Confirm-Step -Description "Configuring System Settings (UAC, Taskbar, Start Menu, File Explorer, Theme)..." -Action {
  
    # Disable UAC (requires reboot)
    Set-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Type DWord
    # Disable Password expiry
    # wmic UserAccount set PasswordExpires=False
    # TASKBAR - Removes Widgets and Task View from the Taskbar / Aligns the taskbar to the left
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -Type DWord
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -Type DWord
    # START - Hide recently added apps / Show most used apps
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Value "0" -Type DWord
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name "ShowFrequentList" -Value "1" -Type DWord
    # Personalize theme (Dark Theme)
    Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value "0" -Type DWord
    Set-itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value "0" -Type DWord
    # FILE EXPLORER - Show file extensions, Show hidden folders, do not use check boxes to select items
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0" -Type DWord
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1" -Type DWord
    Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value "0" -Type DWord
    # StorageSense - set to run every day.
    # Set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "2048" -Value "1" -Type DWord #-Force
    
    Write-Host "✔️ System settings applied." -ForegroundColor Green
}


# Step 2: Windows Defender Configuration
Confirm-Step -Description "Configuring Windows Defender settings..." -Action {
    # Defender exclusion list
    Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\","M:\","X:\"
    # Defender - disable (Uncomment if needed)
    # Set-itemproperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value "1" -Type DWord -Force
    
    Write-Host "✔️ Defender settings applied." -ForegroundColor Green
}


# Step 3: Power Settings Configuration
Confirm-Step -Description "Configuring Power settings..." -Action {
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
    
    Write-Host "✔️ Power settings applied." -ForegroundColor Green
}


# Step 4: Language Configuration
Confirm-Step -Description "Language configuration... (has to be tested)" -Action {
    $NewLangList = New-WinUserLanguageList -Language "en-US"
    $NewLangList[0].InputMethodTips.Clear()
    $NewLangList[0].InputMethodTips.Add("0409:00000424")
    Set-WinUserLanguageList -LanguageList $NewLangList -Force

    Write-Host "✔️ Language settings applied." -ForegroundColor Green
}


# Step 5: AppX and Winget Management
Confirm-Step -Description "Managing AppX packages and Winget applications..." -Action {
    Write-Host "-> Uninstalling bloatware..." -ForegroundColor Yellow
    # Uninstall AppX
    $AppXPackages = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.WindowsMaps",
        "Microsoft.YourPhone",
        "Microsoft.People",
        "Microsoft.OutlookForWindows",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.GetHelp",
        "Clipchamp.Clipchamp",
        "MicrosoftCorporationII.QuickAssist",
        "microsoft.windowscommunicationsapps",
        "MicrosoftWindows.Client.WebExperience",
        "Microsoft.Teams",
        "Microsoft.Copilot",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera",
        "Microsoft.GamingApp",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.Xbox.TCUI",
        "MSTeams"
    )
    
    foreach ($AppID in $AppXPackages) {
        Get-AppxPackage -alluser $AppID | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    
    # Uninstall using winget
    winget uninstall 9NBLGGH4QGHW -e -h # StickyNotes
    winget uninstall 9WZDNCRFHVFW -e -h # Microsoft News
    winget uninstall 9NBLGGH5R558 -e -h # Microsoft To Do
    winget uninstall 9WZDNCRFJ3Q2 -e -h # MSN Weather
    winget uninstall 9NFTCH6J7FHV -e -h # Power Automate
    # winget uninstall onedrive -e -h

    Write-Host "-> Installing desired applications..." -ForegroundColor Yellow
    # Install using winget
    winget install -e --id Google.Chrome
    winget install -e --id Google.GoogleDrive
    winget install -e --id XP89DCGQ3K6VLD -s msstore -h # PowerToys
    winget install -e --id Adobe.Acrobat.Reader.64-bit
    winget install -e --id 7zip.7zip
    winget install -e --id FlorianHeidenreich.Mp3tag

    Write-Host "✔️ App/Winget management completed." -ForegroundColor Green
}


# Step 6: Wallpaper Configuration - Download multiple backgrounds
Confirm-Step -Description "Downloading and setting desktop backgrounds from GitHub (files starting with 'bkg-')..." -Action {

    $DownloadFilter = "bkg-*" # Confirmed filter for 'bkg-meow...' files
    $ApiUrl = "https://api.github.com/repos/juronja/homelab-configs/contents/OS-Windows/assets?ref=main"
    $DownloadFolder = "$env:USERPROFILE\Pictures"
    
    # --- Execution ---
    
    # 1. Get file list from GitHub API
    Write-Host "-> Querying GitHub API for file list ..." -ForegroundColor Yellow
    try {
        # Fetch content details (files and folders) from the API
        $Files = Invoke-RestMethod -Uri $ApiUrl -Method Get
    }
    catch {
        Write-Host "!! ERROR: Could not access GitHub API. Check URL/Network." -ForegroundColor Red
        return
    }

    # 2. Filter files and download them
    $DownloadedFiles = @()
    # Filter for objects that are 'file' type and whose name matches the 'bkg-*' pattern
    $FilteredFiles = $Files | Where-Object { $_.name -like $DownloadFilter -and $_.type -eq "file" }

    if ($FilteredFiles.Count -eq 0) {
        Write-Host "-> No files found matching '$DownloadFilter'. Skipping download." -ForegroundColor DarkGray
    } else {
        Write-Host "-> Found $($FilteredFiles.Count) background files. Downloading..." -ForegroundColor Yellow
        
        foreach ($File in $FilteredFiles) {
            $DownloadUrl = $File.download_url # The direct raw URL
            $SavePath = Join-Path -Path $DownloadFolder -ChildPath $File.name
            
            # Use Invoke-WebRequest to download the file and save it locally
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $SavePath
            $DownloadedFiles += $SavePath
        }
    }

# # 3. Configure Registry for Slideshow
#     if ($DownloadedFilesCount -ge 1) {
#         Write-Host "-> Configuring Windows for daily desktop slideshow..." -ForegroundColor Yellow
        
#         # # A. Set the source folder for the slideshow (WallpaperSource)
#         # $PersonalizeKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Personalization\DesktopSlideshow"
#         # if (-not (Test-Path $PersonalizeKey)) {
#         #     New-Item -Path $PersonalizeKey -Force | Out-Null
#         # }
#         # # The key stores the path to the folder to be used for the slideshow
#         # Set-ItemProperty -Path $PersonalizeKey -Name 'ImagePath0' -Value $DownloadFolder -Type String -Force
        
#         # B. Set Slideshow Interval to 1 Day (86400 seconds)
#         $DesktopKey = "HKCU:\Control Panel\Desktop"
#         # The DWORD value stores the time in milliseconds. 1 day = 86400000 ms
#         Set-ItemProperty -Path $DesktopKey -Name 'Interval' -Value 86400000 -Type DWord -Force
        
#         # C. Set Wallpaper Style and Status
#         # The registry key for 'TileWallpaper' also controls slideshow status:
#         # 2: Slideshow is enabled
#         Set-ItemProperty -Path $DesktopKey -Name 'TileWallpaper' -Value 2 -Type String -Force
#         # 2: Stretch/Fill mode (WallpaperStyle is often ignored for slideshow, but set to a common value)
#         Set-ItemProperty -Path $DesktopKey -Name 'WallpaperStyle' -Value 2 -Type String -Force
        
#         # D. Set Background Type
#         $ControlKey = "HKCU:\Control Panel\Personalization"
#         # The value '2' represents Slideshow
#         Set-ItemProperty -Path $ControlKey -Name 'BackgroundType' -Value 2 -Type DWord -Force
        
#         # 4. Refresh the desktop immediately
#         Write-Host "-> Refreshing desktop to apply the slideshow configuration." -ForegroundColor Cyan
        
#         # Use SystemParametersInfo to force a refresh (Wallpaper parameter is needed for the call, but it's the refresh action that matters)
#         $signature = @'
# [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
# public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
# '@
#         Add-Type -MemberDefinition $signature -Name "User32" -Namespace "Win32" -PassThru | Out-Null
#         # SPI_SETDESKWALLPAPER = 20, SPIF_UPDATEINIFILE = 0x01, SPIF_SENDCHANGE = 0x02
#         # Set the Wallpaper value to the folder path to ensure the Slideshow control is triggered on refresh.
#         [Win32.User32]::SystemParametersInfo(20, 0, $DownloadFolder, 3) | Out-Null
        
#         Write-Host "✔️ Slideshow configuration applied. Pictures will change daily." -ForegroundColor Green
#     } else {
#         Write-Host "-> Wallpaper step finished, but no files were found or set." -ForegroundColor DarkGray
#     }
}


# --- SCRIPT END ---
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "Script finished." -ForegroundColor Green
Write-Host "Some changes (like UAC) require a system reboot to take full effect." -ForegroundColor Yellow
Write-Host ""
