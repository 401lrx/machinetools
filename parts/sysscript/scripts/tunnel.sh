#!/bin/bash

function usage()
{
    echo "$0 forward local_ip local_port remote_ip remote_port proxy_server [mysql|http|https]"
    echo "$0 reverse local_ip local_port remote_ip remote_port proxy_server [netstat]"
    echo "$0 proxy local_ip local_port proxy_server [netstat|http url]"
    exit -1
}

tunnel_type=$1
if [[ $tunnel_type == "forward" || $tunnel_type == "reverse" ]]; then
  if [[ $# < 6 ]]; then
    usage
  fi
  local_ip=$2
  local_port=$3
  remote_ip=$4
  remote_port=$5
  proxy_server=$6
  checker=$7
elif [[ $tunnel_type == "proxy" ]]; then
  if [[ $# < 4 ]]; then
    usage
  fi
  local_ip=$2
  local_port=$3
  proxy_server=$4
  checker=$5
  checker_param1=$6
  if [[ $checker == "http" && $# < 6 ]]; then
    usage
  fi
else
  usage
fi

MYSQL=/usr/local/mysql/bin/mysql
if [[ ! -f $MYSQL ]]; then MYSQL=/usr/bin/mysql; fi

if [[ $tunnel_type == "forward" ]]; then
  cmd="ssh -f -N -L $local_ip:$local_port:$remote_ip:$remote_port $proxy_server"
  checkcmd=""
  if [[ $checker == "mysql" ]]; then
    checkcmd="echo 'SHOW DATABASES' | MYSQL_PWD=mttd2014 $MYSQL --connect_timeout=15 -h $local_ip -P $local_port -umttd | grep mysql"
  elif [[ $checker == "mobamysql" ]]; then
    checkcmd="echo 'SHOW DATABASES' | MYSQL_PWD=moba2016 $MYSQL --connect_timeout=15 -h $local_ip -P $local_port -umoba | grep mysql"
  elif [[ $checker == "http" ]]; then
    checkcmd="curl -m 15 -I -H 'Host:' http://$local_ip:$local_port 2> /dev/null | sed '1!d' | grep '^HTTP/'"
  elif [[ $checker == "https" ]]; then
    checkcmd="timeout 15 openssl s_client -connect $local_ip:$local_port -showcerts < /dev/null 2>/dev/null | grep -- '-----BEGIN CERTIFICATE-----'"
  fi
elif [[ $tunnel_type == "reverse" ]]; then
  cmd="ssh -f -N -R $remote_ip:$remote_port:$local_ip:$local_port $proxy_server"
  checkcmd=""
  if [[ $checker == "netstat" ]]; then
    checkcmd="ssh -o ConnectTimeout=15 $proxy_server netstat -nlt | grep ' $remote_ip:$remote_port '"
  fi
elif [[ $tunnel_type == "proxy" ]]; then
  cmd="ssh -f -N -D $local_ip:$local_port $proxy_server"
  checkcmd=""
  if [[ $checker == "netstat" ]]; then
    checkcmd="netstat -nlt | grep ' $local_ip:$local_port '"
  elif [[ $checker == "http" ]]; then
    checkcmd="curl -m 15 --socks5 $local_ip:$local_port -I '$checker_param1' 2> /dev/null | sed '1!d' | grep '^HTTP/'"
  fi
else
  usage
fi

pid=$(pgrep -f -x "$cmd")
if [[ $pid == "" || ( $checkcmd != "" && $(eval $checkcmd | wc -l) == 0 ) ]]; then
  if [[ $pid != "" ]]; then
    echo "kill at $(date +'%Y-%m-%d %H:%M:%S'), pid: $pid"
    kill -9 $pid
  fi

  echo "start at $(date +'%Y-%m-%d %H:%M:%S')"
  $cmd
else
  echo "check fine. $(date +'%Y-%m-%d %H:%M:%S'), pid: $pid"
fi
