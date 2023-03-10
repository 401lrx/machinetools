#! /bin/bash

cd `dirname $0`

function usage
{
    echo "$0 disk"
    echo "  example: $0 /dev/sdb"
    echo "  example: $0 /dev/sd[bc]"
}

if [ $# -lt 1 ];then
    usage
    exit 1
fi

for disk in "$@";do
    smartresult=`smartctl -H ${disk} | sed -n "s/\(.\+\)\(result: \)\(.\+\)/\3/p"`
    if [[ "x${smartresult}" != "xPASSED" ]];then
        subject="[!!! ATTENTION !!!] disk ${disk} may has error !"
        msg="${disk} not healthy, pls check!!!
disk info:
`smartctl -i ${disk}`

disk health:
`smartctl -H ${disk}`

disk info2:
`smartctl -A ${disk}`

disk error:
`smartctl -l error ${disk}`"
        mysendmail send -t "1716318413@qq.com" -m "${msg}" -s "${subject}"
    fi
done
