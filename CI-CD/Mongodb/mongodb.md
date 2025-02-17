# Useful Mongodb configurations

## Add database users

Admin user
```bash
use admin 
db.createUser({user: "admin_user", pwd: passwordPrompt(), roles: [{role: "root", db: "admin"}]})
```

Create user for each db if needed
```bash
use database_name 
db.createUser({user: "db_user", pwd: passwordPrompt(), roles: [{role: "readWrite", db: "database_name"}]})
```


## Enable authentication

Windows -> c: > Program Files > MongoDB > Server > version > bin > mongod.cfg
Linux -> /etc/mongod.conf

Add this lines:
```bash
security:
  authorization: "enabled"
```
OR use SED:

```bash
sudo sed -i 's/#security:/security:\n  authorization: "enabled"/' /etc/mongod.conf 
```


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


## Login

```bash
mongosh --authenticationDatabase "company_db" -u "juronja" -p
```
