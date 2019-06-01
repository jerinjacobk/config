#!/bin/bash
# set -x


files=$1/*
cpus=`getconf _NPROCESSORS_ONLN`

changeset=`git log --oneline | head -n 1 | cut -f 1 -d " "`

if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

echo "gcc test"
for f in $files
do
	#echo "$f"
	rm -rf build
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "git am failed $f"
		exit
	fi
	make config T=x86_64-native-linux-gcc 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make config failed $f"
		git reset --hard $changeset
		exit
	fi

	CC="ccache gcc"  make -j $cpus 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make failed $f"
		git reset --hard $changeset
		exit
	fi

	CC="ccache gcc"  make -j $cpus test-build 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make test-build failed $f"
		git reset --hard $changeset
		exit
	fi

	export RTE_SDK=`pwd`
	export RTE_TARGET=build
	CC="ccache gcc"  make -j $cpus -C examples 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make example failed $f"
		git reset --hard $changeset
		exit
	fi
done

git reset --hard $changeset
