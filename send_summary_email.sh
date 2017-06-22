#!/bin/bash

config_file=$1
sendgrid_api_key=$(cat $config_file| jq -r '.sendgridApiKey')
h=$(hostname)
to=$(cat $config_file| jq -r '.to')
from=$(cat $config_file| jq -r '.from')
BASEDIR=$(dirname "$0")
plotfilename=$(date +"%Y%m%d%H%M%S")"nodeplot.png"

$BASEDIR/plot_nodes.sh
img_base64=$(base64 --wrap 0 node_plot.png)
node_stats=$(bash ${BASEDIR}/node_summary_statistics.sh | tr -d '\n')

data="{\"personalizations\": [{\"to\": ${to} }], \"from\": ${from},\"subject\": \"Gadgetron Cloud Summary ($h)\",\"content\": [{\"type\": \"text/html\", \"value\": \"<h1>Node Summary Statistics</h1>${node_stats}<img src='cid:ii_nodeplot${plotfilename}'/>\"}],\"attachments\": [{\"content\": \"$img_base64\", \"type\": \"image/png\", \"filename\": \"${plotfilename}\", \"disposition\":\"inline\",\"content_id\":\"ii_nodeplot${plotfilename}\"}]}"

curl --request POST --url https://api.sendgrid.com/v3/mail/send --header "Authorization: Bearer $sendgrid_api_key" --header 'Content-Type: application/json' --data "$data"

