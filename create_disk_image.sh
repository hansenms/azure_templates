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

#command="wget https://raw.githubusercontent.com/hansenms/azure_templates/master/setup_disk_creator.sh"
#ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

#command="sudo sh ./setup_disk_creator.sh ${docker_username} ${docker_password} ${docker_image}"
#ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

#Deprovision
command="waagent -force -deprovision"
ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

sh ./create_image_from_vm.sh ${group_name}  gtDiskCreator

