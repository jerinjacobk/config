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
	./devtools/check-doc-vs-code.sh
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "./devtools/check-doc-vs-code.sh failed"
		exit
	fi
	count=`expr $count + 1`
done

git clean -xdf 2>/dev/null 1>/dev/null
PKG_CONFIG_PATH=/export/cross_prefix/prefix/lib/pkgconfig/ meson build --cross=config/arm/arm64_armada_linux_gcc  1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "armada build config failed"
	exit
fi
ninja -C build 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "armada build failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
meson --cross-file config/x86/cross-mingw -Dexamples=helloworld build-mingw 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "Windows build config failed"
	exit
fi
ninja -C build-mingw/ 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "Windows cross build failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
meson --werror -Dc_args='-DRTE_ENABLE_ASSERT' --buildtype=debug -Denable_docs=true build 1> /tmp/build.log 2> /tmp/build.log
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

grep -ri "WARN" /tmp/build.log
if [ $? -eq 0 ]; then
	git reset --hard $changeset
	echo "doc build has errros"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
echo "build done"

# ABI check
DPDK_ABI_REF_VERSION=v21.11 bash ./devtools/test-meson-builds.sh 1> /tmp/build.log 2> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "ABI check failed"
	exit
fi

grep "Error: ABI issue reported" /tmp/build.log
if [ $? -eq 0 ]; then
	echo "ABI issue"
	exit
fi

grep "Error:" /tmp/build.log

./devtools/check-git-log.sh -n $count
if [ $? $val -ne 0 ]; then
	echo "check-git-log failed"
fi

./devtools/checkpatches.sh -n $count
if [ $? -ne 0 ]; then
	echo "checkpatch failed"
fi
