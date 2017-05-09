#!/bin/bash

group_name="gtDiskCreator$(date +%Y%m%d%H%M%S)"
template_file="image_generator.json"
template_parameters="image_generator.parameters.json"
location="eastus"

ME=$(basename "$0")

print_usage ()
{
    printf "\n"
    printf "Usage: "
    printf "\t%s [OPTIONS]\n" "$ME"
    printf "Available options\n\n"
    printf "  -h | --help                          : Print help text\n"
    printf "  -g | --group <GROUP NAME>            : Name of ResourceGroup (default: $group_name)\n"
    printf "  -t | --template <TEMPLATE FILE>      : Template file name (default: $template_file)\n"
    printf "  -p | --parameters <PARAMETERS FILE>  : Template parameters file name (default: $template_parameters)\n"
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
        -t  | --template )             shift
                                       template_file=$1
                                       ;;
        -p  | --parameters )           shift
                                       template_parameters=$1
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


time az group create --name ${group_name} --location ${location}
time az group deployment create --resource-group ${group_name} --template-file ${template_file} --parameters @${template_parameters}

while [ $(az vm show -g ${group_name} -n gtDiskCreator | jq -r .provisioningState) != "Succeeded" ]; do
    echo "Waiting for VM to deploy"
done

sleep 20

#Remove extension so that we can add a new one later. 
extension_id=$(az vm extension list -g $group_name --vm-name gtDiskCreator | jq -r .[0].id)
az vm extension delete --ids $extension_id 

#Deprovision
command="sudo waagent -force -deprovision"
ssh -o StrictHostKeyChecking=no gadgetron@${group_name}vm.${location}.cloudapp.azure.com $command

sh ./create_image_from_vm.sh ${group_name}  gtDiskCreator

