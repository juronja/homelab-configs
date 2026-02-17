# Caddy configurations

## Installation

Use the official script to install the Server.
⚠️ After installation delete the .tar file.

## Add agents

sample code:

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.3-1.msi -OutFile $env:tmp\wazuh-agent; msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='wazuh.lan' WAZUH_AGENT_GROUP='default' WAZUH_AGENT_NAME='win-client-1'
```
