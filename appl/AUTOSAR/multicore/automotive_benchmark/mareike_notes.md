1. setup Docker 
    1. run_docker.sh
2. build (only one time)
    1. meson setup build --native-file native-debian.ini
3. cd build/
    1. ninja -t targets 
    2. ninja ara@@run_autosar_multicore_andreas_pmu_get_spinlock_pi4

# subprojects
Code of all repos is found there :) or in gitlab

# examples
cd subprojects/ara/appl/AUTOSAR/multicore/andreas
edit ara/appl/AUTOSAR/meson.build to add new examples

# libs
subprojects/ara/libs/autosar
os.h + test/test.h + arch/arm/platforms/raspberry/perf.h for wait


# Running application
Can test either with QEMU or on local Pi!

## QEMU
use lines 23-26 in ara/libs/autosar/meson.build
'''ninja ara@@run_autosar_multicore_automotive_benchmark_hello_world_base_pi4'''

## Pi
comment lines 23-26 out in ara/libs/autosar/meson.build.

Use pdu to start pi (can only be done from inside sra network). SSH to lab-pc67, works only with ip 10.33.23.167 inside the sra network.
Use '''sudo minicom -D /dev/ttyUSB0''' to read serial via USB cable.
### sd card -- not used anymore
Copy files to sd card and boot then: 4x files + 1x test.img.
'''ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_hello_world_a_pi4.bin'''
### tftp
follow manual and setup tftp-hpa server, confige dnsmasq.conf. Then no sd card in pi and connect Lan cable, then pi should boot. Also add /srv/tftp to Docker file. 
!DOESNT work yet, give Pi ip addr, instead do:

'''ninja ara@@tftp_autosar_multicore_automotive_benchmark_hello_world_base_pi4''' to create test.img in /srv/tftp/test.img
copy to lab-pc00 /proj/tftp/research/rpi4: '''scp /srv/tftp/test.img mar.burg@lab-pc00:/proj/tftp/research/rpi4/base.img''' and change config.txt to match image
then start pi and it continuesly netboots the image
