#!/bin/sh -e
# set -x

test=$(basename $0)

apply_patch()
{
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
}

if [ `echo $1 | grep -c "-" ` -gt 0 ]
then
	base=`echo $1 | cut -f 1 -d -`
	num=`echo $1 | cut -f 2 -d -`
	end=`expr $base + $num - 1`
	changes=`seq -s' ' $base $end`
	for change in $changes
	do
		apply_patch $change
	done
else
	while [ "$1" != "" ]; do
		apply_patch $1
		shift;
	done;
fi


