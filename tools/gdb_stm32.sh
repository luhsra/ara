#!/bin/bash

st-util &
gdb-multiarch ${1} -ex "target extended-remote :4242" -ex "layout split"
pkill st-util
