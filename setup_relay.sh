#!/bin/bash

logshare=$1
dependenciesshare=$2
storageaccount=$3
share_key=$4

echo "sh mount_and_run_docker.sh $logshare $dependenciesshare $storageaccount $share_key 192.168.1.1"
sh mount_and_run_docker.sh $logshare $dependenciesshare $storageaccount $share_key 192.168.1.1

sh azure_login.sh

mkdir -p /usr/local/share/gadgetron/azure
cd /usr/local/share/gadgetron/azure
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/mount_and_run_docker.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/update_iptables.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/update_iptables_relay.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_custom_data.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/azure_login.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/cloud_monitor.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/cloud_monitor.conf
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_node_from_ip.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_total_nodes.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_deallocated_nodes.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_instance_id_from_ip.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/increment_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/set_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/vmss_update.json


chmod +x cloud_monitor.sh
cp cloud_monitor.conf /etc/init/

service cloud_monitor start
