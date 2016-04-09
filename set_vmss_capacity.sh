#!/bin/bash

group_name=$1
vmss_name=$2
capacity=$3

timestamp() {
  date +"%H%M%S"
}

sku_name=$(azure vmss get ${group_name} ${vmss_name} --json | jq .sku.name | tr -d '"')

azure group deployment create -g ${group_name} -n vmss_update$(timestamp) -m Incremental --template-file vmss_update.json -p "{\"vmssname\" : {\"value\": \"${vmss_name}\"}, \"vmsize\": {\"value\": \"${sku_name}\"}, \"capacity\" : {\"value\": ${capacity}}}"
