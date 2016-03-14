#!/bin/bash

group=$1

ecode=124
try_count=0
while [ "$ecode" -eq 124 ] && [ "$try_count" -lt  10 ]; do
    numnodes=$(timeout 10 azure vm list -g $group --json| jq 'length')
    ecode=$?
    try_count=`expr $try_count + 1`
done

if [ "$ecode" -eq 124 ]; then
    numnodes=0
fi

echo "$numnodes"
