#!/bin/bash

echo $@
# qemu-system-stm32 -machine stm32-p103 -nographic -serial mon:stdio -kernel ${1}
qemu-system-stm32 -machine stm32-p103 -nographic -serial file:/dev/stdout -monitor none -kernel $@
