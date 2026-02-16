# Install necessary roles and management tools
Write-Host "Installing AD, DNS services roles and management tools ... This can take a few minutes (Patience)" -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
Write-Host "Roles and management tools installed successfully." -ForegroundColor Green
