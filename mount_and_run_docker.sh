#!/bin/bash

relayhostname=$1
relay_ip=$2

mkdir -p /gtmount/gtlog
mkdir -p /gtmount/gtdependencies
echo "${relayhostname}:/home/shares/gtlog /gtmount/gtlog nfs rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab
echo "${relayhostname}:/home/shares/gtdependencies /gtmount/gtdependencies nfs rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab
sleep 3
mount -a
sleep 10

if [ -z "$(mount | grep /gtmount/gtlog)" ]; then
    echo "Failed to mount gtlog"
    exit 113
fi

if [ -z "$(mount | grep /gtmount/gtdependencies)" ]; then
    echo "Failed to mount gtdependencies"
    exit 113
fi

mkdir -p /gtmount/gtlog/$(hostname)
chown root:root /gtmount/gtlog/$(hostname)
chmod 0777 /gtmount/gtlog/$(hostname)

#Restart needed of docker needed after mounting drive
service docker restart

#Now run container
docker run -e "GADGETRON_LOG_FILE=/tmp/gtlog/gadgetron.log" -e "GADGETRON_RELAY_HOST=${relay_ip}" -v /gtmount/gtlog/$(hostname):/tmp/gtlog -v /gtmount/gtdependencies:/tmp/gadgetron --name=gadgetron_container --publish=9002:9002 --publish=8002:8002 --publish=18002:18002 --publish=9080:9080 --restart=unless-stopped --detach -t current_gadgetron
