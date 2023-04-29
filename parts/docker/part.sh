#!/bin/bash
cd `dirname $0`
source ../partfunc.sh

partname=docker

function usage
{
    cat << EOF
cur part: $partname
usage: $0 op
    op [install|clean|help]
EOF
}

function _install
{
    ostype=$(getostype)
    case $ostype in
        centos|pve|ubuntu)
            #replace here ToDo something
            error "$ostype not support now"
        ;;
        *)
            error "$ostype not support now"
        ;;
    esac
}

function _clean
{
    ostype=$(getostype)
    case $ostype in
        centos|pve|ubuntu)
            #replace here ToDo something
            error "$ostype not support now"
        ;;
        *)
            error "$ostype not support now"
        ;;
    esac
}

if [[ $# -lt 1 ]];then
    usage
    exit 0
fi

op=$1
case $op in
    install)
        while true; do
            read -p "Do you wish to install ${partname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _install; break;;
                [Nn]* ) exit 100;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    clean)
        while true; do
            read -p "Do you wish to clean ${partname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _clean; break;;
                [Nn]* ) exit 100;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    help) usage;;
    *) error "Unknow op:" $op;;
esac
