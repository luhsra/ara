
# Downloads and setup the Zephyr project
#
# Usage:
# ./init_zephyr <Meson build dir>
#
# The default <Meson build dir> is build

# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit

if [ "x$1" = "x" ] ; then
	readonly MESON_BUILD=build
else
	readonly MESON_BUILD=$1
fi

readonly ZEPHYR_PROJECT=${MESON_BUILD}/zephyrproject

# Make sure that zephyr ARA Repo is up to date
./init

# Install west
pip3 install --user -U west
echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc
source ~/.bashrc

# Get Zephyr code:
west init ${ZEPHYR_PROJECT}
cd ${ZEPHYR_PROJECT}
west update
west zephyr-export
pip3 install --user -r zephyr/scripts/requirements.txt

# Replace Zephyr directory by our Zephyr ARA Repo
rm -rf zephyr
ln -s ../../subprojects/zephyr zephyr
west update

# Allow Meson to find ${ZEPHYR_PROJECT}
cd .. # back to: ${MESON_BUILD}
meson configure -D zephyr_dir=$(pwd)/${ZEPHYR_PROJECT}
