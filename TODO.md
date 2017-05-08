To Do List
-----------

* Remove email argument for Docker
* Set privileges for image blob in script - Maybe not needed if we grab account when copying disks.
* Use managed disks
  * Add managed disk ID to template
  * Finish script for copying managed disks
    * Should only create group if it doesn't exist
    * Can we make a progress bar for copying?? 
  * Remove storage account from main template. Not needed. 
  * Remove storage account from image generator. Should not be needed. 
* Add ability to disk creator to run in different region. 
* Write documentation
* Add storage drive to relay - We need more drived and possibly an array. (https://docs.microsoft.com/en-us/azure/virtual-machines/linux/configure-raid)
* Share storage drive with instances
* Let instances copy image from relay and use `docker load` to start
* Status/statistics script
* Daily emails with stats and status

