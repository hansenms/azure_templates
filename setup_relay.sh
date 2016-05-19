#!/bin/bash

wget https://raw.githubusercontent.com/hansenms/azure_templates/development/setup_relay_shares.sh

sh setup_relay_shares.sh

sh mount_and_run_docker.sh $(hostname) 192.168.1.1

sh azure_login.sh

mkdir -p /usr/local/share/gadgetron/azure
cd /usr/local/share/gadgetron/azure
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/mount_and_run_docker.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/update_iptables.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/update_iptables_relay.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_custom_data.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/azure_login.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/cloud_monitor.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/cloud_monitor.conf
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_node_from_ip.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_total_nodes.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_deallocated_nodes.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_instance_id_from_ip.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/get_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/increment_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/set_vmss_capacity.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/vmss_update.json
wget https://raw.githubusercontent.com/hansenms/azure_templates/development/delete_failed_nodes.sh


chmod +x cloud_monitor.sh
cp cloud_monitor.conf /etc/init/

service cloud_monitor start
