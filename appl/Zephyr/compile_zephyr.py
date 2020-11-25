from argparse import ArgumentParser
import os
import shutil
import string

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
parser.add_argument('--board', type=str)
parser.add_argument('--libgcc', type=str)
parser.add_argument('name', metavar='N', type=str)

args = parser.parse_args()

# Clear the build dir if it exits and we can't prove that the existing build is for the same board.
# This is required by the zephyr build system. Otherwise cmake runs into caching issues.
# TODO: Investigate how ninja clean handles zephyr 
same_board = False
try: 
    if os.path.exists(args.build_dir):
        with open(os.path.join(args.build_dir, 'zephyr/.config'), 'r') as config:
            for line in config.readlines():
                board = line.find('CONFIG_BOARD="')
                if board > -1:
                    board = line[board+len('CONFIG_BOARD="'):]
                    if board.find(args.board) == 0:
                        print('Board has not changed, skipping cmake...')
                        same_board = True

        if not same_board:
            print('Board might have changed, regenerating cmake...')
            shutil.rmtree(args.build_dir)
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
    cmake_call += ' -D ZEPHYR_BASE=' + '/home/kenny/zephyrproject/zephyr'
    cmake_call += ' -D TOOLCHAIN_ROOT=' + '/home/kenny/zephyrproject/zephyr'
    # Normally cmake *should* find them by itself, but this seems to be the only way to make it work
    # reliably
    cmake_call += ' -D CMAKE_OBJCOPY=' + args.objcopy
    cmake_call += ' -D CMAKE_OBJDUMP=' + args.objdump
    cmake_call += ' -D CMAKE_=NM' + args.nm
    cmake_call += ' -D CMAKE_=AR' + args.ar
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
# Copy the lib.ll to the top level for ease of use
try:
    shutil.copyfile(os.path.join(args.build_dir, 'app/libapp.ll'), os.path.join(args.build_dir,
        '..', args.name + '.ll'))
except FileNotFoundError:
    pass
    



