#!/bin/bash

cd `dirname $0`

function usage
{
    cat << EOF
usage: $0 part_name
EOF
}

if [[ $# -lt 1 ]];then
    usage
    exit 0
fi

partname=$1

if [ ! -d $partname ];then
    mkdir $partname
fi

cp part_template.sh $partname/part.sh
sed -i 's/__PART_NAME__/'$partname'/g' $partname/part.sh