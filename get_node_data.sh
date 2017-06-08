#!/bin/bash

since="1 day ago"

if [ $# -gt 0 ]; then
    since=$1
fi

journalctl --since "$since" -u cloud_monitor.service --output json --no-pager | grep "Nodes: " | jq -r .MESSAGE | awk '{print $1 " " $2 ";" $4 ";" $6}'| tr -d "[],"
