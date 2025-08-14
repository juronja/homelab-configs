# DDNS Configurations

Install:
```bash
opkg update
opkg install ddns-scripts
# opkg install ddns-scripts-services #all services
opkg install ddns-scripts-cloudflare #cloudflare service
opkg install luci-app-ddns

```

## Enable service on startup

System > Startup
Enable `ddns` service

## Cloudflare config

Detailed info:
https://alexskra.com/blog/dynamc-dnsddns-with-openwrt-and-cloudflare/

DDNS config: /etc/config/ddns

### Cloudflare homelabtales lab-pernica proxied

```bash
uci set ddns.cloudflarelabpernica=service
uci set ddns.cloudflarelabpernica.service_name='cloudflare.com-v4'
uci set ddns.cloudflarelabpernica.use_ipv6='0'
uci set ddns.cloudflarelabpernica.domain='lab-pernica@homelabtales.com'
uci set ddns.cloudflarelabpernica.lookup_host='lab-pernica.homelabtales.com'
uci set ddns.cloudflarelabpernica.username='Bearer'
uci set ddns.cloudflarelabpernica.password='APIKEY' #UPDATE!
uci set ddns.cloudflarelabpernica.ip_source='network'
uci set ddns.cloudflarelabpernica.interface='wan'
uci set ddns.cloudflarelabpernica.ip_network='wan'
uci set ddns.cloudflarelabpernica.use_syslog='2'
uci set ddns.cloudflarelabpernica.check_interval='15'
uci set ddns.cloudflarelabpernica.check_unit='minutes'
uci set ddns.cloudflarelabpernica.force_interval='5'
uci set ddns.cloudflarelabpernica.force_unit='days'
uci set ddns.cloudflarelabpernica.retry_unit='seconds'
uci set ddns.cloudflarelabpernica.use_https='1'
uci set ddns.cloudflarelabpernica.cacert='/etc/ssl/certs'
uci set ddns.cloudflarelabpernica.enabled='1'

uci commit
service ddns restart

```

### Cloudflare homelabtales pernica DNS-only

```bash
uci set ddns.cloudflarepernica=service
uci set ddns.cloudflarepernica.service_name='cloudflare.com-v4'
uci set ddns.cloudflarepernica.use_ipv6='0'
uci set ddns.cloudflarepernica.domain='pernica@DOMAIN' #UPDATE!
uci set ddns.cloudflarepernica.lookup_host='pernica.DOMAIN' #UPDATE!
uci set ddns.cloudflarepernica.username='Bearer'
uci set ddns.cloudflarepernica.password='APIKEY' #UPDATE!
uci set ddns.cloudflarepernica.ip_source='network'
uci set ddns.cloudflarepernica.interface='wan'
uci set ddns.cloudflarepernica.ip_network='wan'
uci set ddns.cloudflarepernica.use_syslog='2'
uci set ddns.cloudflarepernica.check_interval='15'
uci set ddns.cloudflarepernica.check_unit='minutes'
uci set ddns.cloudflarepernica.force_interval='5'
uci set ddns.cloudflarepernica.force_unit='days'
uci set ddns.cloudflarepernica.retry_unit='seconds'
uci set ddns.cloudflarepernica.use_https='1'
uci set ddns.cloudflarepernica.cacert='/etc/ssl/certs'
uci set ddns.cloudflarepernica.enabled='1'

uci commit
service ddns restart

```

### Cloudflare homelabtales lab-smokuc proxied (For ASUS N11P-B1)

```bash
uci set ddns.cloudflarelabsmokuc=service
uci set ddns.cloudflarelabsmokuc.service_name='cloudflare.com-v4'
uci set ddns.cloudflarelabsmokuc.use_ipv6='0'
uci set ddns.cloudflarelabsmokuc.domain='lab-smokuc@homelabtales.com'
uci set ddns.cloudflarelabsmokuc.lookup_host='lab-smokuc.homelabtales.com'
uci set ddns.cloudflarelabsmokuc.username='Bearer'
uci set ddns.cloudflarelabsmokuc.password='APIKEY' #UPDATE!
uci set ddns.cloudflarelabsmokuc.ip_source='web'
uci set ddns.cloudflarelabsmokuc.ip_url='https://checkip.amazonaws.com'
uci set ddns.cloudflarelabsmokuc.interface='lan'
# uci set ddns.cloudflarelabsmokuc.bind_network='lan'
uci set ddns.cloudflarelabsmokuc.use_syslog='2'
uci set ddns.cloudflarelabsmokuc.check_interval='15'
uci set ddns.cloudflarelabsmokuc.check_unit='minutes'
uci set ddns.cloudflarelabsmokuc.force_interval='5'
uci set ddns.cloudflarelabsmokuc.force_unit='days'
uci set ddns.cloudflarelabsmokuc.retry_unit='seconds'
uci set ddns.cloudflarelabsmokuc.use_https='1'
uci set ddns.cloudflarelabsmokuc.cacert='/etc/ssl/certs'
uci set ddns.cloudflarelabsmokuc.enabled='1'

uci commit
service ddns restart

