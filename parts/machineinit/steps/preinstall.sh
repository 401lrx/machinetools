#!/bin/bash
cd `dirname $0`

installlist=(
"vim"
"expect"
"rsync"
"gawk"
)

if [ $# -lt 1 ];then
    exit 1
fi

cmd=""
case $1 in
    centos)
        cmd=yum
        appendlist=(
            "epel-release"
        )
        installlist=("${installlist[@]}" "${appendlist[@]}")
    ;;
    pve|ubuntu)
        cmd=apt-get
    ;;
    *)
        exit 1
    ;;
esac

for software in "${installlist[@]}";do
    ${cmd} install -y "${software}"
done
