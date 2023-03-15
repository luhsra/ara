<!--
SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
SPDX-FileCopyrightText: 2020 Yannick Loeck
SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
SPDX-FileCopyrightText: 2021 Kenny Albes
SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
SPDX-FileCopyrightText: 2022 Jan Neugebauer

SPDX-License-Identifier: GPL-3.0-or-later
-->

ARA - Automatic Real-time System Analyzer
=========================================

Tool to automatically analyse real-time systems.
Currently capable of systems written with FreeRTOS and OSEK.

Building
--------

The following dependencies are needed:

- [meson](https://mesonbuild.com/) (>=0.60.0)
- [llvm](http://llvm.org/) (==14)
- [cython](https://cython.org/) (>=0.29.14)
- [python](https://www.python.org/) (>=3.7)
- [pydot](https://pypi.org/project/pydot/)
- [graph-tool](https://graph-tool.skewed.de/)

Optional dependencies:

- [pygments](https://pygments.org/) (Runtime depedency to get dot files linked to the source code)

Dependencies that are built as subproject:

- [SVF](http://svf-tools.github.io/SVF/)
  - SVF needs [Z3](https://github.com/Z3Prover/z3) additionally

Getting packages in SRA lab:
```
pip3 install --user meson
. ~/.profile
```

Outside of the SRA lab some extra dependencies might be needed:
```
sudo apt install cmake pkgconf libboost-all-dev libsparsehash-dev gcc-arm-none-eabi libcairo2-dev python3-dev
pip3 install -U pycairo matplotlib
```


To initialize the external modules, run the init script:
```
./init
```


To build the program type:
```
meson build
cd build
ninja
```
(Note: `build` is actually a placeholder for an arbitrary path.)

To build only ARA itself use:
```
ninja ara.py
```

There are some build options to deactivate parts of the project. Take a look at `meson configure` for that.

Zephyr
------
In order to build and analyze Zephyr-RTOS apps some additional steps are required: (you can use the init_zephyr.sh script to automate this process)
To obtain Zephyr and its dependencies follow steps 1 to 3 (inclusive) from their [starter guide](https://docs.zephyrproject.org/2.4.0/getting_started/index.html).

Delete the zephyrproject/zephyr repo and replace it with our [internal one](https://scm.sra.uni-hannover.de/diffusion/412/repository/ara/). 
Switch to branch `ara` and update the dependencies with west.
```
rm -rf ./zephyr
git clone -b ara git@scm.sra.uni-hannover.de:research/zephyrproject-rtos.git zephyr
west update
```
Configure meson so that it finds the zephyr install.
```
meson configure -D zephyr_dir=<...>/zephyrproject/
```
To test zephyr apps without a test case use this target:
```
ninja zephyr_examples
ninja z_clean
```

To analyze them with ARA:
```
./ara.py --os Zephyr --step-settings ../settings/zephyr.json --entry-point="" ./appl/Zephyr/static_threads.ll
```

Usage
-----

`ara.py` cannot be run without proper installation, due to misplaced binary modules.
Therefore meson generates a replacement script `ara.py` in the build directory that works out of the box. Run this with:
```
build/ara.py -h
```

Note: The input of the program is an LLVM IR file. To compile a C/C++ applications into IR files, invoke clang with the flags described in `settings/meson.build`.

Test Cases
----------

There are some predefined test cases. Run them with:
```
cd build
meson test
```

Architecture
------------

ARA is divided into steps that operate on the same system model. When starting the program the correct chain of steps is calculated and then executed. A listing of the steps can be retrieved by:
```
build/ara.py -l
```
Steps can be written into Python (defined in `steps`) or in C++ (defined in `steps/native`).
The model is written in C++ with Python bindings (defined in `graph`).

Program configuration
---------------------

ARA can be configured in multiple ways:

1. Global options: Options specified per command line. See `build/ara.py -h` for all available options.
2. Per-step options: See the following text.

Steps can define their own options. See `build/ara.py -l` for a list of steps and their options.
Step wise configuration can be configured with the `--step-settings` command line switch.

Input must be a JSON file with this syntax:
```
{
	"Stepname1": {
		"key1": "value",
		"key2": 45
	},
	"Stepname2": {
		"other_key1": "other_value",
	},
	...
}
```
Additionally to that, steps can be configured to run multiple times with different options. In this case, the settings file gets an additional entry `steps` that can be a list of steps that should be executed:
```
{
	"steps": ["MyStep1", "MyStep2", ...],
	"MyStep1": {
		"key": "value"
	}
}
```
or a list of step configurations or a mix of both:
```
{
	"steps": [
		"MyStep1",
		{
			"name": "MyStep2"
			"key": "value"
		}
		{
			"name": "MyStep2"
			"key": "value2"
		}
	],
	"MyStep1": {
		"key": "value"
	}
}
```
In this case *MyStep2* is executed two times with different options.

Applying of options goes from local to global. So a step get the configuration in `steps` first, then the per step configuration and then the global configuration.

### Logging configuration
Logging in ARA is done with the Python logging framework and makes extensive use of (Sub)Loggers.
In most cases, these loggers are equivalent with a step and can be configured via setting of the step's `log_level`.
However, some loggers are not for steps, e.g. the `StepManager` logger.

These loggers can be configured with an additional entry in the configuration file:
```
{
	"logger": {
		"StepManager": "debug",
		"Solver": "info",
	}
}
```
Note that only non-step loggers can be configured in this way.

Developing
----------
If you want to develop with ARA, some common actions are usual.

### Adding a new Python step

- Create the step in the `steps` directory. You can use `steps/dummy.py` as template.
- Add the step to `steps/__init__.py`.
  - Add to the `__all__`-attribute.
  - Add to the `provide_steps()` function.
- Create a test case for this step in the `test` directory. See the existing tests and `test/meson.build` for hints how to achieve this.

### Adding a new C++ step

- Create the step in the `steps/native` directory. You can use `steps/native/cdummy.{cpp,h,pxd}` as template.
- Add the step to `steps/native/meson.build` (both the `pxd` and the `cpp` file) to enable compilation.
- Add the step to `steps/native/step.pyx` to create a Python wrapper. Add an `cimport` and add the step to `provide_steps`.
- Create a test case for this step in the `test/native_step_test` directory. Usually, it is enough to add your test to `test/native_step_test/meson.build`.
  - C++ steps often need other C++ code to test it. For that add an extra test step in `steps/native/test.h` and `steps/native/test/` and call it from your test case.

### Autoformat

ARA uses `clang-format` as automatic formatting for its C++ sources.

One possibility to integrate this with git is a pre-commit hook like the following. Create a file `.git/hooks/pre-commit`:
```sh
#!/bin/sh

if git clang-format --diff $(git diff --name-only --cached 2>&1) 2>&1 | grep diff 2>&1 >/dev/null; then
	echo "ERROR: clang-format has changes."
	exit 1
fi
exit 0
```
And then manually invoke `git clang-format`.

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

### meson directory is really/too big
This is because of precompiled headers. They fasten the build a little bit but need a lot of disk space. You can deactivate precompiled headers with:
```
meson configure -Db_pch=false
```
