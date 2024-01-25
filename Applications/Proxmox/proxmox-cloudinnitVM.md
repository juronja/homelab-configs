# Cloud innit VM setup
How to setup a cloud VM with Cloudinit.

## STEP 1 - Proxmox Cloudinit VM
Copy this line in the Proxmox CLI. Edit what is needed.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Proxmox/scripts/cloudinnitvm.sh)"

```

## STEP 2 - Username and password
Set the username and password inside proxmox UI

## STEP 3 - Convert to template
Convert the created VM to template for future use.

## STEP 4 - Edit any cloud innit before starting
And you are done!