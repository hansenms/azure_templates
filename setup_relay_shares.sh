#!/bin/bash

mkdir -p "/home/shares"
mkdir -p "/home/shares/gtlog"
mkdir -p "/home/shares/gtdependencies"
chmod -R a+rwX /home/shares

echo "/home/shares/gtlog *(rw,sync,no_subtree_check)" >> /etc/exports
echo "/home/shares/gtdependencies *(rw,sync,no_subtree_check)" >> /etc/exports

service rpcbind restart
service nfs-kernel-server restart
