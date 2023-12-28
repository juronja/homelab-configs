# How to make a SMB share in ubuntu

Official docs: https://help.ubuntu.com/community/How%20to%20Create%20a%20Network%20Share%20Via%20Samba%20Via%20CLI%20%28Command-line%20interface/Linux%20Terminal%29%20-%20Uncomplicated,%20Simple%20and%20Brief%20Way!

1. Install Samba

```bash
sudo apt-get update
sudo apt-get install samba

```
2. Set a password for your user in Samba

```bash
sudo smbpasswd -a <user_name>

```
Note: Samba uses a separate set of passwords than the standard Linux system accounts (stored in /etc/samba/smbpasswd), so you'll need to create a Samba password for yourself. This tutorial implies that you will use your own user and it does not cover situations involving other users passwords, groups, etc...
Tip1: Use the password for your own user to facilitate.
Tip2: Remember that your user must have permission to write and edit the folder you want to share.
Eg.:
sudo chown <user_name> /var/opt/blah/blahblah
sudo chown :<user_name> /var/opt/blah/blahblah
Tip3: If you're using another user than your own, it needs to exist in your system beforehand, you can create it without a shell access using the following command :
sudo useradd USERNAME --shell /bin/false

You can also hide the user on the login screen by adjusting lightdm's configuration, in /etc/lightdm/users.conf add the newly created user to the line :
hidden-users=

3. Create a directory to be shared

```bash
mkdir /home/<user_name>/<folder_name>

```
4. Make a safe backup copy of the original smb.conf file to your home folder, in case you make an error

```bash
sudo cp /etc/samba/smb.conf ~

```
5. Edit the file "/etc/samba/smb.conf"

```bash
sudo nano /etc/samba/smb.conf

```
Once "smb.conf" has loaded, add this to the very end of the file:

[<folder_name>]
path = /home/<user_name>/<folder_name>
valid users = <user_name>
read only = no
Tip: There Should be in the spaces between the lines, and note que also there should be a single space both before and after each of the equal signs.

6. Restart the samba:

```bash
sudo service smbd restart

```
7. Once Samba has restarted, use this command to check your smb.conf for any syntax errors

```bash
testparm
```