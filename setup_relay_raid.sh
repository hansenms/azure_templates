#!/bin/bash

partition_disk()
{

diskname=$1

cat <<EOF
EOF | fdisk $diskname
n
p
1

t
fd
w
EOF
partprobe

}

apt-get install -y mdadm

#TODO: search with lshw -class disk to find available drives
disks="/dev/sdc /dev/sdd /dev/sde /dev/sdf"
raidname="/dev/md127"
partitions=""
for d in $disks; do 
    partition_disk $d
    partitions="$partitions ${d}1"
done

mdadm --create /dev/md127 --level 0 --raid-devices 4 $partitions
mkfs -t ext4 /dev/md127

diskidline=$(/sbin/blkid | grep "/dev/md127")
disk_uuid=$(echo $diskidline| sed 's/[^=]*="\([^"]*\).*/\1/g')

mkdir -p /data

echo "UUID=$disk_uuid  /data  ext4  defaults  0  2" >> /etc/fstab
mount -a

