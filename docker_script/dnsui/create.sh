#!/bin/bash

cd `dirname $0`

function usage()
{
	echo "$0 op"
    echo "      op=1: create file or dir only not exists."
    echo "      op=2: force create file or dir, replace the same one."
}

if [ $# -lt 1 ];then
	usage
	exit 1
fi

op=$1
chmod -R 777 ./createfile
if (( op == 1 ));then
    awk 'BEGIN {cmd="cp -rpi ./createfile/* ./ "; print "n" |cmd; }'
elif (( op == 2 ));then
    cp -rpf ./createfile/* ./
fi

curpath=`pwd`
docker run --detach \
        --net=host \
        --name dnsmasq-ui \
        --volume ${curpath}/dnsmasq.conf:/etc/dnsmasq.conf \
        --volume ${curpath}/resolv.conf:/etc/resolv.conf \
        --log-opt "max-size=1m" \
        -e "PORT=10880" \
        -e "HTTP_USER=admin" \
        -e "HTTP_PASS=19950127" \
        dnsmasq-ui:3.0