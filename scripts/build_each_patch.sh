#!/bin/bash
# set -x

export MAKE_PAUSE=n

files=$1/*
cpus=`getconf _NPROCESSORS_ONLN`

changeset=`git log --oneline | head -n 1 | cut -f 1 -d " "`

if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

git reset --hard $changeset

echo "meson build test"
for f in $files
do
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	if [ $? -ne 0 ]; then
		echo "git am failed $f"
		git reset --hard $changeset
		exit
	fi
	time ./devtools/test-meson-builds.sh 2> /tmp/build.log 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "meson: build failed"
		exit
	fi
done

git clean -xdf 2>/dev/null 1>/dev/null
meson build --cross=config/arm/arm64_armada_linux_gcc -Dlib_musdk_dir="/home/jerin/musdk-marvell/usr/local/" 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-armada meson config failed"
	exit
fi
ninja -C build 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-armada meson build failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
echo "build done"

## ABI check
DPDK_ABI_REF_VERSION=v20.05 DPDK_ABI_REF_DIR=/tmp ./devtools/test-meson-builds.sh 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "ABI check failed"
	exit
fi

## coding standard checks
./devtools/check-git-log.sh > /tmp/check-git-log.sh
val=`wc -l /tmp/check-git-log.sh | cut -f1  -d " "`
if [ $val -ne 0 ]; then
	echo "check-git-log failed"
	cat /tmp/check-git-log.sh
	rm /tmp/check-git-log.sh
	exit
fi

./devtools/checkpatches.sh
if [ $? -ne 0 ]; then
	echo "checkpatch failed"
	exit
fi

git reset --hard $changeset
