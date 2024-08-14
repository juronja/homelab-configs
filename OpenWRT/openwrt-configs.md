# Useful OpenWRT configurations

## General configs

### Set password for UI

```bash
passwd
```

### System settings

```bash
uci set system.@system[0].zonename='Europe/Ljubljana'
uci set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'
uci set system.@system[0].hostname=GW-TP-Link-Archer-C7v4 #Change te device name here
uci set system.@system[0].hostname=AP-TL-WR1043NDv2 #Change te device name here
```

## Setup Modes

### AP Mode

Official documentation: https://openwrt.org/docs/guide-user/network/wifi/dumbap

By default, the main router will have an address of 192.168.1.1

#### Set dynamic IP, disable wan, wan6 and disable services to safe resources

If you need static IP, better reserve in router.
You can also delete the WAN and WAN& interfaces in UI.

```bash
uci set network.lan.proto="dhcp"
uci set dhcp.lan.ignore=1
uci set dhcp.lan.ra='disable'
uci set dhcp.lan.dhcpv6='disable'
uci set dhcp.lan.ndp='disable'
uci set network.wan.proto='none'
uci set network.wan.auto='0'
uci set network.wan6.proto='none'
uci set network.wan6.auto='0'
service dnsmasq disable
service dnsmasq stop
service odhcpd disable
service odhcpd stop
service firewall disable
service firewall stop # Note even though these services are now disabled, after you flash a new image to the device they will be re-enabled.
uci commit
reboot
```

After reboot reserve a static IP in gateway router and go to that IP to manage further.

#### Enable Wifi band 2G/802.11b/g/n

:warning: **Warning:** Double check which radio is 2g or 5g and replace accordingly.


```bash
uci set wireless.radio1=wifi-device
uci set wireless.radio1.band='2g'
uci set wireless.radio1.htmode='HT20'
uci set wireless.radio1.country='SI'
uci set wireless.radio1.channel='auto'
uci set wireless.radio1.disabled='0'
uci set wireless.default_radio1=wifi-iface
uci set wireless.default_radio1.device='radio1'
uci set wireless.default_radio1.network='lan'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.key='PASSWORD' # Enter password here
uci set wireless.default_radio1.encryption='sae-mixed'
uci set wireless.default_radio1.ssid='rw' # Enter SSID
#uci set wireless.default_radio1.ieee80211k='1' # For band-steering
#uci set wireless.default_radio1.bss_transition='1' # For band-steering
uci commit
wifi up #Turns Wifi ON
```

#### Enable Wifi band 5G/802.11ac/n

:warning: **Warning:** Double check which radio is 2g or 5g and replace accordingly.


```bash
uci set wireless.radio0=wifi-device
uci set wireless.radio0.band='5g'
uci set wireless.radio0.htmode='VHT80'
uci set wireless.radio0.country='SI'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.disabled='0'
uci set wireless.default_radio0=wifi-iface
uci set wireless.default_radio0.device='radio0'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.mode='ap'
uci set wireless.default_radio0.key='PASSWORD' # Enter password here
uci set wireless.default_radio0.encryption='sae-mixed'
uci set wireless.default_radio0.ssid='rw' # Enter SSID
#uci set wireless.default_radio0.ieee80211k='1' # For band-steering
#uci set wireless.default_radio0.bss_transition='1' # For band-steering
uci commit
wifi up #Turns Wifi ON
```


#### Disable Daemons Persistently

Add bellow for loop to /etc/rc.local. You can access this also in the UI. System > Startup > Local Startup

```bash
# these services do not run on dumb APs
for i in firewall dnsmasq odhcpd; do
  if /etc/init.d/"$i" enabled; then
    /etc/init.d/"$i" disable
    /etc/init.d/"$i" stop
  fi
done

```


### Router Mode

Official documentation: https://openwrt.org/docs/guide-user/network/openwrt_as_routerdevice

By default, the LAN ports of the router will have an address of 192.168.1.1


#### Static IP settings, DHCP, Firewall syn-flood

