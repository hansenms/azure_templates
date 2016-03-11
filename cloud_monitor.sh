#!/bin/bash

scaleup_interval=5
activity_time=60
cooldown_interval=600
idle_time=1800
node_increment=5
verbose=0

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

cooldown_counter=$cooldown_interval
while true; do

    active_nodes=$(number_of_active_nodes)
    nodes=$(number_of_nodes)
    ideal_nodes=$nodes
    if [ "$active_nodes" -gt 0 ]; then
	ideal_nodes=`expr $active_nodes + $node_increment`
    fi

    log "Nodes: $nodes, Active: $active_nodes, Ideal: $ideal_nodes"

    sleep $scaleup_interval
    cooldown_counter=`expr $cooldown_counter - $scaleup_interval`

    if [ "$cooldown_counter" -lt 0 ]; then
        log "Cool down check"
        cooldown_counter=$cooldown_interval
    fi    
done
