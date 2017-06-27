Gadgetron Lighthouse Azure Templates
=========================

Prerequisites
--------------

* Docker username and password (needed when creating images)
* An Azure service principal with credentials (needed when deploying). You should read the [documentation for service principals](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal)
* [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) 

Overview
--------

The workflow for standing up a Gadgetron Lighthouse cloud deployment involves the following steps:

1. Create Service Principal (you should have already done this)
2. Create an account on [Docker Hub](https://hub.docker.com) (you should have already done this)
3. Install the [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
4. Log into Azure from the command line using `az login`
5. Create a disk image with the `create_disk_image.sh` tool.
6. Make a note of the [Managed Disk Image](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource) ID. 
7. Enter the Managed Disk ID into the parameters file for the actual gadgetron deployment along with service principal details, etc. 
8. Deploy the Gadgetron Lighthouse Cloud with the `create_gadgetron_cloud.sh` tool. 

Detailed Instructions
-----------------------

Clone the github repo with the tools:

```
git clone https://github.com/hansenms/azure_templates
cd azure_templates
```

First create an image using the `create_disk_image.sh` tool. You can see the usage instructions of this tool with `./create_disk_image.sh --help`:

```
Usage:  create_disk_image.sh [OPTIONS]
Available options

  -h | --help                          : Print help text
  -g | --group <GROUP NAME>            : Name of ResourceGroup (default: gtDiskCreator20170627141625)
  -u | --docker-user <USERNAME>        : Docker username (default: DockerUser)
  -p | --docker-password <PASSWORD>    : Password for docker use
  -i | --docker-image <IMAGE>          : Docker image name (default: gadgetron/ubuntu_1604_no_cuda
  -l | --location <LOCATION>           : Location (default: eastus)
```

In practice you would call it with something like:

```
./create_disk_image.sh -u <DOCKER USER> -p <DOCKER PASSWORD>
```
At the end of this process (which will probably take 10-30 minutes), you will have a managed disk image in Azure. You can find the ID of this image by looking at the output of `az image list`. If you just want the IDs of the images `az image list | jq .[].id`.

Now you need to make a configuration file with parameters for the cloud deployment itself. You can find an example configuration file in `gadgetron.parameters.json`:

```
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "0.0.0.1",
     "parameters": {
        "adminUsername": {
            "value": "<USERNAME FOR NODES>"
        },
        "adminPassword": {
            "value": "<PASSWORD FOR NODES>"
        },
        "sshKeyValue1": {
          "value": "<SSH PUBLIC KEY>"
        },
        "sshKeyValue2": {
          "value": "<SSH PUBLIC KEY>"
        },
        "sshKeyValue3": {
          "value": "<SSH PUBLIC KEY>"
        },
        "vmSize": {
            "value": "Standard_F16"
        },
        "numberOfComputeNodes": {
            "value": 0
        },
        "azure_client_id": {
            "value": "<CLIENT ID>"
        },
        "azure_tenant_id": {
            "value": "<TENANT ID>"
        },
        "azure_key": {
            "value": "<KEY>"
        },
        "managedDiskImageID": {
            "value": "<DISK IMAGE ID>"
        }

   }
}
```
The SSH key values are to let you specify a number of keys that will give access to the relay node. The `azure_client_id`, `azure_tenant_id`, and `azure_key` are the service principal credentials. The relay node will need these in order to manage resources. The `managedDiskID` is the managed disk ID found in the `az image list`.Once you have filled this parameter file in once, you will probably only need to change the `managedDiskID` when you make a new deployment. 

With the completed parameters file you can now make a deployment:

```
./create_gadgetron_cloud.sh --parameters gadgetron.parameters.MyDeployment.hansen.json --group NameOfDeploymentGroup --location eastus
```

This will take 5 minutes or so after which you should be able to log into `NameOfDeploymentGroup.LOCATION.cloudapp.azure.com` with the credentials you specified in the parameters file. You can get the details on how to use the `create_gadgetron_cloud.sh` script with `./create_gadgetron_cloud.sh --help`:

```
Usage:  create_gadgetron_cloud.sh [OPTIONS]
Available options

  -h | --help                          : Print help text
  -g | --group <GROUP NAME>            : Name of ResourceGroup (default: nhlbi20170509161746)
  -t | --template <TEMPLATE FILE>      : Template file name (default: gadgetron.json)
  -p | --parameters <PARAMETERS FILE>  : Template parameters file name (default: gadgetron.parameters.json)
  -l | --location <LOCATION>           : Location (default: eastus)
```

Using a different repository location
-------------------------------------

The setup scripts pull resources (scripts and configuration files) from the default location https://raw.githubusercontent.com/hansenms/azure_templates/master, if you would like to use a different location, e.g., a branch you are working on or a clone of the repository, you should specify the parameter `scriptBasePathUri` in the template parameters file. 

Monitoring and Maintenance
--------------------------

On Ubuntu 14.04 base images (old version), the cloud monitor log can be found at `/var/log/upstart/cloud_monitor.log`. On the newer Ubuntu 16.04 base images, the log can be browsed with the `journalctl` tool, e.g., to follow the cloud monitor log:

```
journalctl -f -u cloud_monitor.service
```

Recommended Additional Setup
----------------------------

It is recommended that you clone this github repo on the relay node. It contains useful additional scripts.

You should periodically clean up the group deployments, there is a script for it, which you could run with:

```
nohup sudo bash ./clean_up_group_deployments.sh <GROUP NAME>
```

You can then put that script in the background and log out.

If you would like email notifications, you can use the `send_summary_email.sh` script. It needs a configuration file:

```
{
    "sendgridApiKey":"<APIKEY>",
    "to": [{"email": "firstperson@mailserver.com"}, {"email":"cloudfanatic@example.com"}],
    "from": {"email": "myadmin@example.com", "name": "Gadgetron Cloud Administrator"}
}	    
```

The `APIKEY` is the API key from the [SendGrid](https://sendgrid.com/docs/API_Reference/Web_API_v3/How_To_Use_The_Web_API_v3/authentication.html) that is used by the email sending script. You can send a single summary email with:

```
./send_summary_email.sh summary_email_config.hansen.json
```

Or add it as a CRON job, if you want to run it every day at say midnight, use `crontab -e` to edit and enter a line like:

```
0 0 * * * /home/gadgetron/azure_templates/send_summary_email.sh /home/gadgetron/azure_templates/summary_email_config.hansen.json
```

Scheduling
----------

It is possible to provide a schedule for managing the number of active nodes (in addition to the increases/decreases in response to activity). The schedule can be specified in the file `/usr/local/share/gadgetron/azure/schedule.json`. In the default installation, this file is empty and consequently, the minimum number of nodes is zero and the maximum is the maximum specifed by the `cloud_monitor` (i.e., default 20). If you would like to provide a different schedule, you can follow the example in `schedule.example.json` file:

```
{
    "schedule": [
	{
	    "start": "07:30",
	    "end": "19:30",
	    "weekdays": [ "Monday", "Tuesday", "Wednesday", "Thursday","Friday" ],
            "min": 8,
            "max": 20
	}
    ]
}
```

This configuration sets the minimum number of nodes to be 8 (and he maximum 20) between the hours of 07:30 and 19:30 (UTC), Monday through Friday. This would allow operation without a start scan during normal clinical operating hours. 