#!/bin/bash

mkdir -p "/home/shares"
mkdir -p "/home/shares/gtlog"
mkdir -p "/home/shares/gtdependencies"
chmod -R a+rwX /home/shares

echo "" >> "/etc/samba/smb.conf"
echo "[gtlog]" >> "/etc/samba/smb.conf"
echo "        path = /home/shares/gtlog" >> "/etc/samba/smb.conf"
echo "        read only = No" >> "/etc/samba/smb.conf"
echo "        guest ok = Yes" >> "/etc/samba/smb.conf"
echo "        directory mask = 0777" >> "/etc/samba/smb.conf"
echo "        create mask = 0777" >> "/etc/samba/smb.conf"
echo "" >> "/etc/samba/smb.conf"
echo "[gtdependencies]" >> "/etc/samba/smb.conf"
echo "        path = /home/shares/gtdependencies" >> "/etc/samba/smb.conf"
echo "        read only = No" >> "/etc/samba/smb.conf"
echo "        guest ok = Yes" >> "/etc/samba/smb.conf"
echo "        directory mask = 0777" >> "/etc/samba/smb.conf"
echo "        create mask = 0777" >> "/etc/samba/smb.conf"
echo "" >> "/etc/samba/smb.conf"

service smbd restart
