#!/bin/bash

shopt -s extglob

alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -='cd -'
alias grep='grep --color'
alias grepr='grep --exclude-dir .svn --color -RIn'
alias l='ls -alFv --color=auto'
alias ll='ls -lv --color=auto'
alias ll.='ls -lv --color=auto -d .*'
alias lh='l -h'
alias rz='rz -b'
alias sz='sz -b'
alias df="df -h"
alias du="du -h"
alias cp="cp -v"
alias cpr="cp -vr"
alias mv="mv -v"
alias reload='source ~/.bashrc'
export PATH=$PATH:/usr/sbin:/data/mfw/bin

####################################################################

function showip()
{
	if [[ $1 != "" && $1 != "in" && $1 != "out" ]]; then
		echo "Usage: $FUNCNAME [in|out]" >&2
		return 1
	fi

	local ips=$(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'|grep -v 127.0.0.1)
	local showip=""
	if [[ $1 == "in" ]]; then
		showip=$(echo "$ips" | awk -F. '$1==10 || ($1==192 && $2==168) || ($1==172 && $2>=16 && $2<=31){print}')
	fi
	if [[ $1 == "out" || "x${showip}" == "x" ]]; then
		showip=$(echo "$ips" | awk -F. '!($1==10 || ($1==192 && $2==168) || ($1==172 && $2>=16 && $2<=31)){print}' )
		if [ -z "$showip" ];then
			showip=$(curl ipecho.net/plain)
		fi
	fi
	echo $showip | awk '{print $1}'
}

case $(whoami) in
	root)
		PS1='┌-[\[\033[1;31m\]\u\[\033[0m\]@'$(showip in | head -1)']-['$(date +"%H:%M:%S")']-[\w]\n└\[\033[1;31m\]$\[\033[0m\] '
	;;
	homecc)
		PS1='┌-[\[\033[1;32m\]\u\[\033[0m\]@'$(showip in | head -1)']-['$(date +"%H:%M:%S")']-[\w]\n└\[\033[1;32m\]$\[\033[0m\] '
	;;
	*)
		PS1='[\u@'"$(showip in | head -1)"':\w]\$ '
	;;
esac

function listargs()
{
	echo "args num: $#"
	local n=0
	for arg in "$@"; do
		echo "arg $((++n)): $arg"
	done
}

