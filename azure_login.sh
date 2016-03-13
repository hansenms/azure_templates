#!/bin/bash 

custom_data=$(sudo sh get_custom_data.sh)
client_id=$(echo $custom_data|jq .azure_client_id|tr -d '"')
tenant_id=$(echo $custom_data|jq .azure_tenant_id|tr -d '"')
key=$(echo $custom_data|jq .azure_key|tr -d '"')

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    azure config mode arm
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$ecode" -eq 124 ]; then
    exit 1
fi

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    azure login -u $client_id -p $key --tenant $tenant_id --service-principal
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$ecode" -eq 124 ]; then
    exit 1
fi
