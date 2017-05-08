#!/bin/bash

docker_username=$1
docker_password=$2
docker_image=$3

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/apt/lists/partial/*
apt-get clean
apt-get update
apt-get install -y apt-transport-https ca-certificates emacs nfs-common nfs-kernel-server jq
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get purge lxc-docker
apt-cache policy docker-engine
sudo apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y apparmor
apt-get install -y docker-engine
service docker start
apt-get install -y curl
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | tee /etc/apt/sources.list.d/azure-cli.list
apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
apt-get update && apt-get install -y azure-cli
apt-get -qq install cifs-utils -y
apt-get install -y jq

#Download the requested image
docker login -u $docker_username -p $docker_password
docker pull $docker_image
docker tag $docker_image current_gadgetron
