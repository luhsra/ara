#!/bin/bash

qemu-system-stm32 -machine stm32-p103 -nographic -serial mon:stdio -kernel ${1}
