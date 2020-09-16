#!/bin/bash

set -euo pipefail
shopt -s extglob

files=$1/*
if [ "$1" == "" ]; then
	echo "patch directory is missing"
	exit
fi

for f in $files
do
	echo $f
	git clean -dxf 2>/dev/null 1>/dev/null
	git am -3 $f
	./scripts/checkpatch.pl $f
	echo "bootstrap"
	./bootstrap 2>/dev/null 1>/dev/null
	echo "configure"
	./configure --enable-doxygen-doc 2>/dev/null 1>/dev/null
	echo "build"
	make -j 2>/dev/null 1>/dev/null
	echo "build doc"
	make doxygen-doc
	echo "check"
	make check 2>/dev/null 1>/dev/null
	git clean -dxf 2>/dev/null 1>/dev/null
	echo "bootstrap"
	./bootstrap 2>/dev/null 1>/dev/null
	echo "configure"
	./configure --disable-abi-compat --enable-doxygen-doc 2>/dev/null 1>/dev/null
	echo "build"
	make -j 2>/dev/null 1>/dev/null
	echo "build doc"
	make doxygen-doc
	echo "check"
	make check 2>/dev/null 1>/dev/null
done

