#!/bin/sh -e
# set -x

test=$(basename $0)

while [ "$1" != "" ]; do
	pwclient get $1 2> /dev/null 1> /tmp/$test
	if [ $? -ne 0 ]; then
		echo "pwclient get failed $1"
		exit
	fi
	j=`cat /tmp/$test | grep -oP "^Saved patch to \K.*"`

	git am -3 $j

	if [ $? -ne 0 ]; then
		echo "git am -3 $j failed"
		rm /tmp/$test
		git am --abort
		git checkout .
		exit
	fi

	shift;
done;

