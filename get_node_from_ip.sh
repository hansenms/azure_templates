#!/bin/bash

group=$1
ip=$2

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    nic=$(timeout 10 sh -c "azure network nic list -g $group --json|jq 'map(select(.ipConfigurations[0].privateIPAddress == \"${ip}\")) | .[0].id ' | tr -d '\"'")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    nodename=$(timeout 10 sh -c "azure vm list -g $group --json| jq 'map(select(.networkProfile.networkInterfaces[0].id == \"$nic\"))| .[0].name'|tr -d '\"'")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

echo "$nodename"
