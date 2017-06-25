#!/bin/bash

relay_info=$(curl -s http://localhost:18002/info/json)
nodes=$(echo $relay_info|jq .number_of_nodes)
nodeip=""
if [ "$nodes" -gt 0 ]; then
    nodeip=$(echo $relay_info|jq -M .nodes[].address| tr -d '"'|sort)
fi
sh update_iptables.sh $nodeip
    
