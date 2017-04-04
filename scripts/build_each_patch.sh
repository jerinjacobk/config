#!/bin/sh -e
# set -x

files=$1/*

if [ "$1" != "" ]; then
	for f in $files
	do
		echo "$f"
		rm -rf build
		git clean -xdf
		git am $f
		if [ $? -ne 0 ]; then
			echo "git am failed $f"
			exit
		fi
		make config T=x86_64-native-linuxapp-gcc
		if [ $? -ne 0 ]; then
			echo "make config failed $f"
			exit
		fi
		make -j8 test-build 1> /dev/null
		if [ $? -ne 0 ]; then
			echo "make test-build failed $f"
			exit
		fi
	done
fi

