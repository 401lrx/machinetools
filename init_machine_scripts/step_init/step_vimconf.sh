#!/bin/bash

cd `dirname $0`
source ../config.sh
source ../machine_func.sh

if [[ "${sys_env}" == "centos" ]];then
    if [ -f /etc/vimrc ];then
        cp /etc/vimrc /root/.vimrc
    fi
elif [[ "${sys_env}" == "pve" ]];then
    if [ -f /etc/vim/vimrc ];then
        cp /etc/vim/vimrc /root/.vimrc
    fi
fi

if [ -f /root/.vimrc ];then
    echoVimConf >> /root/.vimrc
fi
