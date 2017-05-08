#!/bin/bash

group_name=$1
template_file=$2
template_parameters=$3

if [ $# -le 3 ]; then
    region="eastus"
else
    region=$4
fi

az group create --name ${group_name} --location ${region}
time az group deployment create -g ${group_name} --parameters @${template_parameters} --template-file ${template_file}
