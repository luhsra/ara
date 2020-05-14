#!/bin/bash

tmux new-session \
st-util ';' \
new-window \
"gdb-multiarch ${1} -ex 'target extended-remote :4242' -ex 'layout split'" ';'
pkill st-util
