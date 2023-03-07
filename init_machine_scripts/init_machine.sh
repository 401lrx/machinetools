#!/bin/bash

cd `dirname $0`

function usage()
{
	echo "$0 init|list|listformat"
}


if [ $# -lt 1 ];then
	usage
	exit 1
fi

source config.sh
source machine_func.sh

if [[ "$script_path" != "`pwd`" ]];then
	echo "need put scripts dir in /root/"
	exit 1
fi

if [[ "x${sys_env}" == "x" ]];then
	echo "sys_env not configure, pls set sys_env config in config.sh"
	exit 1
fi

op=$1
if [[ $op == "init" ]];then
	if [[ $enable_init == 0 ]];then
		echo "init not enable, pls set enable_init config in config.sh"
		exit 1
	fi
elif [[ $op == "list" ]];then
	listAllInitStep
	exit 0
elif [[ $op == "listformat" ]];then
	getInitStepConfigFormat
	exit 0
else
	usage
	exit 1
fi

start_time=`date +%s`
echo "***************** begin init:`date '+%Y-%m-%d %H:%M:%S'` *****************"

chmod +x ${init_step_path}/*

echo "init steps:"
for step in ${init_step[@]};do
	echo $step
done
echo ""

for step in ${init_step[@]};do
	echo "******* init step:${step} *******"
	bash ${init_step_path}/step_${step}.sh
	echo "******* init done:${step} *******"
done

echo ""
end_time=`date +%s`
echo "***************** end init:`date '+%Y-%m-%d %H:%M:%S'` *****************"
echo "running time:"$((${end_time}-${start_time}))
