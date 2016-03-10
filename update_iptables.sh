#!/bin/bash

N=$#
new_ips="$@"
timestamp=$(date +%s)
current_chain=$(iptables -t nat -S OUTPUT|grep 'dport 9002'|awk '{print $10}')
new_chain="gadgetron${timestamp}"
current_ips=""

#if there are no IPs remove any rules
if [ -z "$new_ips" ]; then
    if [ -n "$current_chain" ]; then
	iptables -t nat -F $current_chain
	iptables -t nat -D OUTPUT -p tcp --dport 9002 -j $current_chain
	iptables -t nat -X $current_chain
    fi
    exit
fi

#What is in the list now?
if [ -n "$current_chain" ]; then
    current_ips=$(iptables -t nat -L $current_chain|grep -Po '(\d+\.){3}\d+'|tr '\n' ' '|sort|xargs)
fi

if [ "$current_ips" = "$new_ips" ]; then
    #no need for changes we are done
    exit 
fi

#Create new chain
iptables -t nat -N $new_chain
for var in "$@"
do
    if [ $N -gt 1 ]; then
        iptables -t nat -A $new_chain -m statistic --mode nth --every $N --packet $(( N-1 )) -p tcp --dport 9002 -j DNAT --to-destination $var
        N=$(( N-1 ))
    else
        iptables -t nat -A $new_chain -p tcp --dport 9002 -j DNAT --to-destination $var
    fi
done
iptables -t nat -I OUTPUT -p tcp --dport 9002 -j $new_chain

#if there is an old chain, get rid of it
if [ -n "$current_chain" ]; then
    iptables -t nat -F $current_chain
    iptables -t nat -D OUTPUT -p tcp --dport 9002 -j $current_chain
    iptables -t nat -X $current_chain
fi
