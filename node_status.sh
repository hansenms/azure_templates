#!/bin/bash

group_name=$1
vmss_name=$2

node_list=$(azure vmssvm list ${group_name} ${vmss_name} --json)
nic_list=$(azure network nic list -g ${group_name} --json)
nodes=$(echo $node_list| jq '. | length')

echo "Status of $group_name, $vmss_name"
echo "Number of nodes: $nodes\n"
n=0
echo "Node \t| Id \t| Node name         \t| IP     \t| Provisioning \t| Extension \t| Logfile                                            \t| Log modified    \t|" 
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

while [ "$n" -lt "$nodes" ]; do
    instanceid=$(echo $node_list | jq .[$n] | jq .instanceId | tr -d '"')
    nodename=$(echo $node_list | jq .[$n] | jq .osProfile.computerName | tr -d '"')
    nicid=$(echo $node_list | jq .[$n] | jq .networkProfile.networkInterfaces[0].id | tr -d '"')
    ip=$(echo $nic_list | jq "map(select(.id == \"$nicid\")) | .[0].ipConfigurations[0].privateIPAddress" | tr -d '"')
    pstate=$(echo $node_list| jq .[$n].provisioningState | tr -d '"')
    epstate=$(echo $node_list| jq .[$n].resources[0].provisioningState | tr -d '"')
    logfile="/gtmount/gtlog/${nodename}/gadgetron.log"
    LT="MISSING LOG FILE !!"
    if [ -e "$logfile" ]; then
	ecode=124
	try_count=0
	while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    		LT=$(timeout 2 sh -c "tac $logfile | grep -m1 -oP '(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})'")
    		ecode=$?
    		try_count=`expr $try_count + 1`
	done

	if [ "$try_count" -ge 10 ]; then
   		LT="TIMEOUT ON LOG FILE"
	fi
    fi
    echo "$n \t| $instanceid \t| $nodename \t| $ip \t| $pstate \t| $epstate \t| $logfile \t| $LT \t|" 
    n=`expr $n + 1`
done
