#!/bin/bash

cd `dirname $0`

source /etc/profile

function usage()
{
	echo "$0 disk"
	echo "example: $0 /dev/sda"
}

if [ $# -lt 1 ];then
	usage
	exit 1
fi

disk=$1

diskstate=`hdparm -C ${disk} 2>&1 | grep " drive state is:  "  | sed 's/ drive state is:  //'`

if [[ "${diskstate}x" == "x" ]];then
    diskstate="not exists"
fi

echo "${disk} : ${diskstate}"
echo "${disk} : ${diskstate}" > diskstate

chmod +r diskstate
