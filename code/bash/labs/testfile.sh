#!/bin/bash
#
# testfile: Evaluate the status of a file
#

FILE=$1

if [ -e "$FILE" ]; then
	if [ -f "$FILE" ]; then
		echo "$FILE: regular"
	fi
	if [ -d "$FILE" ]; then
		echo "$FILE: directory"
	fi
	if [ -r "$FILE" ]; then
		echo "$FILE: readable"
	fi
	if [ -w "$FILE" ]; then
		echo "$FILE: writable"
	fi
	if [ -x "$FILE" ]; then
		echo "$FILE: executalbe/searchable"
	fi
else
	echo "$FILE: does not exist"
	exit 1
fi

exit
