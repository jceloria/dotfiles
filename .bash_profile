# ~/.bash_profile
# -------------------------------------------------------------------------------------------------------------------- #

# User specific functions
shopt -s nullglob; declare -a _i; _i=(~/.bash_functions.d/*); shopt -u nullglob
for i in ${_i[@]}; do [[ -e ${i} ]] && source ${i}; done; unset i _i

# -------------------------------------------------------------------------------------------------------------------- #

# Additional directories for user's ${PATH}
pathAppend ~/.local/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
hash manpath 2>&- && {
    unset MANPATH; export MANPATH=$(manpath):~/.local/share/man
}

# General environment variables
export HOST=${HOST:-$HOSTNAME}
export SYSTEM=$(uname -s)
export USER=$(id|sed 's/^.*uid=\([0-9]*\)(\([^)]*\).*/\2/')
export VIMEDITOR=$(type -P nvim || type -P vim)
export EDITOR=${VIMEDITOR:-vi}
export LC_COLLATE="C"
export GPG_TTY=$(tty)

# Restrictive umask
[[ ${USER} != 'root' ]] && umask 027

# Local user system specific environment
export LPREFIX=~/.local/${SYSTEM}
pathAppend "${LPREFIX}/bin"
[[ ${MANPATH} ]] && pathAppend "${LPREFIX}/man" MANPATH
[[ -e "${LPREFIX}/profile" ]] && . "${LPREFIX}/profile"
[[ -d "${HOME}/.fonts" ]] && export X_FONTPATH="${HOME}/.fonts"

# NeoVim
: ${XDG_CONFIG_HOME:=${HOME}/.config}
if [[ ${VIMEDITOR} = "$(type -P nvim)" ]] && [[ ! -e ${XDG_CONFIG_HOME}/nvim ]]; then
    mkdir -p ${XDG_CONFIG_HOME}/nvim
    ln -s ~/.vimrc ${XDG_CONFIG_HOME}/nvim/init.vim
    ln -s ${XDG_CONFIG_HOME}/nvim ~/.vim
fi

# Python specific environment
export PYTHONIOENCODING="utf-8"
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYENV_ROOT=~/.pyenv
pathPrepend ${PYENV_ROOT}/bin
hash pyenv 2>&- || { hash git 2>&- && curl https://pyenv.run | bash; }
hash pyenv 2>&- && { eval "$(pyenv init --path)" && eval "$(pyenv virtualenv-init -)"; }
if [[ ! -e ${PYENV_ROOT}/versions/default ]]; then
    PY3=($(type -a python3|awk '{print $NF}'))
    if [[ ${#PY3[@]} -gt 1 ]]; then
        PS3="Multiple python3's found: "
        while [[ ! ${i} ]]; do
            select i in ${PY3[@]}; do
                export PY3=${i}; break
            done
            [[ -z ${i} ]] && echo "Invalid selection!"
        done
    fi
    pyenv virtualenv -p ${PY3} default && pyenv global default
fi

# Golang specific envionment
export GOPATH=${LPREFIX}/go
pathAppend "${GOPATH}/bin"

# Rust specific environment
pathAppend ~/.cargo/bin

# Bitwarden configuration
export BITWARDENCLI_APPDATA_DIR=~/.config/bitwarden-cli

# -------------------------------------------------------------------------------------------------------------------- #
# Aliases
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias grep='grep --color -I'
alias less='less -r'
alias vi="${EDITOR}"
alias view="${EDITOR}"
alias quit='exit'
alias q='quit'
alias HG='history|grep $*'
alias cpan='perl -MCPAN -e shell'
alias buildlocal='./configure $* --prefix=${LPREFIX} && make'
alias curl='curl -C - -sL'
alias sortIP='sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n'
alias strip-text="sed -e $'s,\\(\x1b\\[[0-9;]*[a-zA-Z]\\|^[\x02-\x03]\\),,g'"

# -------------------------------------------------------------------------------------------------------------------- #
# OS specific
case ${SYSTEM} in
    CYGWIN_NT*|MSYS_NT*)
        pathPrepend /usr/bin    # Before win32 system path

        stty erase ^? 2>/dev/null

        alias ls='ls --color'
        alias updatedb="updatedb --prunepaths='/proc /cygdrive/[^/]*'"
    ;;
    Darwin)
        hash brew 2>&- && {
            for i in $(brew --prefix)/opt/*/libexec/gnubin; do pathPrepend $i; done
            for i in $(brew --prefix)/etc/profile.d/*.sh; do source $i; done
        }

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

# -------------------------------------------------------------------------------------------------------------------- #
# Host specific
case ${HOST} in
    *local|*internal)
        unset SSH_AGENT_PID
        if [[ -d ~/.gnupg ]] && [[ ! -e ~/.gnupg/trustdb.gpg ]]; then
            chmod 700 ~/.gnupg && gpg --import-ownertrust < ~/.gnupg/ownertrust.txt
        fi
        if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
            export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        fi
        gpg-connect-agent updatestartuptty /bye >/dev/null

        pathAppend ~/Sync/${SYSTEM}/bin
    ;;
esac

# -------------------------------------------------------------------------------------------------------------------- #
# Set our prompt (bash.d/01_prompt.sh will overwrite)
PS1="\n-(\u@\h:<\l>)->\\$ "

# Source additional files if found...
shopt -s nullglob;
for f in ~/.bash.d/{functions.d/*,*.sh}; do source ${f}; done; unset f
shopt -u nullglob

# Check window size and update LINES and COLUMNS after each command
shopt -s checkwinsize

# Save bash history
export HISTFILESIZE= HISTSIZE=
export HISTCONTROL='ignoreboth'
export HISTIGNORE='ls:bg:fg:history:HG:hh'
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=${HISTFILE:-~/.bash_history}
shopt -s direxpand

# Check for new dotfiles
[[ ${gitCheck:=1} -eq 1 ]] && gitCheck && unset gitCheck

# -------------------------------------------------------------------------------------------------------------------- #
