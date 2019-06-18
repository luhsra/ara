ARA - Automatic Realtime-System Analyzer
========================================

Tool to automatically analyse realtime-systems.
Currently capable of FreeRTOS and OSEK.

Building
--------

The following dependencies are needed:

- [meson](https://mesonbuild.com/) (>=0.48.0)
- [llvm](http://llvm.org/) (==7.0)
- [cython](https://cython.org/) (>=0.26.1)
- [python](https://www.python.org/) (>=3.6)

Getting packages in SRA lab:
```
echo addpackage llvm-7.0 >> ~/.bashrc
echo export LD_LIBRARY_PATH=/proj/opt/llvm-7.0/lib:\$LD_LIBRARY_PATH >> ~/.bashrc
echo export PATH=`pwd`/.local/bin:\$PATH >> ~/.bashrc
. ~/.bashrc
pip3 install --user meson
```


To build the program type:
```
meson build
cd build
ninja
```
(Note: `build` is actually a placeholder for an arbitrary path.)

Usage
-----

To run the program `ara.py` needs to be executed with the correct `PYTHONPATH`.
For convenience a small wrapper script is generated by meson that sets the correct environment variables. Run this with:
```
build/ara.sh -h
```

Note: The input of the program are some LLVM IR files. To compile a C/C++ application into IR files, invoke clang with the flags described in `appl/meson.build`.

Test Cases
----------

There are some predefined test cases. Run them with:
```
cd build
meson test
```

Architecture
------------

ARA is devided into steps that operate on the same system model. When starting the program the correct chain of steps is calculated and then executed. A listing of the steps can be retrieved by:
```
build/ara.sh -l
```
Steps can be written into Python (defined in `steps`) or in C++ (defined in `steps/native`).
The model is written in C++ with Python bindings (defined in `libgraph`).

Troubleshooting
---------------

### LLVM is not found
Sometime Meson is unable to find the correct LLVM libraries because detection of the `llvm-config` file fails.
In this case, add a file `native.txt` with this content:
```
[binaries]
llvm-config = '/path/to/llvm-config'
```
Then configure your build directory with:
```
meson build --native-file native.txt
```