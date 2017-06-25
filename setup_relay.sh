#!/bin/bash

basepath=$1

wget ${basepath}/setup_relay_shares.sh
wget ${basepath}/setup_relay_raid.sh

bash setup_relay_raid.sh
sh setup_relay_shares.sh

sh mount_and_run_docker.sh $(hostname) 192.168.1.1

sh azure_login.sh

mkdir -p /usr/local/share/gadgetron/azure
cd /usr/local/share/gadgetron/azure
wget ${basepath}/mount_and_run_docker.sh
wget ${basepath}/update_iptables.sh
wget ${basepath}/update_iptables_relay.sh
wget ${basepath}/get_custom_data.sh
wget ${basepath}/azure_login.sh
wget ${basepath}/cloud_monitor.sh
wget ${basepath}/cloud_monitor.service
wget ${basepath}/get_node_from_ip.sh
wget ${basepath}/get_total_nodes.sh
wget ${basepath}/get_deallocated_nodes.sh
wget ${basepath}/get_instance_id_from_ip.sh
wget ${basepath}/get_vmss_capacity.sh
wget ${basepath}/increment_vmss_capacity.sh
wget ${basepath}/set_vmss_capacity.sh
wget ${basepath}/vmss_update.json
wget ${basepath}/delete_failed_nodes.sh
wget ${basepath}/schedule.json


chmod +x cloud_monitor.sh
cp cloud_monitor.service /etc/systemd/system/

systemctl start cloud_monitor.service
