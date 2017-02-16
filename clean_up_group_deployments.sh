#!/bin/bash

group_name=$1

delete_date=$(date +%Y-%m-%d -d "5 days ago")
deployments=$(azure group deployment list --json ${group_name})
deployment_names=$(echo $deployments | jq ".[] | select(.properties.timestamp <= \"$delete_date\") | select(.name |contains(\"vmss\"))" | jq .name | tr -d '"')

for d in $deployment_names; do
    echo "azure group deployment delete -q $group_name $d" 
    azure group deployment delete -q $group_name $d
done
