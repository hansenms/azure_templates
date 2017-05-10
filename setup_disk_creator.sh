#!/bin/bash

docker_username=$1
docker_password=$2
docker_image=$3

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/apt/lists/partial/*
apt-get clean
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common emacs nfs-common nfs-kernel-server jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get purge lxc-docker
sudo apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y apparmor
apt-get install -y docker-ce
service docker start
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | tee /etc/apt/sources.list.d/azure-cli.list
apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
apt-get update && apt-get install -y azure-cli
apt-get -qq install cifs-utils -y

#Download the requested image
docker login -u $docker_username -p $docker_password
docker pull $docker_image
docker tag $docker_image current_gadgetron

#waagent -force -deprovision+user
