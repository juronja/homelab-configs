# Setting up TP-Link Archer C7 v4 Device

By default, the main router will have an address of 192.168.1.1

## Set password for UI

```shell
passwd
```

## System settings

```shell
uci set system.@system[0].zonename='Europe/Ljubljana'
uci set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'
uci set system.@system[0].hostname=GW-TP-Link-Archer-C7v4 #Change te device name here
```

### Set as Router mode

Official documentation: https://openwrt.org/docs/guide-user/network/openwrt_as_routerdevice

#### Static IP settings, DHCP, Firewall syn-flood

```shell
# uci show dhcp.lan
uci set network.lan.proto="static"
uci set network.lan.ipaddr="192.168.84.1"
uci set network.lan.netmask="255.255.255.0"
uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='50'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.lan.dhcp_option='6,192.168.84.253' #Adguard server address
uci set dhcp.lan.ndp='disable'
uci set dhcp.wan.ra='disable'
uci set dhcp.wan.dhcpv6='disable'
uci set dhcp.wan.ndp='disable'
uci set firewall.@defaults[0].synflood_protect='1'
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='REJECT'
uci commit
reboot

```

#### Enable LAN Wifi band 2G/802.11b/g/n

:warning: **Warning:** Double check which radio is 2g or 5g and replace accordingly.


```bash
uci set wireless.radio1=wifi-device
uci set wireless.radio1.band='2g'
uci set wireless.radio1.htmode='HT20'
uci set wireless.radio1.country='SI'
uci set wireless.radio1.channel='auto'
uci set wireless.radio1.disabled='0'
uci set wireless.default_radio1=wifi-iface
uci set wireless.default_radio1.ocv='0'
uci set wireless.default_radio1.device='radio1'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.key='PASSWORD' # Enter password
uci set wireless.default_radio1.encryption='sae-mixed'
uci set wireless.default_radio1.ssid='rw_lan' # Enter SSID
# Fast Transition
# uci set wireless.default_radio1.ieee80211r='1'
# uci set wireless.default_radio1.mobility_domain='4f57'
# uci set wireless.default_radio1.ft_over_ds='0'
# Band-steering
# uci set wireless.default_radio1.ieee80211k='1' 
# uci set wireless.default_radio1.bss_transition='1'
uci commit
wifi up #Turns Wifi ON
```

#### Enable LAN Wifi band 5G/802.11ac/n

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
uci set wireless.default_radio0.key='PASSWORD' # Enter password
uci set wireless.default_radio0.encryption='sae-mixed'
uci set wireless.default_radio0.ssid='rw_lan5g' # Enter SSID
# Fast Transition
# uci set wireless.default_radio0.ieee80211r='1'
# uci set wireless.default_radio0.mobility_domain='4f57'
# uci set wireless.default_radio0.ft_over_ds='0'
# Band-steering
# uci set wireless.default_radio0.ieee80211k='1'
# uci set wireless.default_radio0.bss_transition='1'
uci commit
wifi up #Turns Wifi ON
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
        option dest_ip '192.168.84.x' # Adjust IP
        option dest_port '32400'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Wireguard'
        list proto 'udp'
        option src 'wan'
        option src_dport '51820'
        option dest_ip '192.168.84.x' # Adjust IP
        option dest_port '51820'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'qBittorrent'
        option src 'wan'
        option src_dport '50413'
        option dest_ip '192.168.84.x' # Adjust IP
        list proto 'tcp'
        option dest_port '50413'

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Storj'
        option src 'wan'
        option src_dport '28967'
        option dest_ip '192.168.84.x' # Adjust IP
        list proto 'tcp'
        option dest_port '28967'

```
Restart firewall for effect
```shell
service firewall restart
```

#### Cloudflare & Proxy Manager conditional port forwarding rules

Cloudflare IPs: https://www.cloudflare.com/en-in/ips/


```shell
uci add firewall ipset
uci set firewall.@ipset[-1].name='cloudflare-ips'
uci set firewall.@ipset[-1].match='src_net'
uci set firewall.@ipset[-1].enabled='1'
uci set firewall.@ipset[-1].loadfile='/tmp/cloudflare-ips.txt' # create file!!
uci commit
```

Add conditions in the configuration file `/etc/config/firewall`

```yml
config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Proxy Manager 80'
        option family 'ipv4'
        option ipset 'cloudflare-ips'
        list proto 'tcp'
        option src 'wan'
        option src_dport '80'
        option dest_ip '192.168.84.x' # Adjust to proxy IP

config redirect
        option dest 'lan'
        option target 'DNAT'
        option name 'Proxy Manager 443'
        option family 'ipv4'
        option ipset 'cloudflare-ips'
        list proto 'tcp'
        option src 'wan'
        option src_dport '443'
        option dest_ip '192.168.84.x' # Adjust to proxy IP


