Gadgetron Azure Templates
=========================

These configurations are a good starting point for spinning up a Gadgetron Azure Cloud. 

Prerequisites
--------------

* Docker username and password (needed when creating images)
* An Azure service principal with credentials (needed when deploying). You should read the [documentation for service principals](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal)
* [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) 

Getting up and running
-----------------------

First create an image:

      bash ./create_disk_image.sh <GROUP NAME> image_generator.json image_generator.parameters.hansen.json <DOCKER USERNAME> <DOCKER PASSWORD> <DOCKER IMAGE>

`<GROUP NAME>` is a name for the resource group that will hold the disk image you are creating. It cannot be an existing group. `image_generator.parameters.json` is a json file containing some basic parameters needed to log into the VM and run various configuration tasks. It should look something like:

```
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "0.0.0.1",
    "parameters": {
        "adminUsername": {
            "value": "gadgetron"
        },
        "adminPassword": {
            "value": "<PASSWORD FOR IMAGE CREATOR>"
        },
        "sshKeyValue1": {
          "value": "ssh-rsa JAJSHKDHSKJDHKJSDHJKDHSJSDKJHSKJHKSDJHJKDHSKHDKSJHDKSDHJK  exportedkey"  
        }
    }
}
```
The `sshKeyValue1` is the public key that will be installed on the VM to enable login to run the configuration scripts. It should be a key that works with the user that you are running this script as. You would probably find that key by typing `cat ~/.ssh/id_rsa.pub`.

At the end of this process, you will have a managed disk image in Azure. You can find the ID of this image by looking at the output of `az image list`. If you just want the IDs of the images `az image list | jq .[].id`.

How you need to make a configuration file with parameters for the cloud deployment itself. You can find an example configuration file in `gadgetron.parameters.json`:

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
The SSH key values are to let you specify a number of keys that will give access to the relay node. The `azure_client_id`, `azure_tenant_id`, and `azure_key` are the service principal credentials. The relay node will need these in order to manage resources. The `managedDiskID` is the managed disk ID found in the `az image list`.

