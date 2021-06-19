
# This script rebuilds the libmicrohttpd LLVM IR
# Execute this script after modifying the libmicrohttpd project. 
 
# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit 1

rm ../build/appl/POSIX/microhttpd_demo.ll
rm ../build/appl/POSIX/libmicrohttpd.ll
rm ../build/appl/POSIX/objs/microhttpd_demo.ll
rm ../build/appl/POSIX/objs/microhttpd_demo_without_lib.ll
rm ../build/appl/POSIX/bin/microhttpd_demo

#(cd ../appl/POSIX && make clean-libmicrohttpd)
(cd ../appl/POSIX && make -j$(nproc))