```
Restart firewall for effect
```shell
service firewall restart
```

### Setup VLANS

Device specific VLAN creation via uci.

#### IOT VLAN
```shell
# Add Switch VLAN, this will auto create a device in Network > Interfaces > Devices for usage.
uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='3'
uci set network.@switch_vlan[-1].vid='3'
uci set network.@switch_vlan[-1].description='iot'
uci set network.@switch_vlan[-1].ports='0t 2t 3t 4t 5'
uci commit
# Create a bridge device
uci add network device
uci set network.@device[-1].type='bridge'
uci set network.@device[-1].name='br-iot'
uci add_list network.@device[-1].ports='eth0.3'
uci commit
# Create new interface
uci set network.iot=interface
uci set network.iot.proto="static"
uci set network.iot.device='br-iot'
uci set network.iot.ipaddr="192.168.3.1"
uci set network.iot.netmask="255.255.255.0"
uci set dhcp.iot=dhcp
uci set dhcp.iot.interface='iot'
uci set dhcp.iot.start='20'
uci set dhcp.iot.limit='200'
uci set dhcp.iot.leasetime='12h'
uci add_list dhcp.iot.dhcp_option='6,9.9.9.11,1.1.1.2' #Public DNS
uci commit
# Add firewall entry
uci add firewall zone
uci set firewall.@zone[-1].name='iot'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci commit
# Connect firewall and create forwarding rule
uci add_list firewall.@zone[-1].network='iot'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='iot'
uci set firewall.@forwarding[-1].dest='wan'
uci commit
# Add a firewall traffic rule for network so they can use DNS and DHCP
uci add firewall rule
uci set firewall.@rule[-1].name='iot DHCP and DNS'
uci set firewall.@rule[-1].src='iot'
uci set firewall.@rule[-1].dest_port='53 67 68'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit
# also allow tv to plex
uci add firewall rule
uci set firewall.@rule[-1].name='allow tv to plex'
uci add_list firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].src='iot'
uci add_list firewall.@rule[-1].src_ip='192.168.3.X'
uci set firewall.@rule[-1].dest='lan'
uci add_list firewall.@rule[-1].dest_ip='192.168.84.X'
uci set firewall.@rule[-1].dest_port='32400'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit
# also allow guest devices to plex
uci add firewall rule
uci set firewall.@rule[-1].name='allow guests to plex'
uci add_list firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].src='guest'
uci set firewall.@rule[-1].dest='lan'
uci add_list firewall.@rule[-1].dest_ip='192.168.84.X'
uci set firewall.@rule[-1].dest_port='32400'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit
# Enable Wifi band 2G/802.11b/g/n
# Double check which radio is 2g or 5g and replace accordingly.
uci set wireless.wifinet2=wifi-iface
uci set wireless.wifinet2.device='radio1'
uci set wireless.wifinet2.mode='ap'
uci set wireless.wifinet2.network='iot'
uci set wireless.wifinet2.ssid='rw_iot' # Enter SSID
uci set wireless.wifinet2.encryption='psk2'
uci set wireless.wifinet2.key='PASSWORD' # Enter password
# Fast Transition
# uci set wireless.wifinet2.ieee80211r='1'
# uci set wireless.wifinet2.mobility_domain='4f57'
# uci set wireless.wifinet2.ft_over_ds='0'
# Band-steering
# uci set wireless.wifinet2.ieee80211k='1' 
# uci set wireless.wifinet2.bss_transition='1'
uci commit
service network restart
```

#### Guest VLAN
```shell
# Add Switch VLAN, this will auto create a device in Network > Interfaces > Devices for usage.
uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='4'
uci set network.@switch_vlan[-1].vid='4'
uci set network.@switch_vlan[-1].description='guest'
uci set network.@switch_vlan[-1].ports='0t 2t 3t 4t'
uci commit
# Create a bridge device
uci add network device
uci set network.@device[-1].type='bridge'
uci set network.@device[-1].name='br-guest'
uci add_list network.@device[-1].ports='eth0.4'
uci commit
# Create new interface
uci set network.guest=interface
uci set network.guest.proto="static"
uci set network.guest.device='br-guest'
uci set network.guest.ipaddr="192.168.4.1"
uci set network.guest.netmask="255.255.255.0"
uci set dhcp.guest=dhcp
uci set dhcp.guest.interface='guest'
uci set dhcp.guest.start='10'
uci set dhcp.guest.limit='200'
uci set dhcp.guest.leasetime='12h'
uci add_list dhcp.guest.dhcp_option='6,9.9.9.11,1.1.1.2' #Public DNS
uci commit
# Add firewall entry
uci add firewall zone
uci set firewall.@zone[-1].name='guest'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci commit
# Connect firewall and create forwarding rule
uci add_list firewall.@zone[-1].network='guest'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='guest'
uci set firewall.@forwarding[-1].dest='wan'
uci commit
# Add a firewall traffic rule for network so they can use DNS and DHCP
uci add firewall rule
uci set firewall.@rule[-1].name='guest DHCP and DNS'
uci set firewall.@rule[-1].src='guest'
uci set firewall.@rule[-1].dest_port='53 67 68'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit
# Enable Wifi band 2G/802.11b/g/n
# Double check which radio is 2g or 5g and replace accordingly.
uci set wireless.wifinet3=wifi-iface
uci set wireless.wifinet3.device='radio1'
uci set wireless.wifinet3.mode='ap'
uci set wireless.wifinet3.network='guest'
uci set wireless.wifinet3.ocv='0'
uci set wireless.wifinet3.ssid='rw_guest' # Enter SSID
uci set wireless.wifinet3.encryption='sae-mixed'
uci set wireless.wifinet3.key='PASSWORD' # Enter password
# Fast Transition
# uci set wireless.wifinet3.ieee80211r='1'
# uci set wireless.wifinet3.mobility_domain='4f57'
# uci set wireless.wifinet3.ft_over_ds='0'
# Band-steering
# uci set wireless.wifinet3.ieee80211k='1' 
# uci set wireless.wifinet3.bss_transition='1'
uci commit
service network restart
```


