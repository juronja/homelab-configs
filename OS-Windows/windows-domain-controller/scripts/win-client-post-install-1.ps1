# --- Inputs ---

Write-Host "Getting user input ... " -ForegroundColor Cyan

# Computer name variable
$newName = ""
while ([string]::IsNullOrWhiteSpace($newName)) {
    $inputName = Read-Host "Enter the new name for this server machine (Required)"

    if ([string]::IsNullOrWhiteSpace($inputName)) {
        Write-Host "❌ Computer name cannot be empty." -ForegroundColor Red
    } else {
        # Trim surrounding whitespace and replace internal spaces with "-"
        $newName = $inputName.Trim().Replace(" ", "-")
        Write-Host "Computer name set to: $newName" -ForegroundColor Cyan
    }
}

# --- Actions ---

# Wazuh agent Setup
$confirmation = Read-Host "Do you want to install the Wazuh agent? (y/n)"

if ($confirmation -match "^(y|yes)$") {
    Write-Host "Installing Wazuh..." -ForegroundColor Cyan

    $wazuhFQDN = Read-Host "Enter the Wazuh FQDN (eg. wazuh.lan)"
    winget install -e --id Wazuh.WazuhAgent -s winget --override "/q WAZUH_MANAGER=$wazuhFQDN WAZUH_AGENT_GROUP=default WAZUH_AGENT_NAME=$newName"

    Write-Host "✔️ Wazuh Agent installed." -ForegroundColor Green
} else {
    Write-Host "Skipping Wazuh Agent installation." -ForegroundColor Yellow
}

# Computer Rename
Write-Host "Renaming computer to $newName and restarting..." -ForegroundColor Cyan
Rename-Computer -NewName $newName -Restart -Force
