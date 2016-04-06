#!/bin/bash

docker_username=$1
docker_password=$2
docker_email=$3
docker_image=$4

apt-get update
apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get purge lxc-docker
apt-cache policy docker-engine
sudo apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y apparmor
apt-get install -y docker-engine
service docker start
sudo apt-get install curl
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash –
sudo apt-get install -y nodeJS
node –v (v4.4.2)
npm –v (2.15.0)
sudo npm install -g azure-cli
apt-get -qq install cifs-utils -y

#Download the requested image
docker login -u $docker_username -p $docker_password -e $docker_email
docker pull $docker_image
docker tag $docker_image current_gadgetron

#Deprovision
waagent -force -deprovision
