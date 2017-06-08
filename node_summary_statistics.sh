#!/bin/bash

days="1"
relayip=$(getent hosts $(hostname) | awk '{ print $1 }')

logfiles=$(find /gtmount/gtlog/ -path "*node*/*.log" -ctime -$days -printf "%T+;%p\n" | sort -r)

reconstructions=0
echo "<div><table>"
echo "<tr><th>Last Activity</th><th>Node Name</th><th>Direct Connections</th><th>Cloud Connections</th></tr>"
for f in $logfiles; do
    timestamp=$(echo $f|awk -F';' '{print $1}')
    logfile=$(echo $f|awk -F';' '{print $2}')
    nodename=$(echo $logfile| awk -F'/' '{print $4}')
    relay_counter=$(cat $logfile | grep "Connection" | grep "$relayip" | wc -l)
    internal_counter=$(cat $logfile | grep "Connection" | grep -v "$relayip" | wc -l)
    reconstructions=$(( $reconstructions + $relay_counter ))
    echo "<tr><td>$timestamp</td><td>$nodename</td><td>$relay_counter</td><td>$internal_counter</td></tr>"
done
echo "<table></div>"
echo "<div><b>Reconstructions: $reconstructions</b></div>"
