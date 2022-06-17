#!/bin/bash
# set -x


files=$1/*

changeset=`git log --oneline | head -n 1 | cut -f 1 -d " "`

if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

rm -rf build && meson -Dexamples=all -Denable_docs=true build  1> /tmp/build.log 2> /tmp/build.log
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
	./devtools/check-meson.py
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "./devtools/check-meson.py failed"
		exit
	fi
	./devtools/check-spdx-tag.sh
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "./devtools/check-spdx-tag.sh failed"
		exit
	fi
	#./devtools/check-doc-vs-code.sh ef38db95de
	./devtools/check-doc-vs-code.sh
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "./devtools/check-doc-vs-code.sh failed"
		exit
	fi
done

git reset --hard $changeset
