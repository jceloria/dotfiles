# ~/.bash.functions

#################################################### bash functions ####################################################
########################################################################################################################
# $PATH manipulation
function pathRemove() {
    local IFS=':' NEWPATH DIR PATHVARIABLE=${2:-PATH} MATCH
    [[ ${BASH_VERSINFO} -ge 4 ]] && declare -A MATCH
    for DIR in ${!PATHVARIABLE}; do
        if [[ ${BASH_VERSINFO} -ge 4 ]]; then
            [[ ${MATCH["${DIR}"]} -eq 1 ]] && continue || MATCH["${DIR}"]=1
        else
            MATCH="(^|:)${DIR}(:|$)"
            [[ ${NEWPATH} =~ ${MATCH} ]] && continue
        fi
        if [[ "${DIR}" != "$1" ]] ; then
            NEWPATH=${NEWPATH:+$NEWPATH:}${DIR}
        fi
    done
    export $PATHVARIABLE="$NEWPATH"
}

function pathPrepend() {
    pathRemove $1 $2
    local PATHVARIABLE=${2:-PATH}
    export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

function pathAppend() {
    pathRemove $1 $2
    local PATHVARIABLE=${2:-PATH}
    export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}
########################################################################################################################
# date for timestamp
function DATE() {
    date '+%Y%m%d%H%M%S'
}
########################################################################################################################
# generate random string
function genRandom() {
    local num=${1:-32}
    LC_CTYPE=C tr -dc '[:alnum:]' < /dev/urandom | fold -w ${num} | head -n1
}
########################################################################################################################
# generate random password
function genPassword() {
    local num=${1:-12}
    LC_CTYPE=C tr -dc '[:graph:]' < /dev/urandom | fold -w ${num} | head -n1
}
########################################################################################################################
# Display seconds in human readable time
function s2htime() {
  local T=$1; local D=$((T/60/60/24)); local H=$((T/60/60%24))
  local M=$((T/60%60)); local S=$((T%60)); local unit; local result
  unit=day; [[ ${D} > 1 ]] && unit=${unit}s
  [[ ${D} > 0 ]] && result+=$(printf " %d ${unit}" ${D})
  unit=hour; [[ ${H} > 1 ]] && unit=${unit}s
  [[ ${H} > 0 ]] && result+=$(printf " %d ${unit}" ${H})
  unit=minute; [[ ${M} > 1 ]] && unit=${unit}s
  [[ ${M} > 0 ]] && result+=$(printf " %d ${unit}" ${M})
  unit=second; [[ ${S} > 1 ]] && unit=${unit}s
  [[ ${D} > 0 || ${H} > 0 || ${M} > 0 ]] && [[ ${S} > 0 ]] && result+=' and'
  [[ ${S} > 0 ]] && result+=$(printf " %d ${unit}" ${S})

  [[ ${#result} -eq 0 ]] && result='none '
  echo ${result}; return 0
}
########################################################################################################################
# find 1st match for GNU commands
function GNU() {
    local cmd gnu opts ncmd
    gnu='GNU|Free Software Foundation'
    for cmd in $@; do
        for cmd in $(type -P g${cmd} ${cmd}); do
            grep -qE "${gnu}" ${cmd} && ncmd="${cmd} ${opts[*]:1}"
            [[ ! -z ${ncmd} ]] && break 2
        done
    done
    ncmd=${ncmd:-$cmd}; echo ${ncmd}
}
########################################################################################################################
# pt: Port Tester
function pt() {
    [[ -z $(type -P timeout) ]] && return 1
    local host=${1:-127.0.0.1} port x open closed
    declare -i port; port=$2 
    x=1; [[ ${port} -ne 0 ]] && x=$((x+1)) || port=22; shift ${x}

    echo -ne "Port \E[1;37m${port}\E[0m on \E[1;37m${host}\E[0m is "
    (timeout 3 bash -c "exec {FD}<>/dev/tcp/${host}/${port}") &>/dev/null; x=$?
    open='\E[1;32mopen\E[0m' closed='\E[1;31mclosed\E[0m'
    if [[ ${x} -eq 0 ]]; then
        echo -e ${open}
        [[ $# -gt 0 ]] && exec $@
    else
        echo -e ${closed}
    fi

    return ${x}
}
########################################################################################################################
# gURL: get URL
function gURL() {
    local OPTIND OPTSTRING opt url file cmd
    for cmd in curl perl; do cmd=$(type -P ${cmd}) && break; done
    case ${cmd} in
        *curl) ${cmd} -L $* ;;
        *perl)
            while getopts "O:" opt; do
                url=${OPTARG:?"URL not specified"}
                file=${url##*/}
                case "${opt}" in
                    O) ${cmd} -MLWP::Simple -e "getstore('${url}', '${file}')"    ;;
                esac
            done
            [[ -z ${url} ]] && perl -MLWP::Simple -e "getprint('$*')"
        ;;
    esac
}
########################################################################################################################
# getPM: search and download perl modules from cpan
function getPM() {
    local pm mod cpan_url="http://search.cpan.org"

    function _links() {
        perl -0ne 'print "$1\n" while(/.*href="(.*?)"><b>('$1')<\/b><\/a>/igs)'
    }

    function _dl() {
        perl -0ne 'print "$1\n" while(/Download:.*?href="(.*?)"/igs)'
    }

    for pm in $@; do
        pm=${pm//\//::} pm=${pm%.pm} mod=${pm//:/%3A}
        mod=$cpan_url$(pURL "$cpan_url/search?query=$mod&mode=all"|_links $pm)
        mod=$cpan_url$(pURL "$mod"|_dl)
        [[ "$mod" != "$cpan_url" ]] && (echo "Downloading: $mod"; pURL -O $mod)
    done

    unset _links _dl
}
########################################################################################################################
# get seconds since epoch
function getEpoch() {
    local c=$(type -P $(GNU date perl))
    case ${c} in
        *date) ${c} '+%s' 2>/dev/null ;;
        *perl) ${c} -e 'print time,"\n"' ;;
    esac

    return $?
}
########################################################################################################################
# get file ownership
function getOwner() {
    [[ $# -lt 1 ]] && return 1

    local c=$(type -P $(GNU stat perl))
    case ${c} in
        *stat) ${c} -c %U $@ 2>/dev/null ;;
        *perl) ${c} -e 'printf"%s\n",((getpwuid((stat)[4]))[0]) for @ARGV' ;;
    esac
}
########################################################################################################################
# get file access time
function getAtime() {
    [[ $# -lt 1 ]] && return 1

    local c=$(type -P $(GNU stat perl))
    case ${c} in
        *stat) ${c} -c %X $@ 2>/dev/null ;;
        *perl) ${c} -e 'printf"%s\n",(stat)[8] for @ARGV' $@ ;;
    esac
}
########################################################################################################################
# get file modification time
function getMtime() {
    [[ $# -lt 1 ]] && return 1

    local c=$(type -P $(GNU stat perl))
    case ${c} in
        *stat) ${c} -c %Y $@ 2>/dev/null ;;
        *perl) ${c} -e 'printf"%s\n",(stat)[9] for @ARGV' $@ ;;
    esac
}
########################################################################################################################
# Get process ids from string
getPID() {
    [[ $# -lt 1 ]] && return 1

    for cmd in pgrep ps; do cmd=$(type -P ${cmd}) && break; done
    case ${cmd} in
        *pgrep) ${cmd} -f "$*" 2>/dev/null                                          ;;
        *ps) ${cmd} ax -o pid,command | awk '$0~/'"$*"'/ && $2!="awk" {print $1}'   ;;
    esac
}
########################################################################################################################
# get local ip address(es)
function getIPaddr() {
    local c=$(type -P ip ifconfig)
    case ${c} in
        *ip) ip addr show $@|sed -nr 's|.*inet ([^ ]+)/.*|\1|p'         ;;
        *ifconfig) ifconfig $@|awk '$1=="inet"{print $2}'|cut -d: -f2   ;;
    esac
}
########################################################################################################################
# open a remote tunnel, connect back with dynamic socks proxy port.
function s0x() {
    ssh -At -R 2080:localhost:22 $* ssh -At -p2080 -D1080 localhost ssh -AtX $*;
}
########################################################################################################################
# cpan configuration for non-root
function cpanUserconf() {
    mkdir -p ${PERLDIR} && source ~/.bash_profile
    myconf=~/.cpan/CPAN/MyConfig.pm
    if [[ -e ${myconf} ]]; then
        echo "CPAN configuration exists"
    else
        echo "Building non-root CPAN configuration..."
        echo | perl -MCPAN -e 'mkmyconfig' >/dev/null 2>&1
        args=${MAKEPL_ARGS[@]}
        perl -pi -e 's#(.*makepl_.*\[).*(\])#\1'"$args"'\2#' ${myconf}
    fi
}
########################################################################################################################
# set/unset proxy environment variables
function setProxy() { 
    local i proxy_vars=(
        http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY
    )
    if [[ ${#PROXIES[@]} -lt 1 ]]; then
        PROXY=${PROXY:?"evironment variable not set"}
    elif [[ ${#PROXIES[@]} -gt 1 ]]; then
        PS3="Multiple proxies found: "
        while [[ ! ${i} ]]; do
            select i in ${PROXIES[@]}; do
                export PROXY=${i}; break
            done
            [[ -z ${i} ]] && echo "Invalid selection!"
        done
    else
        PROXY=${PROXIES[0]}
    fi

    case $1 in
        on)
            for i in ${proxy_vars[@]}; do export ${i}=${PROXY}; done
        ;;
        off)
            for i in ${proxy_vars[@]}; do unset ${i}; done
            [[ ${#PROXIES[@]} -ge 1 ]] && unset PROXY
        ;;
        *)
            echo "Usage: proxy [on|off]"
        ;;
    esac
}
########################################################################################################################
# use gpg to encrypt/decrypt files
function gCrypt() { 
    local tar=$(type -P $(GNU tar))
    hash gpg 2>&- || { echo "gpg executable not found"; return 1; }

    local OPTIND OPTSTRING OUT
    [[ $# -le 1 ]] && echo "Usage: gCrypt [-d|-e] <file(s)|directory>" >&2
    [[ $# -eq 2 ]] && OUT="${2%/}.tgz.gpg" || OUT='-'

    gpg="gpg --batch --use-agent -q"
    while getopts "d:e:" opt; do
        case ${opt} in
            d)  shift; ${gpg} -o - ${1%/} | ${tar} xzf - && /bin/rm -f ${1} ;;
            e)  shift; ${tar} czf - ${@} 2>/dev/null | ${gpg} -ea -o ${OUT} ;;
            :)  echo "-${OPTARG} requires an argument." >&2                 ;;
        esac
    done

    [[ -e "${OUT}" ]] && /bin/rm -rf ${OUT%.tgz.gpg}
}
########################################################################################################################
# pull any new changes from git repository (default hour last accessed)
function gitCheck() {
    [[ -z $(type -P git) ]] && return 1
    (cd ~/ && git symbolic-ref HEAD >/dev/null 2>&1) || return 1

    local i _git=0 sec=${1:-3600} lock="${HOME}/.gitCheck.lock"
    for i in ~/.bash.d/01_prompt.sh; do
        [[ ! -e ${i} ]] && continue
        [[ $(($(getEpoch)-$(getAtime ${i}))) -gt ${sec} ]] && _git=1
    done
    if [[ "${_git}" -eq 1 ]]; then
        if [[ ! -e "${lock}" ]]; then
            echo "Checking for newer dotfiles..."
            touch "${lock}"
        fi
        (   cd ~/ && \
            git pull && \
            git submodule update --init --recursive && \
            touch ${i}
        ) && exec bash -l
    else
        rm -f "${lock}"
    fi
}
########################################################################################################################
# commit and push any new changes to git repository
function gitPush() {
    [[ -z $(type -P git) ]] && return 1
    local var x msg commit

    var=$(git status -uno --porcelain 2>/dev/null; echo -n x); var="${var%x}"

    if [[ ${#var} > 0 ]]; then
        git diff && printf "%80s\n"|tr " " "#" 
        echo -e "Uncomitted changes found in local git repository:"
        echo -n "${var}"

        read -p "Commit all changes? [y/N]: " x
        case ${x} in y*|Y*) commit=1 ;; *) commit=0 ;; esac

        if [[ ${commit} -eq 1 ]]; then
            while [[ -z "${msg}" ]]; do
                read -p "Enter a message for your changes: " msg
                if [[ ! -z "${msg}" ]]; then
                    read -p "Continue? [Y/n]: " x
                    case ${x} in N*|n*) unset msg ;; esac
                fi
            done

            git commit -a -m "${msg}" && git push
        fi
    fi
}
########################################################################################################################
# Update remote upstream fork
function gitUpFork() {
    [[ -z $(type -P git) ]] && return 1
    local x remote upsrepo branch

    git remote -v; echo
    read -p "Add new remote upstream repo? [y/N]: " x
    case ${x} in y*|Y*) remote=1 ;; *) remote=0 ;; esac

    branch=$(git rev-parse --abbrev-ref HEAD)

    if [[ ${remote} -eq 1 ]]; then
        while [[ -z ${upsrepo} ]]; do
            read -p "Enter the upstream repository: " upsrepo
            git remote add upstream ${upsrepo} || {
                echo "Something wen't wrong adding: ${upsrepo}"; unset upsrepo
            }
        done
    fi

    git fetch upstream && git checkout ${branch} && git merge upstream/${branch}
}
########################################################################################################################
# array element test
function inArray() {
  local e
  for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done; return 1;
}
########################################################################################################################
# Logging function
function log() {
    local level levels=(notice warning crit)
    level="+($(IFS='|';echo "${levels[*]}"))"

    shopt -s extglob; case ${1} in
        ${level}) level=${1}; shift ;;
        *) level=notice ;;
    esac; shopt -u extglob

    [[ -z ${RETVAL} ]] && { for RETVAL in "${!levels[@]}"; do
        [[ ${levels[${RETVAL}]} = "${level}" ]] && break
    done }

    logger -s -p ${level} -t "[${SELF}:${FUNCNAME[1]}()]" -- $@;
}
########################################################################################################################
# tar copy a directory perserving permissions and structure
function tcopy() {
    local src=$1; local dest=${2:?"source and destination are required"}

    [[ ! -e ${dest} ]] && mkdir -p ${dest}
    [[ ${USER} == 'root' ]] && local opts="xpvf" || opts="xvf"

    (cd ${src} && tar cf - .) | (cd ${dest} && tar ${opts} -)
}
########################################################################################################################
function pad() {
    local length string end x
    length=$1; shift; string="# $*"; end=" #"; [[ $# -gt 0 ]] && string+=" "
    echo -en "${string}"; for ((x=1;x<=(${length}-${#string}-${#end});x++)) { echo -n "-"; }; echo "${end}"
}
########################################################################################################################
# dos2unix
function dos2unix() {
    [[ $# -lt 1 ]] && return 1

    local c=$(type -P $(GNU dos2unix sed perl)) file
    case ${c} in
        *dos2unix)  c="${c}"                  ;;
        *sed)       c="${c} -i s/\r// $i"     ;;
        *perl)      c="${c} -pi -e s/[\r]//g" ;;
    esac

    for file in $@; do [[ -f ${file} ]] && ${c} ${file}; done
    return 0
}
########################################################################################################################
# unix2dos
function unix2dos() {
    [[ $# -lt 1 ]] && return 1

    local c=$(type -P $(GNU unix2dos sed perl)) file
    case ${c} in
        *unix2dos)  c="${c}"                          ;;
        *sed)       c="${c} -i s/$/\r/"               ;;
        *perl)      c="${c} -pi -e s/[\r]*\n/\r\n/g"  ;;
    esac

    for file in $@; do [[ -f ${file} ]] && ${c} ${file}; done
    return 0
}
########################################################################################################################
# vultr.com API
function vultrAPI() {
    [[ -z $(type -P pass) ]] && return 1
    local api=$(pass Development/vultr.com | awk '$1=="api:"{print $2}')
    local uri="https://api.vultr.com/v1/server"

    case $@ in
        list)
            curl -s -H "API-Key: ${api}" ${uri}/list | jq '.[]'
            ;;
        SUBID)
            curl -s -H "API-Key: ${api}" ${uri}/list | jq '.[].SUBID'
            ;;
        internal_ip)
            curl -s -H "API-Key: ${api}" ${uri}/list | jq '.[].internal_ip'
            ;;
        *)
            curl -s -H "API-Key: ${api}" ${uri}/$@ | jq '.'
            ;;
    esac
}
########################################################################################################################
# ssh wrapper to continuously retry if unavailable
function ssh-retry() {
    local next prev host port
    for ((i=1;i<=$#;++i)); do
        next=$((i+1)); [[ $((i-1)) -eq 0 ]] || prev=$((i-1))
        case "${!i}" in
            -p*) [[ "${!i}" =~ -p$ ]] && port=${!next} || port=${!i//-p} ;;
            *@*) host=${!i##*@} ;;
            -*) true ;;
            *) [[ ! "${host}" ]] && [[ ! "${!prev}" =~ ^- ]] && host=${!i} ;;
        esac
    done

    echo "Waiting for ssh port '${port:=22}' on '${host}' to become available:"
    ( bash -c "exec {FD}<>/dev/tcp/${host}/${port}" ) &> /dev/null
    while [[ $? -ne 0 ]]; do
        sleep 2; ( bash -c "exec {FD}<>/dev/tcp/${host}/${port}" ) &> /dev/null
    done

    $(type -P ssh) "$@"
}
########################################################################################################################
# simple web server
function webz() {
    hash python3 2>&- && (python3 -m http.server $@ || python -m SimpleHTTPServer $@) 2>/dev/null
}
########################################################################################################################
