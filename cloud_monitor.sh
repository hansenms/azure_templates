#!/bin/bash

# Cloud monitoring for Gadgetron Azure Cloud
# Michael S. Hansen (michael.hansen@nih.gov

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
    n=0
    if [ "$(number_of_nodes)" -gt 0 ]; then
	n=$(sh -c "curl -s http://localhost:18002/info/json| jq '.nodes | map(select(.last_recon < ${activity_time})) |length'")
	if [ -z "$n" ]; then
	    n=0
	fi
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

function deallocate_node
{
    log "Deallocating node $1"
    azure vm deallocate -g $group $1 
    log "Node $1 deallocated"
}

function start_node
{
    log "Start node $1"
    azure vm start -g $group $1
    log "Node $1 started"
}

function start_up_to_X_nodes
{
    X=$1
    nlist=$(timeout 60 sh -c "azure vm list -g $group --json | jq 'map(select(.powerState == \"VM deallocated\")) | .[0:$X] | .[].name' | tr -d '\"'")
    if [ "$nlist" != "Terminated" ] && [ -n "$nlist" ]; then
	for n in "$nlist"
	do
	    start_node $n &
	done
    fi

}

function get_packet_count
{
    iptables -x -Z -L INPUT -v|grep "Chain INPUT" | awk '{print $5}'
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
                                     idle_time=$1
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

#Figure out how many nodes that we have total (started and stopped)
available_nodes=$(total_nodes)

#Reset some counters before looping
cooldown_counter=$cooldown_interval
packets=$(get_packet_count)
counter=0
while true; do
    active_nodes=$(number_of_active_nodes)
    nodes=$(number_of_nodes)
    ideal_nodes=$nodes
    if [ "$active_nodes" -gt 0 ]; then
	ideal_nodes=`expr $active_nodes + $node_increment`
    fi

    #Log every 5th run through the loop
    if [ "$(expr $counter % 5)" -eq 0 ]; then
	log "Nodes: $nodes, Active: $active_nodes, Ideal: $ideal_nodes"
    fi
    counter=`expr $counter + 1`

    bash update_iptables_relay.sh

    if [ "$ideal_nodes" -gt "$nodes" ] && [ "$nodes" -lt "$available_nodes" ]; then
	log "More nodes will be recruited from deallocated pool"
	nodes_to_start=`expr $ideal_nodes - $nodes`
	start_up_to_X_nodes $nodes_to_start
    fi

    #Let's see if there is traffic
    packets=$(get_packet_count)
    if [ "$nodes" -eq 0 ] && [ "$packets" -gt 1000 ]; then
	log "Network activty detected, starting nodes"
	start_up_to_X_nodes $node_increment
    fi

    sleep $scaleup_interval
    cooldown_counter=`expr $cooldown_counter - $scaleup_interval`

    if [ "$cooldown_counter" -lt 0 ]; then
        log "Cool down check"
	if [ "$ideal_nodes" -le "$nodes" ] && [ "$nodes" -gt 0 ]; then
	    on=$(oldest_node)
	    lastr=$(echo $on | jq .last_recon | tr -d '"')
	    if [ "${lastr%.*}" -gt "$idle_time" ]; then
		nip=$(echo $on | jq .address | tr -d '"')
		nname=$(bash get_node_from_ip.sh $group $nip)
		if [ -n "$nname" ]; then
		    log "Shutting down node $nname with IP $nip"
		    curl http://${nip}:9080/acceptor/close
		    bash update_iptables_relay.sh
		    deallocate_node $nname &
		fi
	    fi
	fi
        cooldown_counter=$cooldown_interval
    fi    
done
