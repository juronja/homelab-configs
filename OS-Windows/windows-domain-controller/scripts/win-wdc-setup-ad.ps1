# Install necessary roles and management tools
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

# Get the DSRM password securely from the user
$dsrmPassword = Read-Host "Enter DSRM Password" -AsSecureString

# Promote the server as Domain Controller (New Forest)
Install-ADDSForest `
    -DomainName "ad.lan" `
    -DomainNetbiosName "AD" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $dsrmPassword `
    -NoRebootOnCompletion:$false `
    -Force:$true