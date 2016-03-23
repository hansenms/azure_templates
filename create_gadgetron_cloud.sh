#!/bin/bash

group_name=$1
template_file=$2
template_parameters=$3
image_uri=$4

region="eastus"
storage_account="$(echo $group_name| tr '[:upper:]' '[:lower:]'| tr -d '-')sa"

azure group create --name ${group_name} --location ${region}
azure storage account create --type LRS --location ${region} -g ${group_name} ${storage_account}

key=$(azure storage account keys list -g  ${group_name} ${storage_account} --json | jq .key1| tr -d '"')

azure storage container create --account-name ${storage_account} --account-key ${key} images
azure storage blob copy start --dest-account-name ${storage_account} --dest-account-key ${key} --source-uri ${image_uri} --dest-container images --dest-blob gtimage.vhd
