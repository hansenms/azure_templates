#!/bin/bash

group_name="gtDiskCreator$(date +%Y%m%d%H%M%S)"
vm_name="dcreator"
template_file="image_generator.json"
template_parameters="image_generator.parameters.json"
location="eastus"
docker_user=$(whoami)
docker_password=""
docker_image="gadgetron/ubuntu_1604_no_cuda"
ME=$(basename "$0")

print_usage ()
{
    printf "\n"
    printf "Usage: "
    printf "\t%s [OPTIONS]\n" "$ME"
    printf "Available options\n\n"
    printf "  -h | --help                          : Print help text\n"
    printf "  -g | --group <GROUP NAME>            : Name of ResourceGroup (default: $group_name)\n"
    printf "  -u | --docker-user <USERNAME>        : Docker username (default: $docker_user)\n"
    printf "  -p | --docker-password <PASSWORD>    : Password for docker user\n"
    printf "  -i | --docker-image <IMAGE>          : Docker image name (default: ${docker_image}\n"
    printf "  -l | --location <LOCATION>           : Location (default: $location)\n"
    printf "\n\n"
}

#Parse any command line options and store in global variables
while [[ $1 =~ ^- ]]; do 
    case $1 in
        -h  | --help )                 print_usage
                                       exit 0
                                       ;;
        -g  | --group )                shift
                                       group_name=$1
                                       ;;
        -u  | --docker-user )          shift
                                       docker_user=$1
                                       ;;
        -p  | --docker-password )      shift
                                       docker_password=$1
                                       ;;
        -i  | --docker-image )         shift
                                       docker_image=$1
                                       ;;
        -l  | --location )             shift
                                       location=$1
                                       ;;
        * )                            echo "Unknown option $1"
                                       print_usage
                                       exit 1
    esac
    shift
done

if [[ -z $docker_password ]]; then
    echo "You must specify a Docker password"
    exit 1
fi

az group create --name ${group_name} --location ${location}
az vm create -g ${group_name} -n ${vm_name} --image UbuntuLTS --generate-ssh-keys

az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --settings "{\"fileUris\": [ \"https://raw.githubusercontent.com/hansenms/azure_templates/master/setup_disk_creator.sh\" ], \"commandToExecute\": \"bash ./setup_disk_creator.sh $docker_user $docker_password $docker_image\" }" --resource-group ${group_name} --vm-name ${vm_name}

#Remove extension so that we can add a new one later. 
extension_id=$(az vm extension list -g ${group_name} --vm-name ${vm_name} | jq -r .[0].id)
az vm extension delete --ids $extension_id 
ipaddr=$(az vm list-ip-addresses -g ${group_name} -n ${vm_name} | jq -r .[0].virtualMachine.network.publicIpAddresses[0].ipAddress)

#Deprovision
command="sudo waagent -force -deprovision+user"
ssh -o StrictHostKeyChecking=no $ipaddr $command

sh ./create_image_from_vm.sh ${group_name} ${vm_name}

