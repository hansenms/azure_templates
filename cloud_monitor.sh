#!/bin/bash

scaleup_interval=5
activity_time=60
cooldown_interval=600
idle_time=1800
verbose=0

function usage
{
    echo "usage cloud_monitor [--scale-up-interval <SECONDS>]"
    echo "                    [--activity-time <SECONDS>]"
    echo "                    [--cool-down-interval <SECONDS>]"
    echo "                    [--idle-time <SECONDS>]"
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

cooldown_counter=$cooldown_interval
while true; do

    log "Upscale check"
    sleep $scaleup_interval
    cooldown_counter=`expr $cooldown_counter - $scaleup_interval`

    if [ "$cooldown_counter" -lt 0 ]; then
        log "Cool down check"
        cooldown_counter=$cooldown_interval
    fi
    
done
