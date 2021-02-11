# commit any forgotten changes in git repo
(cd ~/ && gitPush)

# additional commands to run
[[ -e ~/.bash.d/bashd_logout ]] && source ~/.bash.d/bashd_logout

[[ $(type -P clear) ]] && clear
