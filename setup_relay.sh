#!/bin/bash

wget https://raw.githubusercontent.com/hansenms/azure_templates/master/setup_relay_shares.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/setup_relay_raid.sh

bash setup_relay_raid.sh
sh setup_relay_shares.sh

sh mount_and_run_docker.sh $(hostname) 192.168.1.1

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
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/delete_failed_nodes.sh


chmod +x cloud_monitor.sh
cp cloud_monitor.conf /etc/init/

service cloud_monitor start
