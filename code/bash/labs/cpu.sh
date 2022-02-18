#!/bin/bash

if [ ! -f /sys/devices/system/node/node0/cpu0/online ] ; then
	echo "node0/cpu0 is always Online."
fi

function showcpus()
{
	cpu=${1:-'*'}
	for node in 'ls -d /sys/devices/system/node/node*/cpu${cpu} | \
		cut -d"/" -f6 | sort -u'
	do
		grep . /sys/devices/system/node/${node}/cpu*/online /dev/null \
			| cut -d"/" -f6- | sed s/"\/online"/""/g | \
			sed s/":1$"/" is Online"/g | sed s/":0$"/" is Offline"/g
	done
}

