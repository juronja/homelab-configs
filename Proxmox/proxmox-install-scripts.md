# Proxmox Helper-Scripts

Official docs: https://tteck.github.io/Proxmox/

## Install HAOS-VM

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm.sh)"

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

## Install WireGuard LXC

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/wireguard.sh)"

```
Host Configuration
```bash
nano /etc/pivpn/wireguard/setupVars.conf

```
Add Clients
```bash
pivpn add
```

## Unifi Network Application

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/unifi.sh)"
```

UniFi Interface: (https)IP:8443
