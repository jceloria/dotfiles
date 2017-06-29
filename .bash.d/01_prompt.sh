################################################## set a bash prompt ################################################### 
########################################################################################################################
function gitBranch() {
    type -P git >/dev/null 2>&1 || return 1
    local repo=$(git config --get remote.origin.url 2>/dev/null)
    local branch=$(git symbolic-ref HEAD 2>/dev/null)
    echo ${branch##*refs/heads/}
}
########################################################################################################################
function gitStatus() {
    type -P git >/dev/null 2>&1 || return 1

    local branch=$(gitBranch) colors status binfo
    [[ -z ${branch} ]] && return 1

    # Clean = white, Uncommited Pending = yellow, Unpushed Pending = red
    colors=('1;37m') binfo="\e[${colors[0]}${branch}\e[m"

    # Uncommited changes
    git diff --quiet 2>/dev/null || colors=('1;33m') binfo="\e[${colors[0]}${branch}\e[m"

    # Unpushed changes
    local status=$(git branch --list -v ${branch} 2>/dev/null | grep -o '\[.*\]')
    [[ -z ${status} ]] || colors+=('1;31m') binfo+=":\e[${colors[1]}${status}\e[m"

    printf "${binfo}"
}
########################################################################################################################
function bash_prompt_cmd() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=25

    # Indicate that there has been dir truncation
    local trunc_symbol=".."
    local dir=${PWD##*/}

    pwdmaxlen=$(((pwdmaxlen < ${#dir}) ? ${#dir} : pwdmaxlen))

    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

    if [ ${pwdoffset} -gt "0" ]; then
        NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi

    local pinfo unique
    [[ ${BASH_VERSINFO} -ge 4 ]] && declare -A unique
    PC+=(gitStatus); for pinfo in ${PC[@]}; do
        if [[ ${BASH_VERSINFO} -ge 4 ]]; then
            [[ ${unique[${pinfo}]} -eq 1 ]] && continue || unique[${pinfo}]=1
        fi
        hash ${pinfo} 2>&- && pinfo=$(${pinfo})
        [[ ! -z ${pinfo} ]] && { PI=${pinfo}; break; } || continue
    done; PC=("${!unique[@]}")

    [[ ! -e ~/.bash.d ]] && mkdir -p ~/.bash.d
    touch -a ~/.bash.d/01_prompt.sh # I touch myself to update atime (gitCheck)

    # Save bash history
    builtin history -a
    builtin history -n
}
########################################################################################################################
function bash_prompt() {
    local user
    case ${TERM} in
     xterm*|rxvt*)
         local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
          ;;
     *)
         local TITLEBAR=""
          ;;
    esac

    # Reset the color back to default
    local NC='\[\e[0m\]'

    # generate a random color scheme for our prompt
    if [[ ! -e ~/.bash.d/00_colors.sh ]]; then
        echo "UCOLORS=($(($RANDOM%231)) $(($RANDOM%231)))" > \
            ~/.bash.d/00_colors.sh && source ~/.bash.d/00_colors.sh
    fi

    # 1st is regular, second is bold
    [[ ${#UCOLORS[@]} -eq 2 ]] && user=(${UCOLORS[@]}) || user=(76 46)
    if [[ ${UID} == 0 ]]; then
        [[ ${#RCOLORS[@]} -eq 2 ]] && user=(${RCOLORS[@]}) || user=(1 9)
    fi

    # Prompt colors (Regular, Bold, Underlined, Directory)
    local REG="${NC}\[\e[38;5;${user[0]}m\]"
    local BLD="${NC}\[\e[38;5;${user[1]}m\]"
    local UND="\[\e[4m\]"
    local DIR="\[\e[38;5;75m\]"

    # Assign prompt sections
    local USER_AT_HOST="${BLD}${UND}\u${REG}@${BLD}${UND}\${HN:-\h}${REG}"
    local INFO="${NC}\${PI:-\l}${REG}"
    local TIME="${NC}\D{%T}${REG}"
    local DIRECTORY="${DIR}\${NEW_PWD}${REG}"

    # Extra backslash in front of \$ to make bash colorize the prompt
    PS1="\n${REG}┌❨${USER_AT_HOST}:❬${INFO}❭❩─❨${TIME}❩┐\n"
    PS1="${PS1}└❨${DIRECTORY}❩\\$""─►${NC} "
}
########################################################################################################################

# Set the prompt!
PROMPT_COMMAND="bash_prompt_cmd"
bash_prompt
unset bash_prompt

########################################################################################################################
