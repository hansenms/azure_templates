#!/bin/bash 

custom_data=$(sudo sh get_custom_data.sh)
client_id=$(echo $custom_data|jq .azure_client_id|tr -d '"')
tenant_id=$(echo $custom_data|jq .azure_tenant_id|tr -d '"')
key=$(echo $custom_data|jq .azure_key|tr -d '"')

azure config mode arm
azure login -u $client_id -p $key --tenant $tenant_id --service-principal
