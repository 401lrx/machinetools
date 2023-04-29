#!/bin/bash
cd `dirname $0`

function usage()
{
    echo "$0 ip user"
}

if [ $# -lt 2 ];then
    usage
    exit 1
fi

# 特殊密码
pw=$(echo '

' | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d; ' | awk -vip="$1" -vusr="$2" 'NF==3 && ip==$1 && usr==$2 {print $3} NF==4 && (ip==$1 || ip==$2) && usr==$3 {print $4}' | head -n 1 )

if [[ $pw == "" ]];then
  if [[ "$2" == "root" ]]; then
    pw=19950127
  elif [[ "$2" == "homecc" ]];then
    pw="homecc"
  fi
fi

echo $pw