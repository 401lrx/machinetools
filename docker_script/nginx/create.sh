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
        --publish 80:80 \
        --name nginx --restart unless-stopped \
        --link php-fpm:php \
        --volume ${curpath}/conf.d:/etc/nginx/conf.d \
        --volume ${curpath}/www:/usr/share/nginx/html \
        --volume ${curpath}/logs:/var/log/nginx \
        --volume ${curpath}/nginx.conf:/etc/nginx/nginx.conf \
        --privileged=true \
        nginx:1.21.6