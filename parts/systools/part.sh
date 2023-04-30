#!/bin/bash
cd `dirname $0`
source ../partfunc.sh

partname=systools
tools_path=tools
install_path=$tools_path/systools
config_path=config
config_install_path=$config_path/template

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
        bash $MACHINE_INIT_PREFIX/$install_path/mystart.sh
        ;;
    "stop" )
        bash $MACHINE_INIT_PREFIX/$install_path/mystop.sh
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

    # install prefix/tools/systools
    createPath $tools_path 777
    createPath $install_path 755
    yes 2>/dev/null | cp -Rf $MACHINE_INIT_WORK_DIR/source/systools/* $MACHINE_INIT_PREFIX/$install_path/
    chmod -R 755 $MACHINE_INIT_PREFIX/$install_path

    # install prefix/config/template
    createPath $config_path 777
    createPath $config_install_path 755
    yes 2>/dev/null | cp -Rf $MACHINE_INIT_WORK_DIR/source/configtemplate/* $MACHINE_INIT_PREFIX/$config_install_path/
    chmod -R 644 $MACHINE_INIT_PREFIX/$config_install_path/*
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

    # delete prefix/tools/systools
    rm -rf $MACHINE_INIT_PREFIX/$install_path
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
