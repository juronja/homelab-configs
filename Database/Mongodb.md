# Useful Mongodb configurations

## General

Check status or start db:
```bash
systemctl status mongod
nohup systemctl start mongod
```

Login to mongodb:
```bash
mongosh
```

## Secure Access with Admin user

```bash
use admin
db.createUser({user: "juronja", pwd: passwordPrompt(), roles: [{role: "userAdminAnyDatabase", db: "admin"}]})
show users
```

## Enable Authentication

Update configuration file in `/etc/mongod.conf`

```bash
security:
    authorization: enabled
```

OR use SED:

```bash
sudo sed -i 's/#security:/security:\n  authorization: enabled/' /etc/mongod.conf 
```

OR

Start with `systemctl start mongod --auth`

## Create user for each db if needed

```bash
use {company_db}
db.createUser({user: "juronja", pwd: passwordPrompt(), roles: [{role: "readWrite", db: "company_db"}]})
show users
```

## Login

```bash
mongosh --authenticationDatabase "company_db" -u "juronja" -p
```

