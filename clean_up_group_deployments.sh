#!/bin/bash

group_name=$1

delete_date=$(date +%Y-%m-%d -d "5 days ago")
deployments=$(az group deployment list -g ${group_name})
deployment_names=$(echo $deployments | jq ".[] | select(.properties.timestamp <= \"$delete_date\") | select(.name |contains(\"vmss\"))" | jq .name | tr -d '"')

for d in $deployment_names; do
    echo "az group deployment delete -g $group_name -n $d" 
    az group deployment delete -g $group_name -n $d
done
