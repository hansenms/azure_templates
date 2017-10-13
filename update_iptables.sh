#!/bin/bash

N=$#
new_ips="$@"
timestamp=$(date +%s)
current_chain=$(iptables -w -t nat -S OUTPUT|grep 'dport 9002'|awk '{print $10}')
new_chain="gadgetron${timestamp}"
current_ips=""

#if there are no IPs remove any rules
if [ -z "$new_ips" ]; then
    if [ -n "$current_chain" ]; then
	iptables -w -t nat -F $current_chain
	iptables -w -t nat -D OUTPUT -p tcp --dport 9002 -j $current_chain
	iptables -w -t nat -X $current_chain
    fi
    exit
fi

#What is in the list now?
if [ -n "$current_chain" ]; then
    current_ips=$(iptables -w -t nat -L $current_chain|grep -Po '(\d+\.){3}\d+'|tr '\n' ' '|sort|xargs)
fi

if [ "$current_ips" = "$new_ips" ]; then
    #no need for changes we are done
    exit 
fi

#Create new chain
iptables -w -t nat -N $new_chain
for var in "$@"
do
    if [ $N -gt 1 ]; then
        iptables -w -t nat -A $new_chain -m statistic --mode nth --every $N --packet $(( N-1 )) -p tcp --dport 9002 -j DNAT --to-destination $var
        N=$(( N-1 ))
    else
        iptables -w -t nat -A $new_chain -p tcp --dport 9002 -j DNAT --to-destination $var
    fi
done
iptables -w -t nat -I OUTPUT -p tcp --dport 9002 -j $new_chain

#if there is an old chain, get rid of it
if [ -n "$current_chain" ]; then
    iptables -w -t nat -F $current_chain
    iptables -w -t nat -D OUTPUT -p tcp --dport 9002 -j $current_chain
    iptables -w -t nat -X $current_chain
fi
