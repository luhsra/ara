# File locations
## Parrot - Meta repository with buildchain + tools
docker/run_docker.sh - Starts Docker enviroment with all tools installed\

## ara - Analyse + Generator
### Mycode
appl/AUTOSAR/multicore/automotive_benchmark/* - My test cases\
### Analyse
ara/ara/os/interrupts.py - fake_interrupt_function (In der ARA Analyse wird durch die MultiSEE eine Graph erstellt, dort für jeden Counter ein fake Interrupt Kern\
ara/ara/setps/printer.py - Konvertieren von Graphstrukturen\
### Meson
appl/AUTOSAR/meson.build - einzelnen appl\
libs/autosar/meson.build - Flags für Architekturen (DDEBUG, DQEMU)\

## ara-libplatforms


# Setup/Run
1. setup Docker (after update rebuild: `docker build -t scm.sra.uni-hannover.de:5050/research/parrot .`)
    1. `run_docker.sh`
2. build (only one time, after update reload all other repos: `meson subprojects update --reset`)
    1. `meson setup build --native-file native-debian.ini`

    X. To "reset" ninja build enviroment run `meson setup build --native-file native-debian.ini --reconfigure`, happend after CTRL-C a ninja cmd.
3. `cd build/`
    1. `ninja -t targets`
    2. `ninja ara@@run_autosar_multicore_andreas_pmu_get_spinlock_pi4`
   
## Debug
- add `-v` to ninja, to show the run cmds
- activate `-DDEBUG` in `subprojects/ara/libs/autosar/meson.build` to change loglevelfor the respective architecture.
- (use `ARA_LOGLEVEL=debug` at the beginning -> show individual cmds.(klappt nicht mehr, bzw wie ging das?))
- Ara step list: `/usr/bin/python3 subprojects/ara/ara.py -l` (or `-l`)


## Example Code
```bash
# Run ara with custom step json:
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_hello_world_auto.pi4.ll --os AUTOSAR --oilfile ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/hello_world/auto_system.json --step-settings ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/hello_world/custom_ara_config_testing.json
# another example:
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC.pi4.ll --os AUTOSAR --oilfile ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/testsuit/runnables_system.json --ir_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_mod.pi4.ll --step-settings ../subprojects/ara/appl/AUTOSAR/multicore/automotive_benchmark/custom_ara_config_testing.json --generator_output subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC_noopt_autosar.pi4.cc
# !!!This above cmd does not rebuild the .ll file, done with:
ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_automotive_benchmark_testsuit_runnables_BASIC.pi4.ll
```




list of steps + properties of each step, enable logging or dumping to `build/dump`. \
"DumpCFG", "DumpCallgraph", "DumpInstances".


- `ara/ara/generator/coder/autosar/os_generic.py`
- `ara/ara/steps/load_oil.py`
- `ara/libs/autosar/os.h`


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
