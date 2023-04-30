#! /bin/bash
cd `dirname $0`

if [ $# -lt 1 ];then
    echo "$0 disk"
    echo "  example: $0 /dev/sdb"
    echo "  example: $0 /dev/sd[bc]"
    exit 1
fi

for disk in "$@";do
    smartresult=`smartctl -H ${disk} | sed -n "s/\(.\+\)\(result: \)\(.\+\)/\3/p"`
    if [[ "x${smartresult}" != "xPASSED" ]];then
        echo "[!!! ATTENTION !!!] disk ${disk} may has error !"
        echo "${disk} not healthy, pls check!!!
disk info:
`smartctl -i ${disk}`

disk health:
`smartctl -H ${disk}`

disk info2:
`smartctl -A ${disk}`

disk error:
`smartctl -l error ${disk}`"
    else
        echo "[healthy] disk ${disk} is healthy! !"
    fi
done
