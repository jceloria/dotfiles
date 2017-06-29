rm -rf ~/.mozilla/*/*/{Cache/*,history.dat,localstore.rdf} ~/.java/*/cache/*

# remove unused ssh-agents
for i in /tmp/ssh-*; do
    [[ ! -e $i ]] && break
    [[ ${USER}x == $(getOwner $i)x ]] && [[ $i != ${SSH_AUTH_SOCK%/*} ]] && \
        /bin/rm -rf $i 2>/dev/null
done; unset i

# commit any forgotten changes in git repo
(cd ~/ && gitPush)

# Unmount encrypted volume(s)
logins=$(last|awk '$1~/'"$USER"'/ && $0~/still logged in/'|wc -l)
[[ ${logins} -le 1 ]] && [[ $(type -P fusermount) ]] && {
    for i in $(mount|awk '$1~/encfs/{print $3}'); do
        fusermount -u $i 2>&-
    done
}

# additional commands to run
[[ -e ~/.bash.d/bashd_logout ]] && source ~/.bash.d/bashd_logout

[[ $(type -P clear) ]] && clear
