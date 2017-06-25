#!/bin/bash

group_name=$1
vmss_name=$2
sku_name=$3

timestamp() {
  date +"%H%M%S"
}

az group deployment create -g ${group_name} -n vmss_update$(timestamp) --mode Incremental --template-file vmss_update.json --parameters "{\"vmssname\" : {\"value\": \"${vmss_name}\"}, \"vmsize\": {\"value\": \"${sku_name}\"}, \"capacity\" : {\"value\": 0}}"
