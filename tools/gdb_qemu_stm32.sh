#!/bin/bash

file=`mktemp`
trap "rm -f -- $file" INT EXIT
echo "target remote :33754" > $file
qemu-system-stm32 -gdb tcp::33754 -machine stm32-p103 -nographic -serial mon:stdio -S -no-shutdown -kernel $@ &
qemu_pid=$!
trap "rm -f -- $file; kill $qemu_pid 2>/dev/null" INT EXIT
cat $file
gdb-multiarch -x $file ${1}