```bash
# uci show dhcp.lan
uci set network.lan.proto="static"
uci set network.lan.ipaddr="192.168.84.1"
uci set network.lan.netmask="255.255.255.0"
uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='50'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.lan.dhcp_option='6,192.168.84.22' #Adguard server address
uci set dhcp.lan.ra='disable'
uci set dhcp.lan.dhcpv6='disable'
uci set dhcp.lan.ndp='disable'
uci set dhcp.wan.ra='disable'
uci set dhcp.wan.dhcpv6='disable'
uci set dhcp.wan.ndp='disable'
uci set firewall.@defaults[0].syn_flood='1'
uci commit
reboot

```

#### SSH KEY Pair Generate and Upload

Make a SSH keypair for easy management.

##### Windows shell

```bash
ssh-keygen -t ed25519 -C "gateway"

```

When asked rename to: `C:\Users\Jure/.ssh/id_gateway`

upload:

```bash
scp $env:USERPROFILE/.ssh/id_gateway.pub root@192.168.X.X:/etc/dropbear/authorized_keys
```

##### Disable password authentication (OpenWRT CLI)

```bash
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit
service dropbear restart

```

#### Common router software

Install:
```bash
opkg update
opkg install nano-full
opkg install etherwake
opkg install luci-app-wol
#opkg install wpad-openssl
#opkg install usteer
#opkg install luci-app-usteer

```

#### Ports forwards

UCI is useful to view the firewall configuration, but not to do any meaningful modifications. Add port forward rules in UI or configuration file in `/etc/config/firewall`

```yml
config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Plex'
        list proto 'tcp'
        option src 'wan'
        option src_dport '32400'
        option dest_ip '192.168.84.10'
        option dest_port '32400'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Wireguard'
        list proto 'udp'
        option src 'wan'
        option src_dport '51820'
        option dest_ip '192.168.84.25'
        option dest_port '51820'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'qBittorrent'
        option src 'wan'
        option src_dport '50413'
        option dest_ip '192.168.84.10'
        list proto 'tcp'
        option dest_port '50413'

```
Restart firewall for effect
```bash
service firewall restart
```

#### Cloudflare & Nginx Proxy Manager conditional port forwarding rules

Cloudflare IPs: https://www.cloudflare.com/en-in/ips/

Add conditions in the configuration file `/etc/config/firewall`

```yml
config	ipset
        option name 'cloudflare-ips'
	option match 'src_net'
	option enabled '1'
	list entry '173.245.48.0/20'
        list entry '103.21.244.0/22'
        list entry '103.22.200.0/22'
        list entry '103.31.4.0/22'
        list entry '141.101.64.0/18'
        list entry '108.162.192.0/18'
        list entry '190.93.240.0/20'
        list entry '188.114.96.0/20'
        list entry '197.234.240.0/22'
        list entry '198.41.128.0/17'
        list entry '162.158.0.0/15'
        list entry '104.16.0.0/13'
        list entry '104.24.0.0/14'
        list entry '172.64.0.0/13'
        list entry '131.0.72.0/22'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Nginx Proxy Manager 80'
        option family 'ipv4'
        option ipset 'cloudflare-ips'
        list proto 'tcp'
        option src 'wan'
        option src_dport '80'
        option dest_ip '192.168.84.24'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Nginx Proxy Manager 443'
        option family 'ipv4'
        option ipset 'cloudflare-ips'
        list proto 'tcp'
        option src 'wan'
        option src_dport '443'
        option dest_ip '192.168.84.24'


```
Restart firewall for effect
```bash
service firewall restart
```

## Add static leases

Linux Homelab
```bash
uci add dhcp host
uci set dhcp.@host[-1].name='homelab'
uci add_list dhcp.@host[-1].mac='MACADRESS'
uci set dhcp.@host[-1].ip='RESERVEIPADDRESS'
uci commit

```

## Notes

To see pending changes use:
```bash
uci changes
```

Make a restore:

```bash
firstboot -y && reboot
```