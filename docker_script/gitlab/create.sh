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
        --hostname git.home.com \
        --publish 7443:443 --publish 7080:80 --publish 7022:22 \
        --name gitlab --restart unless-stopped \
        --volume ${curpath}/config:/etc/gitlab \
        --volume ${curpath}/logs:/var/log/gitlab \
        --volume ${curpath}/data:/var/opt/gitlab \
        --privileged=true \
        gitlab/gitlab-ce:14.9.3-ce.0