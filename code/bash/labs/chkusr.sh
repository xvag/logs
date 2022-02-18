#!/bin/bash

# check a username in /etc/passwd
# use of IFS

FILE=/etc/passwd
file_info=$(grep "^$1:" $FILE)

if [ -n "$file_info" ]; then
	IFS=":" read user pw uid gid name home shell <<< "$file_info"
	echo "User: '$user'"
	echo "UID: '$uid'"
	echo "GID: '$gid'"
	echo "Name: '$name'"
	echo "Home: '$home'"
	echo "Shell: '$shell'"
else
	echo "No such user: $1" >&2
	exit 1
fi

exit
