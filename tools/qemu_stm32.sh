#!/bin/bash
STTY_SETTINGS="$( stty -g )"

function finish {
	stty "$STTY_SETTINGS"
}
trap finish EXIT QUIT HUP INT ABRT TERM

echo $@
# qemu-system-stm32 -machine stm32-p103 -nographic -serial mon:stdio -kernel ${1}
qemu-system-stm32 -machine stm32-p103 -nographic -serial stdio -monitor none -kernel $@
