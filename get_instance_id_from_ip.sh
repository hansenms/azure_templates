#!/bin/bash

group=$1
vmss=$2
ip=$3

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    nic=$(timeout 10 sh -c "az vmss nic list -g $group --vmss-name $vmss|jq 'map(select(.ipConfigurations[0].privateIpAddress == \"${ip}\")) | .[0].id ' | tr -d '\"'")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    instanceid=$(timeout 10 sh -c "az vmss list-instances -g $group -n $vmss | jq 'map(select(.networkProfile.networkInterfaces[0].id == \"$nic\"))| .[0].instanceId'|tr -d '\"'")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

echo "$instanceid"
