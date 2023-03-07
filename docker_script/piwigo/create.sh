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
        --publish 14080:80 \
        --name piwigo --restart unless-stopped \
        --volume ${curpath}/conf:/config \
        --volume ${curpath}/gallery:/gallery \
        --volume ${curpath}/syncdir:/syncdir \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=Asia/Hong_Kong \
        linuxserver/piwigo:12.2.0

echo "pls wait 10s ...."
sleep 10s
docker exec -it piwigo "mv /gallery/galleries/* /syncdir/"
docker exec -it piwigo "rm -rf /gallery/galleries"
docker exec -it piwigo "ln -s /syncdir /gallery/galleries"
