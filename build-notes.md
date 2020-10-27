* Connecting to sra lab
```
ssh ken.albes@lab.sra.uni-hannover.de -p 2224
```


* Even though they are not listed, a number of dependencies are needed to build outside of the SRA lab: 
  * ```sudo apt install cmake pkgconf libboost-all-dev libsparsehash-dev```
  * ``` pip3 install pydot ```
  * [graph_tool](https://git.skewed.de/count0/graph-tool/-/wikis/installation-instructions)

* In the README cython is mentioned and used, but really cython3 is needed. On Ubuntu at least, one has to map cython --> cython3. 

* ARM Toolchain is needed no matter what, meson will not let you choose before it builds and it does not build without an arm toolchain --> ``` sudo apt install gcc-arm-none-eabi ```
* i386 arch is just not working, meson fails with
```
../appl/meson.build:140:4: ERROR: Unknown variable "default_linkerscript".
```
* ```meson configure -Denable_[gpslogger, librepilot, qemu]_tests=false```, otherwise ninja will complain about missing rules
* ninja will fail with:
```
FAILED: ara/graph/cgraph/libgraph.a.p/graph.cpp.o
c++ -Iara/graph/cgraph/libgraph.a.p -Iara/graph/cgraph -I../ara/graph/cgraph -Iara/common -I../ara/common -Isubprojects/pyllco -I../subprojects/pyllco -I/usr/include/python3.8 -I/usr/include/x86_64-linux-gnu/python3.8 -I/usr/include -fdiagnostics-color=always -pipe -D_FILE_OFFSET_BITS=64 -Wall -Winvalid-pch -Wnon-virtual-dtor -Wextra -Wpedantic -std=c++17 -O2 -g -Werror=return-type -fPIC -isystem/usr/lib/python3/dist-packages/graph_tool/include -isystem/usr/lib/python3/dist-packages/graph_tool/include/boost-workaround -isystem/usr/lib/python3/dist-packages/graph_tool/include/pcg-cpp -isystem/usr/lib/python3/dist-packages/cairo/include -isystem/usr/include/python3.8 -pthread -isystem/usr/lib/python3/dist-packages/numpy/core/include -DBOOST_ALL_NO_LIB -isystem/usr/lib/llvm-9/include -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS -D__STDC_FORMAT_MACROS -D_GNU_SOURCE -MD -MQ ara/graph/cgraph/libgraph.a.p/graph.cpp.o -MF ara/graph/cgraph/libgraph.a.p/graph.cpp.o.d -o ara/graph/cgraph/libgraph.a.p/graph.cpp.o -c ../ara/graph/cgraph/graph.cpp
In file included from /usr/lib/python3/dist-packages/graph_tool/include/hash_map_wrap.hh:21,
                 from /usr/lib/python3/dist-packages/graph_tool/include/graph_properties.hh:47,
                 from /usr/lib/python3/dist-packages/graph_tool/include/graph.hh:35,
                 from /usr/lib/python3/dist-packages/graph_tool/include/graph_tool.hh:21,
                 from ../ara/graph/cgraph/graph.h:10,
                 from ../ara/graph/cgraph/graph.cpp:1:
/usr/lib/python3/dist-packages/graph_tool/include/config.h:153:31: fatal error: google/dense_hash_set: No such file or directory
  153 | #define SPARSEHASH_INCLUDE(f) <google/f>
      |                               ^
compilation terminated.
```
* This can be fixed by getting google's sparse hash library ```sudo apt install libsparsehash-dev```

* Trying to run ara with ```./ara.py --verbose ./appl/freertos-syscall``` will reveal a number of missing python modules: 
  * pycairo:
    * ``` sudo apt install libcairo2-dev python3-dev ```
    * ``` pip3 install pycairo ```
  * matplotlib: ``` pip3 install -U matplotlib ```

* Building ninja files for zephyr apps (when in build directory):
```
rm -rf /home/kenny/.cache/zephyr && cmake -GNinja -D BOARD=native_posix -D ZEPHYR_TOOLCHAIN_VARIANT=llvm ..
```

* Building the elf file for an app
```
ninja
```

* Building only the static library for the app
```
ninja ninja libapp.a
```

* Useful ninja commands like ```ninja -t clean``` can be found [here](https://ninja-build.org/manual.html#_extra_tools)

* Building ARA with clang secfaults if precompiled headers are used, turn them off
```
meson configure -Db_pch=false
```

* Running ARA for zephyr apps:
```
./ara.py -v --step-settings ../settings/zephyr.json /home/kenny/ara/appl/Zephyr/cpp_synchronization/build/app/libapp.ll --entry-point zephyr_app_main
```

* Use this for inspection of symbols with mangled names:
```
c++filt
```

* Usefull resources
[llvm-ir](https://stackoverflow.com/questions/9148890/how-to-make-clang-compile-to-llvm-ir)
[gcc-flags](https://www.keil.com/support/man/docs/armclang_ref/armclang_ref_chr1422532346348.htm)
[Zephyr installation instructions]()

# Zehpyr resources
[native-posix](https://docs.zephyrproject.org/1.12.0/boards/posix/native_posix/doc/board.html#id4)
[getting-started](https://docs.zephyrproject.org/1.12.0/getting_started/getting_started.html)
[dev enviroment](https://docs.zephyrproject.org/1.12.0/getting_started/installation_linux.html)
[setup with west](https://docs.zephyrproject.org/latest/guides/beyond-GSG.html)
[west](https://docs.zephyrproject.org/1.12.0/west/index.html)

# The Zephyr buildsystem
## Generator scripts 
All of those scripts are located under ```/home/kenny/zephyrproject/zephyr/scripts/```
1. ```subfolder_list.py```: Walks the given directory and outputs a list of all subdirs to the given file. In this case it appears to be used by the ```parse_syscalls``` script and is listing everything in the ```zephyr/include``` directory. It also generates a symlink structure to all indexed folders. The output is saved to the build directory of the current app ```build/zephyr/misc/generated/```
1. ```parse_syscalls.py```: Scans the ```zephyr/include``` directory for functions that have the ```__syscall``` attribute and generates a list of their prototypes for later boilerplate code generation. The list is stored in the build directory of each app under ```build/zephyr/misc/generated/syscalls.json```. It also generates some sort of map of struct names found under ```build/zephyr/misc/generated/struct_tags.json```. These are somehow used by ```gen_kobject_list.py```.
1. ```gen_kobject_list.py```: A generator for a list and offsets of kernel objects. Seems to generate info from elf files and outputs c code. It is also invoke two times. The gerenated c code is split into three files, all in ```build/zephyr/include/generated/```:
    1. ```offset.h```: Offsets to struct members of kernel objects. Primarily used in asssembler code.
    1. ```otype-to-str.h```: A switch that gives a string representation of a kernel object's name when given the macro (numeric constant) of it.
    1. ```otype-to-size.h```: A switch that gives size of a kernel object when given the macro (numeric constant) of it.
1. ```gen_syscalls.py```: Based on the ```syscalls.json``` created by ```parse_syscalls.py```this generates 3 things in the build direcory of the app under ```build/zephyr/include/generated/```.
    1. ```syscall_dispatch.c```: Dummy syscalls that are used if the original syscall is not implemented.
    1. ```syscall_list.h```: Macros that define the syscall table (aka syscall numbers)
    1. ```/syscalls/*```: A header file for each header file in zephyr that contains a syscall. Within are the generated functions that handle the dispatch of a syscall. If ```CONFIG_USERSPACE``` is set, they handle argmuent transfer and dispatch via trap/syscall table, otherwise they just call the implementations named ```z_impl_*```