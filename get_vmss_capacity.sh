#!/bin/sh

group_name=$1
vmss_name=$2

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    capacity=$(timeout 10 sh -c "az vmss show -g $group_name -n $vmss_name | jq .sku.capacity")
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$try_count" -ge 10 ]; then
    exit 1
fi

echo "$capacity"
