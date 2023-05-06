#! /bin/bash
source /etc/profile
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
        msg=$(cat << EOF
[!!! ATTENTION !!!] disk ${disk} may has error !
${disk} not healthy, pls check!!!
disk info:
`smartctl -i ${disk}`

disk health:
`smartctl -H ${disk}`

disk info2:
`smartctl -A ${disk}`

disk error:
`smartctl -l error ${disk}`
EOF
)
        echo $msg
        bash sysmail.sh "$msg" "Disk Smart Check Error"
    else
        echo "[healthy] disk ${disk} is healthy! !"
    fi
done
