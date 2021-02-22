# Zephyr Samples

This directory contains sample applications for all supported instance types.
These are named dyn_\<name> and static_\<name> respectively.

Some of them are more complex apps taken from Zehpyr's sample apps:
* blinky
* button
* cpp_sems
* dyn_sems
* static_sems
* minimal
* prod_consumer
* shared_mem

To test edge cases, a few other samples exist:
* duplicate_syscalls: Detection of syscalls that are included multiple times
* multi_init: Multiple init calls to one object 

Lastly, there are three bigger apps. These were taken from Zephyr's benchmark suite:
* app_kernel: A lot of different static instances 
* sys_kernel: A huge number of duplicate init calls
