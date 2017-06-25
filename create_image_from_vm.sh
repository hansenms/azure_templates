#!/bin/bash

group_name=$1
vm_name=$2

az vm deallocate -g ${group_name} --name ${vm_name}
az vm generalize -g ${group_name} --name ${vm_name}
az image create --resource-group ${group_name} --name gt$(date +%Y%m%d%H%M%S) --source ${vm_name}
