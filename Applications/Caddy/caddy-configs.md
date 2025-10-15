# Caddy configurations

## Cloudflare CA certificates

Copy the cloudflare certs to a folder.

```shell
mkdir -m 750 /etc/caddy/certs
install -m 640 /dev/null /etc/caddy/certs/homelabtales_com-origin-cert.pem
install -m 640 /dev/null /etc/caddy/certs/homelabtales_com-private-key.key
chown -R root:caddy /etc/caddy/certs
```

## Hash passwords

```shell
caddy hash-password

```

## Rate limit 3rd party module

Build a custom caddy binary with module with xcaddy and move new binary to /usr/bin/ and overwrite.

⚠️ When updating caddy, you have to repeat this steps.

```shell
xcaddy build --with github.com/mholt/caddy-ratelimit
mv caddy /usr/bin/ && systemctl restart caddy
```

## Coraza WAF 3rd party module

Try this at some point.

```shell
xcaddy build --with github.com/corazawaf/coraza-caddy/v2
```

https://medium.com/@jptosso/oss-waf-stack-using-coraza-caddy-and-elastic-3a715dcbf2f2

"$@" >/dev/null 2>&1 echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
