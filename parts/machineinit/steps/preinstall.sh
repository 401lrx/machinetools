#!/bin/bash

cd `dirname $0`
source ../config.sh

installlist=(
"epel-release"
"vim"
"expect"
"rsync"
"gawk"
)

cmd=""
if [[ "${sys_env}" == "centos" ]]; then
    cmd=yum
elif [[ "${sys_env}" == "pve" ]]; then
    cmd=apt-get
else
    echo "[preinstall] can not deal sys_env:${sys_env}!!!"
    exit -1
fi

for software in "${installlist[@]}";do
    ${cmd} install -y "${software}"
done
