#!/bin/bash

logshare=$1
dependenciesshare=$2
shareaccount=$3
sharekey=$4
relay_ip=$5

apt-get -qq install cifs-utils -y
mkdir -p /mnt/gtlog
mkdir -p /mnt/gtdependencies 
echo "${logshare} /mnt/gtlog cifs vers=3.0,username=${shareaccount},password=${sharekey},dir_mode=0777,file_mode=0777" >> /etc/fstab
echo "${dependenciesshare} /mnt/gtdependencies cifs vers=3.0,username=${shareaccount},password=${sharekey},dir_mode=0777,file_mode=0777" >> /etc/fstab
mount -a
sleep 10  
mkdir -p /mnt/gtlog/$(hostname)

#Restart needed of docker needed after mounting drive
service docker restart

#Now run container
docker run -e "GADGETRON_RELAY_HOST=${relay_ip}" -v /mnt/gtlog/$(hostname):/tmp -v /mnt/gtdependencies:/tmp/gadgetron --name=gadgetron_container --publish=9002:9002 --publish=8002:8002 --publish=18002:18002 --publish=9080:9080 --restart=unless-stopped --detach -t current_gadgetron