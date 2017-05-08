#!/bin/bash
#
#  Script for making a copy of a managed disk in a different region
#  Michael S. Hansen (michael.schacht.hansen@gmail.com)
#

imageid=$1
location=$2
group_name=$3

#This is the storage account we will create to hold the BLOB
storage_account="$(echo $group_name| tr '[:upper:]' '[:lower:]'| tr -d '-')sa"

#Get some information from the source BLOB
bloburi=$(az image list | jq -r ".[] | select(.id==\"$imageid\") | .storageProfile.osDisk.blobUri")
source_account=$(echo $bloburi | sed 's,http[s]*://\([^\.]*\)\(.*\),\1,g')
blob_group=$(az image list | jq -r ".[] | select(.id==\"$imageid\") | .resourceGroup")
blob_container=$(echo $bloburi | sed 's,http[s]*://\([^\.]*\)\.blob.core.windows.net/\([^/]*\)\(.*\),\2,g')
blob_name=$(echo $bloburi | sed 's,http[s]*://\([^\.]*\)\.blob.core.windows.net/\([^/]*\)/\(.*\),\3,g')
source_key=$(az storage account keys list -g ${blob_group} -n ${source_account} | jq -r .[0].value)

echo "BLOB URI: $bloburi"
echo "BLOB Storage Account: $source_account"
echo "BLOB Storage Account Key: $source_key"
echo "BLOB container: $blob_container"
echo "BLOB name: $blob_name"

#Create group and storage account to hold BLOB
az group create --name ${group_name} --location ${location}
az storage account create --kind Storage --sku Standard_LRS --location ${location} -g ${group_name} -n ${storage_account}
key=$(az storage account keys list -g ${group_name} -n ${storage_account} | jq -r .[0].value)
az storage container create --account-name ${storage_account} --account-key ${key} -n images

#Start the copy of the blob
az storage blob copy start --account-name ${storage_account} --account-key ${key} --source-account-name ${source_account} --source-account-key ${source_key} --source-container ${blob_container} --source-blob ${blob_name} --destination-container images --destination-blob gtimage.vhd

#Now wait while this copy happening. This could take a while.
while [ $(az storage blob show --account-name ${storage_account} --account-key ${key} --container-name images --name gtimage.vhd| jq .properties.copy.status| tr -d '"') == "pending" ]; do 
    echo "Copying" && sleep 5
done
echo "Copying done"

#What is the name of the copied BLOB
newbloburl=$(az storage blob url --account-name ${storage_account} --account-key ${key} --container-name images --name gtimage.vhd)

#Now create a managed disk image based on that BLOB
az image create --name gt$(date +%Y%m%d%H%M%S) --os-type Linux -g ${group_name} --source ${newbloburl}