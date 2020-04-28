#!/bin/bash
# set -x


files=$1/*

changeset=`git log --oneline | head -n 1 | cut -f 1 -d " "`

if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

rm -rf build && meson -Dexamples=all build  1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	echo "config failed"
	exit
fi

for f in $files
do
	git am -3 $f
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "git am failed $f"
		exit
	fi
	ninja -C build 1> /tmp/build.log 2> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "build failed $f"
		exit
	fi
done

git reset --hard $changeset
