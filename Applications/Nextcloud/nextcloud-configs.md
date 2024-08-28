# NextCloud configurations

## TrueNas Dataset

user and group owners must be `www-data`

## Post install tasks

After you install put this command in the container shell:

```bash
occ config:system:set trusted_domains 0 --value=nextcloud.repina.eu
occ config:system:delete trusted_domains 1
occ config:system:delete trusted_domains 2
occ config:system:delete trusted_domains 3
occ config:system:set trusted_proxies 0 --value=192.168.84.27/24
occ config:system:set overwriteprotocol --value=https
occ config:system:set overwrite.cli.url --value=https://nextcloud.repina.eu
occ config:system:set default_phone_region --value=SI
occ config:system:set maintenance_window_start --type=integer --value=1
occ db:add-missing-indices
```

## Email server

```bash
occ config:system:set mail_smtpmode --value=smtp
occ config:system:set mail_smtphost --value=smtp.gmail.com
occ config:system:set mail_smtpport --value=587
occ config:system:set mail_sendmailmode --value=smtp
occ config:system:set mail_domain --value=gmail.com
occ config:system:set mail_smtpauth --value=1 --type=integer
```

Add email and password manually in UI.

You have to create an app password in gmail to be able to setup the gmail email server.
https://myaccount.google.com/apppasswords