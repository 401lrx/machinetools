#!/bin/bash

RED="\\E[5;33;41m"
GREEN="\\E[1;32m"
YELLOW="\\E[1;33m"
RESET="\\E[0m"
success() { [ $# -ge 1 ] && echo -e $GREEN"$@" $RESET; }
error() { [ $# -ge 1 ] && echo -e $RED"[ERROR] ""$@" $RESET; }
warning() { [ $# -ge 1 ] && echo -e $YELLOW"[WARNING] ""$@" $RESET; }
normalp() { [ $# -ge 1 ] && echo -e $RESET"$@"; }

function getostype
{
    # get from uname -a
    local osstr=`uname -a | tr 'A-Z' 'a-z'`
    if [[ $osstr =~ "centos" ]];then
        echo centos; return
    elif [[ $osstr =~ "pve" ]];then
        echo pve; return
    elif [[ $osstr =~ "ubuntu" ]];then
        echo ubuntu; return
    fi

    # get from /etc/redhat-release
    if [ -f /etc/redhat-release ];then
        osstr=`cat /etc/redhat-release | tr 'A-Z' 'a-z'`
        if [[ $osstr =~ "centos" ]];then
            echo centos; return
        fi
    fi

    # get from /etc/issue
    if [ -f /etc/issue ];then
        osstr=`cat /etc/issue | tr 'A-Z' 'a-z'`
        if [[ $osstr =~ "centos" ]];then
            echo centos; return
        elif [[ $osstr =~ "ubuntu" ]];then
            echo ubuntu; return 
        elif [[ $osstr =~ "pve" ]] || [[ $osstr =~ "proxmox" ]];then
            echo pve; return
        fi
    fi

    echo unknowos
}

function createRootDir
{
    if [ ! -d $MACHINE_INIT_PREFIX ]; then
        mkdir -p $MACHINE_INIT_PREFIX
        chmod 777 $MACHINE_INIT_PREFIX
    fi
}

function createPath
{
    # createPath path mode
    # only set final dir mode
    if [ $# -lt 1 ]; then 
        return
    fi
    createRootDir
    mkdir -p $MACHINE_INIT_PREFIX/$1
    if [ $# -gt 1 ]; then
        chmod $2 $MACHINE_INIT_PREFIX/$1
    fi
}
