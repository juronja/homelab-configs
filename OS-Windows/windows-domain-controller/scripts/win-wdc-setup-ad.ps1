# Install necessary roles and management tools
Write-Host "Installing necessary roles and management tools ... This can take a few minutes (Patience)" -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
Write-Host "Roles and management tools installed successfully." -ForegroundColor Green

# Promote the server as Domain Controller (New Forest)
# Get password input from user
$passMatch = $false
$dsrmPassword = $null

do {
    $p1 = Read-Host "Enter DSRM Password" -AsSecureString
    $p2 = Read-Host "Confirm DSRM Password" -AsSecureString

    # Check if either is empty
    if ($p1.Length -eq 0 -or $p2.Length -eq 0) {
        Write-Host "Error: Password cannot be empty." -ForegroundColor Red
        continue
    }

    # Compare the two SecureStrings (with .NET)
    $bstr1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1)
    $bstr2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2)
    
    try {
        $str1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
        $str2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
        
        if ($str1 -eq $str2) {
            $dsrmPassword = $p1
            $passMatch = $true
            Write-Host "Passwords match!" -ForegroundColor Green
        } else {
            Write-Host "Error: Passwords do not match. Please try again." -ForegroundColor Red
        }
    }
    finally {
        # Clean up memory for security
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
    }
} until ($passMatch)

Write-Host "Promoting server to Domain Controller..." -ForegroundColor Cyan
Write-Host "System will REBOOT automatically upon completion." -ForegroundColor Cyan

Install-ADDSForest `
    -DomainName "ad.lan" `
    -DomainNetbiosName "AD" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $dsrmPassword `
    -NoRebootOnCompletion:$false `
    -Force:$true

Write-Host "Promoting server successfull. System is rebooting ..." -ForegroundColor Green
