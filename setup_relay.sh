#!/bin/bash

share_key=$1

custom_data=$(sh get_custom_data.sh)

logshare=$(echo $custom_data | jq .logshare| tr -d '"')
dependenciesshare=$(echo $custom_data | jq .dependenciesshare | tr -d '"')
storageaccount=$(echo $custom_data | jq .storageaccount | tr -d '"')
sh mount_shares.sh $logshare $dependenciesshare $storageaccount $share_key

sudo apt-get update
sudo apt-get install -y nodejs-legacy jq libxml2-utils emacs wget curl
sudo apt-get install -y npm
sudo npm install -g azure-cli

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

chmod +x cloud_monitor.sh
cp cloud_monitor.conf /etc/init/

service cloud_monitor start
