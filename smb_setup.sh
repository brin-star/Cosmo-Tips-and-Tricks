#!/bin/bash
# run with sudo
apt update -y
apt install samba
systemctl status smbd
ufw allow samba
smbpasswd -a blueteam


groupadd smbgroup

usermod -aG smbgroup blueteam

nano /etc/samba/smb.conf

echo 'make sure to use smbpasswd -a <user> as well as usermod -aG smbgroup <user> for each scored user'
