#!/bin/bash

# Cloud monitoring for Gadgetron Azure Cloud
# Michael S. Hansen (michael.hansen@nih.gov

scaleup_interval=5
activity_time=60
cooldown_interval=600
scale_up_settle_time=300
idle_time=1800
node_increment=8
verbose=0
custom_data=$(sudo sh get_custom_data.sh)
group=$(echo $custom_data|jq .group|tr -d '"')
#TODO: We should fix this. Should be based on a lookup
vmss="${group}node" 
max_nodes=20


usage()
{
    echo "usage cloud_monitor [--scale-up-interval <SECONDS>]"
    echo "                    [--activity-time <SECONDS>]"
    echo "                    [--cool-down-interval <SECONDS>]"
    echo "                    [--idle-time <SECONDS>]"
    echo "                    [--scale-up-settle-time <SECONDS>]"
    echo "                    [--node-increment <NODES>]"    
    echo "                    [--max-nodes <NODES>]"    
    echo "                    [--verbose]"
    echo "                    [--help]"
}


timestamp()
{
    date +"%Y%m%d %H:%M:%S" 
}

log()
{
    if [ "$verbose" -gt 0 ]; then
        echo "[`timestamp`] $1"
    fi    
}

oldest_node()
{
    sh -c "curl -s http://localhost:18002/info/json| jq -M '.nodes | sort_by(.last_recon) | reverse | .[0]'"
}

number_of_nodes()
{
    sh -c "curl -s http://localhost:18002/info/json| jq '.number_of_nodes'"
}

number_of_active_nodes()
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

delete_node()
{
    log "Deallocating node $1"
    azure vmss delete-instances $group $vmss $1 
    log "Node $1 deallocated"
}

increment_nodes()
{
    inc=$1
    sh increment_vmss_capacity.sh $group $vmss $inc
}

get_packet_count()
{
    iptables -x -Z -L INPUT -v|grep "Chain INPUT" | awk '{print $5}'
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --scale-up-interval )     shift
                                       scaleup_interval=$1
                                       ;;
        -a | --activity-time )         shift
                                       activity_time=$1
                                       ;;
        -c | --cool-down-interval )    shift
                                       cooldown_interval=$1
                                       ;;
        -i | --idle-time )             shift
                                       idle_time=$1
                                       ;;
        -S | --scale-up-settle-time )  shift
                                       scale_up_settle_time=$1
                                       ;;
        -n | --node-increment )        shift
                                       node_increment=$1
                                       ;;
        -m | --max-nodes )             shift
                                       max_nodes=$1
                                       ;;
        -v | --verbose )               verbose=1
                                       ;;
        -h | --help )                  usage
                                       exit
                                       ;;
        * )                            usage
                                       exit 1
    esac
    shift
done

#Make sure we are logged into azure
bash azure_login.sh

#Reset some counters before looping
cooldown_counter=$cooldown_interval
scale_up_counter=$scale_up_settle_time
packets=$(get_packet_count)
counter=0
while true; do
    active_nodes=$(number_of_active_nodes)
    nodes=$(number_of_nodes)
    ideal_nodes=$nodes
    if [ "$active_nodes" -gt 0 ]; then
	ideal_nodes=`expr $active_nodes + $node_increment`
    fi

    if [ "$ideal_nodes" -gt "$max_nodes" ]; then
	ideal_nodes=$max_nodes
    fi

    #Log every 5th run through the loop
    if [ "$(expr $counter % 5)" -eq 0 ]; then
	log "Nodes: $nodes, Active: $active_nodes, Ideal: $ideal_nodes"
    fi
    counter=`expr $counter + 1`

    bash update_iptables_relay.sh

    
    scale_up_counter=`expr $scale_up_counter + $scaleup_interval`
    if [ "$ideal_nodes" -gt "$nodes" ] && [ "$scale_up_counter" -ge "$scale_up_settle_time" ]; then
	scale_up_counter=0 
	log "Incrementing nodes nodes"
	nodes_to_start=`expr $ideal_nodes - $nodes`
	increment_nodes $nodes_to_start &
    fi

    #Let's see if there is traffic
    packets=$(get_packet_count)
    if [ "$nodes" -eq 0 ] && [ "$packets" -gt 1000 ] && [ "$scale_up_counter" -ge "$scale_up_settle_time" ]; then
	log "Network activty detected, starting nodes"
	scale_up_counter=0 
	increment_nodes $node_increment &
    fi

    sleep $scaleup_interval
    cooldown_counter=`expr $cooldown_counter - $scaleup_interval`

    if [ "$cooldown_counter" -lt 0 ]; then
        log "Cool down check"

	#First a check to see if we have hanging nodes that have not been provisioned properly. We should get rid of them.
	bash delete_failed_nodes.sh $group $vmss

	if [ "$ideal_nodes" -le "$nodes" ] && [ "$nodes" -gt 0 ]; then
	    on=$(oldest_node)
	    lastr=$(echo $on | jq .last_recon | tr -d '"')
	    if [ "${lastr%.*}" -gt "$idle_time" ]; then
		nip=$(echo $on | jq .address | tr -d '"')
		iid=$(bash get_instance_id_from_ip.sh $group $vmss $nip)
		if [ -n "$iid" ]; then
		    log "Shutting down node $nname with IP $nip"
		    curl http://${nip}:9080/acceptor/close
		    bash update_iptables_relay.sh
		    delete_node $iid &
		fi
	    fi
	fi
        cooldown_counter=$cooldown_interval
    fi    
done
