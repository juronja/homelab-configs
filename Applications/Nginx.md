# Nginx configurations

Good guide: https://www.youtube.com/watch?v=qlcVx-k-02E

## SSL Certificates

Create a cert with DNS challenge.

Domain names: repina.eu *.repina.eu

Provider Clouflare

Create and use zone DNS token:
https://dash.cloudflare.com/profile/api-tokens

1. Token name: Give it a name
2. Permissions: Zone, DNS, Edit
3. Zone Resources: Include, All zones

Propagation Seconds
120

## Proxy Hosts Example

### Details

Domain names: wg.repina.eu
Scheme: choose
IP: Server IP
FWD port: app port
- [x] block common exploits
- [x] Websockets # Home Assistant needs it

### SSL
Choose the cert
- [x] Force SSL
- [x] HTTP/2 Support