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
Confirm-Step -Description "Configuring System Settings (Taskbar, Start Menu, File Explorer, Theme)..." -Action {
  
    # Disable UAC
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
    
    Write-Host "✔️ System settings applied. Recommended to restart PC before continuing..." -ForegroundColor Green
}


# Step 2: Windows Defender Configuration
Confirm-Step -Description "Configuring Windows Defender settings..." -Action {
    # Defender exclusion list
    Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","M:\","P:\","T:\"
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
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 # USB Suspend AC
        
    Write-Host "✔️ Power settings applied." -ForegroundColor Green
}


# Step 4: Language Configuration
Confirm-Step -Description "Language and Regional format configuration..." -Action {
    $NewLangList = New-WinUserLanguageList -Language "en-US"
    $NewLangList[0].InputMethodTips.Clear()
    $NewLangList[0].InputMethodTips.Add("0409:00000424")
    Set-WinUserLanguageList -LanguageList $NewLangList -Force

    # Set the Regional Format (Locale) to English (Slovenia)
    Set-Culture -Culture "en-SI"

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
        "Clipchamp.Clipchamp",
        "MicrosoftCorporationII.QuickAssist",
        "MicrosoftWindows.Client.WebExperience", # Widget app
        "Microsoft.Teams",
        "Microsoft.Copilot",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera",
        "Microsoft.GamingApp",
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
    winget uninstall onedrive -e -h

    Write-Host "-> Installing desired applications..." -ForegroundColor Yellow
    
    # Install using winget
    winget install -e --id Google.Chrome
    winget install -e --id Google.GoogleDrive
    winget install -e --id XP89DCGQ3K6VLD -s msstore -h --accept-package-agreements # PowerToys
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

# 3. Configure Registry for Slideshow
    if ($DownloadedFiles.Count -ge 1) {
        Write-Host "-> Configuring Windows for daily desktop slideshow..." -ForegroundColor Yellow
        
        # # Set Background Type
        # # The value '2' represents Slideshow
        # Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name 'BackgroundType' -Value 2 -Type DWord -Force

        # Set Slideshow Interval to 1 Day
        Set-ItemProperty -Path "HKCU:\Control Panel\Personalization\Desktop Slideshow" -Name 'Interval' -Value 86400000 -Type DWord -Force

        Write-Host "✔️ Slideshow configuration applied." -ForegroundColor Green
    } else {
        Write-Host "-> Wallpaper step finished, but no files were found or set." -ForegroundColor DarkGray
    }
}

# Step 7: Rename computer
Confirm-Step -Description "Rename the computer" -Action {
# --- Computer Rename ---
$newName = ""
# Loop until a valid name is provided
while ([string]::IsNullOrWhiteSpace($newName)) {
    $newName = Read-Host "Enter the new name for this server machine (Required)"
    
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Host "Error: Computer name cannot be empty." -ForegroundColor Red
    }
}
Write-Host "Renaming computer to $newName" -ForegroundColor Yellow
Rename-Computer -NewName $newName -Force
Write-Host "✔️ Computer renamed." -ForegroundColor Green
}

    # --- SCRIPT END ---
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "Script finished." -ForegroundColor Green
Write-Host "Some changes require a system reboot to take full effect." -ForegroundColor Yellow
Write-Host ""
