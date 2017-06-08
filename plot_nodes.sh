#!/bin/bash

BASEDIR=$(dirname "$0")

since="1 day ago"

if [ $# -gt 0 ]; then
    since=$1
fi

$BASEDIR/get_node_data.sh "$since" > /tmp/node_data.txt

gnuplot <<EOF
set xdata time
set timefmt '%Y%m%d %H:%M:%S GMT'
set terminal png 
set output 'node_plot.png'
set datafile separator ";"
set xtics font ", 5"
plot "/tmp/node_data.txt" using 1:2 title "Nodes" with lines ls 1, "/tmp/node_data.txt" using 1:3 title "Active" with lines ls 2
EOF
