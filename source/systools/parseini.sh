#!/bin/bash
#cd `dirname $0`

function usage
{
    cat << EOF
Usage: $0 [op] file [section] [var]
op:
  check                  Check syntax of ini file
  section                Get all sections name
  section [section]      Get all config of specific section
  var [section] [var]    Get value of specific section var
EOF
}

function check_ini_syntax()
{
    if [ ! -f $1 ];then
        echo "[error] file not exists."
        exit 1
    fi

    linenum=0
    while read oline || [[ -n ${line} ]];do
        linenum=$(( $linenum + 1 ))
        # 去除注释
        line=${oline%%#*}
        # 去除左右空格
        line=$(echo $line)
        # 跳过空行
        if [ "x" == "x${line}" ]; then continue; fi
        # 判断类型
        beginc=${line:0:1}
        case $beginc in
            "[")
                if [[ ! "$line" =~ ^\[[[:alnum:]]+\]$ ]];then
                    echo "[error] line $linenum: $oline"
                    echo "[info] Section name must only consist of numbers and letters, without spaces."
                    exit 1
                fi
            ;;
            *)
                if [[ ! "$line" =~ ^[[:alnum:]_]+\=.*$ ]];then
                    echo "[error] line $linenum: $oline"
                    echo "[info] There should be no spaces around the equal sign. Variable names contain only alphanumeric characters and underscores."
                    exit 1
                fi
            ;;
        esac
    done < $1
}

function get_all_section
{
    while read oline || [[ -n ${line} ]];do
        # 去除注释
        line=${oline%%#*}
        # 去除左右空格
        line=$(echo $line)
        # 跳过空行以及非段名定义的行
        if [ "x" == "x${line}" ] || [[ $line =~ ^[[:alnum:]_]+\=.*$ ]]; then continue; fi

        echo $line | awk -F '[][]' '{print $2 }'
    done < $1
}

function get_section_all_var
{
    insection=0
    while read oline || [[ -n ${line} ]];do
        # 去除注释
        line=${oline%%#*}
        # 去除左右空格
        line=$(echo $line)
        # 跳过空行
        if [ "x" == "x${line}" ]; then continue; fi

        # 在段内，碰到下一个段名，返回
        if [ $insection -eq 1 ] && [[ $line =~ ^\[[[:alnum:]]+\]$ ]]; then return; fi
        # 不在段内，直到找到需要的段名
        if [ $insection -eq 0 ] && [[ "$line" != "[$2]" ]]; then continue; fi
        # 进入段内，设置flag，跳过段名行
        if [ $insection -eq 0 ]; then insection=1; continue; fi
        echo $line | awk -F= '{print $1 " " $2}'
    done < $1
}

function get_section_var
{
    insection=0
    while read oline || [[ -n ${line} ]];do
        # 去除注释
        line=${oline%%#*}
        # 去除左右空格
        line=$(echo $line)
        # 跳过空行
        if [ "x" == "x${line}" ]; then continue; fi

        # 在段内，碰到下一个段名，返回
        if [ $insection -eq 1 ] && [[ $line =~ ^\[[[:alnum:]]+\]$ ]]; then return; fi
        # 不在段内，直到找到需要的段名
        if [ $insection -eq 0 ] && [[ "$line" != "[$2]" ]]; then continue; fi
        # 进入段内，设置flag，跳过段名行
        if [ $insection -eq 0 ]; then insection=1; continue; fi
        echo $line | awk -F= '$1=="'$3'" {print $2}'
    done < $1

}

if [ $# -lt 2 ];then 
    usage
    exit 1
fi
op=$1
file=$2
case $op in
    check)
        check_ini_syntax $file
    ;;
    section)
        if [ $# -ge 3 ];then
            get_section_all_var $file $3
        else
            get_all_section $file
        fi
    ;;
    var)
        if [ $# -lt 4 ];then
            usage
            exit 1
        else
            get_section_var $file $3 $4
        fi
    ;;
    *)
        usage
    ;;
esac	