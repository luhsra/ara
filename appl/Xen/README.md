# How to run HyperSSE
```bash
# to use ninja/meson go to parrot/build
cd build

# Run one test case
ninja subprojects/ara/appl/Xen/hc-autosar

# Debug using vscode launch.json (need to run each case before once)
# choose the hypersse.json file for the choosen testcase:
# "--step-settings", "subprojects/ara/appl/Xen/hypersse-min-1.json" 
# OR
# "--step-settings", "subprojects/ara/appl/Xen/hypersse-hardware.json"

# Run test suite
meson test --suite ara-xen-eval
# OR goto parrot/subprojects/ara/test/xen-eval
python3 thesis.py
```

# View graphs
```bash
# Last HSTG
../tools/show_recent_graphs.sh -hstg

# Last two CFGs
../tools/show_recent_graphs.sh -abbs -2
```

# Build guest systems
```bash
# Zephyr
ninja sse-native_sim-zephyr-hw
# to rebuild delete 'parrot/build/subprojects/ara-zephyr-apps/appl/*'

# Autosar
ninja subprojects/ara/appl/AUTOSAR/autosar____Xen_thesis_Autosar_D_ipi_noopt_mod.pi4.ll
ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_andreas_ipi_b_noopt_mod.pi4.ll

# Bare Metal
ninja subprojects/ara/appl/Xen/bare_metal/___min_bm_BareMetal_A_main.pi4.ll
```

# Add test cases
1. New folder with test name
1. One subfolder for each guest with application's code
1. Add applications to their OS-specifc meson file
1. Create new test case target in Xen's meson file with paths to all guests