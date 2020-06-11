#!/bin/sh -e
# set -x

test=$(basename $0)

apply_patch()
{
	git review -x $1
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


