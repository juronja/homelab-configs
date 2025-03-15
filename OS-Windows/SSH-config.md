# SSH configuration

### Create Public/Private keys on your computer/PC 

```bash
ssh-keygen -t ed25519 -C "nameofserver"
```
Rename the key eg. C:\Users\Jure/.ssh/id_nameofserver

### Setup SSH Managing config in Windows

To better manage multiple SSH keys, setup and edit the ssh config file like this.
In "C:\Users\Jure\.ssh\" make a new empty Text Document file named "config.txt". Save and remove the .txt extension.
Open the file with notepad and add this lines and edit what you need
```yaml
Host gateway
  Hostname 192.168.84.1
  User root
  IdentityFile ~/.ssh/id_gateway

Host homelab
  Hostname 192.168.84.16
  User juronja
  IdentityFile ~/.ssh/id_ubuntu-homelab
#  Port if a custom ssh port is set

Host hosting-prod
  Hostname 192.168.84.15
  User juronja
  IdentityFile ~/.ssh/id_hosting-prod

Host k8smaster
  Hostname 192.168.84.7
  User juronja
  IdentityFile ~/.ssh/id_k8s

Host amazon-server
  Hostname 18.185.139.225
  User ec2-user
  IdentityFile ~/.ssh/id_amazon.pem
```

### Upload your Public key to your Linux Server (Windows)

```bash
scp $env:USERPROFILE/.ssh/id_ubuntu-nameofserver.pub username@{IP}:~/.ssh/authorized_keys
```

### Disable password authentication in Linux. Uncomment "PasswordAuthentication" and change to "no"

In Proxmox you can remove the sudo commands for this to work

```bash
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config && sudo systemctl restart ssh
```