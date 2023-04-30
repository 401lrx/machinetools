#!/bin/bash
cd `dirname $0`
source /etc/profile

if [ $# -lt 1 ];then
	echo "$0 disk"
	echo "example: $0 /dev/sda"
	exit 1
fi

disk=$1
diskstate=`hdparm -C ${disk} 2>&1 | grep " drive state is:  "  | sed 's/ drive state is:  //'`

if [[ "${diskstate}x" == "x" ]];then
    diskstate="unknow"
fi

echo $diskstate