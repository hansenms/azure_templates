#!/bin/bash

schedule_file=$1
timepoint=$2
comptimepoint=$(date --date="${timepoint}" +"%H:%M")
echo "$comptimepoint"

schedule_entries=$(cat $schedule_file | jq -r '.schedule | length')

match="{ \"min\": 0, \"max\": 99999999 }"

#Loop over schedule entries
for i in $(seq 1 $schedule_entries); do
    entry=$(cat $schedule_file | jq -r .schedule[$(( $i - 1))])
    start=$(echo $entry | jq -r .start)
    end=$(echo $entry | jq -r .end)
    wd=$(date --date="${timepoint}" +"%A")
    weekdays=$(echo $entry | jq -r .weekdays)
    if [[ "$weekdays" == "null" ]]; then
	weekdays="[\"Monday\", \"Tuesday\", \"Wednesday\", \"Thursday\", \"Friday\", \"Saturday\", \"Sunday\"]"
    fi
    if [[ "$start" < "$comptimepoint"  && "$end" > "$comptimepoint" && $weekdays =~ .*$wd.* ]]; then
	match="$entry"
	break
    fi
done
echo $match

