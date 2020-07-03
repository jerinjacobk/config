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

echo "clang test"
for f in $files
do
	#echo "$f"
	rm -rf build
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	if [ $? -ne 0 ]; then
		echo "git am failed $f"
		git reset --hard $changeset
		exit
	fi
	make config T=x86_64-native-linux-clang 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make config failed $f"
		git reset --hard $changeset
		exit
	fi

	CC="ccache clang"  make -j $cpus 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make failed $f"
		git reset --hard $changeset
		exit
	fi

	CC="ccache clang"  make -j $cpus test-build 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make test-build failed $f"
		git reset --hard $changeset
		exit
	fi

	export RTE_SDK=`pwd`
	export RTE_TARGET=build
	CC="ccache clang"  make -j $cpus -C examples 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make example failed $f"
		git reset --hard $changeset
		exit
	fi
done

git reset --hard $changeset

echo "shared lib test"
for f in $files
do
	#echo "$f"
	rm -rf build
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	if [ $? -ne 0 ]; then
		echo "git am failed $f"
		git reset --hard $changeset
		exit
	fi
	export DPDK_DEP_ZLIB=y
	export DPDK_DEP_PCAP=y
	export DPDK_DEP_SSL=y
	./devtools/test-build.sh -j $cpus x86_64-native-linuxapp-gcc+shared+debug x86_64-native-linuxapp-gcc+debug 2> /tmp/build.log 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "shared lib failed"
		git reset --hard $changeset
		exit
	fi
done

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
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=x86_64-native-linux-gcc 2> /tmp/build.log 1> /tmp/build.log && CC="ccache gcc"  make -j $cpus test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_64 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=x86_64-native-linux-clang 2> /tmp/build.log 1> /tmp/build.log && CC="ccache gcc" make -j $cpus test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_64 build clang failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=i686-native-linux-gcc 2> /tmp/build.log 1> /tmp/build.log &&  sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config &&  CC="ccache gcc"  make -j $cpus test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_32 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=arm64-armv8a-linux-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && CC="ccache gcc" make -j $cpus test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=arm64-thunderx-linux-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && CC="ccache gcc" make -j $cpus test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-thunderx build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j $cpus config T=arm64-armada-linuxapp-gcc  CROSS=/opt/marvell-tools-236.0/bin/aarch64-marvell-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_PMD_MVSAM_CRYPTO=)y,\1n,' build/.config && make -j $cpus test-build CROSS=/opt/marvell-tools-236.0/bin/aarch64-marvell-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-armada build failed"
	exit
fi

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
