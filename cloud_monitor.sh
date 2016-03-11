#!/bin/bash

scaleup_interval=5
activity_time=60
cooldown_interval=600
idle_time=1800
node_increment=5
verbose=0
custom_data=$(sudo sh get_custom_data.sh)
group=$(echo $custom_data|jq .group|tr -d '"')

function usage
{
    echo "usage cloud_monitor [--scale-up-interval <SECONDS>]"
    echo "                    [--activity-time <SECONDS>]"
    echo "                    [--cool-down-interval <SECONDS>]"
    echo "                    [--idle-time <SECONDS>]"
    echo "                    [--node-increment <NODES>]"    
    echo "                    [--verbose]"
    echo "                    [--help]"
}

function timestamp
{
    date +"%Y%m%d %H:%M:%S" 
}

function log
{
    if [ "$verbose" -gt 0 ]; then
        echo "[`timestamp`] $1"
    fi    
}

function oldest_node
{
    sh -c "curl -s http://localhost:18002/info/json| jq -M '.nodes | sort_by(.last_recon) | reverse | .[0]'"
}

function number_of_nodes
{
    sh -c "curl -s http://localhost:18002/info/json| jq '.number_of_nodes'"
}

function number_of_active_nodes
{
    n=$(sh -c "curl -s http://localhost:18002/info/json| jq '.nodes | map(select(.last_recon < ${activity_time})) |length'")
    if [ -z "$n" ]; then
	n=0
    fi
    echo "$n"
}

function total_nodes
{
    numnodes=$(azure vm list -g $group --json| jq 'length')
    expr $numnodes - 1
}

function deallocated_nodes
{
    azure vm list -g $group --json| jq 'map(select(.powerState == "VM deallocated")) | length'
}

function find_node_for_ip
{
    ip=$1
    nic=$(sh -c "azure network nic list -g $group --json|jq 'map(select(.ipConfigurations[0].privateIPAddress == \"${ip}\")) | .[0].id ' | tr -d '\"'")
    sh -c "azure vm list -g $group --json| jq 'map(select(.networkProfile.networkInterfaces[0].id == \"$nic\"))| .[0].name'|tr -d '\"'"
}

function deallocate_node
{
    log "Deallocating node $1"
    azure vm deallocate -g $group $1
    log "Node $1 deallocated"
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --scale-up-interval )   shift
                                     scaleup_interval=$1
                                     ;;
        -a | --activity-time )       shift
                                     activity_time=$1
                                     ;;
        -c | --cool-down-interval )  shift
                                     cooldown_interval=$1
                                     ;;
        -i | --idle-time )           shift
                                     idle-time=$1
                                     ;;
        -n | --node-increment )      shift
                                     node_increment=$1
                                     ;;
        -v | --verbose )             verbose=1
                                     ;;
        -h | --help )                usage
                                     exit
                                     ;;
        * )                          usage
                                     exit 1
    esac
    shift
done

#Make sure we are logged into azure
bash azure_login.sh
available_nodes=$(total_nodes)
da_nodes=$(deallocated_nodes)

log "Available nodes: $available_nodes, Deallocated: $da_nodes"

cooldown_counter=$cooldown_interval
while true; do

    active_nodes=$(number_of_active_nodes)
    nodes=$(number_of_nodes)
    ideal_nodes=$nodes
    if [ "$active_nodes" -gt 0 ]; then
	ideal_nodes=`expr $active_nodes + $node_increment`
    fi

    log "Nodes: $nodes, Active: $active_nodes, Ideal: $ideal_nodes"
    bash update_iptables_relay.sh

    if [ "$ideal_nodes" -gt "$nodes" ]; then
	log "More nodes are needed"
    fi

    sleep $scaleup_interval
    cooldown_counter=`expr $cooldown_counter - $scaleup_interval`

    if [ "$cooldown_counter" -lt 0 ]; then
        log "Cool down check"
	if [ "$ideal_nodes" -le "$nodes" ] && [ "$nodes" -gt 0 ]; then
	    on=$(oldest_node)
	    nip=$(echo $on | jq .address | tr -d '"')
	    nname=$(find_node_for_ip $nip)
	    log "Shutting down node $nname with IP $nip"
	    deallocate_node $nname &
	fi
        cooldown_counter=$cooldown_interval
    fi    
done
