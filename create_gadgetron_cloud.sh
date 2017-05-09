#!/bin/bash

group_name="nhlbi$(date +%Y%m%d%H%M%S)"
template_file="gadgetron.json"
template_parameters="gadgetron.parameters.json"
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

az group create --name ${group_name} --location ${location}
time az group deployment create -g ${group_name} --parameters @${template_parameters} --template-file ${template_file}
