#!/bin/bash
cd `dirname $0`
source ../partfunc.sh

partname=sysscript

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
    # install init.d
    ostype=$(getostype)
    case $ostype in
        centos)
            mystfile=/etc/rc.d/init.d/mystartstop.sh
            mkdir -p "$(dirname "$mystfile")"
            touch "$mystfile"
            chmod 755 $mystfile
            cat > $mystfile << EOFMYSTARTSTOP
#!/bin/bash
#chkconfig: 2345 99 1
#description: mystartup script

if [ \$# -lt 1 ]; then echo "\$0 start|stop"; exit 0; fi

op=\$1

case "\$op" in
    "start" )
        bash /work/system/sysscript/mystart.sh
        ;;
    "stop" )
        bash /work/system/sysscript/mystop.sh
        ;;
esac
EOFMYSTARTSTOP
		chkconfig --add $mystfile
		chkconfig $(basename ${mystfile}) on
        ;;
        pve|ubuntu)
            error "$ostype not support mystartstop script now"
        ;;
    esac

    # install /work/system/sysscript
    mkdir -p /work/system/sysscript
    cp -R scripts/* /work/system/sysscript/
    chmod 777 /work
    chmod -R 700 /work/system
}

function _clean
{
    # clean init.d
    ostype=$(getostype)
    case $ostype in
        centos)
            mystfile=/etc/rc.d/init.d/mystartstop.sh
            rm -rf $mystfile
        ;;
        pve|ubuntu)
            error "$ostype not support mystartstop script now"
        ;;
    esac

    # clean /work/system/sysscript
    rm -rf /work/system/sysscript
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
                [Nn]* ) exit 1;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    clean)
        while true; do
            read -p "Do you wish to clean ${partname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _clean; break;;
                [Nn]* ) exit 1;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    help) usage;;
    *) error "Unknow op:" $op;;
esac
