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
        --publish 15443:8443 \
        --name code-server --restart unless-stopped \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=Asia/Shanghai \
        -e PASSWORD=19950127 \
        -e SUDO_PASSWORD=19950127 \
        -e PROXY_DOMAIN=vscode.home.com \
        --volume ${curpath}/config:/config \
        --log-opt "max-size=1m" \
        linuxserver/code-server:4.4.0