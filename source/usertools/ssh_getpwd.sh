#!/bin/bash
# this script in preix/tools/usertools
# config file in prefix/config
cd `dirname $0`

if [ $# -lt 2 ];then
	exit 1
fi

pw_file=../../config/toolssshpw.txt
if [ ! -f $pw_file ];then
	exit 1
fi

pw=$(cat $pw_file | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d; ' | awk -vip="$1" -vusr="$2" '
NF==2 {
	if (usr==$1) {
		print $2
	}
}
NF==3 {
	pat="^("$1")$"
	if (match(ip, pat) && usr==$2) {
		print $3
	}
}
' | head -n 1)
echo $pw