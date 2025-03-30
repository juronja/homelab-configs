# Useful OpenWRT configurations

By default, the main router will have an address of 192.168.1.1

## Set password for UI

```shell
passwd
```

### SSH KEY Pair Generate and Upload

Make a SSH keypair for easy management.

#### Windows shell

```shell
ssh-keygen -t ed25519 -C "gateway"

```

When asked rename to: `C:\Users\Jure/.ssh/id_gateway`

upload:

```shell
scp $env:USERPROFILE/.ssh/id_gateway.pub root@192.168.X.X:/etc/dropbear/authorized_keys
```

#### Disable password authentication (OpenWRT CLI)

```shell
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit
service dropbear restart

```

### Common router software

```shell
opkg update
opkg install nano-full
opkg install etherwake
opkg install luci-app-wol
#opkg install wpad-openssl
#opkg install usteer
#opkg install luci-app-usteer

```

## Add static leases

VM homelab example
```shell
uci add dhcp host
uci set dhcp.@host[-1].name='lt-jure'
uci add_list dhcp.@host[-1].mac='MACADRESS'
uci set dhcp.@host[-1].ip='RESERVEIPADDRESS'
uci commit

```

## Notes

To see pending changes use:
```shell
uci changes
```

Make a restore:

```shell
firstboot -y && reboot
```