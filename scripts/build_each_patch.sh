#!/bin/bash
# set -x

files=$1/*

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
	git am $f
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "git am failed $f"
		exit
	fi
	make config T=x86_64-native-linuxapp-gcc 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make config failed $f"
		git reset --hard $changeset
		exit
	fi
	make -j8 test-build 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make test-build failed $f"
		git reset --hard $changeset
		exit
	fi

	export RTE_SDK=`pwd`
	export RTE_TARGET=build
	make -j8 -C examples 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make example failed $f"
		git reset --hard $changeset
		exit
	fi
done

git reset --hard $changeset

echo "clang test"
for f in $files
do
	#echo "$f"
	rm -rf build
	git clean -xdf 2>/dev/null 1>/dev/null
	git am $f
	if [ $? -ne 0 ]; then
		echo "git am failed $f"
		git reset --hard $changeset
		exit
	fi
	make config T=x86_64-native-linuxapp-clang 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make config failed $f"
		git reset --hard $changeset
		exit
	fi
	make -j8 test-build 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make test-build failed $f"
		git reset --hard $changeset
		exit
	fi

	export RTE_SDK=`pwd`
	export RTE_TARGET=build
	make -j8 -C examples 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make example failed $f"
		git reset --hard $changeset
		exit
	fi
done

git clean -xdf 2>/dev/null 1>/dev/null
export DPDK_DEP_ZLIB=y
export DPDK_DEP_PCAP=y
export DPDK_DEP_SSL=y
./devtools/test-build.sh -j8 x86_64-native-linuxapp-gcc+shared x86_64-native-linuxapp-gcc+debug 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	echo "test-build.sh failed"
	git reset --hard $changeset
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=x86_64-native-linuxapp-gcc 2> /tmp/build.log 1> /tmp/build.log && make -j 8 test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_64 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=x86_64-native-linuxapp-clang 2> /tmp/build.log 1> /tmp/build.log && make -j 8 test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_64 build clang failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=i686-native-linuxapp-gcc 2> /tmp/build.log 1> /tmp/build.log && make -j 8 test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_32 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=arm64-armv8a-linuxapp-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && make -j 8 test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=arm64-thunderx-linuxapp-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && make -j 8 test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-thunderx build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
export EXTRA_CFLAGS= && export EXTRA_LDFLAGS= && rm -rf build && make -j 8 config RTE_ARCH=arm T=arm-armv7a-linuxapp-gcc CROSS=arm-linux-gnueabihf- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(_KMOD=)y,\1n,' build/.config && make -j 8 test-build CROSS=arm-linux-gnueabihf- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm32 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
echo "build done"


./devtools/check-git-log.sh
if [ $? -ne 0 ]; then
	echo "check-git-log failed"
	exit
fi

./devtools/checkpatches.sh
if [ $? -ne 0 ]; then
	echo "checkpatch failed"
	exit
fi

git reset --hard $changeset
