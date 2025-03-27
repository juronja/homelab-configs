# Setting up ASUS RT-N11P-B1 Device

By default, the main router will have an address of 192.168.1.1

## Set password for UI

```shell
passwd
```

## System settings

```shell
uci set system.@system[0].zonename='Europe/Ljubljana'
uci set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'
uci set system.@system[0].hostname=AP-RT-N11P-B1 # Change te device name here
```

## Set as AP mode

Official documentation: https://openwrt.org/docs/guide-user/network/wifi/dumbap

### Set dynamic IP, disable wan and disable services to safe resources

If you need static IP, better reserve/lease in router.
You can also delete the WAN and WAN6 interfaces in UI.

```shell
uci set network.lan.proto="dhcp"
uci set dhcp.lan.ignore=1
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

### Enable Wifi band 2G/802.11b/g/n

:warning: **Warning:** Double check which radio is 2g or 5g and replace accordingly.


```shell
uci set wireless.radio0=wifi-device
uci set wireless.radio0.band='2g'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.country='SI'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.disabled='0'
uci set wireless.default_radio0=wifi-iface
uci set wireless.default_radio0.device='radio0'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.mode='ap'
uci set wireless.default_radio0.key='PASSWORD' # Enter password
uci set wireless.default_radio0.encryption='sae-mixed'
uci set wireless.default_radio0.ssid='rw_lan' # Enter SSID
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

#### Disable Daemons Persistently on AP mode

Add bellow `for` loop to /etc/rc.local. You can access this also in the UI. System > Startup > Local Startup

```shell
# these services do not run on dumb APs
for i in firewall dnsmasq odhcpd; do
  if /etc/init.d/"$i" enabled; then
    /etc/init.d/"$i" disable
    /etc/init.d/"$i" stop
  fi
done

```