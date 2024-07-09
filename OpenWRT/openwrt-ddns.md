# DDNS Configurations

Install:
```bash
opkg update
opkg install ddns-scripts
opkg install ddns-scripts-cloudflare
opkg install ddns-scripts-services
opkg install luci-app-ddns

```

## Duckdns config

DDNS config:
```bash
uci set ddns.duckdns=service
uci set ddns.duckdns.service_name='duckdns.org'
uci set ddns.duckdns.use_ipv6='0'
uci set ddns.duckdns.domain='pernica.duckdns.org'
uci set ddns.duckdns.username='pernica'
uci set ddns.duckdns.password='ENTER API PASS'
uci set ddns.duckdns.ip_source='network'
uci set ddns.duckdns.ip_network='wan'
uci set ddns.duckdns.use_syslog='2'
uci set ddns.duckdns.check_interval='30'
uci set ddns.duckdns.check_unit='minutes'
uci set ddns.duckdns.force_interval='72'
uci set ddns.duckdns.force_unit='hours'
uci set ddns.duckdns.interface='wan'
uci set ddns.duckdns.lookup_host='pernica.duckdns.org'
uci set ddns.duckdns.enabled='1'

uci commit
service ddns restart

```


## Cloudflare config

Detailed info:
https://alexskra.com/blog/dynamc-dnsddns-with-openwrt-and-cloudflare/

DDNS config:
```bash
uci set ddns.cloudflare=service
uci set ddns.cloudflare.service_name='cloudflare.com-v4'
uci set ddns.cloudflare.use_ipv6='0'
uci set ddns.cloudflare.domain='lab-pernica@repina.eu'
uci set ddns.cloudflare.username='Bearer'
uci set ddns.cloudflare.password='ENTER API PASS'
uci set ddns.cloudflare.ip_source='network'
uci set ddns.cloudflare.ip_network='wan'
uci set ddns.cloudflare.use_syslog='2'
#uci set ddns.cloudflare.check_interval='30'
uci set ddns.cloudflare.check_unit='minutes'
#uci set ddns.cloudflare.force_interval='72'
uci set ddns.cloudflare.force_unit='hours'
uci set ddns.cloudflare.interface='wan'
uci set ddns.cloudflare.lookup_host='lab-pernica.repina.eu'
uci set ddns.cloudflare.use_https='1'
uci set ddns.cloudflare.cacert='/etc/ssl/certs'
uci set ddns.cloudflare.enabled='1'

uci commit
service ddns restart

```
