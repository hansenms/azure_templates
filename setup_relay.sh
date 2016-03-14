#!/bin/bash

logshare=$1
dependenciesshare=$2
storageaccount=$3
share_key=$4

echo "sh mount_shares.sh $logshare $dependenciesshare $storageaccount $share_key"
sh mount_shares.sh $logshare $dependenciesshare $storageaccount $share_key

apt-get update
apt-get install -y nodejs-legacy jq libxml2-utils emacs wget curl
apt-get install -y npm
npm install -g azure-cli

sh azure_login.sh

mkdir -p /usr/local/share/gadgetron/azure
cd /usr/local/share/gadgetron/azure
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/mount_shares.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/update_iptables.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/update_iptables_relay.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_custom_data.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/azure_login.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/cloud_monitor.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/cloud_monitor.conf
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_node_from_ip.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_total_nodes.sh
wget https://raw.githubusercontent.com/hansenms/azure_templates/master/get_deallocated_nodes.sh

chmod +x cloud_monitor.sh
cp cloud_monitor.conf /etc/init/

service cloud_monitor start
