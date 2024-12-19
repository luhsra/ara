# Useful stuff
Getrennt ARA analyse und optimieren durch MultiSSE, später generierung. sind verschieden


## Setup
1. setup Docker (after update: `docker build -t scm.sra.uni-hannover.de:5050/research/parrot .`)
    1. run_docker.sh
2. build (only one time)
    1. meson setup build --native-file native-debian.ini
3. cd build/
    1. ninja -t targets 
    2. ninja ara@@run_autosar_multicore_andreas_pmu_get_spinlock_pi4
use `-v` at end for more output /
use `ARA_LOGLEVEL=debug` at the beginning -> show individual cmds. (klappt nicht mehr, bzw wie ging das?)

### Debug
comment `-DDEBUG` in `subprojects/ara/libs/autosar/meson.build` for the respective architecture.

## Error with missing ninja file
Run this to "reset" ninja build enviroment 
`meson setup build --native-file native-debian.ini --reconfigure`, happend after CTRL-C a ninja cmd.

## subprojects
Code of all repos is found there :) or in gitlab. /
### Parrot: Sammelrepo
### ARA: eigene Branch automotive_appl
ara/ara/os/interrupts.py fake_interrupt_function -> In der ARA Analyse wird durch die MultiSEE eine Graph erstellt, dort für jeden Alarm einen eigenen Interrupt Kern, sollte aber besser nur für jeden Counter einen Interrupt kern erzeugen
\
ara/ara/setps/printer.py convertieren von Graphstrukturen
\
(! alles in /build ordner) Ara wird in Steps ausgeführt, auflistbar mit `/usr/bin/python3 subprojects/ara/ara.py -l`, welche wird festgelegt durch .json file. Example here:
```bash
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_hello_world_auto.pi4.ll --os AUTOSAR --oilfile ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/hello_world/auto_system.json --step-settings ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/hello_world/custom_ara_config_testing.json

# another example
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC.pi4.ll --os AUTOSAR --oilfile ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/testsuit/runnables_system.json --ir_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_mod.pi4.ll --step-settings ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/custom_ara_config_testing.json --generator_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_autosar.pi4.cc

# ll neu bauen
ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC.pi4.ll
```
list of steps + properties of each step, enable logging or dumping to `build/dump`. \
"DumpCFG", "DumpCallgraph", "DumpInstances".


- `ara/ara/generator/coder/autosar/os_generic.py`
- `ara/ara/steps/load_oil.py`
- `ara/libs/autosar/os.h`

### ara-libplatforms: automotive_appl nicht mehr in use

## Generator
Creates the template for the .cc files, by setting the syntax up in python. Uses fixed wrapper for that.
Pfad: `subprojects/ara/ara/generator/coder/autosar`, use self.call(syscall) um im generierten Code den Syscall aufzurufen
- os_generic.py 
- syscall_generic.py
- arch_generic.py
Außerdem in `subprojects/ara/libs/autosar/os`, define syscall there.


## Git
Use this cmd to get updates from soso (main branch), and include them into automotive_appl.
```bash
git checkout automotive_appl
git pull origin soso --rebase
git push
```

## Other tools
Graphviewer: xdot (via apt)
graph-tool: Python Library für graphen

\
\
\ 

# examples
cd subprojects/ara/appl/AUTOSAR/multicore/andreas
edit ara/appl/AUTOSAR/meson.build to add new examples

# libs
subprojects/ara/libs/autosar
os.h + test/test.h + arch/arm/platforms/raspberry/perf.h for wait





# Running test cases
`ara/libs/autosar/meson.build` line 17 Debug flag.
## QEMU
Include lines 23-26 in `ara/libs/autosar/meson.build`, then
`ninja ara@@run_autosar_multicore_automotive_benchmark_hello_world_base_pi4`

## Local Pi4
Remove lines 23-26 in `ara/libs/autosar/meson.build`.

Use pdu to start pi (can only be done from inside sra network). SSH to lab-pc67, works only with ip 10.33.23.167 inside the sra network. \

Alternativly use `python3 power.p KVM6 ON` to start the pi.
Use `sudo minicom -D /dev/ttyUSB0` to read serial via USB cable.
Then `ninja ara@@tftp_autosar_multicore_automotive_benchmark_hello_world_base_pi4`
### sd card -- not used anymore
Copy files to sd card and boot then: 4x files + 1x test.img.
'''ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_hello_world_a_pi4.bin'''
### tftp - works automatically now
follow manual and setup tftp-hpa server, confige dnsmasq.conf. Then no sd card in pi and connect Lan cable, then pi should boot. Also add /srv/tftp to Docker file. 
!DOESNT work yet, give Pi ip addr, instead do:

'''ninja ara@@tftp_autosar_multicore_automotive_benchmark_hello_world_base_pi4''' to create test.img in /srv/tftp/test.img
copy to lab-pc00 /proj/tftp/research/rpi4: '''scp /srv/tftp/test.img mar.burg@lab-pc00:/proj/tftp/research/rpi4/base.img''' and change config.txt to match image
then start pi and it continuesly netboots the image.



\
\
\

### Python print all elements of generator in gdb
`print(*(element for element in instances.vp.obj), sep='\n')`

### Noch ein Ara Befehl mit Timings
```bash
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC.pi4.ll --os AUTOSAR --oilfile ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/testsuit/runnables_system.json --ir_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_mod.pi4.ll --step-settings ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/custom_ara_config_testing.json --generator_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_autosar.pi4.cc --timings BB
```

### Ara.py .json config für alle runs located here, 1x opt, 1x nonopt
`subprojects/ara/settings/autosar_generator_arm_opt.json`