#!/bin/bash

customdata=$(sed -n 's/.*<ns1:CustomData>\([^<]*\).*/\1/p' /var/lib/waagent/ovf-env.xml)
echo "$customdata" | base64 --decode
