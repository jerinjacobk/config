#!/bin/bash
# set -x

files=$1/*

changeset=`git log --oneline | head -n 1 | cut -f 1 -d " "`

if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

function build_static
{
	rm -rf build-static && mkdir -p build-static && pushd build-static 2>/dev/null 1>/dev/null && PKG_CONFIG_PATH=/export/cross_prefix/prefix/lib/pkgconfig ../configure  --with-platform=cn10k --host=aarch64-marvell-linux-gnu --disable-abi-compat --disable-shared --enable-test-vald --with-openssl-path=/export/cross_prefix/prefix/ 2>/dev/null 1>/dev/null && popd 2>/dev/null 1>/dev/null

	make -j -C build-static 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "cn10k static build-static failed $f"
		exit 1
	fi
}

function build_shared
{
	rm -rf build-shared && mkdir -p build-shared && pushd build-shared  2>/dev/null 1>/dev/null && PKG_CONFIG_PATH=/export/cross_prefix/prefix/lib/pkgconfig ../configure  --with-platform=cn10k --host=aarch64-marvell-linux-gnu --disable-abi-compat --enable-shared --enable-test-vald --with-openssl-path=/export/cross_prefix/prefix/ 2>/dev/null 1>/dev/null && popd 2>/dev/null 1>/dev/null

	make -j -C build-shared 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "cn10k shared build-shared failed $f"
		exit 1
	fi
}

function build_lto
{
	rm -rf build-lto && mkdir -p build-lto && pushd build-lto 2>/dev/null 1>/dev/null && PKG_CONFIG_PATH=/export/cross_prefix/prefix/lib/pkgconfig ../configure  --with-platform=cn10k --host=aarch64-marvell-linux-gnu --disable-abi-compat --disable-shared --enable-test-vald --enable-lto --with-openssl-path=/export/cross_prefix/prefix/ 2>/dev/null 1>/dev/null && popd 2>/dev/null 1>/dev/null

	make -j -C build-lto 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "cn10k lto build-lto failed $f"
		exit 1
	fi
}



for f in $files
do
	git clean -xdf 2>/dev/null 1>/dev/null
	git am -3 $f
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "git am failed $f"
		exit
	fi
	./bootstrap 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "bootstrap failed $f"
		exit
	fi

	./scripts/marvell-ci/sanity.sh 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then
		git reset --hard $changeset
		echo "sanity failed failed $f"
		exit
	fi
        git format-patch -n1 -s -q
        ./scripts/checkpatch.pl 0001* 2>/tmp/odp_check_patch.txt 1>/tmp/odp_check_patch.txt
	if [ $? -ne 0 ]; then
		echo "check patch failed $f"
		cat /tmp/odp_check_patch.txt
	fi

	build_static &
	P1=$!
	build_shared &
	P2=$!
	build_lto &
	P3=$!

	wait $P1 $P2 $P3

done

git reset --hard $changeset
