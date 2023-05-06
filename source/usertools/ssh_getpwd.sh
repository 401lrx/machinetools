#!/bin/bash
cd `dirname $0`

if [ $# -lt 2 ];then
	exit 1
fi

pw=$(echo "
# 192.168.1.1 usr pw
# 192.168.* usr pw
# .* usr pw

" | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d; ' | awk -vip="$1" -vusr="$2" '
NF==3 {
	pat="^("$1")$"
	if (match(ip, pat) && usr==$2) {
		print $3
	}
}
' | head -n 1)
echo $pw