#!/bin/bash

relay_info=$(curl -s http://localhost:18002/info/json)
nodes=$(echo $relay_info|jq .number_of_nodes)
nodeip=""
if [ "$nodes" -gt 0 ]; then
    nodeip=$(echo $relay_info|jq -M .nodes[].address| tr -d '"'|sort)
    for ip in $nodeip; do
	curl http://${ip}:9080/acceptor/close
    done
fi

bash update_iptables.sh

custom_data=$(sudo sh get_custom_data.sh)
group=$(echo $custom_data|jq .group|tr -d '"')
vmss="${group}node" 

sh set_vmss_capacity.sh $group $vmss 0


