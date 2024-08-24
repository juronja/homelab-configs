# Cloudflare setup a domain

## Security

Things to do to secure the domain.

### Enable DNSSEC

If you are onboarding an existing domain to Cloudflare, make sure DNSSEC is disabled at your registrar (where you purchased your domain name). Otherwise, your domain will experience connectivity errors when you change your nameservers.

Follow this [official instructions](https://developers.cloudflare.com/dns/dnssec/#enable-dnssec)

After you create .pem and .key files add them to Nginx Proxy Manager Host.

### Enable HSTS

You have to enable it in the Nginx Proxy Host too.
