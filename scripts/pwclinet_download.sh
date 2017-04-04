#!/bin/sh -e
# set -x

test=$(basename $0)

while [ "$1" != "" ]; do
	pwclient get $1
	if [ $? -ne 0 ]; then
		echo "pwclient get failed $1"
		exit
	fi
	shift;
done;

