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


sudo docker run --rm -it \
	 --user $UID:$GID --workdir "$HOME" \
	 --env=USER="$USER"\
	 --volume "/etc/group:/etc/group:ro"\
	 --volume "/etc/passwd:/etc/passwd:ro"\
	 --volume "/etc/shadow:/etc/shadow:ro"\
	 --volume "$HOME:$HOME:rw"\
	 $qemu_mount \
	 ara-dev-env /bin/bash
