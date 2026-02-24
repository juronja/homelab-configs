# Wazuh configurations

## Installation

Use the official script to install the Server.
⚠️ After installation delete the .tar file.

## IIS Logs

IIS logs are enabled with WDC install scripts. But you have to make a dashboard.

- logs below alert level 3 are sent to `wazuh-archives-*` database. So you have enable it if you want to get ALL logs.
- Filter by `decoder.name:web.accesslog-iis-default`

## Add agents (If not already added with Windows install)

sample code with winget method:

```powershell
winget install -e --id Wazuh.WazuhAgent -s winget --override "/q WAZUH_MANAGER=wazuh.lan WAZUH_AGENT_GROUP=default WAZUH_AGENT_NAME=win-client-1"

```

## Dashboards

- Exporting configs
