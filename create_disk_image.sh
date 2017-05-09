#!/bin/bash

group_name=$1
template_file=$2
template_parameters=$3

location="eastus"

time az group create --name ${group_name} --location ${location}
time az group deployment create --resource-group ${group_name} --template-file ${template_file} --parameters @${template_parameters}

while [ $(az vm show -g ${group_name} -n gtDiskCreator | jq -r .provisioningState) != "Succeeded" ]; do
    echo "Waiting for VM to deploy"
done

sleep 20

#Remove extension so that we can add a new one later. 
extension_id=$(az vm extension list -g $group_name --vm-name gtDiskCreator | jq -r .[0].id)
vm extension delete --ids $extension_id 

#Deprovision
command="sudo waagent -force -deprovision"
ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

sh ./create_image_from_vm.sh ${group_name}  gtDiskCreator

