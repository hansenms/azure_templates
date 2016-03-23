#!/bin/bash

group_name=$1
vm_name=$2
image_prefix=$3

azure vm deallocate -g ${group_name} ${vm_name}
azure vm generalize -g ${group_name} ${vm_name}
azure vm capture -g ${group_name} ${vm_name} gt$(date +%Y%m%d%H%M%S)