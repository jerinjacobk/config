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
count=0

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
	count=`expr $count + 1`
done

git clean -xdf 2>/dev/null 1>/dev/null
meson build -Denable_docs=true 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "doc build config failed"
	exit
fi
ninja -C build 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "doc build failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
echo "build done"

# ABI check
#DPDK_ABI_REF_VERSION=v20.11 DPDK_ABI_REF_DIR=/tmp ./devtools/test-meson-builds.sh 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "ABI check failed"
	exit
fi

./devtools/check-git-log.sh -n $count
if [ $? $val -ne 0 ]; then
	echo "check-git-log failed"
fi

./devtools/checkpatches.sh -n $count
if [ $? -ne 0 ]; then
	echo "checkpatch failed"
fi
