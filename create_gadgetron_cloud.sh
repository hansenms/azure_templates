#!/bin/bash

group_name=$1
template_file=$2
template_parameters=$3
image_uri=$4

if [ $# -le 4 ]; then
    region="eastus"
else
    region=$5
fi

storage_account="$(echo $group_name| tr '[:upper:]' '[:lower:]'| tr -d '-')sa"

az group create --name ${group_name} --location ${region}
az storage account create --kind Storage --sku Standard_LRS --location ${region} -g ${group_name} -n ${storage_account}

key=$(az storage account keys list -g ${group_name} -n ${storage_account} | jq .[0].value | tr -d '"')

echo "Storage account: ${storage_account}"
echo "Storage key: ${key}"

az storage container create --account-name ${storage_account} --account-key ${key} -n images
#az storage blob copy start --account-name ${storage_account} --account-key ${key} --source-uri ${image_uri} --destination-container images --destination-blob gtimage.vhd

#while [ $(az storage blob show --account-name ${storage_account} --account-key ${key} --container-name images --name gtimage.vhd| jq .properties.copy.status| tr -d '"') == "pending" ]; do 
#    echo "Copying" && sleep 5
#done
#echo "Copying done"

#Finally create deployment
time az group deployment create -g ${group_name} --parameters @${template_parameters} --template-file ${template_file}
