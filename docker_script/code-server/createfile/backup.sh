#!/bin/bash

cd `dirname $0`

if [ ! -d backup ];then
    mkdir backup
    chmod 777 backup
fi

echo "no file need backup."