#!/bin/bash

group_name=$1
vmss_name=$2
increment=$3

capacity=$(sh get_vmss_capacity.sh $group_name $vmss_name)

if [ -z "$capacity" ]; then
    exit 1
fi

new_capacity=`expr $capacity + $increment`

sh set_vmss_capacity.sh $group_name $vmss_name $new_capacity

