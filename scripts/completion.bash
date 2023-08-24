#!/usr/bin/env bash

# Do not ask about implementation. It was hard and pain but works. Make it better, please
# https://devmanual.gentoo.org/tasks-reference/completion/index.html
# Help format description:
# - any possible sudgestion must begins with 2 spaces and ends with <tab>-<space>
# - [WORD] with [] brackets is optional 
# - <Variables> are defined using by <> and should be at the end of the list. There are built-in vars
# - <PATH> - autocompletes by relateve path from curent dir
# - <DOCKER_IMAGE> - autocompletes by builder docker image
# - <CMD> - autocompletes by commands list. NOT implemented
# - Variales in variables in variables are not supported. Only first word in variable description is used

#DBG 
#set -x
#COMP_WORDS=(sq-cmake-build dbg)

complete -F _sq_get_next sq-cmake-build
complete -F _sq_get_next sq-yocto-build
complete -F _sq_get_next sq-aosp-build

get_help()
{
    SQ_CMD=${COMP_WORDS[0]}
    #    set +x
    HELP_OUT=($(${SQ_CMD} --help | gawk 'match($0, /^\s\s(.+)\t-\s.*/, a) {printf "%s@",a[1]}' | tr ' ' '#' | tr '@' ' '))
    for i in ${!HELP_OUT[@]};
    do
        HELP_OUT[$i]=${HELP_OUT[$i]//\#/ }
    done
    #    set -x
}

get_var()
{
    #    set +x
    VAR=()
    local NAME=$1
    local FOUND=false
    VAR=()
    local i
    for i in ${!HELP_OUT[@]};
    do
        local LINE=${HELP_OUT[$i]}
        #Ignore except first word
        LINE=($LINE)
        LINE=${LINE[0]}
        if [[ $LINE =~ ^\<([^\>]+)\> ]]; then #found line with var
            if [ "${BASH_REMATCH[1]}" == "$NAME" ]; then #found line with requested var
                FOUND=true
            elif $FOUND; then #found line with next line
                break
            fi
        else
            $FOUND && VAR+=($LINE)
        fi
    done
    $FOUND || VAR=()
    #    set -x
    DBG="get_var $FOUND (${VAR[@]})"
    return
}

_sq_get_next()
{
    get_help
    local CUR_LINE=""
    local i
    local j
    local RESULT=()

    for j in ${!HELP_OUT[@]};
    do
        CUR_LINE=${HELP_OUT[$j]}
        [[ $CUR_LINE =~ ^\<([^\>]+)\> ]] && break
        DGB="CURLINE= $CUR_LINE"

        local arr
        local FOUND=false
        DBG="This loop shows where we are in completition ${COMP_WORDS[@]} of $COMP_CWORD"
        for WORD in ${COMP_WORDS[@]:1:$COMP_CWORD-1};
        do
            FOUND=false
            arr=($CUR_LINE)
            for i in ${!arr[@]};
            do
                if [[ ${arr[$i]} =~ \[?([^\]]+)\]? ]]; then
                    local OPTIONAL
                    [ "${BASH_REMATCH[0]}" != "${BASH_REMATCH[1]}" ] && OPTIONAL=true || OPTIONAL=false
                    [[ ${BASH_REMATCH[1]} =~ $WORD ]] && FOUND=true && break
                    if [[ ${arr[$i]} =~ \<([^\>]+)\> ]]; then
                        get_var ${BASH_REMATCH[1]}
                        if [[ " ${VAR[*]} " =~ " $WORD " ]]; then
                            FOUND=true
                        fi
                    fi
                    if [[ $FOUND == true || $OPTIONAL == false ]]; then
                        break
                    fi
                fi
            done
            $FOUND && CUR_LINE=${arr[@]:$i+1:${#arr[@]}} || break
        done

        if [[ -z ${COMP_WORDS[1]} || ${COMP_CWORD} == 1 || $FOUND == true ]]; then
            arr=($CUR_LINE)
            DBG="Look for sudgestions in  $CUR_LINE"
            for i in ${!arr[@]};
            do
                if [[ ${arr[$i]} =~ \[?([^\]]+)\]? ]]; then
                    local CUR=${BASH_REMATCH[1]}
                    local OPTIONAL
                    [ "${BASH_REMATCH[0]}" != "${BASH_REMATCH[1]}" ] && OPTIONAL=true || OPTIONAL=false
                    if [[ ${arr[$i]} =~ \<([^\>]+)\> ]]; then
                        case ${BASH_REMATCH[1]} in
                            PATH)
                                compopt -o filenames 2>/dev/null
                                COMPREPLY=( $(compgen -f -- "${COMP_WORDS[COMP_CWORD]}") )
                                return
                                ;;
                            CMD)
                                COMPREPLY=( $(compgen -c -- "${COMP_WORDS[COMP_CWORD]}") )
                                return
                                ;;
                            DOCKER_IMAGE)
                                COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
                                VAR=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep builder)
                                COMPREPLY=($(compgen -W "${VAR[@]}" -- "${COMP_WORDS[COMP_CWORD]}"))
                                return
                                ;;
                            *)
                                get_var ${BASH_REMATCH[1]}
                                ;;
                        esac
                        RESULT+=(${VAR[@]})
                    else
                        RESULT+=(${CUR/|/ })
                    fi
                    [ $OPTIONAL == false ] && break
                fi
            done
        fi
    done
    RES=${RESULT[@]}

    COMPREPLY=($(compgen -o nosort -W "$RES" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _sq_get_next sq-cmake-build
complete -F _sq_get_next sq-aosp-build
complete -F _sq_get_next sq-yocto-build
