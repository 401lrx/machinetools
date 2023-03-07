#!/bin/bash

source config.sh

function getInitStepList()
{	
	if [ $# -lt 1 ];then
		echo "getInitStepList return_step_array"
		exit 1
	fi

	local __retVal=$1
	if [ -z $__retVal ];then
		echo "return_init_step_array must be array"
		exit 1
	fi

	for path in `ls -f ${init_step_path} | grep -e "^step_*" | sort`;
	do
	        stepname=${path#step_}
	        stepname=${stepname%.*}
	        steps="${steps} ${stepname}"
	done

	eval $__retVal="'${steps}'"
	return 0
}

function listAllInitStep()
{
	getInitStepList steps

	i=1
	for step in ${steps[@]};do
	        echo ${i}: ${step}
	        i=`expr $i + 1`
	done
}

function getInitStepConfigFormat()
{
	getInitStepList steps
	for step in ${steps[@]};do
	        #echo \#$step
                echo $step
	done
}

function echoVimConf()
{
	echo '
set tabstop=4       " 一个tab等于多少空格,与set ts=4等效
"set cindent         " c缩进
"set autoindent      " 开启自动缩进
set softtabstop=4   " 当tabstop为8时,一次tab为4个空格,两次tab替换为tab,softtabstop为12时,一次tab为一个tab加4个空格 
set expandtab       " 编辑时可以将tab替换为空格
set shiftwidth=4    " 自动缩进时缩进为4格
set wildmenu        " 增强的命令补全,能显示所有的补全,而不是默认的直接为第一个,看不见其他的
syntax enable       " 打开语法高亮
'
}
