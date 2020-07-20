#!/bin/bash
export UID=$(id -u)
export GID=$(id -g)
# We're entering the container as the same user as the host user. This allows to use stuff located in the home directory such as qemu-system-arm, etc.

qemu="$HOME/git/qemu_stm32/arm-softmmu/qemu-system-arm"
if [ -n "$qemu" ]
then
	echo "QEMU: $qemu"
	export qemu_mount="--volume $qemu:/usr/bin/qemu-system-stm32:ro"
else
	echo no QEMU
	qemu_mount=""
fi

	 # --device "/dev/bus/usb/001/011"\
	 # --volume "/dev/bus/usb/:/dev/bus/usb:rw"\

sudo docker run --rm -it \
	 --user $UID:$GID --workdir "$HOME" \
	 --env=USER="$USER"\
	 --volume "/etc/group:/etc/group:ro"\
	 --volume "/etc/passwd:/etc/passwd:ro"\
	 --volume "/etc/shadow:/etc/shadow:ro"\
	 --volume "/proj/opt:/proj/opt:ro"\
	 --volume "$HOME:$HOME:rw"\
	 --device "/dev/ttyACM0"\
	 --privileged\
	 -v "/tmp/.X11-unix:/tmp/.X11-unix"\
	 --env=DISPLAY=$DISPLAY\
	 $qemu_mount \
	 ara-dev-env-focal /bin/bash
