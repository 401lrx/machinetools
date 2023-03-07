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

if [[ "$2" == "root" ]]; then
  # root的密码管理，格式：ip 密码
  pw=$(echo '
  192.168.5.233 19950127

  ' | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d; ' | awk -vip="$1" 'NF==2 && ip==$1{print $2} NF==3 && (ip==$1 || ip==$2){print $3}' | head -n 1 )

  echo $pw
else
  # 普通密码管理，格式：ip 用户 密码
  pw=$(echo '
  192.168.5.233 ruixiangliu 19950127lrx

  ' | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d; ' | awk -vip="$1" -vusr="$2" 'NF==3 && ip==$1 && usr==$2 {print $3} NF==4 && (ip==$1 || ip==$2) && usr==$3 {print $4}' | head -n 1 )

  echo $pw
fi