function isdigit()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME str [str ...]" >&2
		return 1
	fi

	local yes=1
	while [[ $# -gt 0 ]]; do
		if [[ ! "$1" =~ ^[[:digit:]]+$ ]]; then
			yes=0
			break
		fi
		shift
	done
	echo $yes
}

function isxdigit()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME str [str ...]" >&2
		return 1
	fi

	local yes=1
	while [[ $# -gt 0 ]]; do
		if [[ ! "$1" =~ ^[[:xdigit:]]+$ ]]; then
			yes=0
			break
		fi
		shift
	done
	echo $yes
}


function isinteger()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME str [str ...]" >&2
		return 1
	fi

	local yes=1
	while [[ $# -gt 0 ]]; do
		if [[ ! "$1" =~ ^-?[[:digit:]]+$ ]]; then
			yes=0
			break
		fi
		shift
	done
	echo $yes
}

function isset()
{
	if [[ $# -lt 2 ]]; then
		echo "Usage: $FUNCNAME with_empty var [var ...]" >&2
		return 1
	fi

	local with_empty=$1
	shift

	if [[ $with_empty == "1" ]]; then
		while [[ $# -gt 0 ]]; do
			if [[ ${!1+x} == "" ]]; then
				return 1
			fi
			shift
		done
	else
		while [[ $# -gt 0 ]]; do
			if [[ ${!1:+x} == "" ]]; then
				return 1
			fi
			shift
		done
	fi
	return 0
}

function timestr()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME timedesc [mofidification] [format]" >&2
		echo "    Example: $FUNCNAME 20150906 '1 day -1 sec'" >&2
		return 1
	fi

	local desc=$1
	local modify=$2
	local format=${3:-%Y-%m-%d %H:%M:%S}

	if [[ "$modify" == "" ]]; then
		date -d "$desc" +"$format"
	else
		local t=$(date -d "$desc")
		date -d "$t $modify" +"$format"
	fi
}

function timeseq()
{
	if [[ $# -lt 3 ]]; then
		echo "Usage: $FUNCNAME from to incr [time format]" >&2
		return 1
	fi

	local from=$(date -d "$1" +%s)
	local to=$(date -d "$2" +%s)
	local incr=$3
	local format=${4:-%Y-%m-%d %H:%M:%S}

	if [[ $from -eq $to ]]; then
		timestr "@$from" "" "$format"
		return 0
	fi

	local next=$(timestr "@$from" "$incr" "%s")
	if [[ $from -le $to ]]; then
		if [[ $next -le $from ]]; then
			echo "Error: $(timestr @$from) -> $(timestr @$to) with backward increment '$incr'"
			return 1
		fi

		for ((t = $from; t <= $to; t = $(timestr "@$t" "$incr" "%s") )); do
			timestr "@$t" "" "$format"
		done
	else
		if [[ $next -ge $from ]]; then
			echo "Error: $(timestr @$from) -> $(timestr @$to) with forward increment '$incr'"
			return 1
		fi

		for ((t = $from; t >= $to; t = $(timestr "@$t" "$incr" "%s") )); do
			timestr "@$t" "" "$format"
		done
	fi
}

function dateseq()
{
	if [[ $# -lt 2 ]]; then
		echo "Usage: $FUNCNAME from to [incr] [format]" >&2
		return 1
	fi

	local from=$(date -d "$1" +%Y%m%d)
	local to=$(date -d "$2" +%Y%m%d)
	local incr=$3
	local format=${4:-%Y%m%d}

	if [[ "$incr" == "" ]]; then
		if [[ $from -le $to ]]; then
			incr="1 day"
		else
			incr="-1 day"
		fi
	fi

	timeseq "$from" "$to" "$incr" "$format"
}

function ts()
{
	if [[ $# -eq 0 ]]; then
		set -- now
	fi
	if [[ $1 == '-h' ]]; then
		echo "Usage: $FUNCNAME timedesc|timestamp ..." >&2
		return 1
	fi

	local in
	local out
	while [[ $# -ne 0 ]]; do
		in=$1
		shift

		if [[ $(echo "$in" | sed '/^ *[0-9][0-9]* *$/!d' | wc -l) -eq 1 ]]; then
			in=$(echo "$in" | sed 's/ //g')
			if [[ ${#in} -le 10 ]]; then
				out=$(date +'%Y-%m-%d %H:%M:%S' -d "@$in")
			else
				local mill=${in:$((${#in} - 3))}
				local sec=${in:0:$((${#in} - 3))}
				out=$(date +'%Y-%m-%d %H:%M:%S'.$mill -d "@$sec");
			fi
		else
			out=$(date +'%Y-%m-%d %H:%M:%S' -d "$in")" => "$(date +%s -d "$in")
		fi

		echo "$in => $out"
	done
}


function joinstr()
{
	if [[ $# -lt 1 ]]; then 
		echo "Usage: $FUNCNAME delim [str]..." >&2
		return 1
	fi   
	
	local delim=$1
	shift
	
	local n=0
	local res=''
	while [[ $# -gt 0 ]]; do
		if [[ $((++n)) -ne 1 ]]; then 
			res="$res$delim"
		fi   
		res="$res$1"
		shift
	done 
	echo "$res"
}


function get_process_parents()
{
	local pid ppid
	while [[ $# -gt 0 ]]; do
		pid=$1
		shift

		while [[ $pid -ne 0 ]]; do
			ppid=$(ps -o ppid= -p $pid)
			if [[ $ppid -ne 0 ]]; then
				echo $ppid
			fi
			pid=$ppid
		done
	done
}


function get_process_childs()
{
	local pid ppid
	while [[ $# -gt 0 ]]; do
		ppid=$1
		shift

		if [[ $ppid -ne 0 ]]; then
			for pid in $(ps -o pid= --ppid $ppid); do
				echo $pid
				get_process_childs $pid
			done
		fi
	done
}

function get_process_tree()
{
	local pid
	while [[ $# -gt 0 ]]; do
		pid=$1
		shift

		get_process_childs $pid
		echo $pid
		get_process_parents $pid
	done
}

function pstreeex()
{
	local options="--forest --sort=start_time -o user,pid,ppid,lstart,etime,time,args"
	if [[ $# -eq 0 ]]; then 
		ps $options -e
	elif [[ $1 == '.' ]]; then 
		ps $options -u $(whoami)
	else 
		ps $options -p $(get_process_tree "$@")
	fi   
}

function psex()
{
	local options="--sort=start_time -o user,pid,ppid,lstart,etime,time,args"
	if [[ $# -eq 0 ]]; then
		ps $options -e
	elif [[ $1 == '.' ]]; then
		ps $options -u $(whoami)
	else
		ps $options "$@"
	fi
}

#######################################################################################################


# SSH_GETPWD未设置时初始化(如果已经设置为空就不处理)
# 当BASH_SOURCE设置且不为空，设置SSH_GETPWD为相同目录下的脚本
if [[ ${SSH_GETPWD+x} == "" && ${BASH_SOURCE[0]:+x} != "" && -x $(dirname ${BASH_SOURCE[0]})/ssh_getpwd.sh ]]; then
	export SSH_GETPWD=$(dirname $(readlink -f ${BASH_SOURCE[0]}))/ssh_getpwd.sh
fi

# 当BASH_SOURCE设置且不为空，设置TOOLS_CONFIG位置
if [[ ${TOOLS_CONFIG+x} == "" && ${BASH_SOURCE[0]:+x} != "" && -f $(dirname ${BASH_SOURCE[0]})/toolsconfig.txt ]]; then
	#BASH_SOURCE[0] 当前脚本的名称
	#readlink -f /data/ 获取目录的绝对地址，如果是软链，返回链接对象的绝对地址
	export TOOLS_CONFIG=$(dirname $(readlink -f ${BASH_SOURCE[0]}))/toolsconfig.txt
fi

# BASH_SOURCE设置且不为空，从本地读取文件内容
if [[ ${BASH_SOURCE[0]:+x} != "" ]]; then
	function get_toolsfunc_content()
	{
		cat ${BASH_SOURCE[0]} 2>/dev/null
	}
	function get_sshgetpwd_content()
	{
		cat "$SSH_GETPWD" 2>/dev/null
	}
	function get_toolsconfig_content()
	{
		cat "$TOOLS_CONFIG" 2>/dev/null
	}
fi

function getconfig()
{       
		echo "$@" | awk -venv="$SELECTED_ENV" '
		ARGIND==1 {
				count = NF;
				matching = 0;
				find = 0;
				for (i = 1; i <= NF; ++i)
						param[i] = $i;
		}
		ARGIND==2 && $0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ {
				if ($0 !~ /^[[:space:]]*--/) {
						if (!matching) {
								if (find) {
										exit 0;
								}
								matching = 1;
								find = 0;
						}
						
						if (!find && NF == count) {
								find = 1;
								for (i = 1; i <= count; ++i) {
										pat = "^("$i")$"
										if (!match(param[i], pat)) {
												find = 0;
												break;
										}
								}
						}
				} else {
						matching = 0;
						
						if (find) {
								op = gensub(/^[[:space:]]*--/, "", "g", $1);
								if (op ~ /^[a-zA-Z0-9_]+$/) {
										print gensub(/^[[:space:]]*--/, "", "g", $0);
								} else if (match(op, "^[a-zA-Z0-9_]+\\["env"\\]$")) {
										print gensub(/^[[:space:]]*--([^[]+)[^[:space:]]+/, "\\1", "g", $0);
								}
						}
				}
		} 
		' - <(get_toolsconfig_content)
}

function getconfig_item()
{
		if [[ $# -lt 3 ]]; then
				echo "Usage: getconfig_item type replace params..."
				return 1
		fi

		local type=$1
		local replace=$2
		shift 2

		if [[ $replace == "" ]]; then
				getconfig "$@" | awk -vtype="$type" '$1 == type {pat="^"type"[[:space:]]*"; print gensub(pat, "", 1)}'
		else
				getconfig "$@" | awk -vtype="$type" -vreplace="$replace" '$1 == type {pat="^"type; print gensub(pat, replace, 1)}'
		fi
}

function getconfig_item_rec()
{
		if [[ $# -lt 3 ]]; then
				echo "Usage: getconfig_item_rec type replace params..."
				return 1
		fi

		local num=$(($# - 2))
		local result=
		while [[ $num -gt 0 ]]; do
				result=$(getconfig_item "$1" "$2" "${@:3:$num}")
				if [[ $result != "" ]]; then
						echo "$result"
						break
				fi
				num=$((num - 1))
		done
}

function listconfig()
{
		if [[ $# -eq 0 ]]; then 
				get_toolsconfig_content | awk '$0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*--/{print}'
		else 
				get_toolsconfig_content | tac | awk '
				ARGIND==1{
						for (i = 1; i <= NF; ++i)
								types[$i] = 1;
						find = 0;
						matching = 0;
				}
				ARGIND==2 && $0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ {
						if ($0 ~ /^[[:space:]]*--/) {
								if (!matching) {
										matching = 1;
										find = 0;
								}
								
								op = gensub(/^[[:space:]]*--/, "", "g", $1);
								if (!find && (op in types)) {
										find = 1;
								}
						} else {
								matching = 0;
								if (find) {
										print;
								}
						}
				}' <(echo "$@") - | tac
		fi   
}

function getpath()
{
	if [[ $# -lt 1 ]]; then 
		echo "Usage: $FUNCNAME params..." >&2
		return 1
	fi   

		local cmd=$(getconfig_item_rec setpath echo "$@")
		eval "$cmd"
}

function cdex()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME params..."
		listconfig setpath | cat -n
		return 1
	fi

	local path=$(getpath "$@")
	if [[ $path != '' ]]; then
		cd "$path"
	else
		cd "$@"
	fi
}

function c() { cdex "$@"; }

function getcmd()
{
		if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME params..." >&2
		return 1
	fi

		getconfig_item_rec setcmd '' "$@"
}

function select_env()
{
		local setcmd=$(getcmd ":env-$1:")
		if [[ $setcmd != "" ]]; then
				eval "$setcmd"
				export SELECTED_ENV=$1
		else
				local opts=$(echo $(listconfig | sed -n '/^:env-.*:$/s/:env-\([^:]*\).*/\1/gp') | tr ' ' '|')
				echo "Usage: $FUNCNAME $opts   (current env: $SELECTED_ENV)" >&2
		return 1
		fi
}

function getip()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME params..." >&2
		return 1
	fi

		if [[ $1 =~ ^[0-9]+.[0-9]+.[0-9]+.[0-9]+$ ]]; then
				echo $1
				return 0
		fi

		local cmd=$(getconfig_item_rec setip echo "$@")
	eval "$cmd"
}

function get_ssh_port()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME params..." >&2
		return 1
	fi
	
	local cmd=$(getconfig_item_rec setsshport echo "$@")
	eval "$cmd"
}

function get_ssh_usr()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME params..." >&2
		return 1
	fi

	local cmd=$(getconfig_item_rec setsshusr echo "$@")
	eval "$cmd"
}

function get_expect_commproc()
{
	local proc=$(cat <<'EOF'
# expect用openpty与spawn出来的进程通信
# pty的一个特性是如果slave关闭了，master会读到-1
# expect使用的tcl库内部对pty读取做了一个缓存，大小为4096，读取时先使用缓存，不足再从pty读取(DoReadChars)
# 结合pty的特性和tcl的缓存，如果expect用掉了tcl的缓存并且还不够，tcl再去读pty时就返回-1，即eof，导致数据丢失(Tcl_ReadChars,DoReadChars,GetInput,ChanRead,ExpInputProc)
# 解决方法时每次都让expect读光tcl的缓存，即读取的大小至少大于tcl缓存，保证读到-1时数据已经被消耗光
# 根据expect算法(match_max * 3 + 1大小每次移除1/3 * use)，最少也要设置为4095(expAdjust, exp_buffer_shuffle)
# 正好pty内核的设置N_TTY_BUF_SIZE=4096，每次read pty最多只返回4095个字节数据，而tcl库对读取会有一次block处理，导致每次返回给expect最多4095字节(ChanRead)
match_max -d 16384;

trap {
		 set rows [stty rows]
		 set cols [stty columns]
		 stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

proc getenv { name } {
	if { [info exists ::env($name) ] } {
		return $::env($name);
	};
	return "";
};

proc setenv { name value } {
	set ::env($name) $value;
};

proc feedpasswd { user host {script ""} } {
	set password "";
	#if { [getenv SSH_GETPWD_FROM_INPUT] != "1" } {
	#   puts "\n[exp_pid] req pwd from level [getenv TOOLSFUNC_LEVEL]";
	#} else {
	#   puts "\n[exp_pid] req pwd from level [getenv TOOLSFUNC_LEVEL], redirect to up level";
	#}; 
	if { [getenv SSH_GETPWD_FROM_INPUT] != "1" } {
		if { $password=="" && [info exists ::env(SSH_GETPWD)] && $::env(SSH_GETPWD)!="" } {
			set password [exec $::env(SSH_GETPWD) $host $user];
		} elseif { $password=="" && $script != "" } {
			set password [exec /bin/bash "$script" $host $user];
		};
		if { $password=="" && [info exists ::env(SSH_PWD)] && $::env(SSH_PWD)!="" } {
			set password $::env(SSH_PWD);
		};
	};
	if { $password=="" } {
		stty -echo;
		expect_user -re "(.*)\n";
		stty echo;
		set password $expect_out(1,string);
	};

	#puts "[exp_pid] rsp pwd $password from level [getenv TOOLSFUNC_LEVEL]";
	send -- "$password\n";
};

proc checkret {} {
	set ret [wait];
	set sysret [lindex $ret 2];
	set progret [lindex $ret 3];
	if {$sysret == 0 && $progret == 0} then {
		exit 0;
	} else {
		exit -1;
	}
};
EOF
)
	echo "$proc"
}

function tidyport
{
	local portc=""
	case $1 in
			ssh) portc="-p" ;;
			scp) portc="-P" ;;
			*)
					echo "$@"
					return 1
			;;
	esac
	shift
	local finaloption=""
	local port=0
	while [[ $# -gt 0 ]]; do
			if [[ $1 == $portc ]];then
					port=$2
					shift 2
			else
					finaloption="$finaloption $1"
					shift 1
			fi
	done
	if (( port != 0 ));then
			echo $finaloption $portc $port
	else
			echo $finaloption
	fi
}

function scpex()
{
	if [[ $# -lt 2 ]]; then
		echo "Usage: $FUNCNAME from ... to [scp options]"
		echo "    Example: $FUNCNAME testfile 192.168.30.63:/data"
		echo "             $FUNCNAME -o otherconfig testfile 192.168.30.63:/data"
		echo "             $FUNCNAME -o otherconfig testfile 192.168.30.63:/data -o otherconfig2"
		echo "       set SSH_GETPWD=script for password provider" >&2
		echo "       set SSH_PWD=password for default password" >&2
		return
	fi

	# rearrange parameter order, put from and to at the end
	local n=$#
	local idx=0
	local num=0
	while (( n > 0 )); do
		if [[ ${!n:0:1} == '-' ]]; then
			idx=$n
			num=0
		else
			if (( ++num >= 2 )); then
				break
			fi
		fi
		: $((--n))
	done

	local args=()
	local fromto=()
	if [[ $idx -ne 0 ]]; then
		args=($SCP_OPT "${@:$idx}" "${@:1:$((idx-3))}")
		fromto=("${@:$((idx-2)):2}")
	else
		args=($SCP_OPT "${@:1:$(($#-2))}")
		fromto=("${@:$(($#-1))}")
	fi
	local scpoption=($(tidyport scp "${args[@]}") ${fromto[@]})

	local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set arguments [lrange $argv 1 end];

set stty_init raw;
set timeout 86400;
spawn -noecho /usr/bin/scp -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" {*}$arguments;
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
	-exact "Are you sure you want to continue connecting (yes/no)" {
		send "yes\n"; 
		exp_continue;
	};
	-re {([a-zA-Z0-9]*)@(.*)'.*assword:} {#'这里只是为了脚本显示注释一个单引号
		feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
		exp_continue; 
	};
	eof {};
}
checkret;
EOF
)
	/usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "${scpoption[@]}"
}

function putfile()
{
		if [[ $# -lt 2 ]]; then
				echo "Usage: $FUNCNAME file [user@]host(or serverconfig):[path] [scp options]"
				echo "    Example: $FUNCNAME testfile server:/work"
				echo "             $FUNCNAME testfile 192.168.1.2:/work"
				echo "             $FUNCNAME testfile user@192.168.1.2:/work"
				return 1
		fi

		file=$1
		shift

		if [[ ! $1 =~ .*:.* ]]; then
				echo "remote file format error"
				return 1
		fi

		local svr=${1%%:*}
		local path=${1#*:}

		local usr=""
		if [[ $svr =~ .*@.* ]]; then
				usr=${svr%%@*}
				svr=${svr#*@}
		fi
		shift

		local dstip=$(getip $svr)
		if [[ $usr == "" ]];then
			usr=$(get_ssh_usr $svr)
		fi
		if [[ $usr == "" ]];then
			usr=$SSH_DEFAULT_USER
		fi
		if [[ $usr != "" ]];then
			dstip="${usr}@${dstip}"
		fi

		local scpoption="$@"
		local scpport=$(get_ssh_port $svr)
		if [[ $scpport != "" ]];then
				 scpoption=("-P $scpport" $scpoption )
		fi

		scpex $file $dstip:$path $scpoption
}

# TOOLSFUNC_LEVEL未设置或者为空，初始化为1
if [[ ${TOOLSFUNC_LEVEL:+x} == "" ]]; then
	export TOOLSFUNC_LEVEL=1
fi

function get_toolsfunc_curr_backtrace()
{
	echo "$(whoami)@$(showip in):$(pwd)"
}

function get_toolsfunc_export_script_base64()
{
	(
	echo "function get_toolsfunc_content() { echo '$(get_toolsfunc_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
	echo "function get_sshgetpwd_content() { echo '$(get_sshgetpwd_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
		echo "function get_toolsconfig_content() { echo '$(get_toolsconfig_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
	echo "export TOOLSFUNC_LEVEL=$((TOOLSFUNC_LEVEL + 1))"
	echo "export TOOLSFUNC_BACKTRACE=(${TOOLSFUNC_BACKTRACE[@]} '$(get_toolsfunc_curr_backtrace)')"
	if [[ ${SSH_PWD+x} != "" ]]; then
		echo "export SSH_PWD='$SSH_PWD'"
	fi
	cat <<'EOF'
eval "$(get_toolsfunc_content)"
unset TOOLSFUNC_IMPORT_SCRIPT
[[ $(history | wc -l) -gt 0 ]] && history -d $(( $(history | tail -1 | awk '{print $1}') ))
EOF
	) | gzip -c | base64
}

function get_toolsfunc_export_script()
{
	cat <<EOF
export TOOLSFUNC_IMPORT_SCRIPT='eval "\$(echo "$(get_toolsfunc_export_script_base64)" | base64 -d | gzip -dc )"'
EOF
}

function get_toolsfunc_import_script()
{
	cat <<EOF
eval "\$TOOLSFUNC_IMPORT_SCRIPT"
EOF
}

function suex()
{   
	if [[ $1 == "-h" ]]; then
		echo "Usage: $FUNCNAME [user]"
		echo "       set SSH_GETPWD=script for password provider" >&2
		echo "       set SSH_PWD=password for default password" >&2
		return
	fi
	
	local user=$1
	if [[ $user == "" ]]; then
		user=root
	fi
	
	local ip=$(showip in | head -n 1)
	local command="unset SSH_GETPWD; unset SSH_PWD; $(get_toolsfunc_import_script); echo current toolsfunc shell level: \$TOOLSFUNC_LEVEL;"
	
	local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set user [lindex $argv 1];
set ip [lindex $argv 2];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];

set timeout 86400
spawn -noecho /bin/su $user
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
	-exact "Password:" {
		feedpasswd $user $ip $getpwdscript;
		exp_continue;
	};
	"@" {
		if {$command != ""} {
			send $command; 
			send "\n";
		}
		interact;
	};
}
puts "current toolsfunc shell level: [getenv TOOLSFUNC_LEVEL]";
checkret;
EOF
)
	(
	eval "$(get_toolsfunc_export_script)"
	TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$user" "$ip"
	)
}

#######################################################################################

function shellbt()
{
	local n=0;
	for bt in "${TOOLSFUNC_BACKTRACE[@]}"; do
		printf "  %2d: %s\n" $((++n)) "$bt"
	done
	printf "* %2d: %s\n" $((++n)) "$(get_toolsfunc_curr_backtrace)"
}

function shellex()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME host [command] [ssh options]" >&2
		echo "       set SSH_GETPWD=script for password provider" >&2
		echo "       set SSH_PWD=password for default password" >&2
		echo "   Example: $FUNCNAME 192.168.5.233"
		echo "            $FUNCNAME moonton@192.168.5.233"
		echo "            $FUNCNAME dev"
		return 1
	fi

	local svr=$1
	local usr=""
	if [[ $svr =~ .*@.* ]]; then
		usr=${svr%%@*}
		svr=${svr#*@}
	fi

	if [[ $usr == "" ]];then
		usr=$(get_ssh_usr $svr)
	fi
	if [[ $usr == "" ]];then
		usr=$SSH_DEFAULT_USER
	fi

	local host=$(getip $svr)
	if [[ $usr != "" ]];then
		host="${usr}@${host}"
	fi
	
	local initcmd="$(get_toolsfunc_export_script); exec -la bash bash -l; "
	local command="$(get_toolsfunc_import_script); echo current toolsfunc shell level: \$TOOLSFUNC_LEVEL;"
	if [[ $# -gt 1 && ${2:0:1} != "-" ]]; then
		command="$command$2"
		shift 2
	else
		shift 1
	fi

	# $SSH_OPT config $@
	local sshoption=($SSH_OPT)
	local sshport=$(get_ssh_port $svr)
	if [[ $sshport != "" ]];then
		 sshoption=(${sshoption[@]} "-p $sshport" )
	fi
	sshoption=($(tidyport ssh "${sshoption[@]}" "$@"))

	local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set host [lindex $argv 1];
set arguments [lrange $argv 2 end];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];
set initcmd [getenv TOOLSFUNC_EXPECTENV_INIT_CMD];

set timeout 86400;
spawn -noecho /usr/bin/ssh -t -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" -q {*}$arguments ${host} $initcmd
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
	-exact "Are you sure you want to continue connecting (yes/no)" {
		send "yes\n"; 
		exp_continue; 
	}
	-re {([a-zA-Z0-9]*)@(.*)'.*assword:} {#'这里只是为了脚本显示注释一个单引号
		feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
		exp_continue; 
	}
	"@" {
		if {$command != ""} {
			send $command; 
			send "\n";
		}
		interact;
	}
	eof {
		send_error "some error occurs, quit ssh ...\n";
	}
}
puts "current toolsfunc shell level: [getenv TOOLSFUNC_LEVEL]";
checkret;
EOF
)
	TOOLSFUNC_EXPECTENV_INIT_CMD="$initcmd" TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$host" "${sshoption[@]}"
	local ret=$?
	shellbt
	return $ret
}


function s() { shellex "$@"; }
function sbt() { shellbt "$@"; }

function enter_machine()
{
	if [[ $# -eq 0 ]]; then
		return 0
	fi

	local path=$(getpath "$@")
	local cmd=$(getcmd "$@")
	if [[ $path != "" ]]; then
		cd "$path"
	fi
	if [[ $cmd != "" ]]; then
		eval "$cmd"
	fi
}

function mygo()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: $FUNCNAME [[ssh options] --] user@host"
		listconfig setip | cat -n
		return 1
	fi

	local sshoption=()
	if [[ $1 == "-"* ]]; then
		while [[ $# -gt 0 ]]; do
			if [[ $1 != "--" ]]; then
				sshoption=("${sshoption[@]}" "$1")
				shift
			else
				shift
				break;
			fi
		done
	fi

	local svr=$1
	local user=""
	if [[ $svr =~ .*@.* ]]; then
		user=${svr%%@*}
		svr=${svr#*@}
	fi

	if [[ $user == "" ]];then
		user=$(get_ssh_usr $svr)
	fi
	if [[ $user == "" ]]; then
		user=$SSH_DEFAULT_USER
	fi

	local sshport=$(get_ssh_port $svr)
	if [[ $sshport != "" ]];then
		 sshoption=("-p $sshport" ${sshoption[@]})
	fi

	local ips=($(getip $svr))
	local goenv=$(getconfig_item setenv '' $svr)
	if [[ $goenv == "" ]]; then
		goenv=$SELECTED_ENV
	fi

	local cmd="select_env $goenv; enter_machine $svr"

	if [[ ${#ips[*]} -eq 0 ]]; then
		echo "no ip available: $svr" >&2
		return 1
	fi
	if [[ ${#ips[*]} -eq 1 ]]; then
		shellex $user@${ips[0]} "$cmd" "${sshoption[@]}"
		return $?
	fi

	echo "available ip list: "
	echo "${ips[@]}" | tr ' ' '\n' | cat -n

	local index=0
	until [[ $index -ge 1 && $index -le ${#ips[*]} ]]; do
		echo -n "Select one ip [1 - ${#ips[*]}]: "
		read -r index
	done

	shellex $user@${ips[$((index-1))]} "$cmd" "${sshoption[@]}"
	echo "back"
}

