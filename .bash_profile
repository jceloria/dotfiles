# ~/.bash_profile
########################################################################################################################

# User specific functions
[[ -e ~/.bash_functions ]] && source ~/.bash_functions && gitCheck=1

########################################################################################################################

# Additional directories for user's ${PATH}
pathAppend ~/local/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
hash manpath 2>&- && {
    unset MANPATH; export MANPATH=$(manpath):~/local/share/man
}

# General environment variables
export HOST=${HOST:-$HOSTNAME}
export SYSTEM=$(uname -s)
export USER=$(id|sed 's/^.*uid=\([0-9]*\)(\([^)]*\).*/\2/')
export VIMEDITOR=$(type -P vim)
export EDITOR=${VIMEDITOR:-vi}
export LC_COLLATE="C"
export GPG_TTY=$(tty)

# Restrictive umask
[[ ${USER} != 'root' ]] && umask 027

# Local user system specific environment
export LPREFIX=~/local/${SYSTEM}
pathAppend "${LPREFIX}/bin"

[[ ${MANPATH} ]] && pathAppend "${LPREFIX}/man" MANPATH

[[ -e "${LPREFIX}/profile" ]] && \
    . "${LPREFIX}/profile"

[[ -d "${HOME}/.fonts" ]] && \
    export X_FONTPATH="${HOME}/.fonts"

# PERL specific envionment
export PERLDIR="${LPREFIX}/lib/perl5"
MAKEPL_ARGS=(PREFIX="${LPREFIX}" LIB="${PERLDIR}"
    INSTALLMAN1DIR="${LPREFIX}/man/man1"
    INSTALLMAN3DIR="${LPREFIX}/man/man1"
)
pathPrepend "${PERLDIR}" PERL5LIB
pathAppend "${PERLDIR}/bin"

# Python specific environment
export PYTHONIOENCODING="utf-8"
export VIRTUAL_ENV="${LPREFIX}"
export VIRTUAL_ENV_DISABLE_PROMPT=1
[[ -e ${VIRTUAL_ENV}/bin/activate ]] && source ${VIRTUAL_ENV}/bin/activate

# golang specific envionment
export GOPATH=${LPREFIX}/go
pathAppend "${GOPATH}/bin"

########################################################################################################################

# Aliases
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias grep='grep --color -I'
alias vi="${EDITOR}"
alias view="${EDITOR}"
alias quit='exit'
alias q='quit'
alias HG='history|grep $*'
alias cpan='perl -MCPAN -e shell'
alias buildlocal='./configure $* --prefix=${LPREFIX} && make'
alias curl='curl -C - -sL'
alias sortIP='sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n'
alias webz='python -m SimpleHTTPServer $@'
alias svim='sudo vim -u ~/.vimrc $@'
alias virtualenv3='virtualenv -p python3'

########################################################################################################################

# OS specific
case ${SYSTEM} in
    CYGWIN_NT*|MSYS_NT*)
        pathPrepend /usr/bin    # Before win32 system path

        stty erase ^? 2>/dev/null

        alias ls='ls --color'
        alias updatedb="updatedb --prunepaths='/proc /cygdrive/[^/]*'"
    ;;
    Darwin)
        x=$(networksetup -listallhardwareports|awk '/Wi-Fi/{getline; print $2}')
        SSID=$(networksetup -getairportnetwork ${x}|awk '{print $NF}'); unset x
        pathPrepend /usr/local/opt/coreutils/libexec/gnubin
        hash brew 2>&- && source $(brew --prefix)/etc/bash_completion
        hash rbenv 2>&- && eval "$(rbenv init -)"

        alias ls='ls --color'
    ;;
    HP-UX)
        stty erase ^H intr ^C kill ^U susp ^Z start ^Q stop ^S swtch ^@ 2>&-
    ;;
    Linux)
        alias ln='ln -i'
        alias ls='ls --color'
    ;;
    SunOS)
        pathAppend /usr/ccs/bin:/opt/csw/bin:/usr/X/bin:/usr/bin/X11:/usr/X/bin

        export TERM=xterm
        export PAGER=less
        stty erase ^?

        alias prtdiag="/usr/platform/$(uname -i)/sbin/prtdiag"
    ;;
esac

########################################################################################################################

# Host specific
case ${HOST} in
    *local|*internal)
        chmod 600 ~/.ssh/id_rsa 2>/dev/null
        if [[ -d ~/.keychain ]]; then
            getPID 'keychain.*ssh,gpg' >/dev/null 2>&- && read -p 'Waiting for keychain, [Enter]: '
            while $(getPID 'keychain.*ssh,gpg' >/dev/null 2>&-); do sleep 1; done
            eval $(keychain -Q -q --eval --inherit any --agents ssh,gpg id_rsa 6B10F38A)
        fi

        if [[ -d ~/Sync/.crypt ]]; then
            pgrep -f encfs >/dev/null 2>&1 || mount | grep -q .EncFS || \
                pass Security/EncFS | \
                    encfs -S $(echo ~/Sync/.crypt) $(echo ~/.EncFS)
        fi

        pathAppend ~/Sync/${SYSTEM}/bin
    ;;
esac

########################################################################################################################

# Set our prompt (bash.d/01_prompt.sh will overwrite)
PS1="\n-(\u@\h:<\l>)->\\$ "

# Source custom bash completion if found...
[[ -e ~/.bash_completion ]] && source ~/.bash_completion

# Source any additional files if found...
shopt -s nullglob; declare -a _i; _i=(~/.bash.d/*.sh); shopt -u nullglob
for i in ${_i[@]}; do [[ -e ${i} ]] && source ${i}; done; unset i _i

# Add local bash-completion
[[ -e ~/.bash_completion ]] && source ~/.bash_completion

# Check window size and update LINES and COLUMNS after each command
shopt -s checkwinsize

# Save bash history
export HISTFILESIZE= HISTSIZE=
export HISTCONTROL='ignoreboth:erasedups'
export HISTIGNORE='ls:bg:fg:history:HG:hh'
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=${HISTFILE:-~/.bash_history}
shopt -s histappend direxpand

# Check for new dotfiles
[[ ${gitCheck} -eq 1 ]] && gitCheck && unset gitCheck

########################################################################################################################
