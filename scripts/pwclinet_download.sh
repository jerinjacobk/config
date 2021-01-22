#!/bin/sh -e
# set -x

test=$(basename $0)

pwclinet_get()
{
	git pw patch download $1 /tmp/r/
	if [ $? -ne 0 ]; then
		echo "pwclient get failed $1"
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
		pwclinet_get $change
	done
else
	while [ "$1" != "" ]; do
		pwclinet_get $1
		shift;
	done;
fi


