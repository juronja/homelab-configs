# --- Inputs ---
$ipAddress = Read-Host "Enter the static IP Address"
$gateway = Read-Host "Enter the Default Gateway"

# Basic check to ensure inputs aren't empty
if ([string]::IsNullOrWhiteSpace($ipAddress) -or [string]::IsNullOrWhiteSpace($gateway)) {
    Write-Error "IP Address and Gateway are required. Script aborted."
    return
}

# --- Network Configuration ---
# Finds the active network adapter
$netAdapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

if ($null -eq $netAdapter) {
    Write-Error "No active network adapter found."
    return
}

# --- Actions ---
# Set static IP and Gateway and DNS
Write-Host "Configuring adapter: $($netAdapter.Name)..." -ForegroundColor Cyan
New-NetIPAddress -InterfaceIndex $netAdapter.ifIndex -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex $netAdapter.ifIndex -ServerAddresses ("127.0.0.1", "1.1.1.2")

# --- OpenSSH Setup ---
Write-Host "Setting up OpenSSH..." -ForegroundColor Cyan
Set-Service -Name sshd -StartupType 'Automatic'
Set-NetFirewallRule -Name "OpenSSH*" -Profile Domain, Private
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd

# --- Computer Rename ---
$newName = ""
# Loop until a valid name is provided
while ([string]::IsNullOrWhiteSpace($newName)) {
    $newName = Read-Host "Enter the new name for this server machine (Required)"
    
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Host "Error: Computer name cannot be empty." -ForegroundColor Red
    }
}
Write-Host "Renaming computer to $newName and restarting..." -ForegroundColor Yellow
Rename-Computer -NewName $newName -Restart -Force