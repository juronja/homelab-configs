# Windows Server Domain Controller Setup

Describes how to setup WDC and add users.

## Network / Firewall preparation

- Make/Decide WDC VLAN
- Make/Decide Clients VLAN
- Firewall - Reject Incoming by default
- Allow DNS, DHCP ports for both VLANS (53,67)

## Install WDC VM

Follow [these](https://github.com/juronja/homelab-configs/blob/main/Infrastructure/Proxmox/proxmox-VM-installs.md#windows-server-domain-controller-vm) steps.

## Firewall and DNS forwarding

- Allow Clients to reach WDC Server ports (88 123 135 389 445 464 3268 49152-65535)
- DNS forward to WDC controller (don't use WDC as DNS). Whitelist domain if needed.
