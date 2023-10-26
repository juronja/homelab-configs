# Installing linux the first time

## Proxmox Cloudinit VM

```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 501 --cores 2 --cpu host --memory 4096 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1
qm disk import 501 jammy-server-cloudimg-amd64.img local --format qcow2
qm set 501 --scsi0 local:501/vm-501-disk-0.qcow2,discard=on,ssd=1 --ide2 local:cloudinit && qm disk resize 501 scsi0 32G
qm set 501 --boot order=scsi0

```

## Setting up linux
OpenSSH can be installed when installing Linux, or is usually preinstalled; so after installation you can ssh {{username}}@{{IP}} straight into your machine via the terminal (e.g. Windows PowerShell)
Working in Windows Powershell from here on.

## STEP 1
### Install upgrades / Install guest agent / Change local timezone / Configure automatic updates / Configure firewall / Disable pings in firewall / Remove legacy Docker / Add Docker apt repository / Install Docker / Reboot

### Multiple setup steps
```bash
sudo apt update -y && sudo apt upgrade -y \
  && chmod 700 ~/.ssh \
  && sudo apt install qemu-guest-agent -y \
  && sudo timedatectl set-timezone Europe/Ljubljana \
  && sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades \
  && sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22 && sudo ufw enable \
  && sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules \
  && for pkg in docker.io docker-doc docker-compose dcker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done \
  && sudo apt-get update && sudo apt-get install ca-certificates curl gnupg && sudo install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && sudo chmod a+r /etc/apt/keyrings/docker.gpg && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update \
  && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y && sudo docker run hello-world \
  && sudo reboot

```

## STEP 2 - SSH KEY PAIRS ON WINDOWS >> WindowsPowerShell <<
### Create Public/Private keys on your computer/PC 
```bash
ssh-keygen -t ed25519 -C "ubuntu-nameofserver"

```
### Rename the key eg. id_homelabserver

To better manage multiple SSH keys, setup and edit the ssh config file like this.
In "C:\Users\Jure\.ssh\" make a new empty Text Document file named "config.txt". Save and remove the .txt extension.
Open the file with notepad and add this lines and edit what you need
```yaml
Host ubuntu-nameofserver
  Hostname 192.168.xx.xx
  User username
  IdentityFile ~/.ssh/id_ubuntu-nameofserver

Host ubuntu-nameofserver2
  Hostname 192.168.xx.xx
  User username
  IdentityFile ~/.ssh/id_ubuntu-nameofserver2
#  Port # if a custom ssh port is set

```

### Upload your Public key to your Linux Server (Windows)
```bash
scp $env:USERPROFILE/.ssh/id_ubuntu-nameofserver.pub username@{IP}:~/.ssh/authorized_keys

```
### Disable password authentication. Uncomment "PasswordAuthentication" and change to "no"
```bash
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config && sudo systemctl restart ssh

```
## Change static ip by editing the config file inside this folder 

```bash
cd /etc/netplan/

```
### Restart the netplan

```bash
sudo netplan apply

```

## USEFUL FOR OTHER DISTROS - Ubuntu has this by default

### Install automatic upgrades
```bash
sudo apt install unattended-upgrades && sudo dpkg-reconfigure --priority=low unattended-upgrades
```

### Add user to sudo group
```bash
sudo usermod -aG sudo username
```

### Create the Public Key Directory for SSH on your Linux Server.
```bash
sudo mkdir ~/.ssh && chmod 700 ~/.ssh
```

## Windows setup ##
Firewall exclude folders
User account control
Install power toys