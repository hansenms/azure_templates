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
  -g | --group <GROUP NAME>            : Name of ResourceGroup (default: gtDiskCreator20170509155216)
  -t | --template <TEMPLATE FILE>      : Template file name (default: image_generator.json)
  -p | --parameters <PARAMETERS FILE>  : Template parameters file name (default: image_generator.parameters.json)
  -l | --location <LOCATION>           : Location (default: eastus)
```

In practice you would call it with something like:

```
./create_disk_image.sh --parameters image_generator.parameters.MySpecialConfig.json --location eastus --group MyGeneratorGroupName
```

The configuration (json) file needs to contain the required [Docker](https://docker.com) details along with an SSH key to allow the script to log into the machine to provision it. There is a template for this file in `image_generator.parameters.json`:

```
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "0.0.0.1",
    "parameters": {
        "adminUsername": {
            "value": "<ADMIN USERNAME>"
        },
        "adminPassword": {
            "value": "<ADMIN PASSWORD>"
        },
        "sshKeyValue1": {
            "value": "<SSH KEY>"
        },
        "dockerUsername": {
           "value":"<DOCKER USERNAME>"
        },
        "dockerPassword": {
           "value":"<DOCKER PASSWORD>"
        },
        "dockerImage": {
           "value":"gadgetron/ubuntu_1604_no_cuda"
        }
    }
}
```
The `sshKeyValue1` is the public key that will be installed on the VM to enable login to run the configuration scripts. It should be a key that works with the user that you are running this script as. You would probably find that key by typing `cat ~/.ssh/id_rsa.pub`.

At the end of this process (which will probably take 20-30 minutes), you will have a managed disk image in Azure. You can find the ID of this image by looking at the output of `az image list`. If you just want the IDs of the images `az image list | jq .[].id`.

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
