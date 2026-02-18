# --- Inputs ---

Write-Host "Getting user input ... " -ForegroundColor Cyan

# Network
$ipAddress = Read-Host "Enter the static IP Address for this Server"
$ipPrefix = Read-Host "Enter the prefix CIDR (24,16,...)"
$gateway = Read-Host "Enter the Default Gateway"
# Basic check to ensure inputs aren't empty
if ([string]::IsNullOrWhiteSpace($ipAddress) -or [string]::IsNullOrWhiteSpace($gateway)) {
    Write-Error "IP Address and Gateway are required. Script aborted."
    return
}

# Finds the active network adapter
$netAdapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1
if ($null -eq $netAdapter) {
    Write-Error "No active network adapter found."
    return
}

# Computer name
$newName = ""
while ([string]::IsNullOrWhiteSpace($newName)) {
    $newName = Read-Host "Enter the new name for this server machine (Required)"

    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Host "Error: Computer name cannot be empty." -ForegroundColor Red
    }
}

# --- Actions ---

# Set static IP and Gateway and DNS
Write-Host "Configuring adapter: $($netAdapter.Name)..." -ForegroundColor Cyan
New-NetIPAddress -InterfaceIndex $netAdapter.ifIndex -IPAddress $ipAddress -PrefixLength $ipPrefix -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex $netAdapter.ifIndex -ServerAddresses ("127.0.0.1", "1.1.1.2")
Write-Host "✔️ Configuring adapter successfull." -ForegroundColor Green

# Install necessary roles and management tools
Write-Host "Installing AD, DNS, IIS services roles and management tools ... This can take a few minutes (Patience)" -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services, DNS, Web-Server -IncludeManagementTools
Write-Host "✔️ Roles and management tools installed successfully." -ForegroundColor Green

# Install virtio
msiexec.exe /i "E:\virtio-win-gt-x64.msi" /q
msiexec.exe /i "E:\guest-agent\qemu-ga-x86_64.msi" /q

# Installing Wazuh agent
#Write-Host "Do you want to install a Wazuh agent?" -ForegroundColor Cyan
winget install Wazuh.WazuhAgent --override '/i /q WAZUH_MANAGER="wazuh.lan" WAZUH_AGENT_GROUP="default" WAZUH_AGENT_NAME="win-client-1"'
Write-Host "✔️ Wazuh Agent installed." -ForegroundColor Green


# --- OpenSSH Setup ---
# Write-Host "Setting up OpenSSH..." -ForegroundColor Cyan
# Set-Service -Name sshd -StartupType 'Automatic'
# Set-NetFirewallRule -Name "OpenSSH*" -Profile Domain, Private
# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
# Start-Service sshd

# --- Computer Rename ---
Write-Host "Renaming computer to $newName and restarting..." -ForegroundColor Cyan
Rename-Computer -NewName $newName -Restart -Force
