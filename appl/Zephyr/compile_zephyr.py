from argparse import ArgumentParser
import os
import shutil
import importlib
import sys

parser = ArgumentParser()
parser.add_argument('--objcopy', type=str)
parser.add_argument('--objdump', type=str)
parser.add_argument('--ranlib', type=str)
parser.add_argument('--ld', type=str)
parser.add_argument('--ar', type=str)
parser.add_argument('--size', type=str)
parser.add_argument('--nm', type=str)
parser.add_argument('--source_dir', type=str)
parser.add_argument('--build_dir', type=str)
parser.add_argument('--zephyr_root', type=str)
parser.add_argument('--board', type=str)
parser.add_argument('--libgcc', type=str)
parser.add_argument('--cc', type=str)
parser.add_argument('--llc', type=str)
parser.add_argument('--llvm_link', type=str)
parser.add_argument('name', metavar='N', type=str)

args = parser.parse_args()

def fake_step_module():
    """Fake the step module into the correct package."""
    sys.setdlopenflags(sys.getdlopenflags() | os.RTLD_GLOBAL)
    import graph_tool
    import pyllco
    def load(what, where):
        module = importlib.import_module(what)
        sys.modules[where] = module

    load("graph_data", "ara.graph.graph_data")
    load("py_logging", "ara.steps.py_logging")
    load("step", "ara.steps.step")

    sys.setdlopenflags(sys.getdlopenflags() & ~os.RTLD_GLOBAL)


fake_step_module()

from ara.util import KConfigFile

# Clear the build dir if it exits and we can't prove that the existing build is for the same board.
# This is required by the zephyr build system. Otherwise cmake runs into caching issues.
# TODO: Investigate how ninja clean handles zephyr 
same_board = False
try: 
    if os.path.exists(args.build_dir):
        config = KConfigFile(os.path.join(args.build_dir, 'zephyr/.config'))
        same_board = config['CONFIG_BOARD'] == args.board
        if not same_board:
            print('Board might have changed, regenerating cmake...')
            shutil.rmtree(args.build_dir)
        else:
            print('Board has not changed, skipping cmake...')

except FileNotFoundError:
    print('Could not detect board, regenerating...')
    shutil.rmtree(args.build_dir)
try:
    os.mkdir(args.build_dir)
except FileExistsError:
    pass

# NOTE: Whenever any of these flags change, regenerate manually
if not same_board:
    cmake_call = 'cmake -G Ninja'
    cmake_call += ' -D BOARD=' + args.board
    cmake_call += ' -D ZEPHYR_TOOLCHAIN_VARIANT=llvm'
    cmake_call += ' -D ZEPHYR_BASE=' + args.zephyr_root
    cmake_call += ' -D TOOLCHAIN_ROOT=' + args.zephyr_root
    cmake_call += ' -D CMAKE_C_COMPILER=' + args.cc
    cmake_call += ' -D CMAKE_CXX_COMPILER=' + args.cc
    cmake_call += ' -D CMAKE_LLC=' + args.llc
    cmake_call += ' -D CMAKE_LLVM_LINK=' + args.llvm_link
    # Normally cmake *should* find them by itself, but this seems to be the only way to make it work
    # reliably
    cmake_call += ' -D CMAKE_OBJCOPY=' + args.objcopy
    cmake_call += ' -D CMAKE_OBJDUMP=' + args.objdump
    cmake_call += ' -D CMAKE_NM=' + args.nm
    cmake_call += ' -D CMAKE_AR=' + args.ar
    # Override the linker that clang uses for the exe/elf. Clang defaults to lld which is incompatible
    # with the generated linker scripts. Note that setting CMAKE_LINKER will NOT work since clang
    # ignores that.
    cmake_call += ' -D CMAKE_EXE_LINKER_FLAGS="-fuse-ld=' + args.ld + ' -L ' + args.libgcc + '"' #+ ' -v"'
    # Disable common warnings that gcc does not emit but clang does. Typedef redefinition will be fixed
    # in https://github.com/zephyrproject-rtos/zephyr/pull/29359
    cmake_call += ' -D EXTRA_CFLAGS="-Wno-typedef-redefinition -Wno-unused-command-line-argument"'
    cmake_call += ' -S ' + args.source_dir
    cmake_call += ' -B ' + args.build_dir

    # Generate cmake files
    # Fail with an exeception so that meson/ninja knows something went wrong.
    ret = os.system(cmake_call)
    if ret != 0:
        raise RuntimeError("Cmake failed!")

# Invoke ninja to build
ret = os.system('ninja -C ' + args.build_dir)
if ret != 0:
    raise RuntimeError("Ninja failed!")
# Copy the lib.ll and .config to the top level for ease of use
try:
    shutil.copyfile(os.path.join(args.build_dir, 'app/libapp.ll'), os.path.join(args.build_dir,
        '..', args.name + '.ll'))
    shutil.copyfile(os.path.join(args.build_dir, 'zephyr/.config'), os.path.join(args.build_dir,
        '..', args.name + '.config'))
except FileNotFoundError:
    pass



