#!/bin/bash
# set -x


x=0
while true; do
	x=$(($x + 1))
	echo "#### $x"
	sudo ./build/app/testeventdev --vdev=event_sw;
	if [ $? -ne 0 ]; then
		echo "test failed"
		exit
	fi
	sleep 2;
done

