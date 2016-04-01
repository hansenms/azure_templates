Gadgetron Azure Templates
=========================

These configurations are a good starting point for spinning up a Gadgetron Azure Cloud. 

Prerequisites
--------------

* Docker username and password (needed when creating images)
* An Azure service principal with credentials (needed when deploying)

Getting up and running
-----------------------

First create an image:

    azure group deployment create -g gtImageCreate --parameters-file image_creator.parameters.json --template-file image_generator.json 

This deployment will never really finish because of the way that we clean up the waagent in the instance. Once it has completed (you can log in to the creator and check), create and image:

     sh ./create_image_from_vm.sh gtImageCreate gtDiskCreator

Find the disk image in the group and set blob access. Capture the URI of the image. Then you can deploy with:

     sh ./create_gadgetron_cloud.sh <CLOUDGROUP>  gadgetron.json gadgetron.parameters.json <IMAGE URI>




