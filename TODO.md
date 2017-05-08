To Do List
-----------

* Use managed disks
  * Finish script for copying managed disks
    * Should only create group if it doesn't exist
    * Estimate completion time 
  * Remove storage account from image generator. Should not be needed. 
* Add ability to disk creator to run in different region. 
* Write documentation
* Let instances copy image from relay and use `docker load` to start
* Status/statistics script
* Daily emails with stats and status
* Update to Ubuntu 16.04 as base system
* Change disk creation (goal is to prevent long running setup from loosing connection):
  * Install packages in Custom script
  * Wait for deployment to complete
  * Then deprovision and make image
