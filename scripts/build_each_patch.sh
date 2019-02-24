#!/bin/bash
# set -x

export MESON_PARAMS='-Dwerror=true -Dexamples=all -Denable_kmods=false'

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
	git am -3 $f
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

	make -j8 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make failed $f"
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
	git am -3 $f
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

	make -j8 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "make failed $f"
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
	./devtools/test-build.sh -j8 x86_64-native-linuxapp-gcc+shared+debug x86_64-native-linuxapp-gcc+debug 2> /tmp/build.log 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		echo "shared lib failed"
		git reset --hard $changeset
		exit
	fi
done

git reset --hard $changeset

echo "meson shared lib test"
for f in $files
do
	#echo "$f"
	rm -rf build
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	CC="ccache gcc" meson --default-library=shared $MESON_PARAMS gcc-shared-build 2> /tmp/build.log 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "meson: gcc-shared-build config failed"
		exit
	fi
	ninja -C gcc-shared-build 2> /tmp/build.log 1> /tmp/build.log
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "meson: gcc-shared-build failed"
		exit
	fi
done

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
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=i686-native-linuxapp-gcc 2> /tmp/build.log 1> /tmp/build.log &&  sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config &&  make -j 8 test-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "x86_32 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=arm64-armv8a-linuxapp-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && make -j 8 test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
rm -rf build && unset RTE_KERNELDIR && make -j 8 config T=arm64-thunderx-linuxapp-gcc  CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(CONFIG_RTE_KNI_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_LIBRTE_VHOST_NUMA=)y,\1n,' build/.config &&  sed -ri  's,(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && make -j 8 test-build CROSS=aarch64-linux-gnu- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm64-thunderx build gcc failed"
	exit
fi
#add shared buidl
git clean -xdf 2>/dev/null 1>/dev/null
export EXTRA_CFLAGS= && export EXTRA_LDFLAGS= && rm -rf build && make -j 8 config RTE_ARCH=arm T=arm-armv7a-linuxapp-gcc CROSS=arm-linux-gnueabihf- 2> /tmp/build.log 1> /tmp/build.log && sed -ri    's,(_KMOD=)y,\1n,' build/.config && sed -ri  's,(CONFIG_RTE_EAL_IGB_UIO=)y,\1n,' build/.config && make -j 8 test-build CROSS=arm-linux-gnueabihf- 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
	git reset --hard $changeset
	echo "arm32 build gcc failed"
	exit
fi

git clean -xdf 2>/dev/null 1>/dev/null
echo "build done"

## gcc static
echo "gcc static build"
CC="ccache gcc" meson --default-library=static $MESON_PARAMS gcc-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: gcc-static-build config failed"
        exit
fi
ninja -C gcc-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: gcc-static-build failed"
        exit
fi

## clang shared
echo "clang shared build"
CC="ccache clang" meson --default-library=shared $MESON_PARAMS clang-shared-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: clang-shared-build config failed"
        exit
fi
ninja -C clang-shared-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: clang-shared-build failed"
        exit
fi

## clang static
echo "clang static build"
CC="ccache clang" meson --default-library=static $MESON_PARAMS clang-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: clang-static-build config failed"
        exit
fi
ninja -C clang-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: clang-static-build failed"
        exit
fi

## thunder cross shared build
echo "thunderx cross shared build"
meson --default-library=shared $MESON_PARAMS --cross-file config/arm/arm64_thunderx_linuxapp_gcc thunderx-shared-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: thunderx-shared-config failed"
        exit
fi
ninja -C thunderx-shared-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: thunderx-shared-build failed"
        exit
fi

## thunderx static build
echo "thunderx cross static build"
meson --default-library=static $MESON_PARAMS --cross-file config/arm/arm64_thunderx_linuxapp_gcc thunderx-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: thunderx-static-config failed"
        exit
fi
ninja -C thunderx-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: thunderx-static-build failed"
        exit
fi

## generic arm64 static build
echo "arm64 cross static build"
meson --default-library=static $MESON_PARAMS --cross-file config/arm/arm64_armv8_linuxapp_gcc arm64-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: arm64-static-config failed"
        exit
fi
ninja -C arm64-static-build 2> /tmp/build.log 1> /tmp/build.log
if [ $? -ne 0 ]; then
        git reset --hard $changeset
        echo "meson: arm64-static-build failed"
        exit
fi

## coding standerd checks
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
