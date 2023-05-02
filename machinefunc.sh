#!/bin/bash
source config.sh

RED="\\E[5;33;41m[ERROR]"
GREEN="\\E[1;32m"
RESET="\\E[0m"
success() { [ $# -ge 1 ] && echo -e $GREEN"$@" $RESET; }
error() { [ $# -ge 1 ] && echo -e $RED"$@" $RESET; }
normalp() { [ $# -ge 1 ] && echo -e $RESET"$@"; }

function listAllParts
{
    normalp "Parts in config:"
    for part in ${allparts[@]};do
        normalp $part
    done
    normalp ""
}

function installParts
{
    local PART=all
    if [[ $# -ge 1 ]];then
        PART=$1
    fi

    local installparts=""
    if [[ "$PART" == "all" ]];then
        normalp "Install all part"
        installparts=("${allparts[@]}")
    else
        normalp "Install part:" $PART
        installparts=($PART)
    fi

    local total_start_time=`date +%s`
    normalp "Begin install ... Now: `date '+%Y-%m-%d %H:%M:%S'`"

    for onepart in ${installparts[@]};do
        local controlscript=parts/${onepart}/part.sh
        if [ -f ${controlscript} ];then
            local start_time=`date +%s`
            normalp "Begin install ${onepart}, begin at: `date '+%Y-%m-%d %H:%M:%S'`"
            chmod +x ${controlscript}
            bash ${controlscript} install
            local ret=$?
            if [[ $ret -eq 0 ]];then
                local end_time=`date +%s`
                success "Installation of ${onepart} completed, end at: `date '+%Y-%m-%d %H:%M:%S'`, running time: $((${end_time}-${start_time}))"
            elif [[ $ret -ne 100 ]];then
                error "Install ${onepart} failed !!!"
            fi
        else
            error "The action control for ${onepart} could not be found, please check file ${controlscript}"
        fi
    done

    local total_end_time=`date +%s`
    normalp "End install ... Now: `date '+%Y-%m-%d %H:%M:%S'`, total running time: $((${total_end_time}-${total_start_time}))"
}

function cleanParts
{
    local PART=all
    if [[ $# -ge 1 ]];then
        PART=$1
    fi

    local cleanparts=""
    if [[ "$PART" == "all" ]];then
        normalp "Clean all part"
        cleanparts=("${allparts[@]}")
    else
        normalp "Clean part:" $PART
        cleanparts=($PART)
    fi

    local total_start_time=`date +%s`
    normalp "Begin clean ..."

    for onepart in ${cleanparts[@]};do
        local controlscript=parts/${onepart}/part.sh
        if [ -f ${controlscript} ];then
            chmod +x ${controlscript}
            bash ${controlscript} clean
            if [[ $? -ne 0 ]];then
                error "Clean ${onepart} failed !!!"
            else
                success "Clean of ${onepart} completed"
            fi
        else
            error "The action control for ${onepart} could not be found, please check file ${controlscript}"
        fi
    done

    local total_end_time=`date +%s`
    normalp "End clean ... total running time: $((${total_end_time}-${total_start_time}))"
}