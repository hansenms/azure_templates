#!/bin/bash

logshare=$1
dependenciesshare=$2
shareaccount=$3
sharekey=$4

apt-get -qq install cifs-utils -y
mkdir -p /mnt/gtlog
mkdir -p /mnt/gtdependencies 
echo "${logshare} /mnt/gtlog cifs vers=3.0,username=${shareaccount},password=${sharekey},dir_mode=0777,file_mode=0777" >> /etc/fstab
echo "${dependenciesshare} /mnt/gtdependencies cifs vers=3.0,username=${shareaccount},password=${sharekey},dir_mode=0777,file_mode=0777" >> /etc/fstab
mount -a
sleep 10  
