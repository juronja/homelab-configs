# First steps after installing Windows

- Use Windows Terminal with Admin privileges!
- Update `App Installer` in MS Store to update winget

## Basics

```shell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/juronja/homelab-configs/main/OS-Windows/scripts/win-install-basics.ps1 | Invoke-Expression

```

## Optional Preferences

```shell
# Renames the computer
Rename-Computer -NewName "PC-Pernica"

# Dynamic Lightning - turn uff because it is screwing with the Logitech G hub settings
Set-itemproperty "HKLM:\SOFTWARE\Microsoft\Lighting" -Name "AmbientLightingEnabled" -Value "0" -Type DWord #-Force

# Remove UK language (work in progress better test it)
(Get-WinUserLanguageList | Where-Object LanguageTag -ne 'en-GB') | Set-WinUserLanguageList -Force

# Enable VMP and Install Windows Subsystem for Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -all
wsl --update
wsl --install -d Ubuntu
```

## Install Apps
```shell
winget install -e --id Plex.Plex
winget install -e --id Plex.Plexamp
winget install -e --id Telegram.TelegramDesktop
winget install -e --id WhatsApp.WhatsApp
winget install -e --id Discord.Discord
winget install -e --id Logitech.OptionsPlus
winget install -e --id Logitech.GHUB
winget install -e --id Nvidia.GeForceExperience
winget install -e --id Valve.Steam
winget install -e --id WireGuard.WireGuard
# Development
winget install -e --id Microsoft.VisualStudioCode # Have to manually upgrade with "winget upgrade -e --id Microsoft.VisualStudioCode"
winget install -e --id OpenJS.NodeJS.LTS # Have to manually upgrade with "winget upgrade -e --id OpenJS.NodeJS.LTS"
winget install -e --id Git.Git
winget install -e --id Python.Python.3.14 
winget install -e --id Amazon.AWSCLI
winget install -e --id Kubernetes.kubectl
winget install -e --id Helm.Helm
winget install -e --id Hashicorp.Terraform
winget install -e --id Docker.DockerDesktop
```

## Networking

### Static IP

```shell
Get-NetIPConfiguration
```

```shell
New-NetIPAddress -InterfaceIndex 6 -IPAddress 192.168.84.2 -PrefixLength 24 -DefaultGateway 192.168.84.1
```

```shell
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses 192.168.84.253

```

### Disable IPv6

```shell
Get-NetAdapterBinding -ComponentID ms_tcpip6
```

```shell
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6 

```

## Map network drives
```shell
New-PSDrive -Name "M" -Root "\\nas.lan\media" -Persist -Scope Global -PSProvider "FileSystem"

New-PSDrive -Name "X" -Root "\\nas.lan\personal" -Persist -Scope Global -PSProvider "FileSystem" -Credential juronja

```

## Set Environment Variables

```shell
setx ENV_LOCAL true
setx MONGO_ADMIN_USER "admin_user"
setx MONGO_ADMIN_PASS "pass"

```

## TO DO Windows setup ##
- [ ] disable sounds

