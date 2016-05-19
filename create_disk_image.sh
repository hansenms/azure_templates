#!/bin/bash

group_name=$1
template_file=$2
template_parameters=$3
docker_username=$4
docker_password=$5
docker_email=$6
docker_image=$7

location="eastus"

time azure group create --name ${group_name} --location ${location} --template-file ${template_file} --parameters-file ${template_parameters}

command="wget https://raw.githubusercontent.com/hansenms/azure_templates/development/setup_disk_creator.sh"
ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

command="sudo sh ./setup_disk_creator.sh ${docker_username} ${docker_password} ${docker_email} ${docker_image}"
ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

sh ./create_image_from_vm.sh ${group_name}  gtDiskCreator

