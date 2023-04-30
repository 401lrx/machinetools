#!/bin/sh
hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
wslip=$(hostname -I | awk '{print $1}')
port=7890
PROXY_HTTP="http://${hostip}:${port}"
PROXY_SOCKS5="socks5://${hostip}:${port}"

test_proxy() {
    resp=$(curl -I -s --connect-timeout 5 -m 5 -w "%{http_code}" -o /dev/null www.google.com)
    if [ ${resp} = 200 ]; then
        echo "Proxy setup succeeded!"
    else
        echo "Proxy setup failed!"
    fi
}

set_proxy() {
    export http_proxy="${PROXY_HTTP}"
    export HTTP_PROXY="${PROXY_HTTP}"
    export https_proxy="${PROXY_HTTP}"
    export HTTPS_proxy="${PROXY_HTTP}"
    export all_proxy="${PROXY_SOCKS5}"
    export ALL_PROXY="${PROXY_SOCKS5}"
    git config --global http.proxy "${PROXY_HTTP}"
    git config --global https.proxy "${PROXY_HTTP}"

    echo "Proxy has been opened."
    test_proxy
}

unset_proxy() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset all_proxy
    unset ALL_PROXY
    git config --global --unset http.proxy
    git config --global --unset https.proxy

    echo "Proxy has been closed."
}

show_proxy() {
    echo "Host ip:" ${hostip}
    echo "WSL ip:" ${wslip}
    echo "Current proxy:" $https_proxy
}

usage() {
    echo "usage:  proxy set|unset|show|test"
}


if [ $# -lt 1 ];then
    usage
    return
fi
case $1 in
    set) set_proxy ;;
    unset) unset_proxy ;;
    show) show_proxy ;;
    test) test_proxy ;;
    *) usage ;;
esac
