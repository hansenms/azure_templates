#!/bin/bash


group_name=$1
vmss_name=$2

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    failed_nodes=$(timeout 10 sh -c "az vmss list-instances -g ${group_name} -n ${vmss_name} | jq .[]| jq 'select(.provisioningState == \"Failed\" or .resources[0].provisioningState == \"Failed\")' | jq .instanceId | tr -d '\"'")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

if [ -n "$failed_nodes" ]; then 
    echo "Failed nodes found: ${failed_nodes}. Deleting"
    az vmss delete-instances -g $group_name -n $vmss_name --instance-ids $failed_nodes
fi
