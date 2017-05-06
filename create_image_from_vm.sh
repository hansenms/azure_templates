#!/bin/bash

group_name=$1
vm_name=$2

az vm deallocate -g ${group_name} --name ${vm_name}
az vm generalize -g ${group_name} --name ${vm_name}
az vm capture -g ${group_name} --name ${vm_name} --vhd-name-prefix gt$(date +%Y%m%d%H%M%S)
