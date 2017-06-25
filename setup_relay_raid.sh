#!/bin/bash

#This functions handles the interactive key presses needed for fdisk
partition_disk()
{

diskname=$1

cat <<EOF | fdisk $diskname
n
p
1


t
fd
w
EOF
partprobe

}

#Install necessary packages
export DEBIAN_FRONTEND=noninteractive
apt-get install -y mdadm

#Find out which disks to include
all_disks=$(sudo lshw -class disk|grep "logical name"| grep "/dev/sd" |awk '{print $3}')
disks=""
for d in $all_disks; do
    if [ "$d" != "/dev/sda" ] && [ "$d" != "/dev/sdb" ]; then
	disks="$disks $d"
    fi
done

raidname="/dev/md127"
partitions=""
for d in $disks; do 
    echo "DISK: $d"
    partition_disk $d
    partitions="$partitions ${d}1"
done
echo "PARTITIONS: $partitions"
number_of_partitions=$(echo $partitions | wc -w)
echo "Number of partitions: $number_of_partitions"

#Create the RAID
mdadm --create $raidname --level 0 --raid-devices $number_of_partitions $partitions
mkfs -t ext4 $raidname

#Find disk UUID
diskidline=$(/sbin/blkid | grep "$raidname")
disk_uuid=$(echo $diskidline| sed 's/[^=]*="\([^"]*\).*/\1/g')

#Mount the raid
mkdir -p /data
echo "UUID=$disk_uuid  /data  ext4  defaults  0  2" >> /etc/fstab
mount -a

#Make sure everybody can read and write
chmod -R a+rwX /data
