#!/bin/bash

cd `dirname $0`

function usage()
{
	echo "$0 op [nginxwww]"
    echo "example: $0 1 /work/docker/nginx/www"
    echo "      op=1: create file or dir only not exists."
    echo "      op=2: force create file or dir, replace the same one."
    echo "      nginxwww: nginx www dir path, default: /work/docker/nginx/www"
}

if [ $# -lt 1 ];then
	usage
	exit 1
fi

op=$1
nginxpath=/work/docker/nginx/www
if [ $# -ge 2 ];then
    nginxpath=$2
    if [ ! -d ${nginxpath} ];then
        echo "nginx www dir: ${nginxpath} not exists! pls check"
        usage
        exit 1
    fi
fi

chmod -R 777 ./createfile
if (( op == 1 ));then
    awk 'BEGIN {cmd="cp -rpi ./createfile/* ./ "; print "n" |cmd; }'
elif (( op == 2 ));then
    cp -rpf ./createfile/* ./
fi

docker run --detach \
        --publish 9000:9000 \
        --name php-fpm --restart unless-stopped \
        --volume ${nginxpath}:/var/www/html \
        php:7.2-fpm