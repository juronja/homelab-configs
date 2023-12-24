# Proxmox Helper-Scripts

Official docs: https://tteck.github.io/Proxmox/

## Install HAOS-VM - edited by me.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Proxmox/haos-vm.sh)"
```

## Install PiHole-LXC

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/pihole.sh)"
```

⚠️ Reboot Pi-hole LXC after install

Pi-hole Interface is at: IP/admin

⚙️ To set your password:

```bash
pihole -a -p

```