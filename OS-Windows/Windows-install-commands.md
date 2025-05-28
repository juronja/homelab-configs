# First steps after installing Windows

- Use Windows Terminal with Admin privileges!
- Update `App Installer` in MS Store to update winget

## Basics

```shell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/juronja/homelab-configs/main/OS-Windows/scripts/win-install-basics.ps1 | Invoke-Expression

```

### Backup command for UAC

```shell
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```

## Optional Preferences

```shell
# Renames the computer
Rename-Computer -NewName "PC-Pernica"

# Dynamic Lightning - turn uff because it is screwing with the Logitech G hub settings
Set-itemproperty "HKLM:\SOFTWARE\Microsoft\Lighting" -Name "AmbientLightingEnabled" -Value "0" -Type DWord #-Force
# Disable Print screen key to open screen capture
Set-itemproperty "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value "0" -Type DWord

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
winget install -e --id Microsoft.VisualStudioCode # You have to manually upgrade with "winget upgrade -e --id Microsoft.VisualStudioCode"
winget install -e --id Amazon.AWSCLI
winget install -e --id Kubernetes.kubectl
winget install -e --id Hashicorp.Terraform
winget install -e --id Docker.DockerDesktop
```

## Networking

### Static IP

```shell
Get-NetIPConfiguration
```

```shell
New-NetIPAddress -InterfaceIndex 6 -IPAddress 192.168.84.15 -PrefixLength 24 -DefaultGateway 192.168.84.1
```

```shell
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses 192.168.84.27

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

New-PSDrive -Name "X" -Root "\\nas.lan\cubbit" -Persist -Scope Global -PSProvider "FileSystem" -Credential juronja

```

## Set Environment Variables

```shell
setx ENV_LOCAL true
setx MONGO_ADMIN_USER "admin_user"
setx MONGO_ADMIN_PASS "pass"

```

## TO DO Windows setup ##
- [ ] disable sounds

